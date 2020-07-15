USE [$(DatabaseName2)]
GO

CREATE TABLE [DOI].[SysIndexPhysicalStats]
(
[database_id] [smallint] NOT NULL,
[object_id] [int] NOT NULL,
[index_id] [int] NOT NULL,
[partition_number] [int] NOT NULL,
[index_type_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alloc_unit_type_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[index_depth] [tinyint] NULL,
[index_level] [tinyint] NULL,
[avg_fragmentation_in_percent] [float] NULL,
[fragment_count] [bigint] NULL,
[avg_fragment_size_in_pages] [float] NULL,
[page_count] [bigint] NULL,
[avg_page_space_used_in_percent] [float] NULL,
[record_count] [bigint] NULL,
[ghost_record_count] [bigint] NULL,
[version_ghost_record_count] [bigint] NULL,
[min_record_size_in_bytes] [int] NULL,
[max_record_size_in_bytes] [int] NULL,
[avg_record_size_in_bytes] [float] NULL,
[forwarded_record_count] [bigint] NULL,
[compressed_page_count] [bigint] NULL,
[hobt_id] [bigint] NOT NULL,
[columnstore_delete_buffer_state] [tinyint] NULL,
[columnstore_delete_buffer_state_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_SysIndexPhysicalStats] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [index_id], [partition_number], [hobt_id], [alloc_unit_type_desc])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
