USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysSchemas]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysSchemas];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysSchemas]

AS

DELETE DOI.SysSchemas

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysSchemas'


GO
