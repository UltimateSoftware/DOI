
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysTriggers]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysTriggers];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysTriggers]

AS

DELETE DOI.SysTriggers


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysTriggers'

GO
