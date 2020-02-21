IF OBJECT_ID('[DDI].[spForeignKeysAdd]') IS NOT NULL
	DROP PROCEDURE [DDI].[spForeignKeysAdd];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spForeignKeysAdd]
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
	EXEC DDI.spForeignKeysAdd
        @DatabaseName = 'PaymentReporting',
		@ReferencedSchemaName = 'dbo',
		@ReferencedTableName = 'PayGarnishments',
		@Debug = 1

	EXEC DDI.spForeignKeysAdd
		@ReferencedSchemaName = NULL,
		@ReferencedTableName = NULL,
		@Debug = 1

	EXEC DDI.spForeignKeysAdd
		@ParentSchemaName = 'dbo',
		@ParentTableName = 'Pays',
		@Debug = 1

	EXEC DDI.spForeignKeysAdd
		@ForMetadataTablesOnly = 1,
		@Debug = 1

*/
BEGIN TRY 
    IF @CallingProcess NOT IN ('Deployment', 'Job')
    BEGIN
        RAISERROR('Invalid value for @CallingProcess.', 16, 1)
    END
    
	EXEC DDI.spForeignKeysDrop
        @DatabaseName = @DatabaseName,
		@ReferencedSchemaName = @ReferencedSchemaName,
		@ReferencedTableName = @ReferencedTableName

	DECLARE @AddFKsSQL VARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10)

	SELECT @AddFKsSQL += CASE WHEN @UseExistenceCheck = 1 THEN CreateFKWithExistenceCheckSQL ELSE CreateFKSQL END + CHAR(13) + CHAR(10)
	--select *
	FROM DDI.vwForeignKeys
	WHERE DatabaseName = @DatabaseName
        AND ParentSchemaName <> 'DDI'
        AND ReferencedSchemaName <> 'DDI'
        AND ReferencedSchemaName = CASE WHEN @ReferencedSchemaName IS NOT NULL THEN @ReferencedSchemaName ELSE ReferencedSchemaName END
		AND ReferencedTableName = CASE WHEN @ReferencedTableName IS NOT NULL THEN @ReferencedTableName ELSE ReferencedTableName END
		AND ParentSchemaName = CASE WHEN @ParentSchemaName IS NOT NULL THEN @ParentSchemaName ELSE ParentSchemaName END
		AND ParentTableName = CASE WHEN @ParentTableName IS NOT NULL THEN @ParentTableName ELSE ParentTableName END
        AND DeploymentTime = @CallingProcess
	ORDER BY ReferencedTableName

    SELECT @AddFKsSQL += '
    EXEC dbo.spEnableDisableAllFKs 
	   @Action = ''DISABLE'''

    IF @Debug = 1
    BEGIN
	   EXEC DDI.spPrintOutLongSQL 
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
