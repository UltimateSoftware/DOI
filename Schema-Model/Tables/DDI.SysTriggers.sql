CREATE TABLE [DDI].[SysTriggers]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[object_id] [int] NOT NULL,
[parent_class] [tinyint] NOT NULL,
[parent_class_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parent_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NOT NULL,
[modify_date] [datetime] NOT NULL,
[is_ms_shipped] [bit] NOT NULL,
[is_disabled] [bit] NOT NULL,
[is_not_for_replication] [bit] NOT NULL,
[is_instead_of_trigger] [bit] NOT NULL,
CONSTRAINT [PK_SysTriggers] PRIMARY KEY NONCLUSTERED  ([database_id], [parent_id], [object_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
