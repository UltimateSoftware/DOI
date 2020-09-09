
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysFileGroups]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysFileGroups];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysFileGroups]
    @DatabaseId INT = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysFileGroups]
        @DatabaseId = 18
*/
 
DELETE DOI.SysFilegroups
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysFilegroups',
    @DatabaseId = @DatabaseId

GO