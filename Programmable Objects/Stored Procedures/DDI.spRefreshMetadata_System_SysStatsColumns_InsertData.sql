IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysStatsColumns_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysStatsColumns_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysStatsColumns_InsertData]
AS

DELETE DDI.SysStatsColumns

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysStatsColumns'


GO
