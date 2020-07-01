CREATE TABLE [DOI].[SysCheckConstraints]
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
[is_disabled] [bit] NOT NULL,
[is_not_for_replication] [bit] NOT NULL,
[is_not_trusted] [bit] NOT NULL,
[parent_column_id] [int] NOT NULL,
[definition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uses_database_collation] [bit] NULL,
[is_system_named] [bit] NOT NULL,
CONSTRAINT [PK_SysCheckConstraints] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
