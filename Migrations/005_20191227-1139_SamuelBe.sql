-- <Migration ID="141260d1-5e71-4da3-b392-f8106a4568d5" TransactionHandling="Custom" />
GO

PRINT N'Dropping foreign keys from [DDI].[IndexRowStorePartitions]'
GO
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexRowStorePartitions_IndexesRowStore]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] DROP CONSTRAINT [FK_IndexRowStorePartitions_IndexesRowStore]
GO
PRINT N'Rebuilding [DDI].[ForeignKeys]'
GO
CREATE TABLE [DDI].[RG_Recovery_1_ForeignKeys]
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
INSERT INTO [DDI].[RG_Recovery_1_ForeignKeys]([DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [ParentColumnList_Actual], [ReferencedColumnList_Actual], [DeploymentTime]) SELECT [DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [ParentColumnList_Actual], [ReferencedColumnList_Actual], [DeploymentTime] FROM [DDI].[ForeignKeys]
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
INSERT INTO [DDI].[ForeignKeys]([DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [ParentColumnList_Actual], [ReferencedColumnList_Actual], [DeploymentTime]) SELECT [DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [ParentColumnList_Actual], [ReferencedColumnList_Actual], [DeploymentTime] FROM [DDI].[RG_Recovery_1_ForeignKeys]
GO
UPDATE STATISTICS [DDI].[ForeignKeys] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_1_ForeignKeys]
GO
PRINT N'Rebuilding [DDI].[IndexRowStorePartitions]'
GO
CREATE TABLE [DDI].[RG_Recovery_2_IndexRowStorePartitions]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionResumable] [bit] NOT NULL CONSTRAINT [RG_Recovery_3_IndexRowStorePartitions] DEFAULT ((0)),
[OptionMaxDuration] [smallint] NOT NULL CONSTRAINT [RG_Recovery_4_IndexRowStorePartitions] DEFAULT ((0)),
[OptionDataCompression] [nvarchar] (60) NOT NULL CONSTRAINT [RG_Recovery_5_IndexRowStorePartitions] DEFAULT ('PAGE'),
[NumRows] [bigint] NOT NULL CONSTRAINT [RG_Recovery_6_IndexRowStorePartitions] DEFAULT ((0)),
[TotalPages] [bigint] NOT NULL CONSTRAINT [RG_Recovery_7_IndexRowStorePartitions] DEFAULT ((0)),
[PartitionType] [varchar] (20) NOT NULL CONSTRAINT [RG_Recovery_8_IndexRowStorePartitions] DEFAULT ('RowStore'),
[TotalIndexPartitionSizeInMB] [decimal] (10, 2) NOT NULL CONSTRAINT [RG_Recovery_9_IndexRowStorePartitions] DEFAULT ((0.00)),
[Fragmentation] [float] NOT NULL CONSTRAINT [RG_Recovery_10_IndexRowStorePartitions] DEFAULT ((0)),
[DataFileName] [nvarchar] (260) NOT NULL CONSTRAINT [RG_Recovery_11_IndexRowStorePartitions] DEFAULT (''),
[DriveLetter] [char] (1) NOT NULL CONSTRAINT [RG_Recovery_12_IndexRowStorePartitions] DEFAULT (''),
[PartitionUpdateType] [varchar] (30) NOT NULL CONSTRAINT [RG_Recovery_13_IndexRowStorePartitions] DEFAULT ('None')
)
GO
INSERT INTO [DDI].[RG_Recovery_2_IndexRowStorePartitions]([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType] FROM [DDI].[IndexRowStorePartitions]
GO

DROP FUNCTION IF EXISTS DDI.fnIndexPartitionAgg
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
INSERT INTO [DDI].[IndexRowStorePartitions]([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType] FROM [DDI].[RG_Recovery_2_IndexRowStorePartitions]
GO
UPDATE STATISTICS [DDI].[IndexRowStorePartitions] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_2_IndexRowStorePartitions]
GO
PRINT N'Adding constraints to [DDI].[IndexRowStorePartitions]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexRowStorePartitions_OptionDataCompression]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [Chk_IndexRowStorePartitions_OptionDataCompression] CHECK (([OptionDataCompression]='PAGE' OR [OptionDataCompression]='ROW' OR [OptionDataCompression]='NONE'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexRowStorePartitions_PartitionType]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [Chk_IndexRowStorePartitions_PartitionType] CHECK (([PartitionType]='RowStore'))
GO
PRINT N'Adding foreign keys to [DDI].[ForeignKeys]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_ForeignKeys_ParentTables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[ForeignKeys]', 'U'))
ALTER TABLE [DDI].[ForeignKeys] ADD CONSTRAINT [FK_ForeignKeys_ParentTables] FOREIGN KEY ([DatabaseName], [ParentSchemaName], [ParentTableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_ForeignKeys_ReferencedTables]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[ForeignKeys]', 'U'))
ALTER TABLE [DDI].[ForeignKeys] ADD CONSTRAINT [FK_ForeignKeys_ReferencedTables] FOREIGN KEY ([DatabaseName], [ReferencedSchemaName], [ReferencedTableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
