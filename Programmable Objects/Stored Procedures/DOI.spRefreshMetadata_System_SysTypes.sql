
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysTypes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysTypes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysTypes]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysTypes]
         @DatabaseName = 'DOIUnitTests'
*/

DELETE S
FROM DOI.SysTypes S
    INNER JOIN DOI.SysDatabases D ON S.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END 


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysTypes',
    @DatabaseName = @DatabaseName


GO
