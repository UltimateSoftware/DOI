
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysFileGroups]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysFileGroups];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysFileGroups]
    @DatabaseName NVARCHAR(128) = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysFileGroups]
        @DatabaseName = 'DOIUnitTests'
*/
 
DELETE F
FROM DOI.SysFilegroups F
    INNER JOIN DOI.SysDatabases D ON F.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysFilegroups',
    @DatabaseName = @DatabaseName

GO