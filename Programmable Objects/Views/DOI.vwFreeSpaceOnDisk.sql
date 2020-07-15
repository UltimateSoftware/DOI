USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[vwFreeSpaceOnDisk]') IS NOT NULL
	DROP VIEW [DOI].[vwFreeSpaceOnDisk];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [DOI].[vwFreeSpaceOnDisk]

AS

/*
    SELECT * FROM DOI.vwFreeSpaceOnDisk
*/

SELECT DISTINCT
    SUBSTRING(volume_mount_point, 1, 1) AS DriveLetter
    ,d.name AS DBName
    ,CASE WHEN f.type_desc = 'ROWS' THEN 'DATA' ELSE f.type_desc END AS FileType
    ,total_bytes/1024/1024 AS total_MB
    ,available_bytes/1024/1024 AS available_MB
FROM DOI.SysMasterFiles AS f
    INNER JOIN DOI.SysDatabases d ON d.database_id = f.database_id
    INNER JOIN DOI.SysDmOsVolumeStats vs ON vs.database_id = f.database_id
        AND vs.file_id = f.file_id

GO
