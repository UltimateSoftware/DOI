
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexes]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysIndexes]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE I
FROM DOI.SysIndexes I
    INNER JOIN DOI.SysDatabases D ON I.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysIndexes',
    @DatabaseName = @DatabaseName

GO