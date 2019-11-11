IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysForeignKeys_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysForeignKeys_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysForeignKeys_InsertData]
AS

DELETE DDI.SysForeignKeys

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysForeignKeys'

GO
