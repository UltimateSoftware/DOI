IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysDestinationDataSpaces]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysDestinationDataSpaces];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysDestinationDataSpaces]

AS

DELETE DDI.SysDestinationDataSpaces

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDestinationDataSpaces'

GO