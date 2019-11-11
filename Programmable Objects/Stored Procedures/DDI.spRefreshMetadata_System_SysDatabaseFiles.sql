IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysDatabaseFiles]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysDatabaseFiles];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysDatabaseFiles]

AS

DELETE DDI.SysDatabaseFiles

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDatabaseFiles'

GO