
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDatabases]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabases];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabases]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDatabases]
        @DatabaseId = 18
*/

DELETE DOI.SysDatabases
WHERE name = CASE WHEN @DatabaseName IS NULL THEN name ELSE @DatabaseName END 

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDatabases'

GO