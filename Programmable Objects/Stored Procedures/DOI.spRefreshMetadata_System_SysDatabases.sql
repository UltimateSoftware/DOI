USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDatabases]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabases];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabases]

AS

DELETE DOI.SysDatabases

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDatabases'

GO