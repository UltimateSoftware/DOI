IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysPartitions]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysPartitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysPartitions]

AS

DELETE DDI.SysPartitions

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysPartitions'

GO
