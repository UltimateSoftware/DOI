IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysTypes]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysTypes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysTypes]

AS

DELETE DDI.SysTypes

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysTypes'


GO
