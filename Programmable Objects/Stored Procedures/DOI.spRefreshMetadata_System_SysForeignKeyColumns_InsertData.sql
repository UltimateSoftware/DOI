
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeyColumns_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeyColumns_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeyColumns_InsertData]
    @DatabaseName NVARCHAR(128) = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeyColumns_InsertData]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE FKC
FROM DOI.SysForeignKeyColumns FKC
    INNER JOIN DOI.SysDatabases D ON FKC.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysForeignKeyColumns',
    @DatabaseName = @DatabaseName

GO
