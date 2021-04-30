
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDmOsVolumeStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDmOsVolumeStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDmOsVolumeStats]
    @DatabaseName NVARCHAR(128) = NULL

AS


/*
    set statistics io on
    EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats
         @DatabaseName = 'DOIUnitTests'
*/



DELETE VS
FROM DOI.SysDmOsVolumeStats VS
    INNER JOIN DOI.SysDatabases D ON VS.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DELETE VS
FROM DOI.SysDmOsVolumeStats VS
    INNER JOIN DOI.SysDatabases D ON VS.database_id = D.database_id
WHERE D.name = 'TempDb'

SELECT  FN.*
INTO #SysDmOsVolumeStats
FROM DOI.SysDatabaseFiles p 
            INNER JOIN DOI.SysDatabases D ON d.Database_id = p.database_id
            CROSS APPLY sys.dm_os_volume_stats(p.database_id, p.file_id) FN 
        WHERE D.name IN (@DatabaseName, 'TempDB')



INSERT INTO DOI.SysDmOsVolumeStats
SELECT * FROM #SysDmOsVolumeStats

DROP TABLE #SysDmOsVolumeStats
GO
