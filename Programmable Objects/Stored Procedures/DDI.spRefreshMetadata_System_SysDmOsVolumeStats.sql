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

    SELECT  FN.*
    INTO #SysDmOsVolumeStats
    FROM DDI.SysDatabaseFiles p 
        CROSS APPLY sys.dm_os_volume_stats(p.database_id, p.file_id) FN 
    WHERE p.database_id = DB_ID('PaymentReporting')

    INSERT INTO #SysDmOsVolumeStats
    SELECT  FN.*
    FROM DDI.SysDatabaseFiles p
        CROSS APPLY sys.dm_os_volume_stats(p.database_id, file_id) FN 
    WHERE p.database_id = DB_ID('TempDB')    

    INSERT INTO DDI.SysDmOsVolumeStats
    SELECT * FROM #SysDmOsVolumeStats

DROP TABLE #SysDmOsVolumeStats
GO
