IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysPartitionRangeValues]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysPartitionRangeValues];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysPartitionRangeValues]

AS

DELETE DDI.SysPartitionRangeValues

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysPartitionRangeValues'

GO
