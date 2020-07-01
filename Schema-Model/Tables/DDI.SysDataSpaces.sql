CREATE TABLE [DOI].[SysDataSpaces]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[data_space_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_default] [bit] NOT NULL,
[is_system] [bit] NULL,
CONSTRAINT [PK_SysDataSpaces] PRIMARY KEY NONCLUSTERED  ([database_id], [data_space_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
