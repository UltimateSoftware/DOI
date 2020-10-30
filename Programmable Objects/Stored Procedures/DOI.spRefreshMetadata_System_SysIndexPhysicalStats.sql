
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]
        @DatabaseName = 'DOIUnitTests'
*/


DELETE IPS
FROM DOI.SysIndexPhysicalStats IPS
    INNER JOIN DOI.SysDatabases D ON IPS.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysIndexPhysicalStats',
    @DatabaseName = @DatabaseName

GO