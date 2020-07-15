USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDefaultConstraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDefaultConstraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDefaultConstraints]

AS

DELETE DOI.SysDefaultConstraints


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDefaultConstraints'

GO
