
GO

CREATE TABLE [DOI].[Queue]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[PartitionNumber] [smallint] NOT NULL CONSTRAINT [Def_Queue_PartitionNumber] DEFAULT ((1)),
[IndexSizeInMB] [int] NOT NULL,
[ParentSchemaName] [nvarchar] (128) NULL,
[ParentTableName] [nvarchar] (128) NULL,
[ParentIndexName] [nvarchar] (128) NULL,
[IndexOperation] [varchar] (50) NOT NULL,
[IsOnlineOperation] [bit] NOT NULL,
[TableChildOperationId] [smallint] NOT NULL CONSTRAINT [Def_Queue_TableChildOperationId] DEFAULT ((0)),
[SQLStatement] [varchar] (max) NOT NULL,
[SeqNo] [int] NOT NULL,
[DateTimeInserted] [datetime2] NOT NULL CONSTRAINT [Def_Queue_DateTimeInserted] DEFAULT (sysdatetime()),
[InProgress] [bit] NOT NULL CONSTRAINT [Def_Queue_InProgress] DEFAULT ((0)),
[RunStatus] [varchar] (7) NOT NULL CONSTRAINT [Def_Queue_RunStatus] DEFAULT ('Running'),
[ErrorMessage] [varchar] (max) NULL,
[TransactionId] [uniqueidentifier] NULL,
[BatchId] [uniqueidentifier] NOT NULL,
[ExitTableLoopOnError] [bit] NOT NULL CONSTRAINT [Def_Queue_ExitTableLoopOnError] DEFAULT ((0))
)
GO
ALTER TABLE [DOI].[Queue] ADD CONSTRAINT [Chk_Queue_IndexOperation] CHECK (([IndexOperation]='Delay' OR [IndexOperation]='Update Statistics' OR [IndexOperation]='Create Statistics' OR [IndexOperation]='Drop Statistics' OR [IndexOperation]='Delete PartitionState Metadata' OR [IndexOperation]='Partition State Metadata Validation' OR [IndexOperation]='Resource Governor Settings' OR [IndexOperation]='Release Application Lock' OR [IndexOperation]='Get Application Lock' OR [IndexOperation]='Kill' OR [IndexOperation]='Clean Up Tables' OR [IndexOperation]='Turn Off DataSynch' OR [IndexOperation]='Turn On DataSynch' OR [IndexOperation]='Clear Queue of Other Tables' OR [IndexOperation]='Data Synch Trigger Revert Rename' OR [IndexOperation]='Free TempDB Space Validation' OR [IndexOperation]='Free Log Space Validation' OR [IndexOperation]='Free Data Space Validation' OR [IndexOperation]='Stop Processing' OR [IndexOperation]='Table Revert Rename' OR [IndexOperation]='Constraint Revert Rename' OR [IndexOperation]='Index Revert Rename' OR [IndexOperation]='Prior Error Validation SQL' OR [IndexOperation]='Partition Data Validation SQL' OR [IndexOperation]='Drop Data Synch Table' OR [IndexOperation]='Drop Data Synch Trigger' OR [IndexOperation]='Rename Data Synch Table' OR [IndexOperation]='Delete from Queue' OR [IndexOperation]='Update to In-Progress' OR [IndexOperation]='FinalValidation' OR [IndexOperation]='Temp Table SQL' OR [IndexOperation]='Drop Parent Old Table FKs' OR [IndexOperation]='Drop Ref Old Table FKs' OR [IndexOperation]='Add back Parent Table FKs' OR [IndexOperation]='Add back Ref Table FKs' OR [IndexOperation]='Disable CmdShell' OR [IndexOperation]='Enable CmdShell' OR [IndexOperation]='Rollback DDL' OR [IndexOperation]='Synch Updates' OR [IndexOperation]='Synch Inserts' OR [IndexOperation]='Synch Deletes' OR [IndexOperation]='Rename Existing Table Constraint' OR [IndexOperation]='Rename Existing Table Index' OR [IndexOperation]='Rename New Partitioned Prep Table Constraint' OR [IndexOperation]='Rename New Partitioned Prep Table Index' OR [IndexOperation]='Rename Existing Table' OR [IndexOperation]='Rename New Partitioned Prep Table' OR [IndexOperation]='Drop Table SQL' OR [IndexOperation]='Check Constraint SQL' OR [IndexOperation]='Commit Tran' OR [IndexOperation]='Begin Tran' OR [IndexOperation]='Switch Partitions SQL' OR [IndexOperation]='Partition Prep Table SQL' OR [IndexOperation]='Drop Ref FKs' OR [IndexOperation]='Recreate All FKs' OR [IndexOperation]='Loading Data' OR [IndexOperation]='Create Final Data Synch Trigger' OR [IndexOperation]='Create Final Data Synch Table' OR [IndexOperation]='Create Data Synch Trigger' OR [IndexOperation]='Prep Table SQL' OR [IndexOperation]='Alter Index' OR [IndexOperation]='Create Constraint' OR [IndexOperation]='Create Index' OR [IndexOperation]='Drop Index' OR [IndexOperation]='Change DB' OR [IndexOperation]='Create BCP View' OR [IndexOperation]='Drop BCP View' OR [IndexOperation]='Rename Existing Statistic' OR [IndexOperation]='Create Missing Table Statistic' OR [IndexOperation]='Statistics Revert Rename'))
GO
ALTER TABLE [DOI].[Queue] ADD CONSTRAINT [Chk_Queue_RunStatus] CHECK (([RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
ALTER TABLE [DOI].[Queue] ADD CONSTRAINT [PK_Queue] PRIMARY KEY CLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [TableChildOperationId])
GO
