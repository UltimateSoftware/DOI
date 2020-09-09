
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysColumns]
    @DatabaseId INT = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysColumns]
        @DatabaseId = 18
*/

DELETE DOI.SysColumns
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysColumns',
    @DatabaseId = @DatabaseId


GO