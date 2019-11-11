CREATE TABLE [DDI].[SysDmOsVolumeStats]
(
[database_id] [int] NOT NULL,
[file_id] [int] NOT NULL,
[volume_mount_point] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[volume_id] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logical_volume_name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[file_system_type] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_bytes] [bigint] NOT NULL,
[available_bytes] [bigint] NOT NULL,
[supports_compression] [tinyint] NULL,
[supports_alternate_streams] [tinyint] NULL,
[supports_sparse_files] [tinyint] NULL,
[is_read_only] [tinyint] NULL,
[is_compressed] [tinyint] NULL,
CONSTRAINT [PK_SysDmOsVolumeStats] PRIMARY KEY NONCLUSTERED  ([database_id], [file_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
