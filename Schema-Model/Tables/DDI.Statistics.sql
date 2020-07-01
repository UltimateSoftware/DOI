CREATE TABLE [DOI].[Statistics]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatisticsName] [sys].[sysname] NOT NULL,
[IsStatisticsMissingFromSQLServer] [bit] NOT NULL CONSTRAINT [Def_Statistics_IsStatisticsMissingFromSQLServer] DEFAULT ((0)),
[StatisticsColumnList_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatisticsColumnList_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SampleSizePct_Desired] [tinyint] NOT NULL,
[SampleSizePct_Actual] [tinyint] NOT NULL CONSTRAINT [Def_Statistics_SampleSize_Actual] DEFAULT ((0)),
[IsFiltered_Desired] [bit] NOT NULL,
[IsFiltered_Actual] [bit] NOT NULL CONSTRAINT [Def_Statistics_IsFiltered_Actual] DEFAULT ((0)),
[FilterPredicate_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterPredicate_Actual] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsIncremental_Desired] [bit] NOT NULL,
[IsIncremental_Actual] [bit] NOT NULL CONSTRAINT [Def_Statistics_IsIncremental_Actual] DEFAULT ((0)),
[NoRecompute_Desired] [bit] NOT NULL,
[NoRecompute_Actual] [bit] NOT NULL CONSTRAINT [Def_Statistics_NoRecompute_Actual] DEFAULT ((0)),
[LowerSampleSizeToDesired] [bit] NOT NULL,
[ReadyToQueue] [bit] NOT NULL CONSTRAINT [Def_Statistics_ReadyToQueue] DEFAULT ((0)),
[DoesSampleSizeNeedUpdate] [bit] NOT NULL CONSTRAINT [Def_Statistics_DoesSampleSizeNeedUpdate] DEFAULT ((0)),
[IsStatisticsMissing] [bit] NOT NULL CONSTRAINT [Def_Statistics_IsStatisticsMissing] DEFAULT ((0)),
[HasFilterChanged] [bit] NOT NULL CONSTRAINT [Def_Statistics_HasFilterChanged] DEFAULT ((0)),
[HasIncrementalChanged] [bit] NOT NULL CONSTRAINT [Def_Statistics_HasIncrementalChanged] DEFAULT ((0)),
[HasNoRecomputeChanged] [bit] NOT NULL CONSTRAINT [Def_Statistics_HasNoRecomputeChanged] DEFAULT ((0)),
[NumRowsInTableUnfiltered] [bigint] NULL,
[NumRowsInTableFiltered] [bigint] NULL,
[NumRowsSampled] [bigint] NULL,
[StatisticsLastUpdated] [datetime2] NULL,
[HistogramSteps] [int] NULL,
[StatisticsModCounter] [bigint] NULL,
[PersistedSamplePct] [float] NULL,
[StatisticsUpdateType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_Statistics_StatisticsUpdateType] DEFAULT ('None'),
[ListOfChanges] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsOnlineOperation] [bit] NOT NULL CONSTRAINT [Def_Statistics_IsOnlineOperation] DEFAULT ((0)),
CONSTRAINT [PK_Statistics] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [StatisticsName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DOI].[Statistics] ADD CONSTRAINT [Chk_Statistics_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
ALTER TABLE [DOI].[Statistics] ADD CONSTRAINT [Chk_Statistics_SampleSize_Actual] CHECK (([SampleSizePct_Actual]>=(0) AND [SampleSizePct_Actual]<=(100)))
GO
ALTER TABLE [DOI].[Statistics] ADD CONSTRAINT [Chk_Statistics_SampleSize_Desired] CHECK (([SampleSizePct_Desired]>=(0) AND [SampleSizePct_Desired]<=(100)))
GO
ALTER TABLE [DOI].[Statistics] ADD CONSTRAINT [FK_Statistics_Databases] FOREIGN KEY ([DatabaseName]) REFERENCES [DOI].[Databases] ([DatabaseName])
GO
ALTER TABLE [DOI].[Statistics] NOCHECK CONSTRAINT [FK_Statistics_Databases]
GO
