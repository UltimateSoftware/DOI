
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysColumns]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysColumns]
        @@DatabaseName = 18
*/

DELETE C
FROM DOI.SysColumns C
    INNER JOIN DOI.SysDatabases D ON C.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysColumns',
    @DatabaseName = @DatabaseName


GO