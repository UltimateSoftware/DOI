-- <Migration ID="098d132d-e1a3-4798-92cb-4bddd4abef30" TransactionHandling="Custom" />
GO

PRINT N'Creating types'
GO
IF TYPE_ID(N'[DDI].[LogTT]') IS NULL
CREATE TYPE [DDI].[LogTT] AS TABLE
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
[IsOnlineOperation] [bit] NOT NULL,
[RowCount] [int] NOT NULL,
[TableChildOperationId] [smallint] NOT NULL,
[RunStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorText] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionId] [uniqueidentifier] NULL,
[BatchId] [uniqueidentifier] NOT NULL,
[SeqNo] [int] NOT NULL,
[ExitTableLoopOnError] [bit] NOT NULL,
PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [RunStatus], [TableChildOperationId], [LogDateTime])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysCheckConstraints]'
GO
IF OBJECT_ID(N'[DDI].[SysCheckConstraints]', 'U') IS NULL
CREATE TABLE [DDI].[SysCheckConstraints]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[object_id] [int] NOT NULL,
[principal_id] [int] NULL,
[schema_id] [int] NOT NULL,
[parent_object_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NOT NULL,
[modify_date] [datetime] NOT NULL,
[is_ms_shipped] [bit] NOT NULL,
[is_published] [bit] NOT NULL,
[is_schema_published] [bit] NOT NULL,
[is_disabled] [bit] NOT NULL,
[is_not_for_replication] [bit] NOT NULL,
[is_not_trusted] [bit] NOT NULL,
[parent_column_id] [int] NOT NULL,
[definition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uses_database_collation] [bit] NULL,
[is_system_named] [bit] NOT NULL,
CONSTRAINT [PK_SysCheckConstraints] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysDefaultConstraints]'
GO
IF OBJECT_ID(N'[DDI].[SysDefaultConstraints]', 'U') IS NULL
CREATE TABLE [DDI].[SysDefaultConstraints]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[object_id] [int] NOT NULL,
[principal_id] [int] NULL,
[parent_object_id] [int] NOT NULL,
[schema_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NOT NULL,
[modify_date] [datetime] NOT NULL,
[is_ms_shipped] [bit] NOT NULL,
[is_published] [bit] NOT NULL,
[is_schema_published] [bit] NOT NULL,
[parent_column_id] [int] NOT NULL,
[definition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_system_named] [bit] NOT NULL,
CONSTRAINT [PK_SysDefaultConstraints] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[RefreshIndexes_PartitionState]'
GO
IF OBJECT_ID(N'[DDI].[RefreshIndexes_PartitionState]', 'U') IS NULL
CREATE TABLE [DDI].[RefreshIndexes_PartitionState]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[PrepTableName] [sys].[sysname] NOT NULL,
[PartitionFromValue] [date] NOT NULL,
[PartitionToValue] [date] NOT NULL,
[DataSynchState] [bit] NOT NULL,
[LastUpdateDateTime] [datetime] NULL CONSTRAINT [Def_RefreshIndexes_PartitionState_LastUpdateDateTime] DEFAULT (getdate()),
CONSTRAINT [PK_RefreshIndexes_PartitionState] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [ParentTableName], [PrepTableName], [PartitionFromValue])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Rebuilding [DDI].[IndexesNotInMetadata]'
GO
CREATE TABLE [DDI].[RG_Recovery_1_IndexesNotInMetadata]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [RG_Recovery_2_IndexesNotInMetadata] DEFAULT (getdate()),
[DropSQLScript] [varchar] (500) NOT NULL,
[Ignore] [bit] NOT NULL CONSTRAINT [RG_Recovery_3_IndexesNotInMetadata] DEFAULT ((0))
)
GO
INSERT INTO [DDI].[RG_Recovery_1_IndexesNotInMetadata]([DatabaseName], [SchemaName], [TableName], [IndexName], [DateInserted], [DropSQLScript], [Ignore]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [DateInserted], [DropSQLScript], [Ignore] FROM [DDI].[IndexesNotInMetadata]
GO
DROP TABLE [DDI].[IndexesNotInMetadata]
GO
CREATE TABLE [DDI].[IndexesNotInMetadata]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [Def_IndexesNotInMetadata_DateInserted] DEFAULT (getdate()),
[DropSQLScript] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Ignore] [bit] NOT NULL CONSTRAINT [Def_IndexesNotInMetadata_Ignore] DEFAULT ((0)),
CONSTRAINT [PK_IndexesNotInMetadata] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [DateInserted])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
INSERT INTO [DDI].[IndexesNotInMetadata]([DatabaseName], [SchemaName], [TableName], [IndexName], [DateInserted], [DropSQLScript], [Ignore]) SELECT [DatabaseName], [SchemaName], [TableName], [IndexName], [DateInserted], [DropSQLScript], [Ignore] FROM [DDI].[RG_Recovery_1_IndexesNotInMetadata]
GO
UPDATE STATISTICS [DDI].[IndexesNotInMetadata] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_1_IndexesNotInMetadata]
GO
PRINT N'Creating [DDI].[SysTriggers]'
GO
IF OBJECT_ID(N'[DDI].[SysTriggers]', 'U') IS NULL
CREATE TABLE [DDI].[SysTriggers]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[object_id] [int] NOT NULL,
[parent_class] [tinyint] NOT NULL,
[parent_class_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parent_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NOT NULL,
[modify_date] [datetime] NOT NULL,
[is_ms_shipped] [bit] NOT NULL,
[is_disabled] [bit] NOT NULL,
[is_not_for_replication] [bit] NOT NULL,
[is_instead_of_trigger] [bit] NOT NULL,
CONSTRAINT [PK_SysTriggers] PRIMARY KEY NONCLUSTERED  ([database_id], [parent_id], [object_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Rebuilding [DDI].[Log]'
GO
CREATE TABLE [DDI].[RG_Recovery_4_Log]
(
[LogID] [int] NOT NULL IDENTITY(1, 1),
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[IndexName] [nvarchar] (128) NOT NULL,
[PartitionNumber] [smallint] NOT NULL CONSTRAINT [RG_Recovery_5_Log] DEFAULT ((1)),
[IndexSizeInMB] [int] NOT NULL,
[LoginName] [nvarchar] (128) NOT NULL,
[UserName] [nvarchar] (128) NOT NULL,
[LogDateTime] [datetime2] NOT NULL CONSTRAINT [RG_Recovery_6_Log] DEFAULT (sysdatetime()),
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
[ExitTableLoopOnError] [bit] NOT NULL
)
GO
SET IDENTITY_INSERT [DDI].[RG_Recovery_4_Log] ON
GO
INSERT INTO [DDI].[RG_Recovery_4_Log]([LogID], [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexSizeInMB], [LoginName], [UserName], [LogDateTime], [SQLStatement], [IndexOperation], [IsOnlineOperation], [RowCount], [TableChildOperationId], [RunStatus], [ErrorText], [TransactionId], [BatchId], [SeqNo], [ExitTableLoopOnError]) SELECT [LogID], [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexSizeInMB], [LoginName], [UserName], [LogDateTime], [SQLStatement], [IndexOperation], [IsOnlineOperation], [RowCount], [TableChildOperationId], [RunStatus], [ErrorText], [TransactionId], [BatchId], [SeqNo], [ExitTableLoopOnError] FROM [DDI].[Log]
GO
SET IDENTITY_INSERT [DDI].[RG_Recovery_4_Log] OFF
GO
DROP TABLE [DDI].[Log]
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
SET IDENTITY_INSERT [DDI].[Log] ON
GO
INSERT INTO [DDI].[Log]([LogID], [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexSizeInMB], [LoginName], [UserName], [LogDateTime], [SQLStatement], [IndexOperation], [IsOnlineOperation], [RowCount], [TableChildOperationId], [RunStatus], [ErrorText], [TransactionId], [BatchId], [SeqNo], [ExitTableLoopOnError]) SELECT [LogID], [DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexSizeInMB], [LoginName], [UserName], [LogDateTime], [SQLStatement], [IndexOperation], [IsOnlineOperation], [RowCount], [TableChildOperationId], [RunStatus], [ErrorText], [TransactionId], [BatchId], [SeqNo], [ExitTableLoopOnError] FROM [DDI].[RG_Recovery_4_Log]
GO
SET IDENTITY_INSERT [DDI].[Log] OFF
GO
UPDATE STATISTICS [DDI].[Log] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_4_Log]
GO
PRINT N'Creating [DDI].[RefreshIndexesLog]'
GO
IF OBJECT_ID(N'[DDI].[RefreshIndexesLog]', 'U') IS NULL
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
PRINT N'Creating [DDI].[RefreshIndexesQueue]'
GO
IF OBJECT_ID(N'[DDI].[RefreshIndexesQueue]', 'U') IS NULL
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
PRINT N'Rebuilding [DDI].[DefaultConstraintsNotInMetadata]'
GO
CREATE TABLE [DDI].[RG_Recovery_7_DefaultConstraintsNotInMetadata]
(
[DatabaseName] [nvarchar] (128) NOT NULL,
[SchemaName] [nvarchar] (128) NOT NULL,
[TableName] [nvarchar] (128) NOT NULL,
[ColumnName] [nvarchar] (128) NOT NULL,
[DefaultDefinition] [nvarchar] (max) NOT NULL,
[DefaultConstraintName] [nvarchar] (128) NULL
)
GO
INSERT INTO [DDI].[RG_Recovery_7_DefaultConstraintsNotInMetadata]([DatabaseName], [SchemaName], [TableName], [ColumnName], [DefaultDefinition], [DefaultConstraintName]) SELECT [DatabaseName], [SchemaName], [TableName], [ColumnName], [DefaultDefinition], [DefaultConstraintName] FROM [DDI].[DefaultConstraintsNotInMetadata]
GO
DROP TABLE [DDI].[DefaultConstraintsNotInMetadata]
GO
CREATE TABLE [DDI].[DefaultConstraintsNotInMetadata]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_DefaultConstraintsNotInMetadata] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
INSERT INTO [DDI].[DefaultConstraintsNotInMetadata]([DatabaseName], [SchemaName], [TableName], [ColumnName], [DefaultDefinition], [DefaultConstraintName]) SELECT [DatabaseName], [SchemaName], [TableName], [ColumnName], [DefaultDefinition], [DefaultConstraintName] FROM [DDI].[RG_Recovery_7_DefaultConstraintsNotInMetadata]
GO
UPDATE STATISTICS [DDI].[DefaultConstraintsNotInMetadata] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_7_DefaultConstraintsNotInMetadata]
GO
PRINT N'Rebuilding [DDI].[CheckConstraintsNotInMetadata]'
GO
CREATE TABLE [DDI].[RG_Recovery_8_CheckConstraintsNotInMetadata]
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
INSERT INTO [DDI].[RG_Recovery_8_CheckConstraintsNotInMetadata]([DatabaseName], [SchemaName], [TableName], [ColumnName], [CheckDefinition], [IsDisabled], [CheckConstraintName]) SELECT [DatabaseName], [SchemaName], [TableName], [ColumnName], [CheckDefinition], [IsDisabled], [CheckConstraintName] FROM [DDI].[CheckConstraintsNotInMetadata]
GO
DROP TABLE [DDI].[CheckConstraintsNotInMetadata]
GO
CREATE TABLE [DDI].[CheckConstraintsNotInMetadata]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDisabled] [bit] NOT NULL,
[CheckConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CONSTRAINT [PK_CheckConstraintsNotInMetadata] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [CheckConstraintName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
INSERT INTO [DDI].[CheckConstraintsNotInMetadata]([DatabaseName], [SchemaName], [TableName], [ColumnName], [CheckDefinition], [IsDisabled], [CheckConstraintName]) SELECT [DatabaseName], [SchemaName], [TableName], [ColumnName], [CheckDefinition], [IsDisabled], [CheckConstraintName] FROM [DDI].[RG_Recovery_8_CheckConstraintsNotInMetadata]
GO
UPDATE STATISTICS [DDI].[CheckConstraintsNotInMetadata] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_8_CheckConstraintsNotInMetadata]
GO
PRINT N'Creating [DDI].[SysMasterFiles]'
GO
IF OBJECT_ID(N'[DDI].[SysMasterFiles]', 'U') IS NULL
CREATE TABLE [DDI].[SysMasterFiles]
(
[database_id] [int] NOT NULL,
[file_id] [int] NOT NULL,
[file_guid] [uniqueidentifier] NULL,
[type] [tinyint] NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[data_space_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[physical_name] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state] [tinyint] NULL,
[state_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[size] [int] NOT NULL,
[max_size] [int] NOT NULL,
[growth] [int] NOT NULL,
[is_media_read_only] [bit] NOT NULL,
[is_read_only] [bit] NOT NULL,
[is_sparse] [bit] NOT NULL,
[is_percent_growth] [bit] NOT NULL,
[is_name_reserved] [bit] NOT NULL,
[create_lsn] [numeric] (25, 0) NULL,
[drop_lsn] [numeric] (25, 0) NULL,
[read_only_lsn] [numeric] (25, 0) NULL,
[read_write_lsn] [numeric] (25, 0) NULL,
[differential_base_lsn] [numeric] (25, 0) NULL,
[differential_base_guid] [uniqueidentifier] NULL,
[differential_base_time] [datetime] NULL,
[redo_start_lsn] [numeric] (25, 0) NULL,
[redo_start_fork_guid] [uniqueidentifier] NULL,
[redo_target_lsn] [numeric] (25, 0) NULL,
[redo_target_fork_guid] [uniqueidentifier] NULL,
[backup_lsn] [numeric] (25, 0) NULL,
[credential_id] [int] NULL,
CONSTRAINT [PK_SysMasterFiles] PRIMARY KEY NONCLUSTERED  ([database_id], [file_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Rebuilding [DDI].[Run_PartitionState]'
GO
CREATE TABLE [DDI].[RG_Recovery_9_Run_PartitionState]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[PrepTableName] [sys].[sysname] NOT NULL,
[PartitionFromValue] [date] NOT NULL,
[PartitionToValue] [date] NOT NULL,
[DataSynchState] [bit] NOT NULL,
[LastUpdateDateTime] [datetime] NULL CONSTRAINT [RG_Recovery_10_Run_PartitionState] DEFAULT (getdate())
)
GO
INSERT INTO [DDI].[RG_Recovery_9_Run_PartitionState]([DatabaseName], [SchemaName], [ParentTableName], [PrepTableName], [PartitionFromValue], [PartitionToValue], [DataSynchState], [LastUpdateDateTime]) SELECT [DatabaseName], [SchemaName], [ParentTableName], [PrepTableName], [PartitionFromValue], [PartitionToValue], [DataSynchState], [LastUpdateDateTime] FROM [DDI].[Run_PartitionState]
GO
DROP TABLE [DDI].[Run_PartitionState]
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
INSERT INTO [DDI].[Run_PartitionState]([DatabaseName], [SchemaName], [ParentTableName], [PrepTableName], [PartitionFromValue], [PartitionToValue], [DataSynchState], [LastUpdateDateTime]) SELECT [DatabaseName], [SchemaName], [ParentTableName], [PrepTableName], [PartitionFromValue], [PartitionToValue], [DataSynchState], [LastUpdateDateTime] FROM [DDI].[RG_Recovery_9_Run_PartitionState]
GO
UPDATE STATISTICS [DDI].[Run_PartitionState] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_9_Run_PartitionState]
GO
PRINT N'Creating [DDI].[IndexesRowStoreColumns]'
GO
IF OBJECT_ID(N'[DDI].[IndexesRowStoreColumns]', 'U') IS NULL
CREATE TABLE [DDI].[IndexesRowStoreColumns]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[TableName] [sys].[sysname] NOT NULL,
[IndexName] [sys].[sysname] NOT NULL,
[ColumnName] [sys].[sysname] NOT NULL,
[IsKeyColumn] [bit] NOT NULL,
[IsIncludedColumn] [bit] NOT NULL,
[IsFixedSize] [bit] NOT NULL,
[ColumnSize] [decimal] (10, 2) NOT NULL,
CONSTRAINT [PK_IndexesRowStoreColumns] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Adding constraints to [DDI].[Log]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Log_RunStatus]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Log]', 'U'))
ALTER TABLE [DDI].[Log] ADD CONSTRAINT [Chk_Log_RunStatus] CHECK (([RunStatus]='Error - Skipping...' OR [RunStatus]='Error - Retrying...' OR [RunStatus]='Error' OR [RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
PRINT N'Adding constraints to [DDI].[RefreshIndexesLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_RefreshIndexesLog_RunStatus]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[RefreshIndexesLog]', 'U'))
ALTER TABLE [DDI].[RefreshIndexesLog] ADD CONSTRAINT [Chk_RefreshIndexesLog_RunStatus] CHECK (([RunStatus]='Error - Skipping...' OR [RunStatus]='Error - Retrying...' OR [RunStatus]='Error' OR [RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
PRINT N'Adding constraints to [DDI].[RefreshIndexesQueue]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_RefreshIndexesQueue_IndexOperation]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[RefreshIndexesQueue]', 'U'))
ALTER TABLE [DDI].[RefreshIndexesQueue] ADD CONSTRAINT [Chk_RefreshIndexesQueue_IndexOperation] CHECK (([IndexOperation]='Delay' OR [IndexOperation]='Update Statistics' OR [IndexOperation]='Create Statistics' OR [IndexOperation]='Drop Statistics' OR [IndexOperation]='Delete PartitionState Metadata' OR [IndexOperation]='Partition State Metadata Validation' OR [IndexOperation]='Resource Governor Settings' OR [IndexOperation]='Release Application Lock' OR [IndexOperation]='Get Application Lock' OR [IndexOperation]='Kill' OR [IndexOperation]='Clean Up Tables' OR [IndexOperation]='Turn Off DataSynch' OR [IndexOperation]='Turn On DataSynch' OR [IndexOperation]='Clear Queue of Other Tables' OR [IndexOperation]='Data Synch Trigger Revert Rename' OR [IndexOperation]='Free TempDB Space Validation' OR [IndexOperation]='Free Log Space Validation' OR [IndexOperation]='Free Data Space Validation' OR [IndexOperation]='Stop Processing' OR [IndexOperation]='Table Revert Rename' OR [IndexOperation]='Constraint Revert Rename' OR [IndexOperation]='Index Revert Rename' OR [IndexOperation]='Prior Error Validation SQL' OR [IndexOperation]='Partition Data Validation SQL' OR [IndexOperation]='Drop Data Synch Table' OR [IndexOperation]='Drop Data Synch Trigger' OR [IndexOperation]='Rename Data Synch Table' OR [IndexOperation]='Delete from Queue' OR [IndexOperation]='Update to In-Progress' OR [IndexOperation]='FinalValidation' OR [IndexOperation]='Temp Table SQL' OR [IndexOperation]='Drop Parent Old Table FKs' OR [IndexOperation]='Drop Ref Old Table FKs' OR [IndexOperation]='Add back Parent Table FKs' OR [IndexOperation]='Add back Ref Table FKs' OR [IndexOperation]='Disable CmdShell' OR [IndexOperation]='Enable CmdShell' OR [IndexOperation]='Rollback DDL' OR [IndexOperation]='Synch Updates' OR [IndexOperation]='Synch Inserts' OR [IndexOperation]='Synch Deletes' OR [IndexOperation]='Rename Existing Table Constraint' OR [IndexOperation]='Rename Existing Table Index' OR [IndexOperation]='Rename New Partitioned Prep Table Constraint' OR [IndexOperation]='Rename New Partitioned Prep Table Index' OR [IndexOperation]='Rename Existing Table' OR [IndexOperation]='Rename New Partitioned Prep Table' OR [IndexOperation]='Drop Table SQL' OR [IndexOperation]='Check Constraint SQL' OR [IndexOperation]='Commit Tran' OR [IndexOperation]='Begin Tran' OR [IndexOperation]='Switch Partitions SQL' OR [IndexOperation]='Partition Prep Table SQL' OR [IndexOperation]='Drop Ref FKs' OR [IndexOperation]='Recreate All FKs' OR [IndexOperation]='Loading Data' OR [IndexOperation]='Create Final Data Synch Trigger' OR [IndexOperation]='Create Final Data Synch Table' OR [IndexOperation]='Create Data Synch Trigger' OR [IndexOperation]='Prep Table SQL' OR [IndexOperation]='Alter Index' OR [IndexOperation]='Create Constraint' OR [IndexOperation]='Create Index' OR [IndexOperation]='Drop Index'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_RefreshIndexesQueue_RunStatus]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[RefreshIndexesQueue]', 'U'))
ALTER TABLE [DDI].[RefreshIndexesQueue] ADD CONSTRAINT [Chk_RefreshIndexesQueue_RunStatus] CHECK (([RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
