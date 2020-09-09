
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysTriggers]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysTriggers];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysTriggers]
    @DatabaseId INT = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysTriggers]
        @DatabaseId = 18
*/

DELETE DOI.SysTriggers
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysTriggers',
    @DatabaseId = @DatabaseId

GO
