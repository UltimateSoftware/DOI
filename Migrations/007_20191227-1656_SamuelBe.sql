-- <Migration ID="f29b1dc0-8fc2-4b61-a9c6-5f80c910e47d" TransactionHandling="Custom" />
GO

PRINT N'Rebuilding [DDI].[IndexRowStorePartitions]'
GO
CREATE TABLE [DDI].[RG_Recovery_1_IndexRowStorePartitions]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionResumable] [bit] NOT NULL CONSTRAINT [RG_Recovery_2_IndexRowStorePartitions] DEFAULT ((0)),
[OptionMaxDuration] [smallint] NOT NULL CONSTRAINT [RG_Recovery_3_IndexRowStorePartitions] DEFAULT ((0)),
[OptionDataCompression] [nvarchar] (60) NOT NULL CONSTRAINT [RG_Recovery_4_IndexRowStorePartitions] DEFAULT ('PAGE'),
[NumRows] [bigint] NOT NULL CONSTRAINT [RG_Recovery_5_IndexRowStorePartitions] DEFAULT ((0)),
[TotalPages] [bigint] NOT NULL CONSTRAINT [RG_Recovery_6_IndexRowStorePartitions] DEFAULT ((0)),
[PartitionType] [varchar] (20) NOT NULL CONSTRAINT [RG_Recovery_7_IndexRowStorePartitions] DEFAULT ('RowStore'),
[TotalIndexPartitionSizeInMB] [decimal] (10, 2) NOT NULL CONSTRAINT [RG_Recovery_8_IndexRowStorePartitions] DEFAULT ((0.00)),
[Fragmentation] [float] NOT NULL CONSTRAINT [RG_Recovery_9_IndexRowStorePartitions] DEFAULT ((0)),
[DataFileName] [nvarchar] (260) NOT NULL CONSTRAINT [RG_Recovery_10_IndexRowStorePartitions] DEFAULT (''),
[DriveLetter] [char] (1) NOT NULL CONSTRAINT [RG_Recovery_11_IndexRowStorePartitions] DEFAULT (''),
[PartitionUpdateType] [varchar] (30) NOT NULL CONSTRAINT [RG_Recovery_12_IndexRowStorePartitions] DEFAULT ('None')
)
GO
INSERT INTO [DDI].[RG_Recovery_1_IndexRowStorePartitions]([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType] FROM [DDI].[IndexRowStorePartitions]
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
INSERT INTO [DDI].[IndexRowStorePartitions]([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [NumRows], [TotalPages], [PartitionType], [TotalIndexPartitionSizeInMB], [Fragmentation], [DataFileName], [DriveLetter], [PartitionUpdateType] FROM [DDI].[RG_Recovery_1_IndexRowStorePartitions]
GO
UPDATE STATISTICS [DDI].[IndexRowStorePartitions] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_1_IndexRowStorePartitions]
GO
PRINT N'Rebuilding [DDI].[Queue]'
GO
CREATE TABLE [DDI].[RG_Recovery_13_Queue]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[PartitionNumber] [smallint] NOT NULL CONSTRAINT [RG_Recovery_14_Queue] DEFAULT ((1)),
[IndexSizeInMB] [int] NOT NULL,
[ParentSchemaName] [nvarchar] (128) NULL,
[ParentTableName] [nvarchar] (128) NULL,
[ParentIndexName] [nvarchar] (128) NULL,
[IndexOperation] [varchar] (50) NOT NULL,
[IsOnlineOperation] [bit] NOT NULL,
[TableChildOperationId] [smallint] NOT NULL CONSTRAINT [RG_Recovery_15_Queue] DEFAULT ((0)),
[SQLStatement] [varchar] (max) NOT NULL,
[SeqNo] [int] NOT NULL,
[DateTimeInserted] [datetime2] NOT NULL CONSTRAINT [RG_Recovery_16_Queue] DEFAULT (sysdatetime()),
[InProgress] [bit] NOT NULL CONSTRAINT [RG_Recovery_17_Queue] DEFAULT ((0)),
[RunStatus] [varchar] (7) NOT NULL CONSTRAINT [RG_Recovery_18_Queue] DEFAULT ('Running'),
[ErrorMessage] [varchar] (max) NULL,
[TransactionId] [uniqueidentifier] NULL,
[BatchId] [uniqueidentifier] NOT NULL,
[ExitTableLoopOnError] [bit] NOT NULL CONSTRAINT [RG_Recovery_19_Queue] DEFAULT ((0))
)
GO
INSERT INTO [DDI].[RG_Recovery_13_Queue]([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexSizeInMB], [ParentSchemaName], [ParentTableName], [ParentIndexName], [IndexOperation], [IsOnlineOperation], [TableChildOperationId], [SQLStatement], [SeqNo], [DateTimeInserted], [InProgress], [RunStatus], [ErrorMessage], [TransactionId], [BatchId], [ExitTableLoopOnError]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexSizeInMB], [ParentSchemaName], [ParentTableName], [ParentIndexName], [IndexOperation], [IsOnlineOperation], [TableChildOperationId], [SQLStatement], [SeqNo], [DateTimeInserted], [InProgress], [RunStatus], [ErrorMessage], [TransactionId], [BatchId], [ExitTableLoopOnError] FROM [DDI].[Queue]
GO
DROP TABLE [DDI].[Queue]
GO
CREATE TABLE [DDI].[Queue]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL CONSTRAINT [Def_Queue_PartitionNumber] DEFAULT ((1)),
[IndexSizeInMB] [int] NOT NULL,
[ParentSchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentTableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentIndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IndexOperation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsOnlineOperation] [bit] NOT NULL,
[TableChildOperationId] [smallint] NOT NULL CONSTRAINT [Def_Queue_TableChildOperationId] DEFAULT ((0)),
[SQLStatement] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeqNo] [int] NOT NULL,
[DateTimeInserted] [datetime2] NOT NULL CONSTRAINT [Def_Queue_DateTimeInserted] DEFAULT (sysdatetime()),
[InProgress] [bit] NOT NULL CONSTRAINT [Def_Queue_InProgress] DEFAULT ((0)),
[RunStatus] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_Queue_RunStatus] DEFAULT ('Running'),
[ErrorMessage] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionId] [uniqueidentifier] NULL,
[BatchId] [uniqueidentifier] NOT NULL,
[ExitTableLoopOnError] [bit] NOT NULL CONSTRAINT [Def_Queue_ExitTableLoopOnError] DEFAULT ((0)),
CONSTRAINT [PK_Queue] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [TableChildOperationId])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
INSERT INTO [DDI].[Queue]([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexSizeInMB], [ParentSchemaName], [ParentTableName], [ParentIndexName], [IndexOperation], [IsOnlineOperation], [TableChildOperationId], [SQLStatement], [SeqNo], [DateTimeInserted], [InProgress], [RunStatus], [ErrorMessage], [TransactionId], [BatchId], [ExitTableLoopOnError]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexSizeInMB], [ParentSchemaName], [ParentTableName], [ParentIndexName], [IndexOperation], [IsOnlineOperation], [TableChildOperationId], [SQLStatement], [SeqNo], [DateTimeInserted], [InProgress], [RunStatus], [ErrorMessage], [TransactionId], [BatchId], [ExitTableLoopOnError] FROM [DDI].[RG_Recovery_13_Queue]
GO
UPDATE STATISTICS [DDI].[Queue] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_13_Queue]
GO
PRINT N'Adding constraints to [DDI].[IndexRowStorePartitions]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexRowStorePartitions_OptionDataCompression]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [Chk_IndexRowStorePartitions_OptionDataCompression] CHECK (([OptionDataCompression]='PAGE' OR [OptionDataCompression]='ROW' OR [OptionDataCompression]='NONE'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexRowStorePartitions_PartitionType]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [Chk_IndexRowStorePartitions_PartitionType] CHECK (([PartitionType]='RowStore'))
GO
PRINT N'Adding constraints to [DDI].[Queue]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Queue_IndexOperation]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Queue]', 'U'))
ALTER TABLE [DDI].[Queue] ADD CONSTRAINT [Chk_Queue_IndexOperation] CHECK (([IndexOperation]='Delay' OR [IndexOperation]='Update Statistics' OR [IndexOperation]='Create Statistics' OR [IndexOperation]='Drop Statistics' OR [IndexOperation]='Delete PartitionState Metadata' OR [IndexOperation]='Partition State Metadata Validation' OR [IndexOperation]='Resource Governor Settings' OR [IndexOperation]='Release Application Lock' OR [IndexOperation]='Get Application Lock' OR [IndexOperation]='Kill' OR [IndexOperation]='Clean Up Tables' OR [IndexOperation]='Turn Off DataSynch' OR [IndexOperation]='Turn On DataSynch' OR [IndexOperation]='Clear Queue of Other Tables' OR [IndexOperation]='Data Synch Trigger Revert Rename' OR [IndexOperation]='Free TempDB Space Validation' OR [IndexOperation]='Free Log Space Validation' OR [IndexOperation]='Free Data Space Validation' OR [IndexOperation]='Stop Processing' OR [IndexOperation]='Table Revert Rename' OR [IndexOperation]='Constraint Revert Rename' OR [IndexOperation]='Index Revert Rename' OR [IndexOperation]='Prior Error Validation SQL' OR [IndexOperation]='Partition Data Validation SQL' OR [IndexOperation]='Drop Data Synch Table' OR [IndexOperation]='Drop Data Synch Trigger' OR [IndexOperation]='Rename Data Synch Table' OR [IndexOperation]='Delete from Queue' OR [IndexOperation]='Update to In-Progress' OR [IndexOperation]='FinalValidation' OR [IndexOperation]='Temp Table SQL' OR [IndexOperation]='Drop Parent Old Table FKs' OR [IndexOperation]='Drop Ref Old Table FKs' OR [IndexOperation]='Add back Parent Table FKs' OR [IndexOperation]='Add back Ref Table FKs' OR [IndexOperation]='Disable CmdShell' OR [IndexOperation]='Enable CmdShell' OR [IndexOperation]='Rollback DDL' OR [IndexOperation]='Synch Updates' OR [IndexOperation]='Synch Inserts' OR [IndexOperation]='Synch Deletes' OR [IndexOperation]='Rename Existing Table Constraint' OR [IndexOperation]='Rename Existing Table Index' OR [IndexOperation]='Rename New Partitioned Prep Table Constraint' OR [IndexOperation]='Rename New Partitioned Prep Table Index' OR [IndexOperation]='Rename Existing Table' OR [IndexOperation]='Rename New Partitioned Prep Table' OR [IndexOperation]='Drop Table SQL' OR [IndexOperation]='Check Constraint SQL' OR [IndexOperation]='Commit Tran' OR [IndexOperation]='Begin Tran' OR [IndexOperation]='Switch Partitions SQL' OR [IndexOperation]='Partition Prep Table SQL' OR [IndexOperation]='Drop Ref FKs' OR [IndexOperation]='Recreate All FKs' OR [IndexOperation]='Loading Data' OR [IndexOperation]='Create Final Data Synch Trigger' OR [IndexOperation]='Create Final Data Synch Table' OR [IndexOperation]='Create Data Synch Trigger' OR [IndexOperation]='Prep Table SQL' OR [IndexOperation]='Alter Index' OR [IndexOperation]='Create Constraint' OR [IndexOperation]='Create Index' OR [IndexOperation]='Drop Index'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Queue_RunStatus]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Queue]', 'U'))
ALTER TABLE [DDI].[Queue] ADD CONSTRAINT [Chk_Queue_RunStatus] CHECK (([RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
PRINT N'Adding foreign keys to [DDI].[IndexRowStorePartitions]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DDI].[FK_IndexRowStorePartitions_IndexesRowStore]','F') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [FK_IndexRowStorePartitions_IndexesRowStore] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName], [IndexName]) REFERENCES [DDI].[IndexesRowStore] ([DatabaseName], [SchemaName], [TableName], [IndexName])
GO
