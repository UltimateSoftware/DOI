IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysStats_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysStats_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysStats_InsertData]
AS

DELETE DDI.SysStats

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysStats'

GO
