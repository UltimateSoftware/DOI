
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysAllocationUnits]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysAllocationUnits];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysAllocationUnits]

AS

DELETE DOI.SysAllocationUnits

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysAllocationUnits'

GO
