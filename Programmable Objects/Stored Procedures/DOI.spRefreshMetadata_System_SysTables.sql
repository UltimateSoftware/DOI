
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysTables]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysTables]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE T
FROM DOI.SysTables T
    INNER JOIN DOI.SysDatabases D ON T.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysTables',
    @DatabaseName = @DatabaseName


GO
