
CREATE TABLE [DOI].[Tables]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionFunctionName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storage_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storage_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntendToPartition] [bit] NOT NULL CONSTRAINT [Def_Tables_IntendToPartition] DEFAULT ((0)),
[ReadyToQueue] [bit] NOT NULL CONSTRAINT [Def_Tables_ReadyToQueue] DEFAULT ((0)),
[AreIndexesFragmented] [bit] NOT NULL CONSTRAINT [Def_Tables_AreIndexesFragmented] DEFAULT ((0)),
[AreIndexesBeingUpdated] [bit] NOT NULL CONSTRAINT [Def_Tables_AreIndexesBeingUpdated] DEFAULT ((0)),
[AreIndexesMissing] [bit] NOT NULL CONSTRAINT [Def_Tables_AreIndexesMissing] DEFAULT ((0)),
[IsClusteredIndexBeingDropped] [bit] NOT NULL CONSTRAINT [Def_Tables_IsClusteredIndexBeingDropped] DEFAULT ((0)),
[WhichUniqueConstraintIsBeingDropped] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_Tables_WhichUniqueConstraintIsBeingDropped] DEFAULT ('None'),
[IsStorageChanging] [bit] NOT NULL CONSTRAINT [Def_Tables_IsStorageChanging] DEFAULT ((0)),
[NeedsTransaction] [bit] NOT NULL CONSTRAINT [Def_Tables_NeedsTransaction] DEFAULT ((0)),
[AreStatisticsChanging] [bit] NOT NULL CONSTRAINT [Def_Tables_AreStatisticsChanging] DEFAULT ((0)),
[DSTriggerSQL] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PKColumnList] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PKColumnListJoinClause] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColumnListNoTypes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColumnListWithTypes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateColumnList] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewPartitionedPrepTableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_Tables] PRIMARY KEY NONCLUSTERED ([DatabaseName], [SchemaName], [TableName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DOI].[Tables] ADD CONSTRAINT [Chk_Tables_PartitionFunction_PartitionColumn] CHECK (([PartitionFunctionName] IS NULL AND [PartitionColumn] IS NULL OR [PartitionFunctionName] IS NOT NULL AND [PartitionColumn] IS NOT NULL))
GO
ALTER TABLE [DOI].[Tables] ADD CONSTRAINT [Chk_Tables_PartitioningSetup] CHECK (([IntendToPartition]=(1) AND [PartitionColumn] IS NOT NULL OR [IntendToPartition]=(0) AND [PartitionColumn] IS NULL))
GO
ALTER TABLE [DOI].[Tables] ADD CONSTRAINT [FK_Tables_Databases] FOREIGN KEY ([DatabaseName]) REFERENCES [DOI].[Databases] ([DatabaseName])
GO
ALTER TABLE [DOI].[Tables] NOCHECK CONSTRAINT [FK_Tables_Databases]
GO
