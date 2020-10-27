
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysPartitionRangeValues]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionRangeValues];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
         @DatabaseName = 'DOIUnitTests'
*/

DELETE PRV
FROM DOI.SysPartitionRangeValues PRV
    INNER JOIN DOI.SysDatabases D ON PRV.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysPartitionRangeValues',
    @DatabaseName = @DatabaseName

GO
