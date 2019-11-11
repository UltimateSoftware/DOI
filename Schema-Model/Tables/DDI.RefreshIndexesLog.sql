CREATE TABLE [DDI].[RefreshIndexesLog]
(
[RefreshIndexLogID] [int] NOT NULL IDENTITY(1, 1),
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL CONSTRAINT [Def_RefreshIndexesLog_PartitionNumber] DEFAULT ((1)),
[IndexSizeInMB] [int] NOT NULL,
[LoginName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogDateTime] [datetime2] NOT NULL CONSTRAINT [Def_RefreshIndexesLog_LogDateTime] DEFAULT (sysdatetime()),
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
CONSTRAINT [PK_RefreshIndexesLog] PRIMARY KEY NONCLUSTERED  ([RefreshIndexLogID]),
CONSTRAINT [UQ_RefreshIndexesLog] UNIQUE NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [RunStatus], [TableChildOperationId], [LogDateTime])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DDI].[RefreshIndexesLog] ADD CONSTRAINT [Chk_RefreshIndexesLog_RunStatus] CHECK (([RunStatus]='Error - Skipping...' OR [RunStatus]='Error - Retrying...' OR [RunStatus]='Error' OR [RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
