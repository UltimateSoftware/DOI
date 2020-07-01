IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysCheckConstraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysCheckConstraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysCheckConstraints]

AS

DELETE DOI.SysCheckConstraints


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysCheckConstraints'

GO
