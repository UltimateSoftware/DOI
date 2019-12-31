-- <Migration ID="977c1196-ca02-4735-ae82-2b2417d9b560" TransactionHandling="Custom" />
GO

PRINT N'Creating schemas'
GO
IF SCHEMA_ID(N'Utility') IS NULL
EXEC sp_executesql N'CREATE SCHEMA [Utility]
AUTHORIZATION [dbo]'
GO
PRINT N'Dropping foreign keys from [DDI].[CheckConstraints]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_CheckConstraints_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[CheckConstraints]', 'U'))
ALTER TABLE [DDI].[CheckConstraints] DROP CONSTRAINT [FK_CheckConstraints_Tables]
GO
PRINT N'Dropping foreign keys from [DDI].[DefaultConstraints]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_DefaultConstraints_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[DefaultConstraints]', 'U'))
ALTER TABLE [DDI].[DefaultConstraints] DROP CONSTRAINT [FK_DefaultConstraints_Tables]
GO
PRINT N'Dropping foreign keys from [DDI].[ForeignKeys]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_ForeignKeys_ParentTables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[ForeignKeys]', 'U'))
ALTER TABLE [DDI].[ForeignKeys] DROP CONSTRAINT [FK_ForeignKeys_ParentTables]
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_ForeignKeys_ReferencedTables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[ForeignKeys]', 'U'))
ALTER TABLE [DDI].[ForeignKeys] DROP CONSTRAINT [FK_ForeignKeys_ReferencedTables]
GO
PRINT N'Dropping foreign keys from [DDI].[IndexColumnStorePartitions]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexColumnStorePartitions_IndexesColumnStore]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexColumnStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexColumnStorePartitions] DROP CONSTRAINT [FK_IndexColumnStorePartitions_IndexesColumnStore]
GO
PRINT N'Dropping foreign keys from [DDI].[IndexColumns]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexColumns_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexColumns]', 'U'))
ALTER TABLE [DDI].[IndexColumns] DROP CONSTRAINT [FK_IndexColumns_Tables]
GO
PRINT N'Dropping foreign keys from [DDI].[IndexRowStorePartitions]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexRowStorePartitions_IndexesRowStore]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] DROP CONSTRAINT [FK_IndexRowStorePartitions_IndexesRowStore]
GO
PRINT N'Dropping foreign keys from [DDI].[IndexesColumnStore]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexesColumnStore_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] DROP CONSTRAINT [FK_IndexesColumnStore_Tables]
GO
PRINT N'Dropping foreign keys from [DDI].[IndexesRowStore]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexesRowStore_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] DROP CONSTRAINT [FK_IndexesRowStore_Tables]
GO
PRINT N'Dropping foreign keys from [DDI].[Statistics]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_Statistics_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[Statistics]', 'U'))
ALTER TABLE [DDI].[Statistics] DROP CONSTRAINT [FK_Statistics_Tables]
GO
PRINT N'Dropping foreign keys from [DDI].[Tables]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_Tables_Databases]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[Tables]', 'U'))
ALTER TABLE [DDI].[Tables] DROP CONSTRAINT [FK_Tables_Databases]
GO
PRINT N'Dropping constraints from [DDI].[IndexesColumnStore]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_Filter]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] DROP CONSTRAINT [Chk_IndexesColumnStore_Filter]
GO
PRINT N'Dropping constraints from [DDI].[IndexesRowStore]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_Filter]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] DROP CONSTRAINT [Chk_IndexesRowStore_Filter]
GO
PRINT N'Dropping constraints from [DDI].[IndexesRowStore]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_IncludedColumnsNotAllowed]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] DROP CONSTRAINT [Chk_IndexesRowStore_IncludedColumnsNotAllowed]
GO
PRINT N'Dropping constraints from [DDI].[IndexesRowStore]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_PKvsUQ]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] DROP CONSTRAINT [Chk_IndexesRowStore_PKvsUQ]
GO
PRINT N'Dropping constraints from [DDI].[IndexesRowStore]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_PrimaryKeyIsUnique]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] DROP CONSTRAINT [Chk_IndexesRowStore_PrimaryKeyIsUnique]
GO
PRINT N'Dropping constraints from [DDI].[IndexesRowStore]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_UniqueConstraintIsUnique]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] DROP CONSTRAINT [Chk_IndexesRowStore_UniqueConstraintIsUnique]
GO
PRINT N'Dropping constraints from [DDI].[Statistics]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Statistics_Filter]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Statistics]', 'U'))
ALTER TABLE [DDI].[Statistics] DROP CONSTRAINT [Chk_Statistics_Filter]
GO
PRINT N'Dropping constraints from [DDI].[Tables]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Tables_PartitioningSetup]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Tables]', 'U'))
ALTER TABLE [DDI].[Tables] DROP CONSTRAINT [Chk_Tables_PartitioningSetup]
GO
PRINT N'Creating types'
GO
IF TYPE_ID(N'[DDI].[FilteredRowCountsTT]') IS NULL
CREATE TYPE [DDI].[FilteredRowCountsTT] AS TABLE
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[TableName] [sys].[sysname] NOT NULL,
[IndexName] [sys].[sysname] NOT NULL,
[NumRows] [bigint] NOT NULL,
PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF TYPE_ID(N'[DDI].[IndexColumnsTT]') IS NULL
CREATE TYPE [DDI].[IndexColumnsTT] AS TABLE
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[TableName] [sys].[sysname] NOT NULL,
[IndexName] [sys].[sysname] NOT NULL,
[KeyColumnList_Desired] [varchar] (max) NOT NULL,
[IncludedColumnList_Desired] [varchar] (max) NULL,
PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName])
)
GO
PRINT N'Rebuilding [DDI].[Tables]'
GO
CREATE TABLE [DDI].[RG_Recovery_1_Tables]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[PartitionColumn] [nvarchar] (128) NULL,
[Storage_Desired] [nvarchar] (128) NULL,
[Storage_Actual] [nvarchar] (128) NULL,
[StorageType_Desired] [nvarchar] (128) NULL,
[StorageType_Actual] [nvarchar] (128) NULL,
[IntendToPartition] [bit] NOT NULL CONSTRAINT [RG_Recovery_2_Tables] DEFAULT ((0)),
[ReadyToQueue] [bit] NOT NULL CONSTRAINT [RG_Recovery_3_Tables] DEFAULT ((0)),
[AreIndexesFragmented] [bit] NOT NULL CONSTRAINT [RG_Recovery_4_Tables] DEFAULT ((0)),
[AreIndexesBeingUpdated] [bit] NOT NULL CONSTRAINT [RG_Recovery_5_Tables] DEFAULT ((0)),
[AreIndexesMissing] [bit] NOT NULL CONSTRAINT [RG_Recovery_6_Tables] DEFAULT ((0)),
[IsClusteredIndexBeingDropped] [bit] NOT NULL CONSTRAINT [RG_Recovery_7_Tables] DEFAULT ((0)),
[WhichUniqueConstraintIsBeingDropped] [varchar] (10) NOT NULL CONSTRAINT [RG_Recovery_8_Tables] DEFAULT ('None'),
[IsStorageChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_9_Tables] DEFAULT ((0)),
[NeedsTransaction] [bit] NOT NULL CONSTRAINT [RG_Recovery_10_Tables] DEFAULT ((0)),
[AreStatisticsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_11_Tables] DEFAULT ((0)),
[DSTriggerSQL] [varchar] (max) NULL,
[PKColumnList] [varchar] (max) NULL,
[PKColumnListJoinClause] [varchar] (max) NULL,
[ColumnListNoTypes] [varchar] (max) NULL,
[ColumnListWithTypes] [varchar] (max) NULL,
[UpdateColumnList] [varchar] (max) NULL,
[NewPartitionedPrepTableName] [nvarchar] (128) NULL,
[PartitionFunctionName] [nvarchar] (128) NULL
)
GO
INSERT INTO [DDI].[RG_Recovery_1_Tables]([DatabaseName], [SchemaName], [TableName], [PartitionColumn], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [IntendToPartition], [ReadyToQueue], [AreIndexesFragmented], [AreIndexesBeingUpdated], [AreIndexesMissing], [IsClusteredIndexBeingDropped], [WhichUniqueConstraintIsBeingDropped], [IsStorageChanging], [NeedsTransaction], [AreStatisticsChanging], [DSTriggerSQL], [PKColumnList], [PKColumnListJoinClause], [ColumnListNoTypes], [ColumnListWithTypes], [UpdateColumnList], [NewPartitionedPrepTableName], [PartitionFunctionName]) SELECT [DatabaseName], [SchemaName], [TableName], [PartitionColumn], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [IntendToPartition], [ReadyToQueue], [AreIndexesFragmented], [AreIndexesBeingUpdated], [AreIndexesMissing], [IsClusteredIndexBeingDropped], [WhichUniqueConstraintIsBeingDropped], [IsStorageChanging], [NeedsTransaction], [AreStatisticsChanging], [DSTriggerSQL], [PKColumnList], [PKColumnListJoinClause], [ColumnListNoTypes], [ColumnListWithTypes], [UpdateColumnList], [NewPartitionedPrepTableName], [PartitionFunctionName] FROM [DDI].[Tables]
GO
DROP TABLE [DDI].[Tables]
GO
CREATE TABLE [DDI].[Tables]
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
INSERT INTO [DDI].[Tables]([DatabaseName], [SchemaName], [TableName], [PartitionColumn], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [IntendToPartition], [ReadyToQueue], [AreIndexesFragmented], [AreIndexesBeingUpdated], [AreIndexesMissing], [IsClusteredIndexBeingDropped], [WhichUniqueConstraintIsBeingDropped], [IsStorageChanging], [NeedsTransaction], [AreStatisticsChanging], [DSTriggerSQL], [PKColumnList], [PKColumnListJoinClause], [ColumnListNoTypes], [ColumnListWithTypes], [UpdateColumnList], [NewPartitionedPrepTableName], [PartitionFunctionName]) SELECT [DatabaseName], [SchemaName], [TableName], [PartitionColumn], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [IntendToPartition], [ReadyToQueue], [AreIndexesFragmented], [AreIndexesBeingUpdated], [AreIndexesMissing], [IsClusteredIndexBeingDropped], [WhichUniqueConstraintIsBeingDropped], [IsStorageChanging], [NeedsTransaction], [AreStatisticsChanging], [DSTriggerSQL], [PKColumnList], [PKColumnListJoinClause], [ColumnListNoTypes], [ColumnListWithTypes], [UpdateColumnList], [NewPartitionedPrepTableName], [PartitionFunctionName] FROM [DDI].[RG_Recovery_1_Tables]
GO
UPDATE STATISTICS [DDI].[Tables] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_1_Tables]
GO
PRINT N'Rebuilding [DDI].[CheckConstraints]'
GO
CREATE TABLE [DDI].[RG_Recovery_12_CheckConstraints]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[ColumnName] [nvarchar] (128) NULL,
[CheckDefinition] [nvarchar] (max) NOT NULL,
[IsDisabled] [bit] NOT NULL,
[CheckConstraintName] [nvarchar] (128) NOT NULL
)
GO
INSERT INTO [DDI].[RG_Recovery_12_CheckConstraints]([DatabaseName], [SchemaName], [TableName], [ColumnName], [CheckDefinition], [IsDisabled], [CheckConstraintName]) SELECT [DatabaseName], [SchemaName], [TableName], [ColumnName], [CheckDefinition], [IsDisabled], [CheckConstraintName] FROM [DDI].[CheckConstraints]
GO
DROP TABLE [DDI].[CheckConstraints]
GO
CREATE TABLE [DDI].[CheckConstraints]
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
INSERT INTO [DDI].[CheckConstraints]([DatabaseName], [SchemaName], [TableName], [ColumnName], [CheckDefinition], [IsDisabled], [CheckConstraintName]) SELECT [DatabaseName], [SchemaName], [TableName], [ColumnName], [CheckDefinition], [IsDisabled], [CheckConstraintName] FROM [DDI].[RG_Recovery_12_CheckConstraints]
GO
UPDATE STATISTICS [DDI].[CheckConstraints] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_12_CheckConstraints]
GO
PRINT N'Rebuilding [DDI].[DefaultConstraints]'
GO
CREATE TABLE [DDI].[RG_Recovery_13_DefaultConstraints]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[ColumnName] [nvarchar] (128) NOT NULL,
[DefaultDefinition] [nvarchar] (max) NOT NULL,
[DefaultConstraintName] [nvarchar] (128) NULL
)
GO
INSERT INTO [DDI].[RG_Recovery_13_DefaultConstraints]([DatabaseName], [SchemaName], [TableName], [ColumnName], [DefaultDefinition], [DefaultConstraintName]) SELECT [DatabaseName], [SchemaName], [TableName], [ColumnName], [DefaultDefinition], [DefaultConstraintName] FROM [DDI].[DefaultConstraints]
GO
DROP TABLE [DDI].[DefaultConstraints]
GO
CREATE TABLE [DDI].[DefaultConstraints]
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
INSERT INTO [DDI].[DefaultConstraints]([DatabaseName], [SchemaName], [TableName], [ColumnName], [DefaultDefinition], [DefaultConstraintName]) SELECT [DatabaseName], [SchemaName], [TableName], [ColumnName], [DefaultDefinition], [DefaultConstraintName] FROM [DDI].[RG_Recovery_13_DefaultConstraints]
GO
UPDATE STATISTICS [DDI].[DefaultConstraints] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_13_DefaultConstraints]
GO
PRINT N'Rebuilding [DDI].[ForeignKeys]'
GO
CREATE TABLE [DDI].[RG_Recovery_14_ForeignKeys]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[ParentSchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[ParentColumnList_Desired] [sys].[sysname] NOT NULL,
[ReferencedSchemaName] [sys].[sysname] NOT NULL,
[ReferencedTableName] [sys].[sysname] NOT NULL,
[ReferencedColumnList_Desired] [sys].[sysname] NOT NULL,
[ParentColumnList_Actual] [varchar] (128) NULL,
[ReferencedColumnList_Actual] [varchar] (128) NULL,
[DeploymentTime] [varchar] (10) NULL
)
GO
INSERT INTO [DDI].[RG_Recovery_14_ForeignKeys]([DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [ParentColumnList_Actual], [ReferencedColumnList_Actual], [DeploymentTime]) SELECT [DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [ParentColumnList_Actual], [ReferencedColumnList_Actual], [DeploymentTime] FROM [DDI].[ForeignKeys]
GO
DROP TABLE [DDI].[ForeignKeys]
GO
CREATE TABLE [DDI].[ForeignKeys]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[ParentSchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[ParentColumnList_Desired] [sys].[sysname] NOT NULL,
[ReferencedSchemaName] [sys].[sysname] NOT NULL,
[ReferencedTableName] [sys].[sysname] NOT NULL,
[ReferencedColumnList_Desired] [sys].[sysname] NOT NULL,
[ParentColumnList_Actual] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferencedColumnList_Actual] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeploymentTime] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_ForeignKeys] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
INSERT INTO [DDI].[ForeignKeys]([DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [ParentColumnList_Actual], [ReferencedColumnList_Actual], [DeploymentTime]) SELECT [DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [ParentColumnList_Actual], [ReferencedColumnList_Actual], [DeploymentTime] FROM [DDI].[RG_Recovery_14_ForeignKeys]
GO
UPDATE STATISTICS [DDI].[ForeignKeys] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_14_ForeignKeys]
GO
PRINT N'Rebuilding [DDI].[IndexColumns]'
GO
CREATE TABLE [DDI].[RG_Recovery_15_IndexColumns]
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
[IsFixedSize] [bit] NOT NULL CONSTRAINT [RG_Recovery_16_IndexColumns] DEFAULT ((0)),
[ColumnSize] [decimal] (10, 2) NOT NULL CONSTRAINT [RG_Recovery_17_IndexColumns] DEFAULT ((0))
)
GO
INSERT INTO [DDI].[RG_Recovery_15_IndexColumns]([DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName], [IsKeyColumn], [KeyColumnPosition], [IsIncludedColumn], [IncludedColumnPosition], [IsFixedSize], [ColumnSize]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName], [IsKeyColumn], [KeyColumnPosition], [IsIncludedColumn], [IncludedColumnPosition], [IsFixedSize], [ColumnSize] FROM [DDI].[IndexColumns]
GO
DROP TABLE [DDI].[IndexColumns]
GO
CREATE TABLE [DDI].[IndexColumns]
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
INSERT INTO [DDI].[IndexColumns]([DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName], [IsKeyColumn], [KeyColumnPosition], [IsIncludedColumn], [IncludedColumnPosition], [IsFixedSize], [ColumnSize]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName], [IsKeyColumn], [KeyColumnPosition], [IsIncludedColumn], [IncludedColumnPosition], [IsFixedSize], [ColumnSize] FROM [DDI].[RG_Recovery_15_IndexColumns]
GO
UPDATE STATISTICS [DDI].[IndexColumns] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_15_IndexColumns]
GO
PRINT N'Rebuilding [DDI].[IndexesColumnStore]'
GO
CREATE TABLE [DDI].[RG_Recovery_18_IndexesColumnStore]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[IsIndexMissingFromSQLServer] [bit] NOT NULL CONSTRAINT [RG_Recovery_19_IndexesColumnStore] DEFAULT ((0)),
[IsClustered_Desired] [bit] NOT NULL,
[IsClustered_Actual] [bit] NULL,
[ColumnList_Desired] [nvarchar] (max) NULL,
[ColumnList_Actual] [nvarchar] (max) NULL,
[IsFiltered_Desired] [bit] NOT NULL,
[IsFiltered_Actual] [bit] NULL,
[FilterPredicate_Desired] [varchar] (max) NULL,
[FilterPredicate_Actual] [varchar] (max) NULL,
[OptionDataCompression_Desired] [varchar] (30) NOT NULL CONSTRAINT [RG_Recovery_20_IndexesColumnStore] DEFAULT ('COLUMNSTORE'),
[OptionDataCompression_Actual] [varchar] (30) NULL,
[OptionDataCompressionDelay_Desired] [int] NOT NULL,
[OptionDataCompressionDelay_Actual] [int] NULL,
[Storage_Desired] [nvarchar] (128) NOT NULL,
[Storage_Actual] [nvarchar] (128) NULL,
[StorageType_Desired] [nvarchar] (120) NULL,
[StorageType_Actual] [nvarchar] (120) NULL,
[PartitionFunction_Desired] [nvarchar] (128) NULL,
[PartitionFunction_Actual] [nvarchar] (128) NULL,
[PartitionColumn_Desired] [nvarchar] (128) NULL,
[PartitionColumn_Actual] [nvarchar] (128) NULL,
[AllColsInTableSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_21_IndexesColumnStore] DEFAULT ((0)),
[NumFixedCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_22_IndexesColumnStore] DEFAULT ((0)),
[NumVarCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_23_IndexesColumnStore] DEFAULT ((0)),
[NumCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_24_IndexesColumnStore] DEFAULT ((0)),
[FixedColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_25_IndexesColumnStore] DEFAULT ((0)),
[VarColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_26_IndexesColumnStore] DEFAULT ((0)),
[ColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_27_IndexesColumnStore] DEFAULT ((0)),
[NumRows_Actual] [bigint] NOT NULL CONSTRAINT [RG_Recovery_28_IndexesColumnStore] DEFAULT ((0)),
[IndexSizeMB_Actual] [decimal] (10, 2) NOT NULL CONSTRAINT [RG_Recovery_29_IndexesColumnStore] DEFAULT ((0)),
[DriveLetter] [char] (1) NULL,
[IsIndexLarge] [bit] NOT NULL CONSTRAINT [RG_Recovery_30_IndexesColumnStore] DEFAULT ((0)),
[IndexMeetsMinimumSize] [bit] NOT NULL CONSTRAINT [RG_Recovery_31_IndexesColumnStore] DEFAULT ((0)),
[Fragmentation] [float] NOT NULL CONSTRAINT [RG_Recovery_32_IndexesColumnStore] DEFAULT ((0)),
[FragmentationType] [varchar] (5) NOT NULL CONSTRAINT [RG_Recovery_33_IndexesColumnStore] DEFAULT ('None'),
[AreDropRecreateOptionsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_34_IndexesColumnStore] DEFAULT ((0)),
[AreRebuildOptionsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_35_IndexesColumnStore] DEFAULT ((0)),
[AreRebuildOnlyOptionsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_36_IndexesColumnStore] DEFAULT ((0)),
[AreReorgOptionsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_37_IndexesColumnStore] DEFAULT ((0)),
[AreSetOptionsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_38_IndexesColumnStore] DEFAULT ((0)),
[IsColumnListChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_39_IndexesColumnStore] DEFAULT ((0)),
[IsFilterChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_40_IndexesColumnStore] DEFAULT ((0)),
[IsClusteredChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_41_IndexesColumnStore] DEFAULT ((0)),
[IsPartitioningChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_42_IndexesColumnStore] DEFAULT ((0)),
[IsDataCompressionChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_43_IndexesColumnStore] DEFAULT ((0)),
[IsDataCompressionDelayChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_44_IndexesColumnStore] DEFAULT ((0)),
[IsStorageChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_45_IndexesColumnStore] DEFAULT ((0)),
[NumPages_Actual] [int] NULL CONSTRAINT [RG_Recovery_46_IndexesColumnStore] DEFAULT ((0)),
[TotalPartitionsInIndex] [int] NOT NULL CONSTRAINT [RG_Recovery_47_IndexesColumnStore] DEFAULT ((0)),
[NeedsPartitionLevelOperations] [bit] NOT NULL CONSTRAINT [RG_Recovery_48_IndexesColumnStore] DEFAULT ((0))
)
GO
INSERT INTO [DDI].[RG_Recovery_18_IndexesColumnStore]([DatabaseName], [SchemaName], [TableName], [IndexName], [IsIndexMissingFromSQLServer], [IsClustered_Desired], [IsClustered_Actual], [ColumnList_Desired], [ColumnList_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [OptionDataCompression_Desired], [OptionDataCompression_Actual], [OptionDataCompressionDelay_Desired], [OptionDataCompressionDelay_Actual], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [PartitionFunction_Desired], [PartitionFunction_Actual], [PartitionColumn_Desired], [PartitionColumn_Actual], [AllColsInTableSize_Estimated], [NumFixedCols_Estimated], [NumVarCols_Estimated], [NumCols_Estimated], [FixedColsSize_Estimated], [VarColsSize_Estimated], [ColsSize_Estimated], [NumRows_Actual], [IndexSizeMB_Actual], [DriveLetter], [IsIndexLarge], [IndexMeetsMinimumSize], [Fragmentation], [FragmentationType], [AreDropRecreateOptionsChanging], [AreRebuildOptionsChanging], [AreRebuildOnlyOptionsChanging], [AreReorgOptionsChanging], [AreSetOptionsChanging], [IsColumnListChanging], [IsFilterChanging], [IsClusteredChanging], [IsPartitioningChanging], [IsDataCompressionChanging], [IsDataCompressionDelayChanging], [IsStorageChanging], [NumPages_Actual], [TotalPartitionsInIndex], [NeedsPartitionLevelOperations]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [IsIndexMissingFromSQLServer], [IsClustered_Desired], [IsClustered_Actual], [ColumnList_Desired], [ColumnList_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [OptionDataCompression_Desired], [OptionDataCompression_Actual], [OptionDataCompressionDelay_Desired], [OptionDataCompressionDelay_Actual], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [PartitionFunction_Desired], [PartitionFunction_Actual], [PartitionColumn_Desired], [PartitionColumn_Actual], [AllColsInTableSize_Estimated], [NumFixedCols_Estimated], [NumVarCols_Estimated], [NumCols_Estimated], [FixedColsSize_Estimated], [VarColsSize_Estimated], [ColsSize_Estimated], [NumRows_Actual], [IndexSizeMB_Actual], [DriveLetter], [IsIndexLarge], [IndexMeetsMinimumSize], [Fragmentation], [FragmentationType], [AreDropRecreateOptionsChanging], [AreRebuildOptionsChanging], [AreRebuildOnlyOptionsChanging], [AreReorgOptionsChanging], [AreSetOptionsChanging], [IsColumnListChanging], [IsFilterChanging], [IsClusteredChanging], [IsPartitioningChanging], [IsDataCompressionChanging], [IsDataCompressionDelayChanging], [IsStorageChanging], [NumPages_Actual], [TotalPartitionsInIndex], [NeedsPartitionLevelOperations] FROM [DDI].[IndexesColumnStore]
GO
DROP TABLE [DDI].[IndexesColumnStore]
GO
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
INSERT INTO [DDI].[IndexesColumnStore]([DatabaseName], [SchemaName], [TableName], [IndexName], [IsIndexMissingFromSQLServer], [IsClustered_Desired], [IsClustered_Actual], [ColumnList_Desired], [ColumnList_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [OptionDataCompression_Desired], [OptionDataCompression_Actual], [OptionDataCompressionDelay_Desired], [OptionDataCompressionDelay_Actual], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [PartitionFunction_Desired], [PartitionFunction_Actual], [PartitionColumn_Desired], [PartitionColumn_Actual], [AllColsInTableSize_Estimated], [NumFixedCols_Estimated], [NumVarCols_Estimated], [NumCols_Estimated], [FixedColsSize_Estimated], [VarColsSize_Estimated], [ColsSize_Estimated], [NumRows_Actual], [IndexSizeMB_Actual], [DriveLetter], [IsIndexLarge], [IndexMeetsMinimumSize], [Fragmentation], [FragmentationType], [AreDropRecreateOptionsChanging], [AreRebuildOptionsChanging], [AreRebuildOnlyOptionsChanging], [AreReorgOptionsChanging], [AreSetOptionsChanging], [IsColumnListChanging], [IsFilterChanging], [IsClusteredChanging], [IsPartitioningChanging], [IsDataCompressionChanging], [IsDataCompressionDelayChanging], [IsStorageChanging], [NumPages_Actual], [TotalPartitionsInIndex], [NeedsPartitionLevelOperations]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [IsIndexMissingFromSQLServer], [IsClustered_Desired], [IsClustered_Actual], [ColumnList_Desired], [ColumnList_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [OptionDataCompression_Desired], [OptionDataCompression_Actual], [OptionDataCompressionDelay_Desired], [OptionDataCompressionDelay_Actual], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [PartitionFunction_Desired], [PartitionFunction_Actual], [PartitionColumn_Desired], [PartitionColumn_Actual], [AllColsInTableSize_Estimated], [NumFixedCols_Estimated], [NumVarCols_Estimated], [NumCols_Estimated], [FixedColsSize_Estimated], [VarColsSize_Estimated], [ColsSize_Estimated], [NumRows_Actual], [IndexSizeMB_Actual], [DriveLetter], [IsIndexLarge], [IndexMeetsMinimumSize], [Fragmentation], [FragmentationType], [AreDropRecreateOptionsChanging], [AreRebuildOptionsChanging], [AreRebuildOnlyOptionsChanging], [AreReorgOptionsChanging], [AreSetOptionsChanging], [IsColumnListChanging], [IsFilterChanging], [IsClusteredChanging], [IsPartitioningChanging], [IsDataCompressionChanging], [IsDataCompressionDelayChanging], [IsStorageChanging], [NumPages_Actual], [TotalPartitionsInIndex], [NeedsPartitionLevelOperations] FROM [DDI].[RG_Recovery_18_IndexesColumnStore]
GO
UPDATE STATISTICS [DDI].[IndexesColumnStore] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_18_IndexesColumnStore]
GO
PRINT N'Rebuilding [DDI].[IndexColumnStorePartitions]'
GO
CREATE TABLE [DDI].[RG_Recovery_49_IndexColumnStorePartitions]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionDataCompression] [nvarchar] (60) NOT NULL CONSTRAINT [RG_Recovery_50_IndexColumnStorePartitions] DEFAULT ('COLUMNSTORE')
)
GO
INSERT INTO [DDI].[RG_Recovery_49_IndexColumnStorePartitions]([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionDataCompression]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionDataCompression] FROM [DDI].[IndexColumnStorePartitions]
GO
DROP TABLE [DDI].[IndexColumnStorePartitions]
GO
CREATE TABLE [DDI].[IndexColumnStorePartitions]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionDataCompression] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexColumnStorePartitions_OptionDataCompression] DEFAULT ('COLUMNSTORE'),
CONSTRAINT [PK_IndexColumnStorePartitions] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
INSERT INTO [DDI].[IndexColumnStorePartitions]([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionDataCompression]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionDataCompression] FROM [DDI].[RG_Recovery_49_IndexColumnStorePartitions]
GO
UPDATE STATISTICS [DDI].[IndexColumnStorePartitions] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_49_IndexColumnStorePartitions]
GO
PRINT N'Rebuilding [DDI].[IndexesRowStore]'
GO
CREATE TABLE [DDI].[RG_Recovery_51_IndexesRowStore]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[IsIndexMissingFromSQLServer] [bit] NOT NULL CONSTRAINT [RG_Recovery_52_IndexesRowStore] DEFAULT ((0)),
[IsUnique_Desired] [bit] NOT NULL,
[IsUnique_Actual] [bit] NULL,
[IsPrimaryKey_Desired] [bit] NOT NULL,
[IsPrimaryKey_Actual] [bit] NULL,
[IsUniqueConstraint_Desired] [bit] NOT NULL CONSTRAINT [RG_Recovery_53_IndexesRowStore] DEFAULT ((0)),
[IsUniqueConstraint_Actual] [bit] NULL,
[IsClustered_Desired] [bit] NOT NULL,
[IsClustered_Actual] [bit] NULL,
[KeyColumnList_Desired] [nvarchar] (max) NOT NULL,
[KeyColumnList_Actual] [nvarchar] (max) NULL,
[IncludedColumnList_Desired] [nvarchar] (max) NULL,
[IncludedColumnList_Actual] [nvarchar] (max) NULL,
[IsFiltered_Desired] [bit] NOT NULL,
[IsFiltered_Actual] [bit] NULL,
[FilterPredicate_Desired] [varchar] (max) NULL,
[FilterPredicate_Actual] [varchar] (max) NULL,
[Fillfactor_Desired] [tinyint] NOT NULL CONSTRAINT [RG_Recovery_54_IndexesRowStore] DEFAULT ((90)),
[Fillfactor_Actual] [tinyint] NULL,
[OptionPadIndex_Desired] [bit] NOT NULL CONSTRAINT [RG_Recovery_55_IndexesRowStore] DEFAULT ((1)),
[OptionPadIndex_Actual] [bit] NULL,
[OptionStatisticsNoRecompute_Desired] [bit] NOT NULL CONSTRAINT [RG_Recovery_56_IndexesRowStore] DEFAULT ((0)),
[OptionStatisticsNoRecompute_Actual] [bit] NULL,
[OptionStatisticsIncremental_Desired] [bit] NOT NULL CONSTRAINT [RG_Recovery_57_IndexesRowStore] DEFAULT ((0)),
[OptionStatisticsIncremental_Actual] [bit] NULL,
[OptionIgnoreDupKey_Desired] [bit] NOT NULL CONSTRAINT [RG_Recovery_58_IndexesRowStore] DEFAULT ((0)),
[OptionIgnoreDupKey_Actual] [bit] NULL,
[OptionResumable_Desired] [bit] NOT NULL CONSTRAINT [RG_Recovery_59_IndexesRowStore] DEFAULT ((0)),
[OptionResumable_Actual] [bit] NULL,
[OptionMaxDuration_Desired] [smallint] NOT NULL CONSTRAINT [RG_Recovery_60_IndexesRowStore] DEFAULT ((0)),
[OptionMaxDuration_Actual] [smallint] NULL,
[OptionAllowRowLocks_Desired] [bit] NOT NULL CONSTRAINT [RG_Recovery_61_IndexesRowStore] DEFAULT ((1)),
[OptionAllowRowLocks_Actual] [bit] NULL,
[OptionAllowPageLocks_Desired] [bit] NOT NULL CONSTRAINT [RG_Recovery_62_IndexesRowStore] DEFAULT ((1)),
[OptionAllowPageLocks_Actual] [bit] NULL,
[OptionDataCompression_Desired] [nvarchar] (60) NOT NULL CONSTRAINT [RG_Recovery_63_IndexesRowStore] DEFAULT ('PAGE'),
[OptionDataCompression_Actual] [nvarchar] (60) NULL,
[OptionDataCompressionDelay_Desired] [bit] NOT NULL CONSTRAINT [RG_Recovery_64_IndexesRowStore] DEFAULT ((0)),
[OptionDataCompressionDelay_Actual] [bit] NOT NULL CONSTRAINT [RG_Recovery_65_IndexesRowStore] DEFAULT ((0)),
[Storage_Desired] [nvarchar] (128) NOT NULL,
[Storage_Actual] [nvarchar] (128) NULL,
[StorageType_Desired] [nvarchar] (120) NULL,
[StorageType_Actual] [nvarchar] (120) NULL,
[PartitionFunction_Desired] [nvarchar] (128) NULL,
[PartitionFunction_Actual] [nvarchar] (128) NULL,
[PartitionColumn_Desired] [nvarchar] (128) NULL,
[PartitionColumn_Actual] [nvarchar] (128) NULL,
[NumRows_Actual] [bigint] NOT NULL CONSTRAINT [RG_Recovery_66_IndexesRowStore] DEFAULT ((0)),
[AllColsInTableSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_67_IndexesRowStore] DEFAULT ((0)),
[NumFixedKeyCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_68_IndexesRowStore] DEFAULT ((0)),
[NumVarKeyCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_69_IndexesRowStore] DEFAULT ((0)),
[NumKeyCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_70_IndexesRowStore] DEFAULT ((0)),
[NumFixedInclCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_71_IndexesRowStore] DEFAULT ((0)),
[NumVarInclCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_72_IndexesRowStore] DEFAULT ((0)),
[NumInclCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_73_IndexesRowStore] DEFAULT ((0)),
[NumFixedCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_74_IndexesRowStore] DEFAULT ((0)),
[NumVarCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_75_IndexesRowStore] DEFAULT ((0)),
[NumCols_Estimated] [smallint] NOT NULL CONSTRAINT [RG_Recovery_76_IndexesRowStore] DEFAULT ((0)),
[FixedKeyColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_77_IndexesRowStore] DEFAULT ((0)),
[VarKeyColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_78_IndexesRowStore] DEFAULT ((0)),
[KeyColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_79_IndexesRowStore] DEFAULT ((0)),
[FixedInclColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_80_IndexesRowStore] DEFAULT ((0)),
[VarInclColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_81_IndexesRowStore] DEFAULT ((0)),
[InclColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_82_IndexesRowStore] DEFAULT ((0)),
[FixedColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_83_IndexesRowStore] DEFAULT ((0)),
[VarColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_84_IndexesRowStore] DEFAULT ((0)),
[ColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_85_IndexesRowStore] DEFAULT ((0)),
[PKColsSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_86_IndexesRowStore] DEFAULT ((0)),
[NullBitmap_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_87_IndexesRowStore] DEFAULT ((0)),
[Uniqueifier_Estimated] [tinyint] NOT NULL CONSTRAINT [RG_Recovery_88_IndexesRowStore] DEFAULT ((0)),
[TotalRowSize_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_89_IndexesRowStore] DEFAULT ((0)),
[NonClusteredIndexRowLocator_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_90_IndexesRowStore] DEFAULT ((0)),
[NumRowsPerPage_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_91_IndexesRowStore] DEFAULT ((0)),
[NumFreeRowsPerPage_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_92_IndexesRowStore] DEFAULT ((0)),
[NumLeafPages_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_93_IndexesRowStore] DEFAULT ((0)),
[LeafSpaceUsed_Estimated] [decimal] (18, 2) NOT NULL CONSTRAINT [RG_Recovery_94_IndexesRowStore] DEFAULT ((0)),
[LeafSpaceUsedMB_Estimated] [decimal] (10, 2) NOT NULL CONSTRAINT [RG_Recovery_95_IndexesRowStore] DEFAULT ((0)),
[NumNonLeafLevelsInIndex_Estimated] [tinyint] NOT NULL CONSTRAINT [RG_Recovery_96_IndexesRowStore] DEFAULT ((0)),
[NumIndexPages_Estimated] [int] NOT NULL CONSTRAINT [RG_Recovery_97_IndexesRowStore] DEFAULT ((0)),
[IndexSizeMB_Estimated] [decimal] (10, 2) NOT NULL CONSTRAINT [RG_Recovery_98_IndexesRowStore] DEFAULT ((0)),
[IndexSizeMB_Actual] [decimal] (10, 2) NOT NULL CONSTRAINT [RG_Recovery_99_IndexesRowStore] DEFAULT ((0)),
[DriveLetter] [char] (1) NULL,
[IsIndexLarge] [bit] NOT NULL CONSTRAINT [RG_Recovery_100_IndexesRowStore] DEFAULT ((0)),
[IndexMeetsMinimumSize] [bit] NOT NULL CONSTRAINT [RG_Recovery_101_IndexesRowStore] DEFAULT ((0)),
[Fragmentation] [float] NOT NULL CONSTRAINT [RG_Recovery_102_IndexesRowStore] DEFAULT ((0)),
[FragmentationType] [varchar] (5) NOT NULL CONSTRAINT [RG_Recovery_103_IndexesRowStore] DEFAULT ('None'),
[AreDropRecreateOptionsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_104_IndexesRowStore] DEFAULT ((0)),
[AreRebuildOptionsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_105_IndexesRowStore] DEFAULT ((0)),
[AreRebuildOnlyOptionsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_106_IndexesRowStore] DEFAULT ((0)),
[AreReorgOptionsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_107_IndexesRowStore] DEFAULT ((0)),
[AreSetOptionsChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_108_IndexesRowStore] DEFAULT ((0)),
[IsUniquenessChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_109_IndexesRowStore] DEFAULT ((0)),
[IsPrimaryKeyChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_110_IndexesRowStore] DEFAULT ((0)),
[IsKeyColumnListChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_111_IndexesRowStore] DEFAULT ((0)),
[IsIncludedColumnListChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_112_IndexesRowStore] DEFAULT ((0)),
[IsFilterChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_113_IndexesRowStore] DEFAULT ((0)),
[IsClusteredChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_114_IndexesRowStore] DEFAULT ((0)),
[IsPartitioningChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_115_IndexesRowStore] DEFAULT ((0)),
[IsPadIndexChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_116_IndexesRowStore] DEFAULT ((0)),
[IsFillfactorChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_117_IndexesRowStore] DEFAULT ((0)),
[IsIgnoreDupKeyChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_118_IndexesRowStore] DEFAULT ((0)),
[IsStatisticsNoRecomputeChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_119_IndexesRowStore] DEFAULT ((0)),
[IsStatisticsIncrementalChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_120_IndexesRowStore] DEFAULT ((0)),
[IsAllowRowLocksChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_121_IndexesRowStore] DEFAULT ((0)),
[IsAllowPageLocksChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_122_IndexesRowStore] DEFAULT ((0)),
[IsDataCompressionChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_123_IndexesRowStore] DEFAULT ((0)),
[IsDataCompressionDelayChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_124_IndexesRowStore] DEFAULT ((0)),
[IsStorageChanging] [bit] NOT NULL CONSTRAINT [RG_Recovery_125_IndexesRowStore] DEFAULT ((0)),
[IndexHasLOBColumns] [bit] NOT NULL CONSTRAINT [RG_Recovery_126_IndexesRowStore] DEFAULT ((0)),
[NumPages_Actual] [int] NOT NULL CONSTRAINT [RG_Recovery_127_IndexesRowStore] DEFAULT ((0)),
[TotalPartitionsInIndex] [int] NOT NULL CONSTRAINT [RG_Recovery_128_IndexesRowStore] DEFAULT ((0)),
[NeedsPartitionLevelOperations] [bit] NOT NULL CONSTRAINT [RG_Recovery_129_IndexesRowStore] DEFAULT ((0))
)
GO
INSERT INTO [DDI].[RG_Recovery_51_IndexesRowStore]([DatabaseName], [SchemaName], [TableName], [IndexName], [IsIndexMissingFromSQLServer], [IsUnique_Desired], [IsUnique_Actual], [IsPrimaryKey_Desired], [IsPrimaryKey_Actual], [IsUniqueConstraint_Desired], [IsUniqueConstraint_Actual], [IsClustered_Desired], [IsClustered_Actual], [KeyColumnList_Desired], [KeyColumnList_Actual], [IncludedColumnList_Desired], [IncludedColumnList_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [Fillfactor_Desired], [Fillfactor_Actual], [OptionPadIndex_Desired], [OptionPadIndex_Actual], [OptionStatisticsNoRecompute_Desired], [OptionStatisticsNoRecompute_Actual], [OptionStatisticsIncremental_Desired], [OptionStatisticsIncremental_Actual], [OptionIgnoreDupKey_Desired], [OptionIgnoreDupKey_Actual], [OptionResumable_Desired], [OptionResumable_Actual], [OptionMaxDuration_Desired], [OptionMaxDuration_Actual], [OptionAllowRowLocks_Desired], [OptionAllowRowLocks_Actual], [OptionAllowPageLocks_Desired], [OptionAllowPageLocks_Actual], [OptionDataCompression_Desired], [OptionDataCompression_Actual], [OptionDataCompressionDelay_Desired], [OptionDataCompressionDelay_Actual], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [PartitionFunction_Desired], [PartitionFunction_Actual], [PartitionColumn_Desired], [PartitionColumn_Actual], [NumRows_Actual], [AllColsInTableSize_Estimated], [NumFixedKeyCols_Estimated], [NumVarKeyCols_Estimated], [NumKeyCols_Estimated], [NumFixedInclCols_Estimated], [NumVarInclCols_Estimated], [NumInclCols_Estimated], [NumFixedCols_Estimated], [NumVarCols_Estimated], [NumCols_Estimated], [FixedKeyColsSize_Estimated], [VarKeyColsSize_Estimated], [KeyColsSize_Estimated], [FixedInclColsSize_Estimated], [VarInclColsSize_Estimated], [InclColsSize_Estimated], [FixedColsSize_Estimated], [VarColsSize_Estimated], [ColsSize_Estimated], [PKColsSize_Estimated], [NullBitmap_Estimated], [Uniqueifier_Estimated], [TotalRowSize_Estimated], [NonClusteredIndexRowLocator_Estimated], [NumRowsPerPage_Estimated], [NumFreeRowsPerPage_Estimated], [NumLeafPages_Estimated], [LeafSpaceUsed_Estimated], [LeafSpaceUsedMB_Estimated], [NumNonLeafLevelsInIndex_Estimated], [NumIndexPages_Estimated], [IndexSizeMB_Estimated], [IndexSizeMB_Actual], [DriveLetter], [IsIndexLarge], [IndexMeetsMinimumSize], [Fragmentation], [FragmentationType], [AreDropRecreateOptionsChanging], [AreRebuildOptionsChanging], [AreRebuildOnlyOptionsChanging], [AreReorgOptionsChanging], [AreSetOptionsChanging], [IsUniquenessChanging], [IsPrimaryKeyChanging], [IsKeyColumnListChanging], [IsIncludedColumnListChanging], [IsFilterChanging], [IsClusteredChanging], [IsPartitioningChanging], [IsPadIndexChanging], [IsFillfactorChanging], [IsIgnoreDupKeyChanging], [IsStatisticsNoRecomputeChanging], [IsStatisticsIncrementalChanging], [IsAllowRowLocksChanging], [IsAllowPageLocksChanging], [IsDataCompressionChanging], [IsDataCompressionDelayChanging], [IsStorageChanging], [IndexHasLOBColumns], [NumPages_Actual], [TotalPartitionsInIndex], [NeedsPartitionLevelOperations]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [IsIndexMissingFromSQLServer], [IsUnique_Desired], [IsUnique_Actual], [IsPrimaryKey_Desired], [IsPrimaryKey_Actual], [IsUniqueConstraint_Desired], [IsUniqueConstraint_Actual], [IsClustered_Desired], [IsClustered_Actual], [KeyColumnList_Desired], [KeyColumnList_Actual], [IncludedColumnList_Desired], [IncludedColumnList_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [Fillfactor_Desired], [Fillfactor_Actual], [OptionPadIndex_Desired], [OptionPadIndex_Actual], [OptionStatisticsNoRecompute_Desired], [OptionStatisticsNoRecompute_Actual], [OptionStatisticsIncremental_Desired], [OptionStatisticsIncremental_Actual], [OptionIgnoreDupKey_Desired], [OptionIgnoreDupKey_Actual], [OptionResumable_Desired], [OptionResumable_Actual], [OptionMaxDuration_Desired], [OptionMaxDuration_Actual], [OptionAllowRowLocks_Desired], [OptionAllowRowLocks_Actual], [OptionAllowPageLocks_Desired], [OptionAllowPageLocks_Actual], [OptionDataCompression_Desired], [OptionDataCompression_Actual], [OptionDataCompressionDelay_Desired], [OptionDataCompressionDelay_Actual], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [PartitionFunction_Desired], [PartitionFunction_Actual], [PartitionColumn_Desired], [PartitionColumn_Actual], [NumRows_Actual], [AllColsInTableSize_Estimated], [NumFixedKeyCols_Estimated], [NumVarKeyCols_Estimated], [NumKeyCols_Estimated], [NumFixedInclCols_Estimated], [NumVarInclCols_Estimated], [NumInclCols_Estimated], [NumFixedCols_Estimated], [NumVarCols_Estimated], [NumCols_Estimated], [FixedKeyColsSize_Estimated], [VarKeyColsSize_Estimated], [KeyColsSize_Estimated], [FixedInclColsSize_Estimated], [VarInclColsSize_Estimated], [InclColsSize_Estimated], [FixedColsSize_Estimated], [VarColsSize_Estimated], [ColsSize_Estimated], [PKColsSize_Estimated], [NullBitmap_Estimated], [Uniqueifier_Estimated], [TotalRowSize_Estimated], [NonClusteredIndexRowLocator_Estimated], [NumRowsPerPage_Estimated], [NumFreeRowsPerPage_Estimated], [NumLeafPages_Estimated], [LeafSpaceUsed_Estimated], [LeafSpaceUsedMB_Estimated], [NumNonLeafLevelsInIndex_Estimated], [NumIndexPages_Estimated], [IndexSizeMB_Estimated], [IndexSizeMB_Actual], [DriveLetter], [IsIndexLarge], [IndexMeetsMinimumSize], [Fragmentation], [FragmentationType], [AreDropRecreateOptionsChanging], [AreRebuildOptionsChanging], [AreRebuildOnlyOptionsChanging], [AreReorgOptionsChanging], [AreSetOptionsChanging], [IsUniquenessChanging], [IsPrimaryKeyChanging], [IsKeyColumnListChanging], [IsIncludedColumnListChanging], [IsFilterChanging], [IsClusteredChanging], [IsPartitioningChanging], [IsPadIndexChanging], [IsFillfactorChanging], [IsIgnoreDupKeyChanging], [IsStatisticsNoRecomputeChanging], [IsStatisticsIncrementalChanging], [IsAllowRowLocksChanging], [IsAllowPageLocksChanging], [IsDataCompressionChanging], [IsDataCompressionDelayChanging], [IsStorageChanging], [IndexHasLOBColumns], [NumPages_Actual], [TotalPartitionsInIndex], [NeedsPartitionLevelOperations] FROM [DDI].[IndexesRowStore]
GO
DROP TABLE [DDI].[IndexesRowStore]
GO
CREATE TABLE [DDI].[IndexesRowStore]
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
INSERT INTO [DDI].[IndexesRowStore]([DatabaseName], [SchemaName], [TableName], [IndexName], [IsIndexMissingFromSQLServer], [IsUnique_Desired], [IsUnique_Actual], [IsPrimaryKey_Desired], [IsPrimaryKey_Actual], [IsUniqueConstraint_Desired], [IsUniqueConstraint_Actual], [IsClustered_Desired], [IsClustered_Actual], [KeyColumnList_Desired], [KeyColumnList_Actual], [IncludedColumnList_Desired], [IncludedColumnList_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [Fillfactor_Desired], [Fillfactor_Actual], [OptionPadIndex_Desired], [OptionPadIndex_Actual], [OptionStatisticsNoRecompute_Desired], [OptionStatisticsNoRecompute_Actual], [OptionStatisticsIncremental_Desired], [OptionStatisticsIncremental_Actual], [OptionIgnoreDupKey_Desired], [OptionIgnoreDupKey_Actual], [OptionResumable_Desired], [OptionResumable_Actual], [OptionMaxDuration_Desired], [OptionMaxDuration_Actual], [OptionAllowRowLocks_Desired], [OptionAllowRowLocks_Actual], [OptionAllowPageLocks_Desired], [OptionAllowPageLocks_Actual], [OptionDataCompression_Desired], [OptionDataCompression_Actual], [OptionDataCompressionDelay_Desired], [OptionDataCompressionDelay_Actual], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [PartitionFunction_Desired], [PartitionFunction_Actual], [PartitionColumn_Desired], [PartitionColumn_Actual], [NumRows_Actual], [AllColsInTableSize_Estimated], [NumFixedKeyCols_Estimated], [NumVarKeyCols_Estimated], [NumKeyCols_Estimated], [NumFixedInclCols_Estimated], [NumVarInclCols_Estimated], [NumInclCols_Estimated], [NumFixedCols_Estimated], [NumVarCols_Estimated], [NumCols_Estimated], [FixedKeyColsSize_Estimated], [VarKeyColsSize_Estimated], [KeyColsSize_Estimated], [FixedInclColsSize_Estimated], [VarInclColsSize_Estimated], [InclColsSize_Estimated], [FixedColsSize_Estimated], [VarColsSize_Estimated], [ColsSize_Estimated], [PKColsSize_Estimated], [NullBitmap_Estimated], [Uniqueifier_Estimated], [TotalRowSize_Estimated], [NonClusteredIndexRowLocator_Estimated], [NumRowsPerPage_Estimated], [NumFreeRowsPerPage_Estimated], [NumLeafPages_Estimated], [LeafSpaceUsed_Estimated], [LeafSpaceUsedMB_Estimated], [NumNonLeafLevelsInIndex_Estimated], [NumIndexPages_Estimated], [IndexSizeMB_Estimated], [IndexSizeMB_Actual], [DriveLetter], [IsIndexLarge], [IndexMeetsMinimumSize], [Fragmentation], [FragmentationType], [AreDropRecreateOptionsChanging], [AreRebuildOptionsChanging], [AreRebuildOnlyOptionsChanging], [AreReorgOptionsChanging], [AreSetOptionsChanging], [IsUniquenessChanging], [IsPrimaryKeyChanging], [IsKeyColumnListChanging], [IsIncludedColumnListChanging], [IsFilterChanging], [IsClusteredChanging], [IsPartitioningChanging], [IsPadIndexChanging], [IsFillfactorChanging], [IsIgnoreDupKeyChanging], [IsStatisticsNoRecomputeChanging], [IsStatisticsIncrementalChanging], [IsAllowRowLocksChanging], [IsAllowPageLocksChanging], [IsDataCompressionChanging], [IsDataCompressionDelayChanging], [IsStorageChanging], [IndexHasLOBColumns], [NumPages_Actual], [TotalPartitionsInIndex], [NeedsPartitionLevelOperations]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [IsIndexMissingFromSQLServer], [IsUnique_Desired], [IsUnique_Actual], [IsPrimaryKey_Desired], [IsPrimaryKey_Actual], [IsUniqueConstraint_Desired], [IsUniqueConstraint_Actual], [IsClustered_Desired], [IsClustered_Actual], [KeyColumnList_Desired], [KeyColumnList_Actual], [IncludedColumnList_Desired], [IncludedColumnList_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [Fillfactor_Desired], [Fillfactor_Actual], [OptionPadIndex_Desired], [OptionPadIndex_Actual], [OptionStatisticsNoRecompute_Desired], [OptionStatisticsNoRecompute_Actual], [OptionStatisticsIncremental_Desired], [OptionStatisticsIncremental_Actual], [OptionIgnoreDupKey_Desired], [OptionIgnoreDupKey_Actual], [OptionResumable_Desired], [OptionResumable_Actual], [OptionMaxDuration_Desired], [OptionMaxDuration_Actual], [OptionAllowRowLocks_Desired], [OptionAllowRowLocks_Actual], [OptionAllowPageLocks_Desired], [OptionAllowPageLocks_Actual], [OptionDataCompression_Desired], [OptionDataCompression_Actual], [OptionDataCompressionDelay_Desired], [OptionDataCompressionDelay_Actual], [Storage_Desired], [Storage_Actual], [StorageType_Desired], [StorageType_Actual], [PartitionFunction_Desired], [PartitionFunction_Actual], [PartitionColumn_Desired], [PartitionColumn_Actual], [NumRows_Actual], [AllColsInTableSize_Estimated], [NumFixedKeyCols_Estimated], [NumVarKeyCols_Estimated], [NumKeyCols_Estimated], [NumFixedInclCols_Estimated], [NumVarInclCols_Estimated], [NumInclCols_Estimated], [NumFixedCols_Estimated], [NumVarCols_Estimated], [NumCols_Estimated], [FixedKeyColsSize_Estimated], [VarKeyColsSize_Estimated], [KeyColsSize_Estimated], [FixedInclColsSize_Estimated], [VarInclColsSize_Estimated], [InclColsSize_Estimated], [FixedColsSize_Estimated], [VarColsSize_Estimated], [ColsSize_Estimated], [PKColsSize_Estimated], [NullBitmap_Estimated], [Uniqueifier_Estimated], [TotalRowSize_Estimated], [NonClusteredIndexRowLocator_Estimated], [NumRowsPerPage_Estimated], [NumFreeRowsPerPage_Estimated], [NumLeafPages_Estimated], [LeafSpaceUsed_Estimated], [LeafSpaceUsedMB_Estimated], [NumNonLeafLevelsInIndex_Estimated], [NumIndexPages_Estimated], [IndexSizeMB_Estimated], [IndexSizeMB_Actual], [DriveLetter], [IsIndexLarge], [IndexMeetsMinimumSize], [Fragmentation], [FragmentationType], [AreDropRecreateOptionsChanging], [AreRebuildOptionsChanging], [AreRebuildOnlyOptionsChanging], [AreReorgOptionsChanging], [AreSetOptionsChanging], [IsUniquenessChanging], [IsPrimaryKeyChanging], [IsKeyColumnListChanging], [IsIncludedColumnListChanging], [IsFilterChanging], [IsClusteredChanging], [IsPartitioningChanging], [IsPadIndexChanging], [IsFillfactorChanging], [IsIgnoreDupKeyChanging], [IsStatisticsNoRecomputeChanging], [IsStatisticsIncrementalChanging], [IsAllowRowLocksChanging], [IsAllowPageLocksChanging], [IsDataCompressionChanging], [IsDataCompressionDelayChanging], [IsStorageChanging], [IndexHasLOBColumns], [NumPages_Actual], [TotalPartitionsInIndex], [NeedsPartitionLevelOperations] FROM [DDI].[RG_Recovery_51_IndexesRowStore]
GO
UPDATE STATISTICS [DDI].[IndexesRowStore] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_51_IndexesRowStore]
GO
PRINT N'Rebuilding [DDI].[IndexRowStorePartitions]'
GO
CREATE TABLE [DDI].[RG_Recovery_130_IndexRowStorePartitions]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionResumable] [bit] NOT NULL CONSTRAINT [RG_Recovery_131_IndexRowStorePartitions] DEFAULT ((0)),
[OptionMaxDuration] [smallint] NOT NULL CONSTRAINT [RG_Recovery_132_IndexRowStorePartitions] DEFAULT ((0)),
[OptionDataCompression] [nvarchar] (60) NOT NULL CONSTRAINT [RG_Recovery_133_IndexRowStorePartitions] DEFAULT ('PAGE'),
[NumRows] [bigint] NOT NULL CONSTRAINT [RG_Recovery_134_IndexRowStorePartitions] DEFAULT ((0)),
[TotalPages] [bigint] NOT NULL CONSTRAINT [RG_Recovery_135_IndexRowStorePartitions] DEFAULT ((0)),
[PartitionType] [varchar] (20) NOT NULL CONSTRAINT [RG_Recovery_136_IndexRowStorePartitions] DEFAULT ('RowStore'),
[TotalIndexPartitionSizeInMB] [decimal] (10, 2) NOT NULL CONSTRAINT [RG_Recovery_137_IndexRowStorePartitions] DEFAULT ((0.00)),
[Fragmentation] [float] NOT NULL CONSTRAINT [RG_Recovery_138_IndexRowStorePartitions] DEFAULT ((0)),
[DataFileName] [nvarchar] (260) NOT NULL CONSTRAINT [RG_Recovery_139_IndexRowStorePartitions] DEFAULT (''),
[DriveLetter] [char] (1) NOT NULL CONSTRAINT [RG_Recovery_140_IndexRowStorePartitions] DEFAULT (''),
[PartitionUpdateType] [varchar] (30) NOT NULL CONSTRAINT [RG_Recovery_141_IndexRowStorePartitions] DEFAULT ('None')
)
GO
INSERT INTO [DDI].[RG_Recovery_130_IndexRowStorePartitions]([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType] FROM [DDI].[IndexRowStorePartitions]
GO
DROP TABLE [DDI].[IndexRowStorePartitions]
GO
CREATE TABLE [DDI].[IndexRowStorePartitions]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionResumable] [bit] NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_OptionResumable] DEFAULT ((0)),
[OptionMaxDuration] [smallint] NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_OptionMaxDuration] DEFAULT ((0)),
[OptionDataCompression] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_OptionDataCompression] DEFAULT ('PAGE'),
[NumRows] [bigint] NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_NumRows] DEFAULT ((0)),
[TotalPages] [bigint] NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_TotalPages] DEFAULT ((0)),
[PartitionType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_PartitionType] DEFAULT ('RowStore'),
[TotalIndexPartitionSizeInMB] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_TotalIndexPartitionSizeInMB] DEFAULT ((0.00)),
[Fragmentation] [float] NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_Fragmentation] DEFAULT ((0)),
[DataFileName] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_DataFileName] DEFAULT (''),
[DriveLetter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_DriveLetter] DEFAULT (''),
[PartitionUpdateType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_PartitionUpdateType] DEFAULT ('None'),
CONSTRAINT [PK_IndexRowStorePartitions] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
INSERT INTO [DDI].[IndexRowStorePartitions]([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType] FROM [DDI].[RG_Recovery_130_IndexRowStorePartitions]
GO
UPDATE STATISTICS [DDI].[IndexRowStorePartitions] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_130_IndexRowStorePartitions]
GO
PRINT N'Rebuilding [DDI].[Statistics]'
GO
CREATE TABLE [DDI].[RG_Recovery_142_Statistics]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[StatisticsName] [sys].[sysname] NOT NULL,
[IsStatisticsMissingFromSQLServer] [bit] NOT NULL CONSTRAINT [RG_Recovery_143_Statistics] DEFAULT ((0)),
[StatisticsColumnList_Desired] [varchar] (max) NOT NULL,
[StatisticsColumnList_Actual] [varchar] (max) NULL,
[SampleSizePct_Desired] [tinyint] NOT NULL,
[SampleSizePct_Actual] [tinyint] NOT NULL CONSTRAINT [RG_Recovery_144_Statistics] DEFAULT ((0)),
[IsFiltered_Desired] [bit] NOT NULL,
[IsFiltered_Actual] [bit] NOT NULL CONSTRAINT [RG_Recovery_145_Statistics] DEFAULT ((0)),
[FilterPredicate_Desired] [varchar] (max) NULL,
[FilterPredicate_Actual] [nvarchar] (max) NULL,
[IsIncremental_Desired] [bit] NOT NULL,
[IsIncremental_Actual] [bit] NOT NULL CONSTRAINT [RG_Recovery_146_Statistics] DEFAULT ((0)),
[NoRecompute_Desired] [bit] NOT NULL,
[NoRecompute_Actual] [bit] NOT NULL CONSTRAINT [RG_Recovery_147_Statistics] DEFAULT ((0)),
[LowerSampleSizeToDesired] [bit] NOT NULL,
[ReadyToQueue] [bit] NOT NULL CONSTRAINT [RG_Recovery_148_Statistics] DEFAULT ((0)),
[DoesSampleSizeNeedUpdate] [bit] NOT NULL CONSTRAINT [RG_Recovery_149_Statistics] DEFAULT ((0)),
[IsStatisticsMissing] [bit] NOT NULL CONSTRAINT [RG_Recovery_150_Statistics] DEFAULT ((0)),
[HasFilterChanged] [bit] NOT NULL CONSTRAINT [RG_Recovery_151_Statistics] DEFAULT ((0)),
[HasIncrementalChanged] [bit] NOT NULL CONSTRAINT [RG_Recovery_152_Statistics] DEFAULT ((0)),
[HasNoRecomputeChanged] [bit] NOT NULL CONSTRAINT [RG_Recovery_153_Statistics] DEFAULT ((0)),
[NumRowsInTableUnfiltered] [bigint] NULL,
[NumRowsInTableFiltered] [bigint] NULL,
[NumRowsSampled] [bigint] NULL,
[StatisticsLastUpdated] [datetime2] NULL,
[HistogramSteps] [int] NULL,
[StatisticsModCounter] [bigint] NULL,
[PersistedSamplePct] [float] NULL,
[StatisticsUpdateType] [varchar] (30) NOT NULL CONSTRAINT [RG_Recovery_154_Statistics] DEFAULT ('None'),
[ListOfChanges] [varchar] (500) NULL,
[IsOnlineOperation] [bit] NOT NULL CONSTRAINT [RG_Recovery_155_Statistics] DEFAULT ((0))
)
GO
INSERT INTO [DDI].[RG_Recovery_142_Statistics]([DatabaseName], [SchemaName], [TableName], [StatisticsName], [IsStatisticsMissingFromSQLServer], [StatisticsColumnList_Desired], [StatisticsColumnList_Actual], [SampleSizePct_Desired], [SampleSizePct_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [IsIncremental_Desired], [IsIncremental_Actual], [NoRecompute_Desired], [NoRecompute_Actual], [LowerSampleSizeToDesired], [ReadyToQueue], [DoesSampleSizeNeedUpdate], [IsStatisticsMissing], [HasFilterChanged], [HasIncrementalChanged], [HasNoRecomputeChanged], [NumRowsInTableUnfiltered], [NumRowsInTableFiltered], [NumRowsSampled], [StatisticsLastUpdated], [HistogramSteps], [StatisticsModCounter], [PersistedSamplePct], [StatisticsUpdateType], [ListOfChanges], [IsOnlineOperation]) SELECT [DatabaseName], [SchemaName], [TableName], [StatisticsName], [IsStatisticsMissingFromSQLServer], [StatisticsColumnList_Desired], [StatisticsColumnList_Actual], [SampleSizePct_Desired], [SampleSizePct_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [IsIncremental_Desired], [IsIncremental_Actual], [NoRecompute_Desired], [NoRecompute_Actual], [LowerSampleSizeToDesired], [ReadyToQueue], [DoesSampleSizeNeedUpdate], [IsStatisticsMissing], [HasFilterChanged], [HasIncrementalChanged], [HasNoRecomputeChanged], [NumRowsInTableUnfiltered], [NumRowsInTableFiltered], [NumRowsSampled], [StatisticsLastUpdated], [HistogramSteps], [StatisticsModCounter], [PersistedSamplePct], [StatisticsUpdateType], [ListOfChanges], [IsOnlineOperation] FROM [DDI].[Statistics]
GO
DROP TABLE [DDI].[Statistics]
GO
CREATE TABLE [DDI].[Statistics]
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
INSERT INTO [DDI].[Statistics]([DatabaseName], [SchemaName], [TableName], [StatisticsName], [IsStatisticsMissingFromSQLServer], [StatisticsColumnList_Desired], [StatisticsColumnList_Actual], [SampleSizePct_Desired], [SampleSizePct_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [IsIncremental_Desired], [IsIncremental_Actual], [NoRecompute_Desired], [NoRecompute_Actual], [LowerSampleSizeToDesired], [ReadyToQueue], [DoesSampleSizeNeedUpdate], [IsStatisticsMissing], [HasFilterChanged], [HasIncrementalChanged], [HasNoRecomputeChanged], [NumRowsInTableUnfiltered], [NumRowsInTableFiltered], [NumRowsSampled], [StatisticsLastUpdated], [HistogramSteps], [StatisticsModCounter], [PersistedSamplePct], [StatisticsUpdateType], [ListOfChanges], [IsOnlineOperation]) SELECT [DatabaseName], [SchemaName], [TableName], [StatisticsName], [IsStatisticsMissingFromSQLServer], [StatisticsColumnList_Desired], [StatisticsColumnList_Actual], [SampleSizePct_Desired], [SampleSizePct_Actual], [IsFiltered_Desired], [IsFiltered_Actual], [FilterPredicate_Desired], [FilterPredicate_Actual], [IsIncremental_Desired], [IsIncremental_Actual], [NoRecompute_Desired], [NoRecompute_Actual], [LowerSampleSizeToDesired], [ReadyToQueue], [DoesSampleSizeNeedUpdate], [IsStatisticsMissing], [HasFilterChanged], [HasIncrementalChanged], [HasNoRecomputeChanged], [NumRowsInTableUnfiltered], [NumRowsInTableFiltered], [NumRowsSampled], [StatisticsLastUpdated], [HistogramSteps], [StatisticsModCounter], [PersistedSamplePct], [StatisticsUpdateType], [ListOfChanges], [IsOnlineOperation] FROM [DDI].[RG_Recovery_142_Statistics]
GO
UPDATE STATISTICS [DDI].[Statistics] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_142_Statistics]
GO
PRINT N'Rebuilding [DDI].[MappingSqlServerDMVToDDITables]'
GO
CREATE TABLE [DDI].[RG_Recovery_156_MappingSqlServerDMVToDDITables]
(
[DDITableName] [sys].[sysname] NOT NULL,
[SQLServerObjectName] [sys].[sysname] NOT NULL,
[SQLServerObjectType] [varchar] (10) NOT NULL,
[HasDatabaseIdInOutput] [bit] NOT NULL,
[DatabaseOutputString] [varchar] (50) NULL,
[FunctionParameterList] [varchar] (500) NULL,
[FunctionParentDMV] [nvarchar] (128) NULL
)
GO
INSERT INTO [DDI].[RG_Recovery_156_MappingSqlServerDMVToDDITables]([DDITableName], [SQLServerObjectName], [SQLServerObjectType], [HasDatabaseIdInOutput], [FunctionParameterList], [FunctionParentDMV]) SELECT [DDITableName], [SQLServerObjectName], [SQLServerObjectType], [HasDatabaseIdInOutput], [FunctionParameterList], [FunctionParentDMV] FROM [DDI].[MappingSqlServerDMVToDDITables]
GO
DROP TABLE [DDI].[MappingSqlServerDMVToDDITables]
GO
CREATE TABLE [DDI].[MappingSqlServerDMVToDDITables]
(
[DDITableName] [sys].[sysname] NOT NULL,
[SQLServerObjectName] [sys].[sysname] NOT NULL,
[SQLServerObjectType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasDatabaseIdInOutput] [bit] NOT NULL,
[DatabaseOutputString] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FunctionParameterList] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FunctionParentDMV] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_MappingSqlServerDMVToDDITables] PRIMARY KEY NONCLUSTERED  ([DDITableName], [SQLServerObjectName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
INSERT INTO [DDI].[MappingSqlServerDMVToDDITables]([DDITableName], [SQLServerObjectName], [SQLServerObjectType], [HasDatabaseIdInOutput], [DatabaseOutputString], [FunctionParameterList], [FunctionParentDMV]) SELECT [DDITableName], [SQLServerObjectName], [SQLServerObjectType], [HasDatabaseIdInOutput], [DatabaseOutputString], [FunctionParameterList], [FunctionParentDMV] FROM [DDI].[RG_Recovery_156_MappingSqlServerDMVToDDITables]
GO
UPDATE STATISTICS [DDI].[MappingSqlServerDMVToDDITables] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_156_MappingSqlServerDMVToDDITables]
GO
PRINT N'Adding constraints to [DDI].[IndexColumnStorePartitions]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexColumnStorePartitions_OptionDataCompression]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexColumnStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexColumnStorePartitions] ADD CONSTRAINT [Chk_IndexColumnStorePartitions_OptionDataCompression] CHECK (([OptionDataCompression]='COLUMNSTORE_ARCHIVE' OR [OptionDataCompression]='COLUMNSTORE'))
GO
PRINT N'Adding constraints to [DDI].[IndexRowStorePartitions]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexRowStorePartitions_OptionDataCompression]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [Chk_IndexRowStorePartitions_OptionDataCompression] CHECK (([OptionDataCompression]='PAGE' OR [OptionDataCompression]='ROW' OR [OptionDataCompression]='NONE'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexRowStorePartitions_PartitionType]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [Chk_IndexRowStorePartitions_PartitionType] CHECK (([PartitionType]='RowStore'))
GO
PRINT N'Adding constraints to [DDI].[IndexesColumnStore]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_OptionDataCompression]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_OptionDataCompression] CHECK (([OptionDataCompression_Desired]='COLUMNSTORE_ARCHIVE' OR [OptionDataCompression_Desired]='COLUMNSTORE'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Def_IndexesColumnStore_StorageType_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Def_IndexesColumnStore_StorageType_Desired] CHECK (([StorageType_Desired]='PARTITION_SCHEME' OR [StorageType_Desired]='ROWS_FILEGROUP'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Def_IndexesColumnStore_StorageType_Actual]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Def_IndexesColumnStore_StorageType_Actual] CHECK (([StorageType_Actual]='PARTITION_SCHEME' OR [StorageType_Actual]='ROWS_FILEGROUP'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_FragmentationType]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_FragmentationType] CHECK (([FragmentationType]='Heavy' OR [FragmentationType]='Light' OR [FragmentationType]='None'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_AreReorgOptionsChanging]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_AreReorgOptionsChanging] CHECK (([AreReorgOptionsChanging]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_AreSetOptionsChanging]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_AreSetOptionsChanging] CHECK (([AreSetOptionsChanging]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_Filter]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL AND [IsClustered_Desired]=(0) OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
PRINT N'Adding constraints to [DDI].[IndexesRowStore]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_IsUniqueConstraint_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_IsUniqueConstraint_Desired] CHECK (([IsUniqueConstraint_Desired]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Indexes_FillFactor_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_Indexes_FillFactor_Desired] CHECK (([Fillfactor_Desired]>=(0) AND [Fillfactor_Desired]<=(100)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_OptionDataCompression_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_OptionDataCompression_Desired] CHECK (([OptionDataCompression_Desired]='PAGE' OR [OptionDataCompression_Desired]='ROW' OR [OptionDataCompression_Desired]='NONE'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_OptionDataCompressionDelay_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_OptionDataCompressionDelay_Desired] CHECK (([OptionDataCompressionDelay_Desired]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_OptionDataCompressionDelay_Actual]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_OptionDataCompressionDelay_Actual] CHECK (([OptionDataCompressionDelay_Actual]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Def_IndexesRowStore_StorageType_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Def_IndexesRowStore_StorageType_Desired] CHECK (([StorageType_Desired]='PARTITION_SCHEME' OR [StorageType_Desired]='ROWS_FILEGROUP'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Def_IndexesRowStore_StorageType_Actual]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Def_IndexesRowStore_StorageType_Actual] CHECK (([StorageType_Actual]='PARTITION_SCHEME' OR [StorageType_Actual]='ROWS_FILEGROUP'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_FragmentationType]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_FragmentationType] CHECK (([FragmentationType]='Heavy' OR [FragmentationType]='Light' OR [FragmentationType]='None'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_Filter]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL AND [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0) AND [IsClustered_Desired]=(0) AND [OptionStatisticsIncremental_Desired]=(0) OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_IncludedColumnsNotAllowed]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_IncludedColumnsNotAllowed] CHECK ((([IncludedColumnList_Desired] IS NOT NULL AND [IsClustered_Desired]=(0) AND [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0)) OR [IncludedColumnList_Desired] IS NULL))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_PKvsUQ]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_PKvsUQ] CHECK (([IsPrimaryKey_Desired]=(1) AND [IsUniqueConstraint_Desired]=(0) OR [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(1) OR [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_PrimaryKeyIsUnique]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_PrimaryKeyIsUnique] CHECK ((([IsPrimaryKey_Desired]=(1) AND [IsUnique_Desired]=(1)) OR [IsPrimaryKey_Desired]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_UniqueConstraintIsUnique]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_UniqueConstraintIsUnique] CHECK ((([IsUniqueConstraint_Desired]=(1) AND [IsUnique_Desired]=(1)) OR [IsUniqueConstraint_Desired]=(0)))
GO
PRINT N'Adding constraints to [DDI].[Statistics]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Statistics_SampleSize_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Statistics]', 'U'))
ALTER TABLE [DDI].[Statistics] ADD CONSTRAINT [Chk_Statistics_SampleSize_Desired] CHECK (([SampleSizePct_Desired]>=(0) AND [SampleSizePct_Desired]<=(100)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Statistics_SampleSize_Actual]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Statistics]', 'U'))
ALTER TABLE [DDI].[Statistics] ADD CONSTRAINT [Chk_Statistics_SampleSize_Actual] CHECK (([SampleSizePct_Actual]>=(0) AND [SampleSizePct_Actual]<=(100)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Statistics_Filter]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Statistics]', 'U'))
ALTER TABLE [DDI].[Statistics] ADD CONSTRAINT [Chk_Statistics_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
PRINT N'Adding constraints to [DDI].[Tables]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Tables_PartitioningSetup]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Tables]', 'U'))
ALTER TABLE [DDI].[Tables] ADD CONSTRAINT [Chk_Tables_PartitioningSetup] CHECK (([IntendToPartition]=(1) AND [PartitionColumn] IS NOT NULL OR [IntendToPartition]=(0) AND [PartitionColumn] IS NULL))
GO
PRINT N'Adding foreign keys to [DDI].[CheckConstraints]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_CheckConstraints_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[CheckConstraints]', 'U'))
ALTER TABLE [DDI].[CheckConstraints] ADD CONSTRAINT [FK_CheckConstraints_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
PRINT N'Adding foreign keys to [DDI].[DefaultConstraints]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_DefaultConstraints_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[DefaultConstraints]', 'U'))
ALTER TABLE [DDI].[DefaultConstraints] ADD CONSTRAINT [FK_DefaultConstraints_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
PRINT N'Adding foreign keys to [DDI].[ForeignKeys]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_ForeignKeys_ParentTables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[ForeignKeys]', 'U'))
ALTER TABLE [DDI].[ForeignKeys] ADD CONSTRAINT [FK_ForeignKeys_ParentTables] FOREIGN KEY ([DatabaseName], [ParentSchemaName], [ParentTableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_ForeignKeys_ReferencedTables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[ForeignKeys]', 'U'))
ALTER TABLE [DDI].[ForeignKeys] ADD CONSTRAINT [FK_ForeignKeys_ReferencedTables] FOREIGN KEY ([DatabaseName], [ReferencedSchemaName], [ReferencedTableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
PRINT N'Adding foreign keys to [DDI].[IndexColumnStorePartitions]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexColumnStorePartitions_IndexesColumnStore]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexColumnStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexColumnStorePartitions] ADD CONSTRAINT [FK_IndexColumnStorePartitions_IndexesColumnStore] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName], [IndexName]) REFERENCES [DDI].[IndexesColumnStore] ([DatabaseName], [SchemaName], [TableName], [IndexName])
GO
PRINT N'Adding foreign keys to [DDI].[IndexColumns]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexColumns_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexColumns]', 'U'))
ALTER TABLE [DDI].[IndexColumns] ADD CONSTRAINT [FK_IndexColumns_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
PRINT N'Adding foreign keys to [DDI].[IndexRowStorePartitions]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexRowStorePartitions_IndexesRowStore]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [FK_IndexRowStorePartitions_IndexesRowStore] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName], [IndexName]) REFERENCES [DDI].[IndexesRowStore] ([DatabaseName], [SchemaName], [TableName], [IndexName])
GO
PRINT N'Adding foreign keys to [DDI].[IndexesColumnStore]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexesColumnStore_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [FK_IndexesColumnStore_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
PRINT N'Adding foreign keys to [DDI].[IndexesRowStore]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexesRowStore_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [FK_IndexesRowStore_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
PRINT N'Adding foreign keys to [DDI].[Statistics]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_Statistics_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[Statistics]', 'U'))
ALTER TABLE [DDI].[Statistics] ADD CONSTRAINT [FK_Statistics_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
PRINT N'Disabling constraints on [DDI].[CheckConstraints]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_CheckConstraints_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[CheckConstraints]', 'U'))
ALTER TABLE [DDI].[CheckConstraints] NOCHECK CONSTRAINT [FK_CheckConstraints_Tables]
GO
PRINT N'Disabling constraints on [DDI].[DefaultConstraints]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_DefaultConstraints_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[DefaultConstraints]', 'U'))
ALTER TABLE [DDI].[DefaultConstraints] NOCHECK CONSTRAINT [FK_DefaultConstraints_Tables]
GO
PRINT N'Disabling constraints on [DDI].[ForeignKeys]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_ForeignKeys_ParentTables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[ForeignKeys]', 'U'))
ALTER TABLE [DDI].[ForeignKeys] NOCHECK CONSTRAINT [FK_ForeignKeys_ParentTables]
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_ForeignKeys_ReferencedTables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[ForeignKeys]', 'U'))
ALTER TABLE [DDI].[ForeignKeys] NOCHECK CONSTRAINT [FK_ForeignKeys_ReferencedTables]
GO
PRINT N'Disabling constraints on [DDI].[IndexColumnStorePartitions]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexColumnStorePartitions_IndexesColumnStore]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexColumnStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexColumnStorePartitions] NOCHECK CONSTRAINT [FK_IndexColumnStorePartitions_IndexesColumnStore]
GO
PRINT N'Disabling constraints on [DDI].[IndexColumns]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexColumns_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexColumns]', 'U'))
ALTER TABLE [DDI].[IndexColumns] NOCHECK CONSTRAINT [FK_IndexColumns_Tables]
GO
PRINT N'Disabling constraints on [DDI].[IndexRowStorePartitions]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexRowStorePartitions_IndexesRowStore]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] NOCHECK CONSTRAINT [FK_IndexRowStorePartitions_IndexesRowStore]
GO
PRINT N'Disabling constraints on [DDI].[IndexesColumnStore]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexesColumnStore_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] NOCHECK CONSTRAINT [FK_IndexesColumnStore_Tables]
GO
PRINT N'Disabling constraints on [DDI].[IndexesRowStore]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexesRowStore_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] NOCHECK CONSTRAINT [FK_IndexesRowStore_Tables]
GO
PRINT N'Disabling constraints on [DDI].[Statistics]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_Statistics_Tables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[Statistics]', 'U'))
ALTER TABLE [DDI].[Statistics] NOCHECK CONSTRAINT [FK_Statistics_Tables]
GO
