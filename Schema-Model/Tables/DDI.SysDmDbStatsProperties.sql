CREATE TABLE [DDI].[SysDmDbStatsProperties]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[stats_id] [int] NOT NULL,
[last_updated] [datetime2] NULL,
[rows] [bigint] NULL,
[rows_sampled] [bigint] NULL,
[steps] [int] NULL,
[unfiltered_rows] [bigint] NULL,
[modification_counter] [bigint] NULL,
CONSTRAINT [PK_SysDmDbStatsProperties] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [stats_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
