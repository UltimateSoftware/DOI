
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysMasterFiles]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysMasterFiles];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysMasterFiles]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysMasterFiles]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE MF
FROM DOI.SysMasterFiles MF
    INNER JOIN DOI.SysDatabases D ON MF.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DELETE MF
FROM DOI.SysMasterFiles MF
    INNER JOIN DOI.SysDatabases D ON MF.database_id = D.database_id
WHERE D.name = 'TempDb'

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysMasterFiles',
    @DatabaseName = @DatabaseName

GO
