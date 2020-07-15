USE [$(DatabaseName2)]
GO

CREATE TABLE [DOI].[SysDefaultConstraints]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[object_id] [int] NOT NULL,
[principal_id] [int] NULL,
[parent_object_id] [int] NOT NULL,
[schema_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NOT NULL,
[modify_date] [datetime] NOT NULL,
[is_ms_shipped] [bit] NOT NULL,
[is_published] [bit] NOT NULL,
[is_schema_published] [bit] NOT NULL,
[parent_column_id] [int] NOT NULL,
[definition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_system_named] [bit] NOT NULL,
CONSTRAINT [PK_SysDefaultConstraints] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
