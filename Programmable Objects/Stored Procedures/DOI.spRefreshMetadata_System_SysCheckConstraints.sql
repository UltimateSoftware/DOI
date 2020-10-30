
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysCheckConstraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysCheckConstraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysCheckConstraints]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysCheckConstraints]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE CC
FROM DOI.SysCheckConstraints CC
    INNER JOIN DOI.SysDatabases D ON CC.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysCheckConstraints',
    @DatabaseName = @DatabaseName

GO
