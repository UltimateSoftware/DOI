CREATE TABLE [DDI].[IndexesColumnStore]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsIndexMissingFromSQLServer] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsIndexMissingFromSQLServer] DEFAULT ((0)),
[IsClustered_Desired] [bit] NOT NULL,
[IsClustered_Actual] [bit] NULL,
[ColumnList_Desired] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColumnList_Actual] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsFiltered_Desired] [bit] NOT NULL,
[IsFiltered_Actual] [bit] NULL,
[FilterPredicate_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterPredicate_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionDataCompression_Desired] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexesColumnStore_OptionDataCompression] DEFAULT ('COLUMNSTORE'),
[OptionDataCompression_Actual] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionDataCompressionDelay_Desired] [int] NOT NULL,
[OptionDataCompressionDelay_Actual] [int] NULL,
[Storage_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storage_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Desired] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Actual] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionFunction_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionFunction_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionColumn_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionColumn_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllColsInTableSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AllColsInTableSize_Estimated] DEFAULT ((0)),
[NumFixedCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesColumnStore_NumFixedCols_Estimated] DEFAULT ((0)),
[NumVarCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesColumnStore_NumVarCols_Estimated] DEFAULT ((0)),
[NumCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesColumnStore_NumCols_Estimated] DEFAULT ((0)),
[FixedColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesColumnStore_FixedColsSize_Estimated] DEFAULT ((0)),
[VarColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesColumnStore_VarColsSize_Estimated] DEFAULT ((0)),
[ColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesColumnStore_ColsSize_Estimated] DEFAULT ((0)),
[NumRows_Actual] [bigint] NOT NULL CONSTRAINT [Def_IndexesColumnStore_NumRows_Actual] DEFAULT ((0)),
[IndexSizeMB_Actual] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexesColumnStore_IndexSizeMB_Actual] DEFAULT ((0)),
[DriveLetter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsIndexLarge] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsIndexLarge] DEFAULT ((0)),
[IndexMeetsMinimumSize] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IndexMeetsMinimumSize] DEFAULT ((0)),
[Fragmentation] [float] NOT NULL CONSTRAINT [Def_IndexesColumnStore_Fragmentation] DEFAULT ((0)),
[FragmentationType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexesColumnStore_FragmentationType] DEFAULT ('None'),
[AreDropRecreateOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AreDropRecreateOptionsChanging] DEFAULT ((0)),
[AreRebuildOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AreRebuildOptionsChanging] DEFAULT ((0)),
[AreRebuildOnlyOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AreRebuildOnlyOptionsChanging] DEFAULT ((0)),
[AreReorgOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AreReorgOptionsChanging] DEFAULT ((0)),
[AreSetOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AreSetOptionsChanging] DEFAULT ((0)),
[IsColumnListChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsColumnListChanging] DEFAULT ((0)),
[IsFilterChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsFilterChanging] DEFAULT ((0)),
[IsClusteredChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsClusteredChanging] DEFAULT ((0)),
[IsPartitioningChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsPartitioningChanging] DEFAULT ((0)),
[IsDataCompressionChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsDataCompressionChanging] DEFAULT ((0)),
[IsDataCompressionDelayChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsDataCompressionDelayChanging] DEFAULT ((0)),
[IsStorageChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsStorageChanging] DEFAULT ((0)),
[NumPages_Actual] [int] NULL CONSTRAINT [Def_IndexesColumnStore_NumPages_Actual] DEFAULT ((0)),
[TotalPartitionsInIndex] [int] NOT NULL CONSTRAINT [Def_IndexesColumnStore_TotalPartitionsInIndex] DEFAULT ((0)),
[NeedsPartitionLevelOperations] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_NeedsPartitionLevelOperations] DEFAULT ((0)),
CONSTRAINT [PK_IndexesColumnStore] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_AreReorgOptionsChanging] CHECK (([AreReorgOptionsChanging]=(0)))
GO
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_AreSetOptionsChanging] CHECK (([AreSetOptionsChanging]=(0)))
GO
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL AND [IsClustered_Desired]=(0) OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_FragmentationType] CHECK (([FragmentationType]='Heavy' OR [FragmentationType]='Light' OR [FragmentationType]='None'))
GO
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_OptionDataCompression] CHECK (([OptionDataCompression_Desired]='COLUMNSTORE_ARCHIVE' OR [OptionDataCompression_Desired]='COLUMNSTORE'))
GO
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Def_IndexesColumnStore_StorageType_Actual] CHECK (([StorageType_Actual]='PARTITION_SCHEME' OR [StorageType_Actual]='ROWS_FILEGROUP'))
GO
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Def_IndexesColumnStore_StorageType_Desired] CHECK (([StorageType_Desired]='PARTITION_SCHEME' OR [StorageType_Desired]='ROWS_FILEGROUP'))
GO
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [FK_IndexesColumnStore_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
ALTER TABLE [DDI].[IndexesColumnStore] NOCHECK CONSTRAINT [FK_IndexesColumnStore_Tables]
GO
