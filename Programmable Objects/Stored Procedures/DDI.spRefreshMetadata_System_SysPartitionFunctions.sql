IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysPartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysPartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysPartitionFunctions]

AS

DELETE DDI.SysPartitionFunctions

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysPartitionFunctions'
GO
