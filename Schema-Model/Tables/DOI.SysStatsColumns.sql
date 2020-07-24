
GO

CREATE TABLE [DOI].[SysStatsColumns]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[stats_id] [int] NOT NULL,
[stats_column_id] [int] NOT NULL,
[column_id] [int] NOT NULL,
CONSTRAINT [PK_SysStatsColumns] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [stats_id], [stats_column_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
