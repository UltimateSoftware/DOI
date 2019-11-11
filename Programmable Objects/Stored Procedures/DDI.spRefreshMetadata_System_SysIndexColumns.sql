IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysIndexColumns]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysIndexColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysIndexColumns]

AS

DELETE DDI.SysIndexColumns

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysIndexColumns'

GO