
GO

IF OBJECT_ID('[DOI].[spForeignKeysDrop]') IS NOT NULL
	DROP PROCEDURE [DOI].[spForeignKeysDrop];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spForeignKeysDrop]
    @DatabaseName           SYSNAME = NULL,
	@ReferencedSchemaName	SYSNAME = NULL,
	@ReferencedTableName	SYSNAME = NULL,
	@ParentSchemaName		SYSNAME = NULL,
	@ParentTableName		SYSNAME = NULL,
	@Debug BIT = 0
AS

/*
	EXEC DOI.spForeignKeysDrop
        @DatabaseName = 'PaymentReporting',
		@ReferencedSchemaName	= 'dbo',
		@ReferencedTableName	= 'Pays',
		@Debug = 1

	EXEC DOI.spForeignKeysDrop
		@ForMetadataTablesOnly = 0,
        @Debug = 1

	EXEC DOI.spForeignKeysDrop
        @DatabaseName = 'PaymentReporting',
		@ParentSchemaName		= 'dbo',
		@ParentTableName		= 'Pays',
		@Debug = 1
*/
BEGIN TRY 
	DECLARE @UseDbSQL NVARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10),
			@SQL NVARCHAR(MAX) = ''
			--CHANGE SQL BELOW TO USE DROP STATEMENT FROM TABLE.
	SELECT @SQL += '
IF EXISTS(  SELECT ''True''
            FROM ' + @DatabaseName + '.sys.foreign_keys fk 
            WHERE fk.name = ''' + FK.name + ''')
BEGIN    
    ALTER TABLE ' + ps.name + '.[' + pt.name + '] DROP CONSTRAINT ' + FK.NAME + '
END'
    --SELECT fk.*
	FROM DOI.SysForeignKeys fk WITH(SNAPSHOT)
        INNER JOIN DOI.SysDatabases D WITH(SNAPSHOT) ON D.database_id = fk.database_id
		INNER JOIN DOI.SysTables pt WITH(SNAPSHOT) ON pt.database_id = fk.database_id
            AND pt.object_id = fk.parent_object_id
		INNER JOIN DOI.SysSchemas ps WITH(SNAPSHOT) ON ps.database_id = pt.database_id
            AND pt.schema_id = ps.schema_id
		INNER JOIN DOI.SysTables rt WITH(SNAPSHOT) ON rt.database_id = fk.database_id
            AND rt.object_id = fk.referenced_object_id
		INNER JOIN DOI.SysSchemas rs WITH(SNAPSHOT) ON rs.database_id = rt.database_id
            AND rt.schema_id = rs.schema_id
	WHERE D.NAME = @DatabaseName
        AND rs.name = CASE WHEN @ReferencedSchemaName IS NOT NULL THEN @ReferencedSchemaName ELSE rs.name END
		AND rt.name = CASE WHEN @ReferencedTableName IS NOT NULL THEN @ReferencedTableName ELSE rt.name END
		AND ps.name = CASE WHEN @ParentSchemaName IS NOT NULL THEN @ParentSchemaName ELSE ps.name END 
		AND pt.name = CASE WHEN @ParentTableName IS NOT NULL THEN @ParentTableName ELSE pt.name END

	IF @SQL = ''
	BEGIN
		SET @UseDbSQL = ''
	END
	ELSE
    BEGIN
		SET @SQL = @UseDbSQL + @SQL
	END


	IF @Debug = 1
	BEGIN
		EXEC DOI.spPrintOutLongSQL 
			@SQLInput = @SQL ,
			@VariableName = N'@SQL'
	
	END
	ELSE
	BEGIN
		EXEC(@SQL)
	END
END TRY

BEGIN CATCH
	THROW;
END CATCH 
GO
