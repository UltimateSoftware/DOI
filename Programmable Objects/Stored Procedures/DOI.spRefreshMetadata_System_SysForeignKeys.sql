

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeys]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys]
    @DatabaseName NVARCHAR(128) = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys]
        @DatabaseName = 'DOIUnitTests'
*/


DELETE FK
FROM DOI.SysForeignKeys FK
    INNER JOIN DOI.SysDatabases D ON FK.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysForeignKeys',
    @DatabaseName = @DatabaseName

GO
