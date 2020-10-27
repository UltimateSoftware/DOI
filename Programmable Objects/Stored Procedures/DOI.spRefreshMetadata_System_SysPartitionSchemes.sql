
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysPartitionSchemes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionSchemes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionSchemes]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionSchemes]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE PS
FROM DOI.SysPartitionSchemes PS
    INNER JOIN DOI.SysDatabases D ON PS.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysPartitionSchemes',
    @DatabaseName = @DatabaseName

GO