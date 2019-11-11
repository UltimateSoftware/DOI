IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysIndexes]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysIndexes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysIndexes]

AS

DELETE DDI.SysIndexes


EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysIndexes'

GO
