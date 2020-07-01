IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexColumns]

AS

DELETE DOI.SysIndexColumns

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysIndexColumns'

GO