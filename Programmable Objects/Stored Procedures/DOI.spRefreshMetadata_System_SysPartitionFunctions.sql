
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysPartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionFunctions]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionFunctions]
        @DatabaseId = 18
*/

DELETE PF
FROM DOI.SysPartitionFunctions PF
    INNER JOIN DOI.SysDatabases D ON PF.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysPartitionFunctions',
    @DatabaseName = @DatabaseName
GO
