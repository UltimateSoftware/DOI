
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysMasterFiles]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysMasterFiles];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysMasterFiles]
    @DatabaseId INT = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysMasterFiles]
        @DatabaseId = 18
*/

DELETE DOI.SysMasterFiles


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysMasterFiles'

GO
