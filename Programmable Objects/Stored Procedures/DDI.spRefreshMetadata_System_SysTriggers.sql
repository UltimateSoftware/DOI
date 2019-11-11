IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysTriggers]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysTriggers];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysTriggers]

AS

DELETE DDI.SysTriggers


EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysTriggers'

GO
