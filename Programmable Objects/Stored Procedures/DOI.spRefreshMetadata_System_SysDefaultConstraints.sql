
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDefaultConstraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDefaultConstraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDefaultConstraints]
    @DatabaseId INT = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDefaultConstraints]
        @DatabaseId = 18
*/

DELETE DOI.SysDefaultConstraints
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDefaultConstraints',
    @DatabaseId = @DatabaseId

GO
