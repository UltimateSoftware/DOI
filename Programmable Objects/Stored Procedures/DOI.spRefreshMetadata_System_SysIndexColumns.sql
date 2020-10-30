
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexColumns]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysIndexColumns]
        @DatabaseName = 'DOIUnitTests'
*/


DELETE IC
FROM DOI.SysIndexColumns IC
    INNER JOIN DOI.SysDatabases D ON IC.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysIndexColumns',
    @DatabaseName = @DatabaseName

GO