
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStatsColumns_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysStatsColumns_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysStatsColumns_InsertData]
    @DatabaseId INT = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysStatsColumns_InsertData]
        @DatabaseId = 18
*/

DELETE DOI.SysStatsColumns
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysStatsColumns',
    @DatabaseId = @DatabaseId


GO
