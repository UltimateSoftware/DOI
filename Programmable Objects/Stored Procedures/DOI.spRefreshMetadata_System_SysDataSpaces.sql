
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDataSpaces]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDataSpaces];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDataSpaces]
    @DatabaseId INT = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDataSpaces]
        @DatabaseId = 18
*/

DELETE DOI.SysDataSpaces
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDataSpaces',
    @DatabaseId = @DatabaseId

GO