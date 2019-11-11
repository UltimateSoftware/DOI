IF OBJECT_ID('[DDI].[spRefreshMetadata_User_DDISettings_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_DDISettings_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_DDISettings_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'DDISettings',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DDI.DDISettings

CREATE TABLE DDI.DDISettings(
		SettingName SYSNAME 
			CONSTRAINT PK_DDISettings PRIMARY KEY NONCLUSTERED,
		SettingValue VARCHAR(50))
        WITH (MEMORY_OPTIMIZED = ON)

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL


GO
