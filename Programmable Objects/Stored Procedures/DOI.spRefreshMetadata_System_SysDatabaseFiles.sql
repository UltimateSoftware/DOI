USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDatabaseFiles]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabaseFiles];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabaseFiles]

AS

DELETE DOI.SysDatabaseFiles

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDatabaseFiles'

GO