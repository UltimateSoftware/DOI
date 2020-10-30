
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]
         @DatabaseName = 'DOIUnitTests'
*/

DELETE SP
FROM DOI.SysDmDbStatsProperties SP
    INNER JOIN DOI.SysDatabases D ON SP.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDmDbStatsProperties',
    @DatabaseName = @DatabaseName,
    @Debug = @Debug

GO