IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysPartitionSchemes]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysPartitionSchemes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysPartitionSchemes]

AS

DELETE DDI.SysPartitionSchemes

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysPartitionSchemes'

GO
