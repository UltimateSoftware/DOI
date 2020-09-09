
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]
    @DatabaseId INT = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]
        @DatabaseId = 18
*/


DELETE DOI.SysIndexPhysicalStats
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysIndexPhysicalStats',
    @DatabaseId = @DatabaseId

GO