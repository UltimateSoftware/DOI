
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDataSpaces]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDataSpaces];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDataSpaces]
    @DatabaseName NVARCHAR(128) = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDataSpaces]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE DS
FROM DOI.SysDataSpaces DS
    INNER JOIN DOI.SysDatabases D ON DS.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END 

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDataSpaces',
    @DatabaseName = @DatabaseName

GO