IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysSchemas]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysSchemas];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysSchemas]

AS

DELETE DDI.SysSchemas

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysSchemas'


GO
