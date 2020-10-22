
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDatabaseFiles]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabaseFiles];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabaseFiles]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDatabaseFiles]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE DF
FROM DOI.SysDatabaseFiles DF
    INNER JOIN DOI.SysDatabases D ON DF.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DELETE DOI.SysDatabaseFiles
WHERE database_id = 2 --TEMPDB


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDatabaseFiles',
    @DatabaseName = @DatabaseName

GO