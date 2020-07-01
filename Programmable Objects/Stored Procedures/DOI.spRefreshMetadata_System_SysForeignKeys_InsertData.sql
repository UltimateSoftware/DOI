IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeys_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys_InsertData]
AS

DELETE DOI.SysForeignKeys

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysForeignKeys'

GO
