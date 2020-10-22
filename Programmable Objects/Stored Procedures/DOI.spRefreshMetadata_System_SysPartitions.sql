
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysPartitions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitions]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysPartitions]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE P
FROM DOI.SysPartitions P
    INNER JOIN DOI.SysDatabases D ON P.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysPartitions',
    @DatabaseName = @DatabaseName

GO
