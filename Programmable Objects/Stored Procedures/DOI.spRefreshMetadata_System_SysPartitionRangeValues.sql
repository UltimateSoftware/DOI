
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysPartitionRangeValues]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionRangeValues];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
    @DatabaseId INT = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
        @DatabaseId = 18
*/

DELETE DOI.SysPartitionRangeValues
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysPartitionRangeValues',
    @DatabaseId = @DatabaseId

GO
