CREATE TABLE [DDI].[SysDatabaseFiles]
(
[database_id] [int] NOT NULL,
[file_id] [int] NOT NULL,
[file_guid] [uniqueidentifier] NULL,
[type] [tinyint] NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[data_space_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[physical_name] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [tinyint] NULL,
[state_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[size] [int] NOT NULL,
[max_size] [int] NOT NULL,
[growth] [int] NOT NULL,
[is_media_read_only] [bit] NOT NULL,
[is_read_only] [bit] NOT NULL,
[is_sparse] [bit] NOT NULL,
[is_percent_growth] [bit] NOT NULL,
[is_name_reserved] [bit] NOT NULL,
[create_lsn] [numeric] (25, 0) NULL,
[drop_lsn] [numeric] (25, 0) NULL,
[read_only_lsn] [numeric] (25, 0) NULL,
[read_write_lsn] [numeric] (25, 0) NULL,
[differential_base_lsn] [numeric] (25, 0) NULL,
[differential_base_guid] [uniqueidentifier] NULL,
[differential_base_time] [datetime] NULL,
[redo_start_lsn] [numeric] (25, 0) NULL,
[redo_start_fork_guid] [uniqueidentifier] NULL,
[redo_target_lsn] [numeric] (25, 0) NULL,
[redo_target_fork_guid] [uniqueidentifier] NULL,
[backup_lsn] [numeric] (25, 0) NULL,
CONSTRAINT [PK_SysDatabaseFiles] PRIMARY KEY NONCLUSTERED  ([database_id], [file_id]),
CONSTRAINT [UQ_SysDatabaseFiles_FileGUID] UNIQUE NONCLUSTERED  ([database_id], [file_guid]),
CONSTRAINT [UQ_SysDatabaseFiles_Name] UNIQUE NONCLUSTERED  ([database_id], [name]),
CONSTRAINT [UQ_SysDatabaseFiles_PhysicalName] UNIQUE NONCLUSTERED  ([database_id], [physical_name])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
