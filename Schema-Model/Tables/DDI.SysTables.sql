CREATE TABLE [DDI].[SysTables]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[object_id] [int] NOT NULL,
[principal_id] [int] NULL,
[schema_id] [int] NOT NULL,
[parent_object_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NOT NULL,
[modify_date] [datetime] NOT NULL,
[is_ms_shipped] [bit] NOT NULL,
[is_published] [bit] NOT NULL,
[is_schema_published] [bit] NOT NULL,
[lob_data_space_id] [int] NOT NULL,
[filestream_data_space_id] [int] NULL,
[max_column_id_used] [int] NOT NULL,
[lock_on_bulk_load] [bit] NOT NULL,
[uses_ansi_nulls] [bit] NULL,
[is_replicated] [bit] NULL,
[has_replication_filter] [bit] NULL,
[is_merge_published] [bit] NULL,
[is_sync_tran_subscribed] [bit] NULL,
[has_unchecked_assembly_data] [bit] NOT NULL,
[text_in_row_limit] [int] NULL,
[large_value_types_out_of_row] [bit] NULL,
[is_tracked_by_cdc] [bit] NULL,
[lock_escalation] [tinyint] NULL,
[lock_escalation_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_filetable] [bit] NULL,
[is_memory_optimized] [bit] NULL,
[durability] [tinyint] NULL,
[durability_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[temporal_type] [tinyint] NULL,
[temporal_type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[history_table_id] [int] NULL,
[is_remote_data_archive_enabled] [bit] NULL,
[is_external] [bit] NOT NULL,
CONSTRAINT [PK_SysTables] PRIMARY KEY NONCLUSTERED  ([database_id], [schema_id], [object_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
