
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysFileGroups]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysFileGroups];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysFileGroups]

AS  
 
DELETE DOI.SysFilegroups

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysFilegroups'

GO