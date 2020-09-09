
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysSchemas]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysSchemas];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysSchemas]
    @DatabaseId INT = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysSchemas]
        @DatabaseId = 18
*/

DELETE DOI.SysSchemas
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysSchemas',
    @DatabaseId = @DatabaseId


GO
