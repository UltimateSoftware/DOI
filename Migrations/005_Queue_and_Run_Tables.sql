-- <Migration ID="141260d1-5e71-4da3-b392-f8106a4568d5" TransactionHandling="Custom" />
GO
DROP TABLE IF EXISTS [DDI].[Queue]
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
ALTER TABLE [DDI].[Queue] ADD CONSTRAINT [Chk_Queue_IndexOperation] CHECK (([IndexOperation]='Delay' OR [IndexOperation]='Update Statistics' OR [IndexOperation]='Create Statistics' OR [IndexOperation]='Drop Statistics' OR [IndexOperation]='Delete PartitionState Metadata' OR [IndexOperation]='Partition State Metadata Validation' OR [IndexOperation]='Resource Governor Settings' OR [IndexOperation]='Release Application Lock' OR [IndexOperation]='Get Application Lock' OR [IndexOperation]='Kill' OR [IndexOperation]='Clean Up Tables' OR [IndexOperation]='Turn Off DataSynch' OR [IndexOperation]='Turn On DataSynch' OR [IndexOperation]='Clear Queue of Other Tables' OR [IndexOperation]='Data Synch Trigger Revert Rename' OR [IndexOperation]='Free TempDB Space Validation' OR [IndexOperation]='Free Log Space Validation' OR [IndexOperation]='Free Data Space Validation' OR [IndexOperation]='Stop Processing' OR [IndexOperation]='Table Revert Rename' OR [IndexOperation]='Constraint Revert Rename' OR [IndexOperation]='Index Revert Rename' OR [IndexOperation]='Prior Error Validation SQL' OR [IndexOperation]='Partition Data Validation SQL' OR [IndexOperation]='Drop Data Synch Table' OR [IndexOperation]='Drop Data Synch Trigger' OR [IndexOperation]='Rename Data Synch Table' OR [IndexOperation]='Delete from Queue' OR [IndexOperation]='Update to In-Progress' OR [IndexOperation]='FinalValidation' OR [IndexOperation]='Temp Table SQL' OR [IndexOperation]='Drop Parent Old Table FKs' OR [IndexOperation]='Drop Ref Old Table FKs' OR [IndexOperation]='Add back Parent Table FKs' OR [IndexOperation]='Add back Ref Table FKs' OR [IndexOperation]='Disable CmdShell' OR [IndexOperation]='Enable CmdShell' OR [IndexOperation]='Rollback DDL' OR [IndexOperation]='Synch Updates' OR [IndexOperation]='Synch Inserts' OR [IndexOperation]='Synch Deletes' OR [IndexOperation]='Rename Existing Table Constraint' OR [IndexOperation]='Rename Existing Table Index' OR [IndexOperation]='Rename New Partitioned Prep Table Constraint' OR [IndexOperation]='Rename New Partitioned Prep Table Index' OR [IndexOperation]='Rename Existing Table' OR [IndexOperation]='Rename New Partitioned Prep Table' OR [IndexOperation]='Drop Table SQL' OR [IndexOperation]='Check Constraint SQL' OR [IndexOperation]='Commit Tran' OR [IndexOperation]='Begin Tran' OR [IndexOperation]='Switch Partitions SQL' OR [IndexOperation]='Partition Prep Table SQL' OR [IndexOperation]='Drop Ref FKs' OR [IndexOperation]='Recreate All FKs' OR [IndexOperation]='Loading Data' OR [IndexOperation]='Create Final Data Synch Trigger' OR [IndexOperation]='Create Final Data Synch Table' OR [IndexOperation]='Create Data Synch Trigger' OR [IndexOperation]='Prep Table SQL' OR [IndexOperation]='Alter Index' OR [IndexOperation]='Create Constraint' OR [IndexOperation]='Create Index' OR [IndexOperation]='Drop Index' OR [IndexOperation]='Change DB'))
GO
ALTER TABLE [DDI].[Queue] ADD CONSTRAINT [Chk_Queue_RunStatus] CHECK (([RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
ALTER TABLE [DDI].[Queue] ADD CONSTRAINT [FK_Queue_Databases] FOREIGN KEY ([DatabaseName]) REFERENCES [DDI].[Databases] ([DatabaseName])
GO
ALTER TABLE [DDI].[Queue] NOCHECK CONSTRAINT [FK_Queue_Databases]
GO
DROP TABLE IF EXISTS [DDI].[Log]
GO
CREATE TABLE [DDI].[Log]
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
[IndexOperation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsOnlineOperation] [bit] NOT NULL,
[RowCount] [int] NOT NULL,
[TableChildOperationId] [smallint] NOT NULL,
[RunStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorText] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionId] [uniqueidentifier] NULL,
[BatchId] [uniqueidentifier] NOT NULL,
[SeqNo] [int] NOT NULL,
[ExitTableLoopOnError] [bit] NOT NULL,
CONSTRAINT [PK_Log] PRIMARY KEY NONCLUSTERED  ([LogID]),
CONSTRAINT [UQ_Log] UNIQUE NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [RunStatus], [TableChildOperationId], [LogDateTime])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DDI].[Log] ADD CONSTRAINT [Chk_Log_RunStatus] CHECK (([RunStatus]='Error - Skipping...' OR [RunStatus]='Error - Retrying...' OR [RunStatus]='Error' OR [RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
ALTER TABLE [DDI].[Log] ADD CONSTRAINT [FK_Log_Databases] FOREIGN KEY ([DatabaseName]) REFERENCES [DDI].[Databases] ([DatabaseName])
GO
ALTER TABLE [DDI].[Log] NOCHECK CONSTRAINT [FK_Log_Databases]
GO
DROP TABLE IF EXISTS [DDI].[Run_PartitionState]
GO
CREATE TABLE [DDI].[Run_PartitionState]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[PrepTableName] [sys].[sysname] NOT NULL,
[PartitionFromValue] [date] NOT NULL,
[PartitionToValue] [date] NOT NULL,
[DataSynchState] [bit] NOT NULL,
[LastUpdateDateTime] [datetime] NULL CONSTRAINT [Def_Run_PartitionState_LastUpdateDateTime] DEFAULT (getdate()),
CONSTRAINT [PK_Run_PartitionState] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [ParentTableName], [PrepTableName], [PartitionFromValue])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DDI].[Run_PartitionState] ADD CONSTRAINT [FK_Run_PartitionState_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [ParentTableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
ALTER TABLE [DDI].[Run_PartitionState] NOCHECK CONSTRAINT [FK_Run_PartitionState_Tables]
GO
