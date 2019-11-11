IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysIndexPhysicalStats]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysIndexPhysicalStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysIndexPhysicalStats]

AS

DELETE DDI.SysIndexPhysicalStats

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysIndexPhysicalStats'

GO