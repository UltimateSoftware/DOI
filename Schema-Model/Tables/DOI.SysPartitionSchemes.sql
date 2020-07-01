CREATE TABLE [DOI].[SysPartitionSchemes]
(
[database_id] [sys].[sysname] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[data_space_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_default] [bit] NULL,
[is_system] [bit] NULL,
[function_id] [int] NOT NULL,
CONSTRAINT [PK_SysPartitionSchemes] PRIMARY KEY NONCLUSTERED  ([function_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
