CREATE TABLE [DDI].[RefreshIndexesQueue]
(
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL CONSTRAINT [Def_RefreshIndexesQueue_PartitionNumber] DEFAULT ((1)),
[IndexSizeInMB] [int] NOT NULL,
[ParentSchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentTableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentIndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IndexOperation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsOnlineOperation] [bit] NOT NULL,
[TableChildOperationId] [smallint] NOT NULL CONSTRAINT [Def_RefreshIndexesQueue_TableChildOperationId] DEFAULT ((0)),
[SQLStatement] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeqNo] [int] NOT NULL,
[DateTimeInserted] [datetime2] NOT NULL CONSTRAINT [Def_RefreshIndexesQueue_DateTimeInserted] DEFAULT (sysdatetime()),
[InProgress] [bit] NOT NULL CONSTRAINT [Def_RefreshIndexesQueue_InProgress] DEFAULT ((0)),
[RunStatus] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_RefreshIndexesQueue_RunStatus] DEFAULT ('Running'),
[ErrorMessage] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionId] [uniqueidentifier] NULL,
[BatchId] [uniqueidentifier] NOT NULL,
[ExitTableLoopOnError] [bit] NOT NULL CONSTRAINT [Def_RefreshIndexStructureQueue] DEFAULT ((0)),
CONSTRAINT [PK_RefreshIndexesQueue] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [TableChildOperationId])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DDI].[RefreshIndexesQueue] ADD CONSTRAINT [Chk_RefreshIndexesQueue_IndexOperation] CHECK (([IndexOperation]='Delay' OR [IndexOperation]='Update Statistics' OR [IndexOperation]='Create Statistics' OR [IndexOperation]='Drop Statistics' OR [IndexOperation]='Delete PartitionState Metadata' OR [IndexOperation]='Partition State Metadata Validation' OR [IndexOperation]='Resource Governor Settings' OR [IndexOperation]='Release Application Lock' OR [IndexOperation]='Get Application Lock' OR [IndexOperation]='Kill' OR [IndexOperation]='Clean Up Tables' OR [IndexOperation]='Turn Off DataSynch' OR [IndexOperation]='Turn On DataSynch' OR [IndexOperation]='Clear Queue of Other Tables' OR [IndexOperation]='Data Synch Trigger Revert Rename' OR [IndexOperation]='Free TempDB Space Validation' OR [IndexOperation]='Free Log Space Validation' OR [IndexOperation]='Free Data Space Validation' OR [IndexOperation]='Stop Processing' OR [IndexOperation]='Table Revert Rename' OR [IndexOperation]='Constraint Revert Rename' OR [IndexOperation]='Index Revert Rename' OR [IndexOperation]='Prior Error Validation SQL' OR [IndexOperation]='Partition Data Validation SQL' OR [IndexOperation]='Drop Data Synch Table' OR [IndexOperation]='Drop Data Synch Trigger' OR [IndexOperation]='Rename Data Synch Table' OR [IndexOperation]='Delete from Queue' OR [IndexOperation]='Update to In-Progress' OR [IndexOperation]='FinalValidation' OR [IndexOperation]='Temp Table SQL' OR [IndexOperation]='Drop Parent Old Table FKs' OR [IndexOperation]='Drop Ref Old Table FKs' OR [IndexOperation]='Add back Parent Table FKs' OR [IndexOperation]='Add back Ref Table FKs' OR [IndexOperation]='Disable CmdShell' OR [IndexOperation]='Enable CmdShell' OR [IndexOperation]='Rollback DDL' OR [IndexOperation]='Synch Updates' OR [IndexOperation]='Synch Inserts' OR [IndexOperation]='Synch Deletes' OR [IndexOperation]='Rename Existing Table Constraint' OR [IndexOperation]='Rename Existing Table Index' OR [IndexOperation]='Rename New Partitioned Prep Table Constraint' OR [IndexOperation]='Rename New Partitioned Prep Table Index' OR [IndexOperation]='Rename Existing Table' OR [IndexOperation]='Rename New Partitioned Prep Table' OR [IndexOperation]='Drop Table SQL' OR [IndexOperation]='Check Constraint SQL' OR [IndexOperation]='Commit Tran' OR [IndexOperation]='Begin Tran' OR [IndexOperation]='Switch Partitions SQL' OR [IndexOperation]='Partition Prep Table SQL' OR [IndexOperation]='Drop Ref FKs' OR [IndexOperation]='Recreate All FKs' OR [IndexOperation]='Loading Data' OR [IndexOperation]='Create Final Data Synch Trigger' OR [IndexOperation]='Create Final Data Synch Table' OR [IndexOperation]='Create Data Synch Trigger' OR [IndexOperation]='Prep Table SQL' OR [IndexOperation]='Alter Index' OR [IndexOperation]='Create Constraint' OR [IndexOperation]='Create Index' OR [IndexOperation]='Drop Index'))
GO
ALTER TABLE [DDI].[RefreshIndexesQueue] ADD CONSTRAINT [Chk_RefreshIndexesQueue_RunStatus] CHECK (([RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
