USE [$(DatabaseName2)]
GO

CREATE TABLE [DOI].[PartitionFunctions]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[PartitionFunctionName] [sys].[sysname] NOT NULL,
[PartitionFunctionDataType] [sys].[sysname] NOT NULL,
[BoundaryInterval] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NumOfFutureIntervals] [tinyint] NOT NULL,
[InitialDate] [date] NOT NULL,
[UsesSlidingWindow] [bit] NOT NULL,
[SlidingWindowSize] [smallint] NULL,
[IsDeprecated] [bit] NOT NULL,
[PartitionSchemeName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumOfCharsInSuffix] [tinyint] NULL,
[LastBoundaryDate] [date] NULL,
[NumOfTotalPartitionFunctionIntervals] [smallint] NULL,
[NumOfTotalPartitionSchemeIntervals] [smallint] NULL,
[MinValueOfDataType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_PartitionFunctions] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [PartitionFunctionName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DOI].[PartitionFunctions] ADD CONSTRAINT [Chk_PartitionFunctions_BoundaryInterval] CHECK (([BoundaryInterval]='Monthly' OR [BoundaryInterval]='Yearly'))
GO
ALTER TABLE [DOI].[PartitionFunctions] ADD CONSTRAINT [Chk_PartitionFunctions_SlidingWindow] CHECK (([UsesSlidingWindow]=(1) AND [SlidingWindowSize] IS NOT NULL OR [UsesSlidingWindow]=(0) AND [SlidingWindowSize] IS NULL))
GO
ALTER TABLE [DOI].[PartitionFunctions] ADD CONSTRAINT [FK_PartitionFunctions_Databases] FOREIGN KEY ([DatabaseName]) REFERENCES [DOI].[Databases] ([DatabaseName])
GO
ALTER TABLE [DOI].[PartitionFunctions] NOCHECK CONSTRAINT [FK_PartitionFunctions_Databases]
GO
