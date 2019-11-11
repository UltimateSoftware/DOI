IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysTables]

AS

DELETE DDI.SysTables


EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysTables'


GO
