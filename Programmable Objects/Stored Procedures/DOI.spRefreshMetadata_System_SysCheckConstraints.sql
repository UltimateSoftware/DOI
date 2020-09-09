
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysCheckConstraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysCheckConstraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysCheckConstraints]
    @DatabaseId INT = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysCheckConstraints]
        @DatabaseId = 18
*/

DELETE DOI.SysCheckConstraints
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysCheckConstraints',
    @DatabaseId = @DatabaseId

GO
