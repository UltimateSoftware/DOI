USE [$(DatabaseName2)]
GO

CREATE TABLE [DOI].[SysPartitionFunctions]
(
[database_id] [sys].[sysname] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[function_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fanout] [int] NOT NULL,
[boundary_value_on_right] [bit] NOT NULL,
[is_system] [bit] NOT NULL,
[create_date] [datetime] NOT NULL,
[modify_date] [datetime] NOT NULL,
CONSTRAINT [PK_SysPartitionFunctions] PRIMARY KEY NONCLUSTERED  ([database_id], [function_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
