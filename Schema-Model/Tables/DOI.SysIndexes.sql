
GO

CREATE TABLE [DOI].[SysIndexes]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[index_id] [int] NOT NULL,
[type] [tinyint] NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[is_unique] [bit] NOT NULL,
[data_space_id] [int] NULL,
[ignore_dup_key] [bit] NOT NULL,
[is_primary_key] [bit] NOT NULL,
[is_unique_constraint] [bit] NOT NULL,
[fill_factor] [tinyint] NOT NULL,
[is_padded] [bit] NOT NULL,
[is_disabled] [bit] NOT NULL,
[is_hypothetical] [bit] NOT NULL,
[allow_row_locks] [bit] NOT NULL,
[allow_page_locks] [bit] NOT NULL,
[has_filter] [bit] NOT NULL,
[filter_definition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compression_delay] [int] NULL,
[key_column_list] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[included_column_list] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_LOB_columns] [bit] NULL,
CONSTRAINT [PK_SysIndexes] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [index_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
