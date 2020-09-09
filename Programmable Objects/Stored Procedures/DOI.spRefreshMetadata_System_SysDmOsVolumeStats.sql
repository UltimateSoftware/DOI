
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDmOsVolumeStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDmOsVolumeStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDmOsVolumeStats]
    @DatabaseId INT

AS


/*
    set statistics io on
    EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats
*/



DELETE DOI.SysDmOsVolumeStats
WHERE database_id = @DatabaseId 

SELECT  FN.*
INTO #SysDmOsVolumeStats
FROM DOI.SysDatabaseFiles p 
    CROSS APPLY sys.dm_os_volume_stats(p.database_id, p.file_id) FN 
WHERE P.database_id = @DatabaseId

INSERT INTO DOI.SysDmOsVolumeStats
SELECT * FROM #SysDmOsVolumeStats

DROP TABLE #SysDmOsVolumeStats
GO
