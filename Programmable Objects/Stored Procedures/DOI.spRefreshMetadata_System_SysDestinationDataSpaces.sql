
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDestinationDataSpaces]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDestinationDataSpaces];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDestinationDataSpaces]
    @DatabaseName NVARCHAR(128) = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDestinationDataSpaces]
         @DatabaseName = 'DOIUnitTests'
*/

DELETE DDS
FROM DOI.SysDestinationDataSpaces DDS
    INNER JOIN DOI.SysDatabases D ON DDS.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDestinationDataSpaces',
    @DatabaseName = @DatabaseName

GO