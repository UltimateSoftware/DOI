CREATE TABLE [DDI].[SysStats]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stats_id] [int] NOT NULL,
[auto_created] [bit] NULL,
[user_created] [bit] NULL,
[no_recompute] [bit] NULL,
[has_filter] [bit] NULL,
[filter_definition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_temporary] [bit] NULL,
[is_incremental] [bit] NULL,
[column_list] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_SysStats] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [stats_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
