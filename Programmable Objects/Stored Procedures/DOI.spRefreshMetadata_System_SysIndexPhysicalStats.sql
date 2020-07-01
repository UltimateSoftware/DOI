IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]

AS

DELETE DOI.SysIndexPhysicalStats

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysIndexPhysicalStats'

GO