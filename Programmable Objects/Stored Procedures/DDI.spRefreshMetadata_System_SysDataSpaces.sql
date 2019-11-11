IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysDataSpaces]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysDataSpaces];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysDataSpaces]
AS

DELETE DDI.SysDataSpaces

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDataSpaces'

GO