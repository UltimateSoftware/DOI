
GO

CREATE TABLE [DOI].[SysFilegroups]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[data_space_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_default] [bit] NULL,
[is_system] [bit] NULL,
[filegroup_guid] [uniqueidentifier] NULL,
[log_filegroup_id] [int] NULL,
[is_read_only] [bit] NULL,
[is_autogrow_all_files] [bit] NULL,
CONSTRAINT [PK_SysFilegroups] PRIMARY KEY NONCLUSTERED  ([database_id], [data_space_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
