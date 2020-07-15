USE [$(DatabaseName2)]
GO

CREATE TABLE [DOI].[IndexesRowStore]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsIndexMissingFromSQLServer] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsIndexMissingFromSQLServer] DEFAULT ((0)),
[IsUnique_Desired] [bit] NOT NULL,
[IsUnique_Actual] [bit] NULL,
[IsPrimaryKey_Desired] [bit] NOT NULL,
[IsPrimaryKey_Actual] [bit] NULL,
[IsUniqueConstraint_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsUniqueConstraint_Desired] DEFAULT ((0)),
[IsUniqueConstraint_Actual] [bit] NULL,
[IsClustered_Desired] [bit] NOT NULL,
[IsClustered_Actual] [bit] NULL,
[KeyColumnList_Desired] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KeyColumnList_Actual] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludedColumnList_Desired] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludedColumnList_Actual] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsFiltered_Desired] [bit] NOT NULL,
[IsFiltered_Actual] [bit] NULL,
[FilterPredicate_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterPredicate_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fillfactor_Desired] [tinyint] NOT NULL CONSTRAINT [Def_Indexes_FillFactor_Desired] DEFAULT ((90)),
[Fillfactor_Actual] [tinyint] NULL,
[OptionPadIndex_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionPadIndex_Desired] DEFAULT ((1)),
[OptionPadIndex_Actual] [bit] NULL,
[OptionStatisticsNoRecompute_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionStatisticsNoRecompute_Desired] DEFAULT ((0)),
[OptionStatisticsNoRecompute_Actual] [bit] NULL,
[OptionStatisticsIncremental_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionStatisticsIncremental_Desired] DEFAULT ((0)),
[OptionStatisticsIncremental_Actual] [bit] NULL,
[OptionIgnoreDupKey_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionIgnoreDupKey_Desired] DEFAULT ((0)),
[OptionIgnoreDupKey_Actual] [bit] NULL,
[OptionResumable_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionResumable_Desired] DEFAULT ((0)),
[OptionResumable_Actual] [bit] NULL,
[OptionMaxDuration_Desired] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionMaxDuration_Desired] DEFAULT ((0)),
[OptionMaxDuration_Actual] [smallint] NULL,
[OptionAllowRowLocks_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionAllowRowLocks_Desired] DEFAULT ((1)),
[OptionAllowRowLocks_Actual] [bit] NULL,
[OptionAllowPageLocks_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionAllowPageLocks_Desired] DEFAULT ((1)),
[OptionAllowPageLocks_Actual] [bit] NULL,
[OptionDataCompression_Desired] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionDataCompression_Desired] DEFAULT ('PAGE'),
[OptionDataCompression_Actual] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionDataCompressionDelay_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionDataCompressionDelay_Desired] DEFAULT ((0)),
[OptionDataCompressionDelay_Actual] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionDataCompressionDelay_Actual] DEFAULT ((0)),
[Storage_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storage_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Desired] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Actual] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionFunction_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionFunction_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionColumn_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionColumn_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumRows_Actual] [bigint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumRows_Actual] DEFAULT ((0)),
[AllColsInTableSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_AllColsInTableSize_Estimated] DEFAULT ((0)),
[NumFixedKeyCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumFixedKeyCols_Estimated] DEFAULT ((0)),
[NumVarKeyCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumVarKeyCols_Estimated] DEFAULT ((0)),
[NumKeyCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumKeyCols_Estimated] DEFAULT ((0)),
[NumFixedInclCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumFixedInclCols_Estimated] DEFAULT ((0)),
[NumVarInclCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumVarInclCols_Estimated] DEFAULT ((0)),
[NumInclCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumInclCols_Estimated] DEFAULT ((0)),
[NumFixedCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumFixedCols_Estimated] DEFAULT ((0)),
[NumVarCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumVarCols_Estimated] DEFAULT ((0)),
[NumCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumCols_Estimated] DEFAULT ((0)),
[FixedKeyColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_FixedKeyColsSize_Estimated] DEFAULT ((0)),
[VarKeyColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_VarKeyColsSize_Estimated] DEFAULT ((0)),
[KeyColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_KeyColsSize_Estimated] DEFAULT ((0)),
[FixedInclColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_FixedInclColsSize_Estimated] DEFAULT ((0)),
[VarInclColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_VarInclColsSize_Estimated] DEFAULT ((0)),
[InclColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_InclColsSize_Estimated] DEFAULT ((0)),
[FixedColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_FixedColsSize_Estimated] DEFAULT ((0)),
[VarColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_VarColsSize_Estimated] DEFAULT ((0)),
[ColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_ColsSize_Estimated] DEFAULT ((0)),
[PKColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_PKColsSize_Estimated] DEFAULT ((0)),
[NullBitmap_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NullBitmap_Estimated] DEFAULT ((0)),
[Uniqueifier_Estimated] [tinyint] NOT NULL CONSTRAINT [Def_IndexesRowStore_Uniqueifier_Estimated] DEFAULT ((0)),
[TotalRowSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_TotalRowSize_Estimated] DEFAULT ((0)),
[NonClusteredIndexRowLocator_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NonClusteredIndexRowLocator_Estimated] DEFAULT ((0)),
[NumRowsPerPage_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumRowsPerPage_Estimated] DEFAULT ((0)),
[NumFreeRowsPerPage_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumFreeRowsPerPage_Estimated] DEFAULT ((0)),
[NumLeafPages_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumLeafPages_Estimated] DEFAULT ((0)),
[LeafSpaceUsed_Estimated] [decimal] (18, 2) NOT NULL CONSTRAINT [Def_IndexesRowStore_LeafSpaceUsed_Estimated] DEFAULT ((0)),
[LeafSpaceUsedMB_Estimated] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexesRowStore_LeafSpaceUsedMB_Estimated] DEFAULT ((0)),
[NumNonLeafLevelsInIndex_Estimated] [tinyint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumNonLeafLevelsInIndex_Estimated] DEFAULT ((0)),
[NumIndexPages_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumIndexPages_Estimated] DEFAULT ((0)),
[IndexSizeMB_Estimated] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexesRowStore_IndexSizeMB_Estimated] DEFAULT ((0)),
[IndexSizeMB_Actual] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexesRowStore_IndexSizeMB_Actual] DEFAULT ((0)),
[DriveLetter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsIndexLarge] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsIndexLarge] DEFAULT ((0)),
[IndexMeetsMinimumSize] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IndexMeetsMinimumSize] DEFAULT ((0)),
[Fragmentation] [float] NOT NULL CONSTRAINT [Def_IndexesRowStore_Fragmentation] DEFAULT ((0)),
[FragmentationType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexesRowStore_FragmentationType] DEFAULT ('None'),
[AreDropRecreateOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_AreDropRecreateOptionsChanging] DEFAULT ((0)),
[AreRebuildOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_AreRebuildOptionsChanging] DEFAULT ((0)),
[AreRebuildOnlyOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_AreRebuildOnlyOptionsChanging] DEFAULT ((0)),
[AreReorgOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_AreReorgOptionsChanging] DEFAULT ((0)),
[AreSetOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_AreSetOptionsChanging] DEFAULT ((0)),
[IsUniquenessChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsUniquenessChanging] DEFAULT ((0)),
[IsPrimaryKeyChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsPrimaryKeyChanging] DEFAULT ((0)),
[IsKeyColumnListChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsKeyColumnListChanging] DEFAULT ((0)),
[IsIncludedColumnListChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsIncludedColumnListChanging] DEFAULT ((0)),
[IsFilterChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsFilterChanging] DEFAULT ((0)),
[IsClusteredChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsClusteredChanging] DEFAULT ((0)),
[IsPartitioningChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsPartitioningChanging] DEFAULT ((0)),
[IsPadIndexChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsPadIndexChanging] DEFAULT ((0)),
[IsFillfactorChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsFillfactorChanging] DEFAULT ((0)),
[IsIgnoreDupKeyChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsIgnoreDupKeyChanging] DEFAULT ((0)),
[IsStatisticsNoRecomputeChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsStatisticsNoRecomputeChanging] DEFAULT ((0)),
[IsStatisticsIncrementalChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsStatisticsIncrementalChanging] DEFAULT ((0)),
[IsAllowRowLocksChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsAllowRowLocksChanging] DEFAULT ((0)),
[IsAllowPageLocksChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsAllowPageLocksChanging] DEFAULT ((0)),
[IsDataCompressionChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsDataCompressionChanging] DEFAULT ((0)),
[IsDataCompressionDelayChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsDataCompressionDelayChanging] DEFAULT ((0)),
[IsStorageChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsStorageChanging] DEFAULT ((0)),
[IndexHasLOBColumns] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IndexHasLOBColumns] DEFAULT ((0)),
[NumPages_Actual] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumPages_Actual] DEFAULT ((0)),
[TotalPartitionsInIndex] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_TotalPartitionsInIndex] DEFAULT ((0)),
[NeedsPartitionLevelOperations] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_NeedsPartitionLevelOperations] DEFAULT ((0)),
CONSTRAINT [PK_IndexesRowStore] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName]),
INDEX [IDX_IndexesRowStore_IndexName] NONCLUSTERED ([IndexName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL AND [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0) AND [IsClustered_Desired]=(0) AND [OptionStatisticsIncremental_Desired]=(0) OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_FragmentationType] CHECK (([FragmentationType]='Heavy' OR [FragmentationType]='Light' OR [FragmentationType]='None'))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_IncludedColumnsNotAllowed] CHECK ((([IncludedColumnList_Desired] IS NOT NULL AND [IsClustered_Desired]=(0) AND [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0)) OR [IncludedColumnList_Desired] IS NULL))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_IsUniqueConstraint_Desired] CHECK (([IsUniqueConstraint_Desired]=(0)))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_OptionDataCompressionDelay_Actual] CHECK (([OptionDataCompressionDelay_Actual]=(0)))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_OptionDataCompressionDelay_Desired] CHECK (([OptionDataCompressionDelay_Desired]=(0)))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_OptionDataCompression_Desired] CHECK (([OptionDataCompression_Desired]='PAGE' OR [OptionDataCompression_Desired]='ROW' OR [OptionDataCompression_Desired]='NONE'))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_PKvsUQ] CHECK (([IsPrimaryKey_Desired]=(1) AND [IsUniqueConstraint_Desired]=(0) OR [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(1) OR [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0)))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_PrimaryKeyIsUnique] CHECK ((([IsPrimaryKey_Desired]=(1) AND [IsUnique_Desired]=(1)) OR [IsPrimaryKey_Desired]=(0)))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_UniqueConstraintIsUnique] CHECK ((([IsUniqueConstraint_Desired]=(1) AND [IsUnique_Desired]=(1)) OR [IsUniqueConstraint_Desired]=(0)))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_Indexes_FillFactor_Desired] CHECK (([Fillfactor_Desired]>=(0) AND [Fillfactor_Desired]<=(100)))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Def_IndexesRowStore_StorageType_Actual] CHECK (([StorageType_Actual]='PARTITION_SCHEME' OR [StorageType_Actual]='ROWS_FILEGROUP'))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Def_IndexesRowStore_StorageType_Desired] CHECK (([StorageType_Desired]='PARTITION_SCHEME' OR [StorageType_Desired]='ROWS_FILEGROUP'))
GO
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [FK_IndexesRowStore_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DOI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
ALTER TABLE [DOI].[IndexesRowStore] NOCHECK CONSTRAINT [FK_IndexesRowStore_Tables]
GO
