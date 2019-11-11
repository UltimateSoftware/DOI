IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysMasterFiles]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysMasterFiles];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysMasterFiles]

AS

DELETE DDI.SysMasterFiles


EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysMasterFiles'

GO
