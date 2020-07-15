USE [$(DatabaseName2)]
GO

CREATE TABLE [DOI].[SysColumns]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[column_id] [int] NOT NULL,
[system_type_id] [tinyint] NOT NULL,
[user_type_id] [int] NOT NULL,
[max_length] [smallint] NOT NULL,
[precision] [tinyint] NOT NULL,
[scale] [tinyint] NOT NULL,
[collation_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_nullable] [bit] NULL,
[is_ansi_padded] [bit] NOT NULL,
[is_rowguidcol] [bit] NOT NULL,
[is_identity] [bit] NOT NULL,
[is_computed] [bit] NOT NULL,
[is_filestream] [bit] NOT NULL,
[is_replicated] [bit] NULL,
[is_non_sql_subscribed] [bit] NULL,
[is_merge_published] [bit] NULL,
[is_dts_replicated] [bit] NULL,
[is_xml_document] [bit] NOT NULL,
[xml_collection_id] [int] NOT NULL,
[default_object_id] [int] NOT NULL,
[rule_object_id] [int] NOT NULL,
[is_sparse] [bit] NULL,
[is_column_set] [bit] NULL,
[generated_always_type] [tinyint] NULL,
[generated_always_type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[encryption_type] [int] NULL,
[encryption_type_desc] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[encryption_algorithm_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[column_encryption_key_id] [int] NULL,
[column_encryption_key_database_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_hidden] [bit] NULL,
[is_masked] [bit] NULL,
CONSTRAINT [PK_SysColumns] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [column_id]),
INDEX [IDX_SysColumns_object_id] NONCLUSTERED ([object_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
