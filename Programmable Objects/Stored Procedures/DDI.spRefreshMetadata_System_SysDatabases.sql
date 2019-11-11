IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysDatabases]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysDatabases];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysDatabases]

AS

DELETE DDI.SysDatabases

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDatabases'

GO