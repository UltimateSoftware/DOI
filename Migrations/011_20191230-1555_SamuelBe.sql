-- <Migration ID="dd1e6500-9220-4742-87b8-444b8faf4644" TransactionHandling="Custom" />
GO

PRINT N'Dropping [DDI].[IndexesRowStoreColumns]'
GO
IF OBJECT_ID(N'[DDI].[IndexesRowStoreColumns]', 'U') IS NOT NULL
DROP TABLE [DDI].[IndexesRowStoreColumns]
GO
PRINT N'Creating types'
GO
IF TYPE_ID(N'[DDI].[SysPartitionRangeValuesTT]') IS NULL
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
PRINT N'Rebuilding [DDI].[SysDmDbStatsProperties]'
GO
CREATE TABLE [DDI].[RG_Recovery_1_SysDmDbStatsProperties]
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
[persisted_sample_percent] [float] NULL
)
GO
INSERT INTO [DDI].[RG_Recovery_1_SysDmDbStatsProperties]([database_id], [object_id], [stats_id], [last_updated], [rows], [rows_sampled], [steps], [unfiltered_rows], [modification_counter]) SELECT [database_id], [object_id], [stats_id], [last_updated], [rows], [rows_sampled], [steps], [unfiltered_rows], [modification_counter] FROM [DDI].[SysDmDbStatsProperties]
GO
DROP TABLE [DDI].[SysDmDbStatsProperties]
GO
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
[persisted_sample_percent] [float] NULL,
CONSTRAINT [PK_SysDmDbStatsProperties] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [stats_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
INSERT INTO [DDI].[SysDmDbStatsProperties]([database_id], [object_id], [stats_id], [last_updated], [rows], [rows_sampled], [steps], [unfiltered_rows], [modification_counter], [persisted_sample_percent]) SELECT [database_id], [object_id], [stats_id], [last_updated], [rows], [rows_sampled], [steps], [unfiltered_rows], [modification_counter], [persisted_sample_percent] FROM [DDI].[RG_Recovery_1_SysDmDbStatsProperties]
GO
UPDATE STATISTICS [DDI].[SysDmDbStatsProperties] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_1_SysDmDbStatsProperties]
GO
