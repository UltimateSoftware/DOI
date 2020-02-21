IF OBJECT_ID('[DDI].[spForeignKeysDrop]') IS NOT NULL
	DROP PROCEDURE [DDI].[spForeignKeysDrop];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spForeignKeysDrop]
    @DatabaseName           SYSNAME,
	@ReferencedSchemaName	SYSNAME = NULL,
	@ReferencedTableName	SYSNAME = NULL,
	@ParentSchemaName		SYSNAME = NULL,
	@ParentTableName		SYSNAME = NULL,
	@Debug BIT = 0
AS

/*
	EXEC DDI.spForeignKeysDrop
        @DatabaseName = 'PaymentReporting',
		@ReferencedSchemaName	= 'dbo',
		@ReferencedTableName	= 'Pays',
		@Debug = 1

	EXEC DDI.spForeignKeysDrop
		@ForMetadataTablesOnly = 0,
        @Debug = 1

	EXEC DDI.spForeignKeysDrop
        @DatabaseName = 'PaymentReporting',
		@ParentSchemaName		= 'dbo',
		@ParentTableName		= 'Pays',
		@Debug = 1
*/
BEGIN TRY 
	DECLARE @SQL NVARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10)

	SELECT @SQL += '
IF EXISTS(  SELECT ''True''
            FROM sys.foreign_keys fk 
            WHERE fk.name = ''' + FK.name + ''')
BEGIN    
    ALTER TABLE ' + ps.name + '.[' + pt.name + '] DROP CONSTRAINT ' + FK.NAME + '
END'
    --SELECT fk.*
	FROM DDI.SysForeignKeys fk
        INNER JOIN DDI.SysDatabases D ON D.database_id = fk.database_id
		INNER JOIN DDI.SysTables pt ON pt.database_id = fk.database_id
            AND pt.object_id = fk.parent_object_id
		INNER JOIN DDI.SysSchemas ps ON ps.database_id = pt.database_id
            AND pt.schema_id = ps.schema_id
		INNER JOIN DDI.SysTables rt ON rt.database_id = fk.database_id
            AND rt.object_id = fk.referenced_object_id
		INNER JOIN DDI.SysSchemas rs ON rs.database_id = rt.database_id
            AND rt.schema_id = rs.schema_id
	WHERE D.NAME = @DatabaseName
        AND rs.name = CASE WHEN @ReferencedSchemaName IS NOT NULL THEN @ReferencedSchemaName ELSE rs.name END
		AND rt.name = CASE WHEN @ReferencedTableName IS NOT NULL THEN @ReferencedTableName ELSE rt.name END
		AND ps.name = CASE WHEN @ParentSchemaName IS NOT NULL THEN @ParentSchemaName ELSE ps.name END 
		AND pt.name = CASE WHEN @ParentTableName IS NOT NULL THEN @ParentTableName ELSE pt.name END

	IF @Debug = 1
	BEGIN
		EXEC DDI.spPrintOutLongSQL 
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
