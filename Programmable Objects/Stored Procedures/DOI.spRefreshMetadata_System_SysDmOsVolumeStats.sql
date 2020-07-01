IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDmOsVolumeStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDmOsVolumeStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDmOsVolumeStats]

AS


/*
    set statistics io on
    EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats
*/

DELETE DOI.SysDmOsVolumeStats

    SELECT  FN.*
    INTO #SysDmOsVolumeStats
    FROM DOI.SysDatabaseFiles p 
        CROSS APPLY sys.dm_os_volume_stats(p.database_id, p.file_id) FN 
    WHERE p.database_id = DB_ID('PaymentReporting')

    INSERT INTO #SysDmOsVolumeStats
    SELECT  FN.*
    FROM DOI.SysDatabaseFiles p
        CROSS APPLY sys.dm_os_volume_stats(p.database_id, file_id) FN 
    WHERE p.database_id = DB_ID('TempDB')    

    INSERT INTO DOI.SysDmOsVolumeStats
    SELECT * FROM #SysDmOsVolumeStats

DROP TABLE #SysDmOsVolumeStats
GO
