USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_DOISettings_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_DOISettings_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_DOISettings_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'DOISettings',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DOI.DOISettings

CREATE TABLE DOI.DOISettings(
		SettingName SYSNAME 
			CONSTRAINT PK_DOISettings PRIMARY KEY NONCLUSTERED,
		SettingValue VARCHAR(50))
        WITH (MEMORY_OPTIMIZED = ON)

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL


GO
