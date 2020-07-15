USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStats_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysStats_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysStats_InsertData]
AS

DELETE DOI.SysStats

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysStats'

GO
