
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDefaultConstraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDefaultConstraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDefaultConstraints]
    @DatabaseName NVARCHAR(128) = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDefaultConstraints]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE DC
FROM DOI.SysDefaultConstraints DC
    INNER JOIN DOI.SysDatabases D ON DC.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDefaultConstraints',
    @DatabaseName = @DatabaseName

GO
