IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeyColumns_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeyColumns_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeyColumns_InsertData]
AS

DELETE DOI.SysForeignKeyColumns

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysForeignKeyColumns'

GO
