IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysDmOsVolumeStats]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysDmOsVolumeStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysDmOsVolumeStats]

AS


/*
    set statistics io on
    EXEC DDI.spRefreshMetadata_System_SysDmOsVolumeStats
*/

DELETE DDI.SysDmOsVolumeStats

EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysDmOsVolumeStats'

GO