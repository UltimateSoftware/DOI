USE [$(DatabaseName2)]
GO

CREATE TABLE [DOI].[SysTypes]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[system_type_id] [tinyint] NOT NULL,
[user_type_id] [int] NOT NULL,
[schema_id] [int] NOT NULL,
[principal_id] [int] NULL,
[max_length] [smallint] NOT NULL,
[precision] [tinyint] NOT NULL,
[scale] [tinyint] NOT NULL,
[collation_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_nullable] [bit] NULL,
[is_user_defined] [bit] NOT NULL,
[is_assembly_type] [bit] NOT NULL,
[default_object_id] [int] NOT NULL,
[rule_object_id] [int] NOT NULL,
[is_table_type] [bit] NOT NULL,
CONSTRAINT [PK_SysTypes] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [user_type_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
