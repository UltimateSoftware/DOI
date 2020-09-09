
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysTypes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysTypes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysTypes]
    @DatabaseId INT = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysTypes]
        @DatabaseId = 18
*/

DELETE DOI.SysTypes
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysTypes',
    @DatabaseId = @DatabaseId


GO
