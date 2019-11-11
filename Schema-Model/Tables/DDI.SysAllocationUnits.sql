CREATE TABLE [DDI].[SysAllocationUnits]
(
[database_id] [int] NOT NULL,
[allocation_unit_id] [bigint] NOT NULL,
[type] [tinyint] NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[container_id] [bigint] NOT NULL,
[data_space_id] [int] NULL,
[total_pages] [bigint] NOT NULL,
[used_pages] [bigint] NOT NULL,
[data_pages] [bigint] NOT NULL,
CONSTRAINT [PK_SysAllocationUnits] PRIMARY KEY NONCLUSTERED  ([database_id], [allocation_unit_id]),
CONSTRAINT [UQ_SysAllocationUnits] UNIQUE NONCLUSTERED  ([container_id], [data_space_id], [type])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
