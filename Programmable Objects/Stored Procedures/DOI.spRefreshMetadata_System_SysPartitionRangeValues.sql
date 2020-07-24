
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysPartitionRangeValues]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionRangeValues];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]

AS

DELETE DOI.SysPartitionRangeValues

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysPartitionRangeValues'

GO
