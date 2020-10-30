
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStatsColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].spRefreshMetadata_System_SysStatsColumns;

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].spRefreshMetadata_System_SysStatsColumns
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysStatsColumns]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE SC
FROM DOI.SysStatsColumns SC
    INNER JOIN DOI.SysDatabases D ON SC.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysStatsColumns',
    @DatabaseName = @DatabaseName


GO
