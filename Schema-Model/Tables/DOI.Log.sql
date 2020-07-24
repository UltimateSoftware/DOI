
GO

CREATE TABLE [DOI].[Log]
(
[LogID] [int] NOT NULL IDENTITY(1, 1),
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[PartitionNumber] [smallint] NOT NULL CONSTRAINT [Def_Log_PartitionNumber] DEFAULT ((1)),
[IndexSizeInMB] [int] NOT NULL,
[LoginName] [nvarchar] (128) NOT NULL,
[UserName] [nvarchar] (128) NOT NULL,
[LogDateTime] [datetime2] NOT NULL CONSTRAINT [Def_Log_LogDateTime] DEFAULT (sysdatetime()),
[SQLStatement] [varchar] (max) NULL,
[IndexOperation] [varchar] (50) NOT NULL,
[IsOnlineOperation] [bit] NOT NULL,
[RowCount] [int] NOT NULL,
[TableChildOperationId] [smallint] NOT NULL,
[RunStatus] [varchar] (20) NOT NULL,
[ErrorText] [varchar] (max) NULL,
[TransactionId] [uniqueidentifier] NULL,
[BatchId] [uniqueidentifier] NOT NULL,
[SeqNo] [int] NOT NULL,
[ExitTableLoopOnError] [bit] NOT NULL,
[InfoMessage] [varchar] (max) NULL
)
GO
ALTER TABLE [DOI].[Log] ADD CONSTRAINT [Chk_Log_RunStatus] CHECK (([RunStatus]='Error - Skipping...' OR [RunStatus]='Error - Retrying...' OR [RunStatus]='Error' OR [RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start' OR [RunStatus]='Info'))
GO
ALTER TABLE [DOI].[Log] ADD CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED  ([LogID])
GO
ALTER TABLE [DOI].[Log] ADD CONSTRAINT [UQ_Log] UNIQUE NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [RunStatus], [TableChildOperationId], [LogDateTime])
GO
