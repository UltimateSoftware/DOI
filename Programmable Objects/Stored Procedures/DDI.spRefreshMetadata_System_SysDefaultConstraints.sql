IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysDefaultConstraints]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysDefaultConstraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysDefaultConstraints]

AS

DELETE DDI.SysDefaultConstraints


EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDefaultConstraints'

GO
