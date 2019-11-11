IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysForeignKeyColumns_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysForeignKeyColumns_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DDI].[spRefreshMetadata_System_SysForeignKeyColumns_InsertData]
AS

DELETE DDI.SysForeignKeyColumns

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysForeignKeyColumns'

GO
