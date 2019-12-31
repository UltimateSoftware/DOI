IF TYPE_ID('[DDI].[SysPartitionRangeValuesTT]') IS NOT NULL
	DROP TYPE [DDI].[SysPartitionRangeValuesTT];

GO
CREATE TYPE [DDI].[SysPartitionRangeValuesTT] AS TABLE
(
[database_id] [sys].[sysname] NOT NULL,
[function_id] [int] NOT NULL,
[boundary_id] [int] NOT NULL,
[parameter_id] [int] NOT NULL,
[value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY NONCLUSTERED  ([database_id], [function_id], [boundary_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
