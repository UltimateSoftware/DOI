IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysAllocationUnits]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysAllocationUnits];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysAllocationUnits]

AS

DELETE DDI.SysAllocationUnits

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysAllocationUnits'

GO
