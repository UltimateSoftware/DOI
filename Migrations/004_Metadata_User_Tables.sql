-- <Migration ID="18878c81-4559-467b-9b75-11e9da703880" TransactionHandling="Custom" />
IF OBJECT_ID('[DOI].[Databases]') IS NULL
CREATE TABLE [DOI].[Databases]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CONSTRAINT [PK_Databases] PRIMARY KEY NONCLUSTERED  ([DatabaseName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DOI].[PartitionFunctions]') IS NULL
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
IF OBJECT_ID('[DOI].[Chk_PartitionFunctions_BoundaryInterval]') IS NULL
ALTER TABLE [DOI].[PartitionFunctions] ADD CONSTRAINT [Chk_PartitionFunctions_BoundaryInterval] CHECK (([BoundaryInterval]='Monthly' OR [BoundaryInterval]='Yearly'))
GO
IF OBJECT_ID('[DOI].[Chk_PartitionFunctions_SlidingWindow]') IS NULL
ALTER TABLE [DOI].[PartitionFunctions] ADD CONSTRAINT [Chk_PartitionFunctions_SlidingWindow] CHECK (([UsesSlidingWindow]=(1) AND [SlidingWindowSize] IS NOT NULL OR [UsesSlidingWindow]=(0) AND [SlidingWindowSize] IS NULL))
GO
IF OBJECT_ID('[DOI].[FK_PartitionFunctions_Databases]') IS NULL
ALTER TABLE [DOI].[PartitionFunctions] ADD CONSTRAINT [FK_PartitionFunctions_Databases] FOREIGN KEY ([DatabaseName]) REFERENCES [DOI].[Databases] ([DatabaseName])
GO
IF OBJECT_ID('[DOI].[FK_PartitionFunctions_Databases]') IS NOT NULL
ALTER TABLE [DOI].[PartitionFunctions] NOCHECK CONSTRAINT [FK_PartitionFunctions_Databases]
GO
IF OBJECT_ID('[DOI].[Tables]') IS NULL
CREATE TABLE [DOI].[Tables]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
[PartitionFunctionName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_Tables] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DOI].[Chk_Tables_PartitioningSetup]') IS NULL
ALTER TABLE [DOI].[Tables] ADD CONSTRAINT [Chk_Tables_PartitioningSetup] CHECK (([IntendToPartition]=(1) AND [PartitionColumn] IS NOT NULL OR [IntendToPartition]=(0) AND [PartitionColumn] IS NULL))
GO
IF OBJECT_ID('[DOI].[FK_Tables_Databases]') IS NULL
ALTER TABLE [DOI].[Tables] ADD CONSTRAINT [FK_Tables_Databases] FOREIGN KEY ([DatabaseName]) REFERENCES [DOI].[Databases] ([DatabaseName])
GO
IF OBJECT_ID('[DOI].[FK_Tables_Databases]') IS NOT NULL
ALTER TABLE [DOI].[Tables] NOCHECK CONSTRAINT [FK_Tables_Databases]
GO

IF OBJECT_ID('[DOI].[CheckConstraints]') IS NULL
CREATE TABLE [DOI].[CheckConstraints]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDisabled] [bit] NOT NULL,
[CheckConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CONSTRAINT [PK_CheckConstraints] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [CheckConstraintName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DOI].[FK_CheckConstraints_Tables]') IS NULL
ALTER TABLE [DOI].[CheckConstraints] ADD CONSTRAINT [FK_CheckConstraints_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DOI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
IF OBJECT_ID('[DOI].[FK_CheckConstraints_Tables]') IS NOT NULL
ALTER TABLE [DOI].[CheckConstraints] NOCHECK CONSTRAINT [FK_CheckConstraints_Tables]
GO
IF OBJECT_ID('[DOI].[DefaultConstraints]') IS NULL
CREATE TABLE [DOI].[DefaultConstraints]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_DefaultConstraints] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DOI].[FK_DefaultConstraints_Tables]') IS NULL
ALTER TABLE [DOI].[DefaultConstraints] ADD CONSTRAINT [FK_DefaultConstraints_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DOI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
IF OBJECT_ID('[DOI].[FK_DefaultConstraints_Tables]') IS NOT NULL
ALTER TABLE [DOI].[DefaultConstraints] NOCHECK CONSTRAINT [FK_DefaultConstraints_Tables]
GO
IF OBJECT_ID('[DOI].[ForeignKeys]') IS NULL
CREATE TABLE [DOI].[ForeignKeys]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[ParentSchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[FKName] [sys].[sysname] NOT NULL,
[ParentColumnList_Desired] [varchar] (MAX) NOT NULL,
[ReferencedSchemaName] [sys].[sysname] NOT NULL,
[ReferencedTableName] [sys].[sysname] NOT NULL,
[ReferencedColumnList_Desired] [varchar] (MAX) NOT NULL,
[ParentColumnList_Actual] [varchar] (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferencedColumnList_Actual] [varchar] (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeploymentTime] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_ForeignKeys] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [ParentSchemaName], [ParentTableName], [FKName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DOI].[FK_ForeignKeys_ParentTables]') IS NULL
ALTER TABLE [DOI].[ForeignKeys] ADD CONSTRAINT [FK_ForeignKeys_ParentTables] FOREIGN KEY ([DatabaseName], [ParentSchemaName], [ParentTableName]) REFERENCES [DOI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
IF OBJECT_ID('[DOI].[FK_ForeignKeys_ReferencedTables]') IS NULL
ALTER TABLE [DOI].[ForeignKeys] ADD CONSTRAINT [FK_ForeignKeys_ReferencedTables] FOREIGN KEY ([DatabaseName], [ReferencedSchemaName], [ReferencedTableName]) REFERENCES [DOI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
IF OBJECT_ID('[DOI].[FK_ForeignKeys_ParentTables]') IS NOT NULL
ALTER TABLE [DOI].[ForeignKeys] NOCHECK CONSTRAINT [FK_ForeignKeys_ParentTables]
GO
IF OBJECT_ID('[DOI].[FK_ForeignKeys_ReferencedTables]') IS NOT NULL
ALTER TABLE [DOI].[ForeignKeys] NOCHECK CONSTRAINT [FK_ForeignKeys_ReferencedTables]
GO
IF OBJECT_ID('[DOI].[IndexesColumnStore]') IS NULL
CREATE TABLE [DOI].[IndexesColumnStore]
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
IF OBJECT_ID('[DOI].[Chk_IndexesColumnStore_AreReorgOptionsChanging]') IS NULL
ALTER TABLE [DOI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_AreReorgOptionsChanging] CHECK (([AreReorgOptionsChanging]=(0)))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesColumnStore_AreSetOptionsChanging]') IS NULL
ALTER TABLE [DOI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_AreSetOptionsChanging] CHECK (([AreSetOptionsChanging]=(0)))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesColumnStore_Filter]') IS NULL
ALTER TABLE [DOI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL AND [IsClustered_Desired]=(0) OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesColumnStore_FragmentationType]') IS NULL
ALTER TABLE [DOI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_FragmentationType] CHECK (([FragmentationType]='Heavy' OR [FragmentationType]='Light' OR [FragmentationType]='None'))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesColumnStore_OptionDataCompression]') IS NULL
ALTER TABLE [DOI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_OptionDataCompression] CHECK (([OptionDataCompression_Desired]='COLUMNSTORE_ARCHIVE' OR [OptionDataCompression_Desired]='COLUMNSTORE'))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesColumnStore_ClusteredColumnListIsNull]') IS NULL
ALTER TABLE [DOI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_ClusteredColumnListIsNull] CHECK (([IsClustered_Desired]=1 AND [ColumnList_Desired] IS NULL) OR ([IsClustered_Desired]=0))
GO
IF OBJECT_ID('[DOI].[Def_IndexesColumnStore_StorageType_Actual]') IS NULL
ALTER TABLE [DOI].[IndexesColumnStore] ADD CONSTRAINT [Def_IndexesColumnStore_StorageType_Actual] CHECK (([StorageType_Actual]='PARTITION_SCHEME' OR [StorageType_Actual]='ROWS_FILEGROUP'))
GO
IF OBJECT_ID('[DOI].[Def_IndexesColumnStore_StorageType_Desired]') IS NULL
ALTER TABLE [DOI].[IndexesColumnStore] ADD CONSTRAINT [Def_IndexesColumnStore_StorageType_Desired] CHECK (([StorageType_Desired]='PARTITION_SCHEME' OR [StorageType_Desired]='ROWS_FILEGROUP'))
GO
IF OBJECT_ID('[DOI].[FK_IndexesColumnStore_Tables]') IS NULL
ALTER TABLE [DOI].[IndexesColumnStore] ADD CONSTRAINT [FK_IndexesColumnStore_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DOI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
IF OBJECT_ID('[DOI].[FK_IndexesColumnStore_Tables]') IS NOT NULL
ALTER TABLE [DOI].[IndexesColumnStore] NOCHECK CONSTRAINT [FK_IndexesColumnStore_Tables]
GO


IF OBJECT_ID('[DOI].[IndexesRowStore]') IS NULL
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
[IndexSizeMB_Actual_Estimated] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexesRowStore_IndexSizeMB_Actual_Estimated] DEFAULT ((0)),
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
IF OBJECT_ID('[DOI].[Chk_IndexesRowStore_Filter]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL AND [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0) AND [IsClustered_Desired]=(0) AND [OptionStatisticsIncremental_Desired]=(0) OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesRowStore_FragmentationType]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_FragmentationType] CHECK (([FragmentationType]='Heavy' OR [FragmentationType]='Light' OR [FragmentationType]='None'))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesRowStore_IncludedColumnsNotAllowed]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_IncludedColumnsNotAllowed] CHECK ((([IncludedColumnList_Desired] IS NOT NULL AND [IsClustered_Desired]=(0) AND [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0)) OR [IncludedColumnList_Desired] IS NULL))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesRowStore_IsUniqueConstraint_Desired]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_IsUniqueConstraint_Desired] CHECK (([IsUniqueConstraint_Desired]=(0)))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesRowStore_OptionDataCompression_Desired]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_OptionDataCompression_Desired] CHECK (([OptionDataCompression_Desired]='PAGE' OR [OptionDataCompression_Desired]='ROW' OR [OptionDataCompression_Desired]='NONE'))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesRowStore_PKvsUQ]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_PKvsUQ] CHECK (([IsPrimaryKey_Desired]=(1) AND [IsUniqueConstraint_Desired]=(0) OR [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(1) OR [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0)))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesRowStore_PrimaryKeyIsUnique]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_PrimaryKeyIsUnique] CHECK ((([IsPrimaryKey_Desired]=(1) AND [IsUnique_Desired]=(1)) OR [IsPrimaryKey_Desired]=(0)))
GO
IF OBJECT_ID('[DOI].[Chk_IndexesRowStore_UniqueConstraintIsUnique]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_UniqueConstraintIsUnique] CHECK ((([IsUniqueConstraint_Desired]=(1) AND [IsUnique_Desired]=(1)) OR [IsUniqueConstraint_Desired]=(0)))
GO
IF OBJECT_ID('[DOI].[Chk_Indexes_FillFactor_Desired]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Chk_Indexes_FillFactor_Desired] CHECK (([Fillfactor_Desired]>=(0) AND [Fillfactor_Desired]<=(100)))
GO
IF OBJECT_ID('[DOI].[Def_IndexesRowStore_StorageType_Actual]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Def_IndexesRowStore_StorageType_Actual] CHECK (([StorageType_Actual]='PARTITION_SCHEME' OR [StorageType_Actual]='ROWS_FILEGROUP'))
GO
IF OBJECT_ID('[DOI].[Def_IndexesRowStore_StorageType_Desired]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [Def_IndexesRowStore_StorageType_Desired] CHECK (([StorageType_Desired]='PARTITION_SCHEME' OR [StorageType_Desired]='ROWS_FILEGROUP'))
GO
IF OBJECT_ID('[DOI].[FK_IndexesRowStore_Tables]') IS NULL
ALTER TABLE [DOI].[IndexesRowStore] ADD CONSTRAINT [FK_IndexesRowStore_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DOI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
IF OBJECT_ID('[DOI].[FK_IndexesRowStore_Tables]') IS NOT NULL
ALTER TABLE [DOI].[IndexesRowStore] NOCHECK CONSTRAINT [FK_IndexesRowStore_Tables]
GO
IF OBJECT_ID('[DOI].[IndexPartitionsColumnStore]') IS NULL
CREATE TABLE [DOI].[IndexPartitionsColumnStore]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionDataCompression] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_OptionDataCompression] DEFAULT ('COLUMNSTORE'),
CONSTRAINT [PK_IndexPartitionsColumnStore] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DOI].[Chk_IndexPartitionsColumnStore_OptionDataCompression]') IS NULL
ALTER TABLE [DOI].[IndexPartitionsColumnStore] ADD CONSTRAINT [Chk_IndexPartitionsColumnStore_OptionDataCompression] CHECK (([OptionDataCompression]='COLUMNSTORE_ARCHIVE' OR [OptionDataCompression]='COLUMNSTORE'))
GO
IF OBJECT_ID('[DOI].[FK_IndexPartitionsColumnStore_IndexesColumnStore]') IS NULL
ALTER TABLE [DOI].[IndexPartitionsColumnStore] ADD CONSTRAINT [FK_IndexPartitionsColumnStore_IndexesColumnStore] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName], [IndexName]) REFERENCES [DOI].[IndexesColumnStore] ([DatabaseName], [SchemaName], [TableName], [IndexName])
GO
IF OBJECT_ID('[DOI].[FK_IndexPartitionsColumnStore_IndexesColumnStore]') IS NOT NULL
ALTER TABLE [DOI].[IndexPartitionsColumnStore] NOCHECK CONSTRAINT [FK_IndexPartitionsColumnStore_IndexesColumnStore]
GO
IF OBJECT_ID('[DOI].[IndexPartitionsRowStore]') IS NULL
CREATE TABLE [DOI].[IndexPartitionsRowStore]
(
[DatabaseName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [SMALLINT] NOT NULL,
[OptionResumable] [BIT] NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_OptionResumable] DEFAULT ((0)),
[OptionMaxDuration] [SMALLINT] NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_OptionMaxDuration] DEFAULT ((0)),
[OptionDataCompression] [NVARCHAR] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_OptionDataCompression] DEFAULT ('PAGE'),
[NumRows] [BIGINT] NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_NumRows] DEFAULT ((0)),
[TotalPages] [BIGINT] NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_TotalPages] DEFAULT ((0)),
[PartitionType] [VARCHAR] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_PartitionType] DEFAULT ('RowStore'),
[TotalIndexPartitionSizeInMB] [DECIMAL] (10, 2) NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_TotalIndexPartitionSizeInMB] DEFAULT ((0.00)),
[Fragmentation] [FLOAT] NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_Fragmentation] DEFAULT ((0)),
[DataFileName] [NVARCHAR] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_DataFileName] DEFAULT (''),
[DriveLetter] [CHAR] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_DriveLetter] DEFAULT (''),
[PartitionUpdateType] [VARCHAR] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_PartitionUpdateType] DEFAULT ('None'),
CONSTRAINT [PK_IndexPartitionsRowStore] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DOI].[Chk_IndexPartitionsRowStore_OptionDataCompression]') IS NULL
ALTER TABLE [DOI].[IndexPartitionsRowStore] ADD CONSTRAINT [Chk_IndexPartitionsRowStore_OptionDataCompression] CHECK (([OptionDataCompression]='PAGE' OR [OptionDataCompression]='ROW' OR [OptionDataCompression]='NONE'))
GO
IF OBJECT_ID('[DOI].[Chk_IndexPartitionsRowStore_PartitionType]') IS NULL
ALTER TABLE [DOI].[IndexPartitionsRowStore] ADD CONSTRAINT [Chk_IndexPartitionsRowStore_PartitionType] CHECK (([PartitionType]='RowStore'))
GO
IF OBJECT_ID('[DOI].[FK_IndexPartitionsRowStore_IndexesRowStore]') IS NULL
ALTER TABLE [DOI].[IndexPartitionsRowStore] ADD CONSTRAINT [FK_IndexPartitionsRowStore_IndexesRowStore] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName], [IndexName]) REFERENCES [DOI].[IndexesRowStore] ([DatabaseName], [SchemaName], [TableName], [IndexName])
GO
IF OBJECT_ID('[DOI].[FK_IndexPartitionsRowStore_IndexesRowStore]') IS NOT NULL
ALTER TABLE [DOI].[IndexPartitionsRowStore] NOCHECK CONSTRAINT [FK_IndexPartitionsRowStore_IndexesRowStore]
GO
IF OBJECT_ID('[DOI].[Statistics]') IS NULL
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
IF OBJECT_ID('[DOI].[Chk_Statistics_Filter]','C') IS NULL
ALTER TABLE [DOI].[Statistics] ADD CONSTRAINT [Chk_Statistics_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
IF OBJECT_ID('[DOI].[Chk_Statistics_SampleSize_Actual]','C') IS NULL
ALTER TABLE [DOI].[Statistics] ADD CONSTRAINT [Chk_Statistics_SampleSize_Actual] CHECK (([SampleSizePct_Actual]>=(0) AND [SampleSizePct_Actual]<=(100)))
GO
IF OBJECT_ID('[DOI].[Chk_Statistics_SampleSize_Desired]','C') IS NULL
ALTER TABLE [DOI].[Statistics] ADD CONSTRAINT [Chk_Statistics_SampleSize_Desired] CHECK (([SampleSizePct_Desired]>=(0) AND [SampleSizePct_Desired]<=(100)))
GO
IF OBJECT_ID('[DOI].[FK_Statistics_Databases]','F') IS NULL
ALTER TABLE [DOI].[Statistics] ADD CONSTRAINT [FK_Statistics_Databases] FOREIGN KEY ([DatabaseName]) REFERENCES [DOI].[Databases] ([DatabaseName])
GO
IF OBJECT_ID('[DOI].[FK_Statistics_Databases]','F') IS NOT NULL
ALTER TABLE [DOI].[Statistics] NOCHECK CONSTRAINT [FK_Statistics_Databases]
GO
IF OBJECT_ID('[DOI].[IndexColumns]') IS NULL
CREATE TABLE [DOI].[IndexColumns]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[TableName] [sys].[sysname] NOT NULL,
[IndexName] [sys].[sysname] NOT NULL,
[ColumnName] [sys].[sysname] NOT NULL,
[IsKeyColumn] [bit] NOT NULL,
[KeyColumnPosition] [smallint] NULL,
[IsIncludedColumn] [bit] NOT NULL,
[IncludedColumnPosition] [smallint] NULL,
[IsFixedSize] [bit] NOT NULL CONSTRAINT [Def_IndexColumns_IsFixedSize] DEFAULT ((0)),
[ColumnSize] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexColumns_ColumnSize] DEFAULT ((0)),
CONSTRAINT [PK_IndexColumns] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO