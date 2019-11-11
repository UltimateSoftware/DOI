IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysColumns]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysColumns]

AS

DELETE DDI.SysColumns

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysColumns'


GO
