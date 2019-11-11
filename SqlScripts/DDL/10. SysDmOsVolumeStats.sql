USE DDI
GO

DROP TABLE IF EXISTS DDI.SysDmOsVolumeStats
GO


CREATE TABLE DDI.SysDmOsVolumeStats (
    database_id	int NOT NULL,
    file_id	int NOT NULL,
    volume_mount_point	nvarchar(256) NULL,
    volume_id	nvarchar(256) NULL,
    logical_volume_name	nvarchar(256) NULL,
    file_system_type	nvarchar(256) NULL,
    total_bytes	bigint NOT NULL,
    available_bytes	bigint NOT NULL,
    supports_compression	tinyint NULL,
    supports_alternate_streams	tinyint NULL,
    supports_sparse_files	tinyint NULL,
    is_read_only	tinyint NULL,
    is_compressed	tinyint NULL

    CONSTRAINT PK_SysDmOsVolumeStats
        PRIMARY KEY NONCLUSTERED (database_id, file_id)
)
WITH (MEMORY_OPTIMIZED = ON)


SELECT vs.*
INTO #SysDmOsVolumeStats
FROM DDI.SysDatabaseFiles df
    CROSS APPLY SYS.dm_os_volume_stats(5, FILE_ID) vs


INSERT INTO DDI.SysDmOsVolumeStats
SELECT * FROM #SysDmOsVolumeStats

DROP TABLE #SysDmOsVolumeStats
go
