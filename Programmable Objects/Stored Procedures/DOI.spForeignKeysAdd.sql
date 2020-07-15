USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spForeignKeysAdd]') IS NOT NULL
	DROP PROCEDURE [DOI].[spForeignKeysAdd];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spForeignKeysAdd]
    @DatabaseName           SYSNAME,
	@ReferencedSchemaName	SYSNAME = NULL,
	@ReferencedTableName	SYSNAME = NULL,
	@ParentSchemaName		SYSNAME = NULL,
	@ParentTableName		SYSNAME = NULL,
    @UseExistenceCheck      BIT = 0,
    @CallingProcess         VARCHAR(20) = 'Deployment',
	@Debug BIT = 0
AS

/*
	EXEC DOI.spForeignKeysAdd
        @DatabaseName = 'PaymentReporting',
		@ReferencedSchemaName = 'dbo',
		@ReferencedTableName = 'PayGarnishments',
		@Debug = 1

	EXEC DOI.spForeignKeysAdd
		@ReferencedSchemaName = NULL,
		@ReferencedTableName = NULL,
		@Debug = 1

	EXEC DOI.spForeignKeysAdd
		@ParentSchemaName = 'dbo',
		@ParentTableName = 'Pays',
		@Debug = 1

	EXEC DOI.spForeignKeysAdd
		@ForMetadataTablesOnly = 1,
		@Debug = 1

*/
BEGIN TRY 
    IF @CallingProcess NOT IN ('Deployment', 'Job')
    BEGIN
        RAISERROR('Invalid value for @CallingProcess.', 16, 1)
    END
    
	EXEC DOI.spForeignKeysDrop
        @DatabaseName = @DatabaseName,
		@ReferencedSchemaName = @ReferencedSchemaName,
		@ReferencedTableName = @ReferencedTableName

	DECLARE @AddFKsSQL VARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10)

	SELECT @AddFKsSQL += CASE WHEN @UseExistenceCheck = 1 THEN CreateFKWithExistenceCheckSQL ELSE CreateFKSQL END + CHAR(13) + CHAR(10)
	--select *
	FROM DOI.vwForeignKeys
	WHERE DatabaseName = @DatabaseName
        AND ParentSchemaName <> 'DOI'
        AND ReferencedSchemaName <> 'DOI'
        AND ReferencedSchemaName = CASE WHEN @ReferencedSchemaName IS NOT NULL THEN @ReferencedSchemaName ELSE ReferencedSchemaName END
		AND ReferencedTableName = CASE WHEN @ReferencedTableName IS NOT NULL THEN @ReferencedTableName ELSE ReferencedTableName END
		AND ParentSchemaName = CASE WHEN @ParentSchemaName IS NOT NULL THEN @ParentSchemaName ELSE ParentSchemaName END
		AND ParentTableName = CASE WHEN @ParentTableName IS NOT NULL THEN @ParentTableName ELSE ParentTableName END
        AND DeploymentTime = @CallingProcess
	ORDER BY ReferencedTableName

    SELECT @AddFKsSQL += '
    EXEC DOI.Utility.spEnableDisableAllFKs 
		@DatabaseName = ''' + @DatabaseName + ''',
		@Action = ''DISABLE'''

    IF @Debug = 1
    BEGIN
	   EXEC DOI.spPrintOutLongSQL 
		  @SQLInput = @AddFKsSQL ,
		  @VariableName = N'@AddFKsSQL'
    END
    ELSE
    BEGIN
	   EXEC(@AddFKsSQL)
    END
END TRY

BEGIN CATCH
	THROW;
END CATCH 
GO
