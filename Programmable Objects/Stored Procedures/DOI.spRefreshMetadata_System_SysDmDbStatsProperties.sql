
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]
    @DatabaseName NVARCHAR(128) = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]
         @DatabaseName = 'DOIUnitTests'
*/

DELETE D
FROM DOI.SysDmDbStatsProperties
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDmDbStatsProperties',
    @DatabaseName = @DatabaseName

GO