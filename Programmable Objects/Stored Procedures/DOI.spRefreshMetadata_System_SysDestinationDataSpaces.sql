USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDestinationDataSpaces]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDestinationDataSpaces];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDestinationDataSpaces]

AS

DELETE DOI.SysDestinationDataSpaces

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDestinationDataSpaces'

GO