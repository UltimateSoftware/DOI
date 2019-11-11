IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysFileGroups]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysFileGroups];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysFileGroups]

AS  
 
DELETE DDI.SysFilegroups

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysFilegroups'

GO