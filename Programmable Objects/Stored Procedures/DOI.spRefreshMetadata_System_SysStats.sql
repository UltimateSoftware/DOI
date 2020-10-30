
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysStats]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysStats]
        @DatabaseName = 'DOIUnitTests'
*/
DELETE ST
FROM DOI.SysStats ST
    INNER JOIN DOI.SysDatabases D ON ST.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysStats',
    @DatabaseName = @DatabaseName

GO