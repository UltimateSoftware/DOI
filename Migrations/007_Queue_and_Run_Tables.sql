-- <Migration ID="141260d1-5e71-4da3-b392-f8106a4568d5" TransactionHandling="Custom" />
IF OBJECT_ID('[DOI].[Queue]') IS NULL
CREATE TABLE [DOI].[Queue]
(
[DatabaseName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [SMALLINT] NOT NULL CONSTRAINT [Def_Queue_PartitionNumber] DEFAULT ((1)),
[IndexSizeInMB] [INT] NOT NULL,
[ParentSchemaName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentTableName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentIndexName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IndexOperation] [VARCHAR] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsOnlineOperation] [BIT] NOT NULL,
[TableChildOperationId] [SMALLINT] NOT NULL CONSTRAINT [Def_Queue_TableChildOperationId] DEFAULT ((0)),
[SQLStatement] [VARCHAR] (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeqNo] [INT] NOT NULL,
[DateTimeInserted] [DATETIME2] NOT NULL CONSTRAINT [Def_Queue_DateTimeInserted] DEFAULT (SYSDATETIME()),
[InProgress] [BIT] NOT NULL CONSTRAINT [Def_Queue_InProgress] DEFAULT ((0)),
[RunStatus] [VARCHAR] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_Queue_RunStatus] DEFAULT ('Running'),
[ErrorMessage] [VARCHAR] (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionId] [UNIQUEIDENTIFIER] NULL,
[BatchId] [UNIQUEIDENTIFIER] NOT NULL,
[ExitTableLoopOnError] [BIT] NOT NULL CONSTRAINT [Def_Queue_ExitTableLoopOnError] DEFAULT ((0)),
CONSTRAINT [PK_Queue] PRIMARY KEY CLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [TableChildOperationId])
)
GO
IF OBJECT_ID('[DOI].[Chk_Queue_IndexOperation]') IS NULL
ALTER TABLE [DOI].[Queue] ADD CONSTRAINT [Chk_Queue_IndexOperation] CHECK (([IndexOperation]='Delay' OR [IndexOperation]='Update Statistics' OR [IndexOperation]='Create Statistics' OR [IndexOperation]='Drop Statistics' OR [IndexOperation]='Delete PartitionState Metadata' OR [IndexOperation]='Partition State Metadata Validation' OR [IndexOperation]='Resource Governor Settings' OR [IndexOperation]='Release Application Lock' OR [IndexOperation]='Get Application Lock' OR [IndexOperation]='Kill' OR [IndexOperation]='Clean Up Tables' OR [IndexOperation]='Turn Off DataSynch' OR [IndexOperation]='Turn On DataSynch' OR [IndexOperation]='Clear Queue of Other Tables' OR [IndexOperation]='Data Synch Trigger Revert Rename' OR [IndexOperation]='Free TempDB Space Validation' OR [IndexOperation]='Free Log Space Validation' OR [IndexOperation]='Free Data Space Validation' OR [IndexOperation]='Stop Processing' OR [IndexOperation]='Table Revert Rename' OR [IndexOperation]='Constraint Revert Rename' OR [IndexOperation]='Index Revert Rename' OR [IndexOperation]='Prior Error Validation SQL' OR [IndexOperation]='Partition Data Validation SQL' OR [IndexOperation]='Drop Data Synch Table' OR [IndexOperation]='Drop Data Synch Trigger' OR [IndexOperation]='Rename Data Synch Table' OR [IndexOperation]='Delete from Queue' OR [IndexOperation]='Update to In-Progress' OR [IndexOperation]='FinalValidation' OR [IndexOperation]='Temp Table SQL' OR [IndexOperation]='Drop Parent Old Table FKs' OR [IndexOperation]='Drop Ref Old Table FKs' OR [IndexOperation]='Add back Parent Table FKs' OR [IndexOperation]='Add back Ref Table FKs' OR [IndexOperation]='Disable CmdShell' OR [IndexOperation]='Enable CmdShell' OR [IndexOperation]='Rollback DDL' OR [IndexOperation]='Synch Updates' OR [IndexOperation]='Synch Inserts' OR [IndexOperation]='Synch Deletes' OR [IndexOperation]='Rename Existing Table Constraint' OR [IndexOperation]='Rename Existing Table Index' OR [IndexOperation]='Rename New Partitioned Prep Table Constraint' OR [IndexOperation]='Rename New Partitioned Prep Table Index' OR [IndexOperation]='Rename Existing Table' OR [IndexOperation]='Rename New Partitioned Prep Table' OR [IndexOperation]='Drop Table SQL' OR [IndexOperation]='Check Constraint SQL' OR [IndexOperation]='Commit Tran' OR [IndexOperation]='Begin Tran' OR [IndexOperation]='Switch Partitions SQL' OR [IndexOperation]='Partition Prep Table SQL' OR [IndexOperation]='Drop Ref FKs' OR [IndexOperation]='Recreate All FKs' OR [IndexOperation]='Loading Data' OR [IndexOperation]='Create Final Data Synch Trigger' OR [IndexOperation]='Create Final Data Synch Table' OR [IndexOperation]='Create Data Synch Trigger' OR [IndexOperation]='Prep Table SQL' OR [IndexOperation]='Alter Index' OR [IndexOperation]='Create Constraint' OR [IndexOperation]='Create Index' OR [IndexOperation]='Drop Index' OR [IndexOperation]='Change DB' OR [IndexOperation]='Create BCP View' OR [IndexOperation]='Drop BCP View' OR [IndexOperation]='Rename Existing Statistic' OR [IndexOperation]='Create Missing Table Statistic' OR [IndexOperation]='Statistics Revert Rename' OR [IndexOperation]='Manual SQL Command' OR [IndexOperation]='Post Partitioning Data Validation' OR [IndexOperation]='Drop Trigger' OR [IndexOperation]='Create Trigger' OR [IndexOperation]='Drop Trigger Revert Rename' OR [IndexOperation]='Create Trigger Revert Rename' OR [IndexOperation]='CreateDropExisting' OR [IndexOperation]='ExchangeTableNonPartitioned_CreatePrepTable' OR [IndexOperation]='ExchangeTableNonPartitioned_CreatePrepTableConstraints' OR [IndexOperation]='ExchangeTableNonPartitioned_CreateDataSynchTable' OR [IndexOperation]='ExchangeTableNonPartitioned_CreateDataSynchTrigger' OR [IndexOperation]='ExchangeTableNonPartitioned_LoadData' OR [IndexOperation]='ExchangeTableNonPartitioned_CreatePrepTableIndexes' OR [IndexOperation]='ExchangeTableNonPartitioned_CreatePrepTableStatistics' OR [IndexOperation]='ExchangeTableNonPartitioned_BeginTran' OR [IndexOperation]='ExchangeTableNonPartitioned_RenameExistingTable' OR [IndexOperation]='ExchangeTableNonPartitioned_RenameNewTable' OR [IndexOperation]='ExchangeTableNonPartitioned_CommitTran' OR [IndexOperation]='ExchangeTableNonPartitioned_DropDataSynchTrigger' OR [IndexOperation]='ExchangeTableNonPartitioned_DropDataSynchTable' OR [IndexOperation]='ExchangeTableNonPartitioned_CreateViewForBCP'))
GO

IF OBJECT_ID('[DOI].[Chk_Queue_RunStatus]') IS NULL
ALTER TABLE [DOI].[Queue] ADD CONSTRAINT [Chk_Queue_RunStatus] CHECK (([RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO

IF OBJECT_ID('[DOI].[Log]') IS NULL
CREATE TABLE [DOI].[Log]
(
[LogID] [int] NOT NULL IDENTITY(1, 1),
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL CONSTRAINT [Def_Log_PartitionNumber] DEFAULT ((1)),
[IndexSizeInMB] [int] NOT NULL,
[LoginName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogDateTime] [datetime2] NOT NULL CONSTRAINT [Def_Log_LogDateTime] DEFAULT (sysdatetime()),
[SQLStatement] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IndexOperation] [varchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RowCount] [int] NOT NULL,
[TableChildOperationId] [smallint] NOT NULL,
[RunStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorText] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InfoMessage] [VARCHAR] (MAX) NULL,
[TransactionId] [uniqueidentifier] NULL,
[BatchId] [uniqueidentifier] NOT NULL,
[SeqNo] [int] NOT NULL,
[ExitTableLoopOnError] [bit] NOT NULL,
CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED  ([LogID]),
CONSTRAINT [UQ_Log] UNIQUE NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [RunStatus], [TableChildOperationId], [LogDateTime])
)
GO
IF OBJECT_ID('[DOI].[Chk_Log_RunStatus]') IS NULL
ALTER TABLE [DOI].[Log] ADD CONSTRAINT [Chk_Log_RunStatus] CHECK (([RunStatus]='Error - Skipping...' OR [RunStatus]='Error - Retrying...' OR [RunStatus]='Error' OR [RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start' OR [RunStatus]='Info'))
GO
IF OBJECT_ID('[DOI].[Run_PartitionState]') IS NULL
CREATE TABLE [DOI].[Run_PartitionState]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[PrepTableName] [sys].[sysname] NOT NULL,
[PartitionFromValue] [date] NOT NULL,
[PartitionToValue] [date] NOT NULL,
[DataSynchState] [bit] NOT NULL,
[LastUpdateDateTime] [datetime] NULL CONSTRAINT [Def_Run_PartitionState_LastUpdateDateTime] DEFAULT (getdate()),
CONSTRAINT [PK_Run_PartitionState] PRIMARY KEY CLUSTERED  ([DatabaseName], [SchemaName], [ParentTableName], [PrepTableName], [PartitionFromValue])
)
GO