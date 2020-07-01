CREATE TABLE [DOI].[SysPartitions]
(
[database_id] [int] NOT NULL,
[partition_id] [bigint] NOT NULL,
[object_id] [int] NOT NULL,
[index_id] [int] NOT NULL,
[partition_number] [int] NOT NULL,
[hobt_id] [bigint] NOT NULL,
[rows] [bigint] NULL,
[filestream_filegroup_id] [smallint] NOT NULL,
[data_compression] [tinyint] NOT NULL,
[data_compression_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_SysPartitions] PRIMARY KEY NONCLUSTERED  ([database_id], [partition_id]),
CONSTRAINT [UQ_SysPartitions] UNIQUE NONCLUSTERED  ([database_id], [object_id], [index_id], [partition_number])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
