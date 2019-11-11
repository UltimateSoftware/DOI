IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysCheckConstraints]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysCheckConstraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysCheckConstraints]

AS

DELETE DDI.SysCheckConstraints


EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysCheckConstraints'

GO
