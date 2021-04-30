IF OBJECT_ID('[DOI].[spRefreshMetadata_2_DmOsVolumeStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_2_DmOsVolumeStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_2_DmOsVolumeStats]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName
    EXEC DOI.spRefreshMetadata_1_DBFiles
	    @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats
	    @DatabaseName = @DatabaseName
GO