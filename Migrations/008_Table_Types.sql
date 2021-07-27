-- <Migration ID="098d132d-e1a3-4798-92cb-4bddd4abef30" TransactionHandling="Custom" />
PRINT N'Creating types'
GO
IF TYPE_ID(N'[DOI].[LogTT]') IS NULL
CREATE TYPE [DOI].[LogTT] AS TABLE
(
[LogID] [int] NOT NULL,
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[IndexSizeInMB] [int] NOT NULL,
[LoginName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogDateTime] [datetime2] NOT NULL,
[SQLStatement] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IndexOperation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RowCount] [int] NOT NULL,
[TableChildOperationId] [smallint] NOT NULL,
[RunStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorText] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionId] [uniqueidentifier] NULL,
[BatchId] [uniqueidentifier] NOT NULL,
[SeqNo] [int] NOT NULL,
[ExitTableLoopOnError] [bit] NOT NULL,
PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [RunStatus], [TableChildOperationId], [LogDateTime])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating types'
GO
IF TYPE_ID(N'[DOI].[FilteredRowCountsTT]') IS NULL
CREATE TYPE [DOI].[FilteredRowCountsTT] AS TABLE
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
IF TYPE_ID(N'[DOI].[IndexColumnsTT]') IS NULL
CREATE TYPE [DOI].[IndexColumnsTT] AS TABLE
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
IF TYPE_ID(N'[DOI].[SysPartitionRangeValuesTT]') IS NULL
CREATE TYPE [DOI].[SysPartitionRangeValuesTT] AS TABLE
(
[database_id] [sys].[sysname] NOT NULL,
[function_id] [int] NOT NULL,
[boundary_id] [int] NOT NULL,
[parameter_id] [int] NOT NULL,
[value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY NONCLUSTERED  ([database_id], [function_id], [boundary_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO