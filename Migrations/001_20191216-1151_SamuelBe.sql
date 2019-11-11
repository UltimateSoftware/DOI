-- <Migration ID="34c17dd7-07bb-4639-9759-e17109d3ebbc" TransactionHandling="Custom" />
GO

PRINT N'Creating [DDI].[SysTables]'
GO
IF OBJECT_ID(N'[DDI].[SysTables]', 'U') IS NULL
CREATE TABLE [DDI].[SysTables]
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
[lob_data_space_id] [int] NOT NULL,
[filestream_data_space_id] [int] NULL,
[max_column_id_used] [int] NOT NULL,
[lock_on_bulk_load] [bit] NOT NULL,
[uses_ansi_nulls] [bit] NULL,
[is_replicated] [bit] NULL,
[has_replication_filter] [bit] NULL,
[is_merge_published] [bit] NULL,
[is_sync_tran_subscribed] [bit] NULL,
[has_unchecked_assembly_data] [bit] NOT NULL,
[text_in_row_limit] [int] NULL,
[large_value_types_out_of_row] [bit] NULL,
[is_tracked_by_cdc] [bit] NULL,
[lock_escalation] [tinyint] NULL,
[lock_escalation_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_filetable] [bit] NULL,
[is_memory_optimized] [bit] NULL,
[durability] [tinyint] NULL,
[durability_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[temporal_type] [tinyint] NULL,
[temporal_type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[history_table_id] [int] NULL,
[is_remote_data_archive_enabled] [bit] NULL,
[is_external] [bit] NOT NULL,
CONSTRAINT [PK_SysTables] PRIMARY KEY NONCLUSTERED  ([database_id], [schema_id], [object_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysStatsColumns]'
GO
IF OBJECT_ID(N'[DDI].[SysStatsColumns]', 'U') IS NULL
CREATE TABLE [DDI].[SysStatsColumns]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[stats_id] [int] NOT NULL,
[stats_column_id] [int] NOT NULL,
[column_id] [int] NOT NULL,
CONSTRAINT [PK_SysStatsColumns] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [stats_id], [stats_column_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysStats]'
GO
IF OBJECT_ID(N'[DDI].[SysStats]', 'U') IS NULL
CREATE TABLE [DDI].[SysStats]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stats_id] [int] NOT NULL,
[auto_created] [bit] NULL,
[user_created] [bit] NULL,
[no_recompute] [bit] NULL,
[has_filter] [bit] NULL,
[filter_definition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_temporary] [bit] NULL,
[is_incremental] [bit] NULL,
[column_list] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_SysStats] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [stats_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysSchemas]'
GO
IF OBJECT_ID(N'[DDI].[SysSchemas]', 'U') IS NULL
CREATE TABLE [DDI].[SysSchemas]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[schema_id] [int] NOT NULL,
[principal_id] [int] NULL,
CONSTRAINT [PK_SysSchemas] PRIMARY KEY NONCLUSTERED  ([database_id], [schema_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysDatabases]'
GO
IF OBJECT_ID(N'[DDI].[SysDatabases]', 'U') IS NULL
CREATE TABLE [DDI].[SysDatabases]
(
[name] [sys].[sysname] NOT NULL,
[database_id] [int] NOT NULL,
[source_database_id] [int] NULL,
[owner_sid] [varbinary] (85) NULL,
[create_date] [datetime] NOT NULL,
[compatibility_level] [tinyint] NOT NULL,
[collation_name] [sys].[sysname] NOT NULL,
[user_access] [tinyint] NULL,
[user_access_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_read_only] [bit] NULL,
[is_auto_close_on] [bit] NOT NULL,
[is_auto_shrink_on] [bit] NULL,
[state] [tinyint] NULL,
[state_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_in_standby] [bit] NULL,
[is_cleanly_shutdown] [bit] NULL,
[is_supplemental_logging_enabled] [bit] NULL,
[snapshot_isolation_state] [tinyint] NULL,
[snapshot_isolation_state_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_read_committed_snapshot_on] [bit] NULL,
[recovery_model] [tinyint] NULL,
[recovery_model_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[page_verify_option] [tinyint] NULL,
[page_verify_option_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_auto_create_stats_on] [bit] NULL,
[is_auto_create_stats_incremental_on] [bit] NULL,
[is_auto_update_stats_on] [bit] NULL,
[is_auto_update_stats_async_on] [bit] NULL,
[is_ansi_null_default_on] [bit] NULL,
[is_ansi_nulls_on] [bit] NULL,
[is_ansi_padding_on] [bit] NULL,
[is_ansi_warnings_on] [bit] NULL,
[is_arithabort_on] [bit] NULL,
[is_concat_null_yields_null_on] [bit] NULL,
[is_numeric_roundabort_on] [bit] NULL,
[is_quoted_identifier_on] [bit] NULL,
[is_recursive_triggers_on] [bit] NULL,
[is_cursor_close_on_commit_on] [bit] NULL,
[is_local_cursor_default] [bit] NULL,
[is_fulltext_enabled] [bit] NULL,
[is_trustworthy_on] [bit] NULL,
[is_db_chaining_on] [bit] NULL,
[is_parameterization_forced] [bit] NULL,
[is_master_key_encrypted_by_server] [bit] NOT NULL,
[is_query_store_on] [bit] NULL,
[is_published] [bit] NOT NULL,
[is_subscribed] [bit] NOT NULL,
[is_merge_published] [bit] NOT NULL,
[is_distributor] [bit] NOT NULL,
[is_sync_with_backup] [bit] NOT NULL,
[service_broker_guid] [uniqueidentifier] NOT NULL,
[is_broker_enabled] [bit] NOT NULL,
[log_reuse_wait] [tinyint] NULL,
[log_reuse_wait_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_date_correlation_on] [bit] NOT NULL,
[is_cdc_enabled] [bit] NOT NULL,
[is_encrypted] [bit] NULL,
[is_honor_broker_priority_on] [bit] NULL,
[replica_id] [uniqueidentifier] NULL,
[group_database_id] [uniqueidentifier] NULL,
[resource_pool_id] [int] NULL,
[default_language_lcid] [smallint] NULL,
[default_language_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_fulltext_language_lcid] [int] NULL,
[default_fulltext_language_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_nested_triggers_on] [bit] NULL,
[is_transform_noise_words_on] [bit] NULL,
[two_digit_year_cutoff] [smallint] NULL,
[containment] [tinyint] NULL,
[containment_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[target_recovery_time_in_seconds] [int] NULL,
[delayed_durability] [int] NULL,
[delayed_durability_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_memory_optimized_elevate_to_snapshot_on] [bit] NULL,
[is_federation_member] [bit] NULL,
[is_remote_data_archive_enabled] [bit] NULL,
[is_mixed_page_allocation_on] [bit] NULL,
CONSTRAINT [PK_SysDatabases] PRIMARY KEY NONCLUSTERED  ([database_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysColumns]'
GO
IF OBJECT_ID(N'[DDI].[SysColumns]', 'U') IS NULL
CREATE TABLE [DDI].[SysColumns]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[column_id] [int] NOT NULL,
[system_type_id] [tinyint] NOT NULL,
[user_type_id] [int] NOT NULL,
[max_length] [smallint] NOT NULL,
[precision] [tinyint] NOT NULL,
[scale] [tinyint] NOT NULL,
[collation_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_nullable] [bit] NULL,
[is_ansi_padded] [bit] NOT NULL,
[is_rowguidcol] [bit] NOT NULL,
[is_identity] [bit] NOT NULL,
[is_computed] [bit] NOT NULL,
[is_filestream] [bit] NOT NULL,
[is_replicated] [bit] NULL,
[is_non_sql_subscribed] [bit] NULL,
[is_merge_published] [bit] NULL,
[is_dts_replicated] [bit] NULL,
[is_xml_document] [bit] NOT NULL,
[xml_collection_id] [int] NOT NULL,
[default_object_id] [int] NOT NULL,
[rule_object_id] [int] NOT NULL,
[is_sparse] [bit] NULL,
[is_column_set] [bit] NULL,
[generated_always_type] [tinyint] NULL,
[generated_always_type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[encryption_type] [int] NULL,
[encryption_type_desc] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[encryption_algorithm_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[column_encryption_key_id] [int] NULL,
[column_encryption_key_database_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_hidden] [bit] NULL,
[is_masked] [bit] NULL,
CONSTRAINT [PK_SysColumns] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [column_id]),
INDEX [IDX_SysColumns_object_id] NONCLUSTERED ([object_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[IndexesColumnStore]'
GO
IF OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U') IS NULL
CREATE TABLE [DDI].[IndexesColumnStore]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsIndexMissingFromSQLServer] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsIndexMissingFromSQLServer] DEFAULT ((0)),
[IsClustered_Desired] [bit] NOT NULL,
[IsClustered_Actual] [bit] NULL,
[ColumnList_Desired] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColumnList_Actual] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsFiltered_Desired] [bit] NOT NULL,
[IsFiltered_Actual] [bit] NULL,
[FilterPredicate_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterPredicate_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionDataCompression_Desired] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexesColumnStore_OptionDataCompression] DEFAULT ('COLUMNSTORE'),
[OptionDataCompression_Actual] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionDataCompressionDelay_Desired] [int] NOT NULL,
[OptionDataCompressionDelay_Actual] [int] NULL,
[Storage_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storage_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Desired] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Actual] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionFunction_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionFunction_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionColumn_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionColumn_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllColsInTableSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AllColsInTableSize_Estimated] DEFAULT ((0)),
[NumFixedCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesColumnStore_NumFixedCols_Estimated] DEFAULT ((0)),
[NumVarCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesColumnStore_NumVarCols_Estimated] DEFAULT ((0)),
[NumCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesColumnStore_NumCols_Estimated] DEFAULT ((0)),
[FixedColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesColumnStore_FixedColsSize_Estimated] DEFAULT ((0)),
[VarColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesColumnStore_VarColsSize_Estimated] DEFAULT ((0)),
[ColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesColumnStore_ColsSize_Estimated] DEFAULT ((0)),
[NumRows_Actual] [bigint] NOT NULL CONSTRAINT [Def_IndexesColumnStore_NumRows_Actual] DEFAULT ((0)),
[IndexSizeMB_Actual] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexesColumnStore_IndexSizeMB_Actual] DEFAULT ((0)),
[DriveLetter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsIndexLarge] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsIndexLarge] DEFAULT ((0)),
[IndexMeetsMinimumSize] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IndexMeetsMinimumSize] DEFAULT ((0)),
[Fragmentation] [float] NOT NULL CONSTRAINT [Def_IndexesColumnStore_Fragmentation] DEFAULT ((0)),
[FragmentationType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexesColumnStore_FragmentationType] DEFAULT ('None'),
[AreDropRecreateOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AreDropRecreateOptionsChanging] DEFAULT ((0)),
[AreRebuildOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AreRebuildOptionsChanging] DEFAULT ((0)),
[AreRebuildOnlyOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AreRebuildOnlyOptionsChanging] DEFAULT ((0)),
[AreReorgOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AreReorgOptionsChanging] DEFAULT ((0)),
[AreSetOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_AreSetOptionsChanging] DEFAULT ((0)),
[IsColumnListChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsColumnListChanging] DEFAULT ((0)),
[IsFilterChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsFilterChanging] DEFAULT ((0)),
[IsClusteredChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsClusteredChanging] DEFAULT ((0)),
[IsPartitioningChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsPartitioningChanging] DEFAULT ((0)),
[IsDataCompressionChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsDataCompressionChanging] DEFAULT ((0)),
[IsDataCompressionDelayChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsDataCompressionDelayChanging] DEFAULT ((0)),
[IsStorageChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_IsStorageChanging] DEFAULT ((0)),
[NumPages_Actual] [int] NULL CONSTRAINT [Def_IndexesColumnStore_NumPages_Actual] DEFAULT ((0)),
[TotalPartitionsInIndex] [int] NOT NULL CONSTRAINT [Def_IndexesColumnStore_TotalPartitionsInIndex] DEFAULT ((0)),
[NeedsPartitionLevelOperations] [bit] NOT NULL CONSTRAINT [Def_IndexesColumnStore_NeedsPartitionLevelOperations] DEFAULT ((0)),
CONSTRAINT [PK_IndexesColumnStore] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[Queue]'
GO
IF OBJECT_ID(N'[DDI].[Queue]', 'U') IS NULL
CREATE TABLE [DDI].[Queue]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [SMALLINT] NOT NULL CONSTRAINT [Def_Queue_PartitionNumber] DEFAULT ((1)),
[IndexSizeInMB] [INT] NOT NULL,
[ParentSchemaName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentTableName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentIndexName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IndexOperation] [VARCHAR] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
CONSTRAINT [PK_Queue] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [TableChildOperationId])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[PartitionFunctions]'
GO
IF OBJECT_ID(N'[DDI].[PartitionFunctions]', 'U') IS NULL
CREATE TABLE [DDI].[PartitionFunctions]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[PartitionFunctionName] [sys].[sysname] NOT NULL,
[PartitionFunctionDataType] [sys].[sysname] NOT NULL,
[BoundaryInterval] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NumOfFutureIntervals] [tinyint] NOT NULL,
[InitialDate] [date] NOT NULL,
[UsesSlidingWindow] [bit] NOT NULL,
[SlidingWindowSize] [smallint] NULL,
[IsDeprecated] [bit] NOT NULL,
[PartitionSchemeName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumOfCharsInSuffix] [tinyint] NULL,
[LastBoundaryDate] [date] NULL,
[NumOfTotalPartitionFunctionIntervals] [smallint] NULL,
[NumOfTotalPartitionSchemeIntervals] [smallint] NULL,
[MinValueOfDataType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_PartitionFunctions] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [PartitionFunctionName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[Tables]'
GO
IF OBJECT_ID(N'[DDI].[Tables]', 'U') IS NULL
CREATE TABLE [DDI].[Tables]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storage_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storage_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntendToPartition] [bit] NOT NULL CONSTRAINT [Def_Tables_IntendToPartition] DEFAULT ((0)),
[ReadyToQueue] [bit] NOT NULL CONSTRAINT [Def_Tables_ReadyToQueue] DEFAULT ((0)),
[AreIndexesFragmented] [bit] NOT NULL CONSTRAINT [Def_Tables_AreIndexesFragmented] DEFAULT ((0)),
[AreIndexesBeingUpdated] [bit] NOT NULL CONSTRAINT [Def_Tables_AreIndexesBeingUpdated] DEFAULT ((0)),
[AreIndexesMissing] [bit] NOT NULL CONSTRAINT [Def_Tables_AreIndexesMissing] DEFAULT ((0)),
[IsClusteredIndexBeingDropped] [bit] NOT NULL CONSTRAINT [Def_Tables_IsClusteredIndexBeingDropped] DEFAULT ((0)),
[WhichUniqueConstraintIsBeingDropped] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_Tables_WhichUniqueConstraintIsBeingDropped] DEFAULT ('None'),
[IsStorageChanging] [bit] NOT NULL CONSTRAINT [Def_Tables_IsStorageChanging] DEFAULT ((0)),
[NeedsTransaction] [bit] NOT NULL CONSTRAINT [Def_Tables_NeedsTransaction] DEFAULT ((0)),
[AreStatisticsChanging] [bit] NOT NULL CONSTRAINT [Def_Tables_AreStatisticsChanging] DEFAULT ((0)),
[DSTriggerSQL] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PKColumnList] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PKColumnListJoinClause] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColumnListNoTypes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColumnListWithTypes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateColumnList] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewPartitionedPrepTableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionFunctionName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_Tables] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[DefaultConstraints]'
GO
IF OBJECT_ID(N'[DDI].[DefaultConstraints]', 'U') IS NULL
CREATE TABLE [DDI].[DefaultConstraints]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_DefaultConstraints] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[DDISettings]'
GO
IF OBJECT_ID(N'[DDI].[DDISettings]', 'U') IS NULL
CREATE TABLE [DDI].[DDISettings]
(
[SettingName] [sys].[sysname] NOT NULL,
[SettingValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_DDISettings] PRIMARY KEY NONCLUSTERED  ([SettingName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysTypes]'
GO
IF OBJECT_ID(N'[DDI].[SysTypes]', 'U') IS NULL
CREATE TABLE [DDI].[SysTypes]
(
[name] [sys].[sysname] NOT NULL,
[system_type_id] [tinyint] NOT NULL,
[user_type_id] [int] NOT NULL,
[schema_id] [int] NOT NULL,
[principal_id] [int] NULL,
[max_length] [smallint] NOT NULL,
[precision] [tinyint] NOT NULL,
[scale] [tinyint] NOT NULL,
[collation_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_nullable] [bit] NULL,
[is_user_defined] [bit] NOT NULL,
[is_assembly_type] [bit] NOT NULL,
[default_object_id] [int] NOT NULL,
[rule_object_id] [int] NOT NULL,
[is_table_type] [bit] NOT NULL,
CONSTRAINT [PK_SysTypes] PRIMARY KEY NONCLUSTERED  ([user_type_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[IndexesRowStore]'
GO
IF OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U') IS NULL
CREATE TABLE [DDI].[IndexesRowStore]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsIndexMissingFromSQLServer] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsIndexMissingFromSQLServer] DEFAULT ((0)),
[IsUnique_Desired] [bit] NOT NULL,
[IsUnique_Actual] [bit] NULL,
[IsPrimaryKey_Desired] [bit] NOT NULL,
[IsPrimaryKey_Actual] [bit] NULL,
[IsUniqueConstraint_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsUniqueConstraint_Desired] DEFAULT ((0)),
[IsUniqueConstraint_Actual] [bit] NULL,
[IsClustered_Desired] [bit] NOT NULL,
[IsClustered_Actual] [bit] NULL,
[KeyColumnList_Desired] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KeyColumnList_Actual] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludedColumnList_Desired] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludedColumnList_Actual] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsFiltered_Desired] [bit] NOT NULL,
[IsFiltered_Actual] [bit] NULL,
[FilterPredicate_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterPredicate_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fillfactor_Desired] [tinyint] NOT NULL CONSTRAINT [Def_Indexes_FillFactor_Desired] DEFAULT ((90)),
[Fillfactor_Actual] [tinyint] NULL,
[OptionPadIndex_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionPadIndex_Desired] DEFAULT ((1)),
[OptionPadIndex_Actual] [bit] NULL,
[OptionStatisticsNoRecompute_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionStatisticsNoRecompute_Desired] DEFAULT ((0)),
[OptionStatisticsNoRecompute_Actual] [bit] NULL,
[OptionStatisticsIncremental_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionStatisticsIncremental_Desired] DEFAULT ((0)),
[OptionStatisticsIncremental_Actual] [bit] NULL,
[OptionIgnoreDupKey_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionIgnoreDupKey_Desired] DEFAULT ((0)),
[OptionIgnoreDupKey_Actual] [bit] NULL,
[OptionResumable_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionResumable_Desired] DEFAULT ((0)),
[OptionResumable_Actual] [bit] NULL,
[OptionMaxDuration_Desired] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionMaxDuration_Desired] DEFAULT ((0)),
[OptionMaxDuration_Actual] [smallint] NULL,
[OptionAllowRowLocks_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionAllowRowLocks_Desired] DEFAULT ((1)),
[OptionAllowRowLocks_Actual] [bit] NULL,
[OptionAllowPageLocks_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionAllowPageLocks_Desired] DEFAULT ((1)),
[OptionAllowPageLocks_Actual] [bit] NULL,
[OptionDataCompression_Desired] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionDataCompression_Desired] DEFAULT ('PAGE'),
[OptionDataCompression_Actual] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionDataCompressionDelay_Desired] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionDataCompressionDelay_Desired] DEFAULT ((0)),
[OptionDataCompressionDelay_Actual] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_OptionDataCompressionDelay_Actual] DEFAULT ((0)),
[Storage_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storage_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Desired] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageType_Actual] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionFunction_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionFunction_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionColumn_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartitionColumn_Actual] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumRows_Actual] [bigint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumRows_Actual] DEFAULT ((0)),
[AllColsInTableSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_AllColsInTableSize_Estimated] DEFAULT ((0)),
[NumFixedKeyCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumFixedKeyCols_Estimated] DEFAULT ((0)),
[NumVarKeyCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumVarKeyCols_Estimated] DEFAULT ((0)),
[NumKeyCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumKeyCols_Estimated] DEFAULT ((0)),
[NumFixedInclCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumFixedInclCols_Estimated] DEFAULT ((0)),
[NumVarInclCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumVarInclCols_Estimated] DEFAULT ((0)),
[NumInclCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumInclCols_Estimated] DEFAULT ((0)),
[NumFixedCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumFixedCols_Estimated] DEFAULT ((0)),
[NumVarCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumVarCols_Estimated] DEFAULT ((0)),
[NumCols_Estimated] [smallint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumCols_Estimated] DEFAULT ((0)),
[FixedKeyColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_FixedKeyColsSize_Estimated] DEFAULT ((0)),
[VarKeyColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_VarKeyColsSize_Estimated] DEFAULT ((0)),
[KeyColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_KeyColsSize_Estimated] DEFAULT ((0)),
[FixedInclColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_FixedInclColsSize_Estimated] DEFAULT ((0)),
[VarInclColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_VarInclColsSize_Estimated] DEFAULT ((0)),
[InclColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_InclColsSize_Estimated] DEFAULT ((0)),
[FixedColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_FixedColsSize_Estimated] DEFAULT ((0)),
[VarColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_VarColsSize_Estimated] DEFAULT ((0)),
[ColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_ColsSize_Estimated] DEFAULT ((0)),
[PKColsSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_PKColsSize_Estimated] DEFAULT ((0)),
[NullBitmap_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NullBitmap_Estimated] DEFAULT ((0)),
[Uniqueifier_Estimated] [tinyint] NOT NULL CONSTRAINT [Def_IndexesRowStore_Uniqueifier_Estimated] DEFAULT ((0)),
[TotalRowSize_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_TotalRowSize_Estimated] DEFAULT ((0)),
[NonClusteredIndexRowLocator_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NonClusteredIndexRowLocator_Estimated] DEFAULT ((0)),
[NumRowsPerPage_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumRowsPerPage_Estimated] DEFAULT ((0)),
[NumFreeRowsPerPage_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumFreeRowsPerPage_Estimated] DEFAULT ((0)),
[NumLeafPages_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumLeafPages_Estimated] DEFAULT ((0)),
[LeafSpaceUsed_Estimated] [decimal] (18, 2) NOT NULL CONSTRAINT [Def_IndexesRowStore_LeafSpaceUsed_Estimated] DEFAULT ((0)),
[LeafSpaceUsedMB_Estimated] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexesRowStore_LeafSpaceUsedMB_Estimated] DEFAULT ((0)),
[NumNonLeafLevelsInIndex_Estimated] [tinyint] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumNonLeafLevelsInIndex_Estimated] DEFAULT ((0)),
[NumIndexPages_Estimated] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumIndexPages_Estimated] DEFAULT ((0)),
[IndexSizeMB_Estimated] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexesRowStore_IndexSizeMB_Estimated] DEFAULT ((0)),
[IndexSizeMB_Actual] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexesRowStore_IndexSizeMB_Actual] DEFAULT ((0)),
[DriveLetter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsIndexLarge] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsIndexLarge] DEFAULT ((0)),
[IndexMeetsMinimumSize] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IndexMeetsMinimumSize] DEFAULT ((0)),
[Fragmentation] [float] NOT NULL CONSTRAINT [Def_IndexesRowStore_Fragmentation] DEFAULT ((0)),
[FragmentationType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexesRowStore_FragmentationType] DEFAULT ('None'),
[AreDropRecreateOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_AreDropRecreateOptionsChanging] DEFAULT ((0)),
[AreRebuildOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_AreRebuildOptionsChanging] DEFAULT ((0)),
[AreRebuildOnlyOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_AreRebuildOnlyOptionsChanging] DEFAULT ((0)),
[AreReorgOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_AreReorgOptionsChanging] DEFAULT ((0)),
[AreSetOptionsChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_AreSetOptionsChanging] DEFAULT ((0)),
[IsUniquenessChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsUniquenessChanging] DEFAULT ((0)),
[IsPrimaryKeyChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsPrimaryKeyChanging] DEFAULT ((0)),
[IsKeyColumnListChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsKeyColumnListChanging] DEFAULT ((0)),
[IsIncludedColumnListChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsIncludedColumnListChanging] DEFAULT ((0)),
[IsFilterChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsFilterChanging] DEFAULT ((0)),
[IsClusteredChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsClusteredChanging] DEFAULT ((0)),
[IsPartitioningChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsPartitioningChanging] DEFAULT ((0)),
[IsPadIndexChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsPadIndexChanging] DEFAULT ((0)),
[IsFillfactorChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsFillfactorChanging] DEFAULT ((0)),
[IsIgnoreDupKeyChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsIgnoreDupKeyChanging] DEFAULT ((0)),
[IsStatisticsNoRecomputeChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsStatisticsNoRecomputeChanging] DEFAULT ((0)),
[IsStatisticsIncrementalChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsStatisticsIncrementalChanging] DEFAULT ((0)),
[IsAllowRowLocksChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsAllowRowLocksChanging] DEFAULT ((0)),
[IsAllowPageLocksChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsAllowPageLocksChanging] DEFAULT ((0)),
[IsDataCompressionChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsDataCompressionChanging] DEFAULT ((0)),
[IsDataCompressionDelayChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsDataCompressionDelayChanging] DEFAULT ((0)),
[IsStorageChanging] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IsStorageChanging] DEFAULT ((0)),
[IndexHasLOBColumns] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_IndexHasLOBColumns] DEFAULT ((0)),
[NumPages_Actual] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_NumPages_Actual] DEFAULT ((0)),
[TotalPartitionsInIndex] [int] NOT NULL CONSTRAINT [Def_IndexesRowStore_TotalPartitionsInIndex] DEFAULT ((0)),
[NeedsPartitionLevelOperations] [bit] NOT NULL CONSTRAINT [Def_IndexesRowStore_NeedsPartitionLevelOperations] DEFAULT ((0)),
CONSTRAINT [PK_IndexesRowStore] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName]),
INDEX [IDX_IndexesRowStore_IndexName] NONCLUSTERED ([IndexName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[IndexColumns]'
GO
IF OBJECT_ID(N'[DDI].[IndexColumns]', 'U') IS NULL
CREATE TABLE [DDI].[IndexColumns]
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
CONSTRAINT [PK_IndexColumns] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysPartitionSchemes]'
GO
IF OBJECT_ID(N'[DDI].[SysPartitionSchemes]', 'U') IS NULL
CREATE TABLE [DDI].[SysPartitionSchemes]
(
[database_id] [sys].[sysname] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[data_space_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_default] [bit] NULL,
[is_system] [bit] NULL,
[function_id] [int] NOT NULL,
CONSTRAINT [PK_SysPartitionSchemes] PRIMARY KEY NONCLUSTERED  ([function_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysPartitions]'
GO
IF OBJECT_ID(N'[DDI].[SysPartitions]', 'U') IS NULL
CREATE TABLE [DDI].[SysPartitions]
(
[database_id] [int] NOT NULL,
[partition_id] [bigint] NOT NULL,
[object_id] [int] NOT NULL,
[index_id] [int] NOT NULL,
[partition_number] [int] NOT NULL,
[hobt_id] [bigint] NOT NULL,
[rows] [bigint] NULL,
[filestream_filegroup_id] [smallint] NOT NULL,
[data_compression] [tinyint] NOT NULL,
[data_compression_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_SysPartitions] PRIMARY KEY NONCLUSTERED  ([database_id], [partition_id]),
CONSTRAINT [UQ_SysPartitions2] UNIQUE NONCLUSTERED  ([database_id], [hobt_id]),
CONSTRAINT [UQ_SysPartitions] UNIQUE NONCLUSTERED  ([database_id], [object_id], [index_id], [partition_number])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysPartitionFunctions]'
GO
IF OBJECT_ID(N'[DDI].[SysPartitionFunctions]', 'U') IS NULL
CREATE TABLE [DDI].[SysPartitionFunctions]
(
[database_id] [sys].[sysname] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[function_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fanout] [int] NOT NULL,
[boundary_value_on_right] [bit] NOT NULL,
[is_system] [bit] NOT NULL,
[create_date] [datetime] NOT NULL,
[modify_date] [datetime] NOT NULL,
CONSTRAINT [PK_SysPartitionFunctions] PRIMARY KEY NONCLUSTERED  ([database_id], [function_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysIndexes]'
GO
IF OBJECT_ID(N'[DDI].[SysIndexes]', 'U') IS NULL
CREATE TABLE [DDI].[SysIndexes]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[index_id] [int] NOT NULL,
[type] [tinyint] NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[is_unique] [bit] NOT NULL,
[data_space_id] [int] NULL,
[ignore_dup_key] [bit] NOT NULL,
[is_primary_key] [bit] NOT NULL,
[is_unique_constraint] [bit] NOT NULL,
[fill_factor] [tinyint] NOT NULL,
[is_padded] [bit] NOT NULL,
[is_disabled] [bit] NOT NULL,
[is_hypothetical] [bit] NOT NULL,
[allow_row_locks] [bit] NOT NULL,
[allow_page_locks] [bit] NOT NULL,
[has_filter] [bit] NOT NULL,
[filter_definition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compression_delay] [int] NULL,
[key_column_list] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[included_column_list] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_LOB_columns] [bit] NULL,
CONSTRAINT [PK_SysIndexes] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [index_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysDmOsVolumeStats]'
GO
IF OBJECT_ID(N'[DDI].[SysDmOsVolumeStats]', 'U') IS NULL
CREATE TABLE [DDI].[SysDmOsVolumeStats]
(
[database_id] [int] NOT NULL,
[file_id] [int] NOT NULL,
[volume_mount_point] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[volume_id] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logical_volume_name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[file_system_type] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_bytes] [bigint] NOT NULL,
[available_bytes] [bigint] NOT NULL,
[supports_compression] [tinyint] NULL,
[supports_alternate_streams] [tinyint] NULL,
[supports_sparse_files] [tinyint] NULL,
[is_read_only] [tinyint] NULL,
[is_compressed] [tinyint] NULL,
CONSTRAINT [PK_SysDmOsVolumeStats] PRIMARY KEY NONCLUSTERED  ([database_id], [file_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysDataSpaces]'
GO
IF OBJECT_ID(N'[DDI].[SysDataSpaces]', 'U') IS NULL
CREATE TABLE [DDI].[SysDataSpaces]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[data_space_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_default] [bit] NOT NULL,
[is_system] [bit] NULL,
CONSTRAINT [PK_SysDataSpaces] PRIMARY KEY NONCLUSTERED  ([database_id], [data_space_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysDatabaseFiles]'
GO
IF OBJECT_ID(N'[DDI].[SysDatabaseFiles]', 'U') IS NULL
CREATE TABLE [DDI].[SysDatabaseFiles]
(
[database_id] [int] NOT NULL,
[file_id] [int] NOT NULL,
[file_guid] [uniqueidentifier] NULL,
[type] [tinyint] NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[data_space_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[physical_name] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CONSTRAINT [PK_SysDatabaseFiles] PRIMARY KEY NONCLUSTERED  ([database_id], [file_id]),
CONSTRAINT [UQ_SysDatabaseFiles_FileGUID] UNIQUE NONCLUSTERED  ([database_id], [file_guid]),
CONSTRAINT [UQ_SysDatabaseFiles_Name] UNIQUE NONCLUSTERED  ([database_id], [name]),
CONSTRAINT [UQ_SysDatabaseFiles_PhysicalName] UNIQUE NONCLUSTERED  ([database_id], [physical_name])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysAllocationUnits]'
GO
IF OBJECT_ID(N'[DDI].[SysAllocationUnits]', 'U') IS NULL
CREATE TABLE [DDI].[SysAllocationUnits]
(
[database_id] [int] NOT NULL,
[allocation_unit_id] [bigint] NOT NULL,
[type] [tinyint] NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[container_id] [bigint] NOT NULL,
[data_space_id] [int] NULL,
[total_pages] [bigint] NOT NULL,
[used_pages] [bigint] NOT NULL,
[data_pages] [bigint] NOT NULL,
CONSTRAINT [PK_SysAllocationUnits] PRIMARY KEY NONCLUSTERED  ([database_id], [allocation_unit_id]),
CONSTRAINT [UQ_SysAllocationUnits] UNIQUE NONCLUSTERED  ([container_id], [data_space_id], [type])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysIndexPhysicalStats]'
GO
IF OBJECT_ID(N'[DDI].[SysIndexPhysicalStats]', 'U') IS NULL
CREATE TABLE [DDI].[SysIndexPhysicalStats]
(
[database_id] [smallint] NOT NULL,
[object_id] [int] NOT NULL,
[index_id] [int] NOT NULL,
[partition_number] [int] NOT NULL,
[index_type_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alloc_unit_type_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[index_depth] [tinyint] NULL,
[index_level] [tinyint] NULL,
[avg_fragmentation_in_percent] [float] NULL,
[fragment_count] [bigint] NULL,
[avg_fragment_size_in_pages] [float] NULL,
[page_count] [bigint] NULL,
[avg_page_space_used_in_percent] [float] NULL,
[record_count] [bigint] NULL,
[ghost_record_count] [bigint] NULL,
[version_ghost_record_count] [bigint] NULL,
[min_record_size_in_bytes] [int] NULL,
[max_record_size_in_bytes] [int] NULL,
[avg_record_size_in_bytes] [float] NULL,
[forwarded_record_count] [bigint] NULL,
[compressed_page_count] [bigint] NULL,
[hobt_id] [bigint] NOT NULL,
[columnstore_delete_buffer_state] [tinyint] NULL,
[columnstore_delete_buffer_state_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_SysIndexPhysicalStats] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [index_id], [partition_number], [hobt_id], [alloc_unit_type_desc])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysIndexColumns]'
GO
IF OBJECT_ID(N'[DDI].[SysIndexColumns]', 'U') IS NULL
CREATE TABLE [DDI].[SysIndexColumns]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[index_id] [int] NOT NULL,
[index_column_id] [int] NOT NULL,
[column_id] [int] NOT NULL,
[key_ordinal] [tinyint] NOT NULL,
[partition_ordinal] [tinyint] NOT NULL,
[is_descending_key] [bit] NULL,
[is_included_column] [bit] NULL,
CONSTRAINT [PK_SysIndexColumns] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [index_id], [index_column_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[Databases]'
GO
IF OBJECT_ID(N'[DDI].[Databases]', 'U') IS NULL
CREATE TABLE [DDI].[Databases]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CONSTRAINT [PK_Databases] PRIMARY KEY NONCLUSTERED  ([DatabaseName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysPartitionRangeValues]'
GO
IF OBJECT_ID(N'[DDI].[SysPartitionRangeValues]', 'U') IS NULL
CREATE TABLE [DDI].[SysPartitionRangeValues]
(
[database_id] [sys].[sysname] NOT NULL,
[function_id] [int] NOT NULL,
[boundary_id] [int] NOT NULL,
[parameter_id] [int] NOT NULL,
[value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_SysPartitionRangeValues] PRIMARY KEY NONCLUSTERED  ([database_id], [function_id], [boundary_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysFilegroups]'
GO
IF OBJECT_ID(N'[DDI].[SysFilegroups]', 'U') IS NULL
CREATE TABLE [DDI].[SysFilegroups]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[data_space_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_default] [bit] NULL,
[is_system] [bit] NULL,
[filegroup_guid] [uniqueidentifier] NULL,
[log_filegroup_id] [int] NULL,
[is_read_only] [bit] NULL,
[is_autogrow_all_files] [bit] NULL,
CONSTRAINT [PK_SysFilegroups] PRIMARY KEY NONCLUSTERED  ([database_id], [data_space_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysDestinationDataSpaces]'
GO
IF OBJECT_ID(N'[DDI].[SysDestinationDataSpaces]', 'U') IS NULL
CREATE TABLE [DDI].[SysDestinationDataSpaces]
(
[database_id] [int] NOT NULL,
[partition_scheme_id] [int] NOT NULL,
[destination_id] [int] NOT NULL,
[data_space_id] [int] NOT NULL,
CONSTRAINT [PK_SysDestinationDataSpaces] PRIMARY KEY NONCLUSTERED  ([database_id], [partition_scheme_id], [destination_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[IndexColumnStorePartitions]'
GO
IF OBJECT_ID(N'[DDI].[IndexColumnStorePartitions]', 'U') IS NULL
CREATE TABLE [DDI].[IndexColumnStorePartitions]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionDataCompression] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexColumnStorePartitions_OptionDataCompression] DEFAULT ('COLUMNSTORE'),
CONSTRAINT [PK_IndexColumnStorePartitions] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[IndexRowStorePartitions]'
GO
IF OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U') IS NULL
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
PRINT N'Creating [DDI].[Statistics]'
GO
IF OBJECT_ID(N'[DDI].[Statistics]', 'U') IS NULL
CREATE TABLE [DDI].[Statistics]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatisticsName] [sys].[sysname] NOT NULL,
[IsStatisticsMissingFromSQLServer] [bit] NOT NULL CONSTRAINT [Def_Statistics_IsStatisticsMissingFromSQLServer] DEFAULT ((0)),
[StatisticsColumnList_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatisticsColumnList_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SampleSizePct_Desired] [tinyint] NOT NULL,
[SampleSizePct_Actual] [tinyint] NOT NULL CONSTRAINT [Def_Statistics_SampleSize_Actual] DEFAULT ((0)),
[IsFiltered_Desired] [bit] NOT NULL,
[IsFiltered_Actual] [bit] NOT NULL CONSTRAINT [Def_Statistics_IsFiltered_Actual] DEFAULT ((0)),
[FilterPredicate_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterPredicate_Actual] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsIncremental_Desired] [bit] NOT NULL,
[IsIncremental_Actual] [bit] NOT NULL CONSTRAINT [Def_Statistics_IsIncremental_Actual] DEFAULT ((0)),
[NoRecompute_Desired] [bit] NOT NULL,
[NoRecompute_Actual] [bit] NOT NULL CONSTRAINT [Def_Statistics_NoRecompute_Actual] DEFAULT ((0)),
[LowerSampleSizeToDesired] [bit] NOT NULL,
[ReadyToQueue] [bit] NOT NULL CONSTRAINT [Def_Statistics_ReadyToQueue] DEFAULT ((0)),
[DoesSampleSizeNeedUpdate] [bit] NOT NULL CONSTRAINT [Def_Statistics_DoesSampleSizeNeedUpdate] DEFAULT ((0)),
[IsStatisticsMissing] [bit] NOT NULL CONSTRAINT [Def_Statistics_IsStatisticsMissing] DEFAULT ((0)),
[HasFilterChanged] [bit] NOT NULL CONSTRAINT [Def_Statistics_HasFilterChanged] DEFAULT ((0)),
[HasIncrementalChanged] [bit] NOT NULL CONSTRAINT [Def_Statistics_HasIncrementalChanged] DEFAULT ((0)),
[HasNoRecomputeChanged] [bit] NOT NULL CONSTRAINT [Def_Statistics_HasNoRecomputeChanged] DEFAULT ((0)),
[NumRowsInTableUnfiltered] [bigint] NULL,
[NumRowsInTableFiltered] [bigint] NULL,
[NumRowsSampled] [bigint] NULL,
[StatisticsLastUpdated] [datetime2] NULL,
[HistogramSteps] [int] NULL,
[StatisticsModCounter] [bigint] NULL,
[PersistedSamplePct] [float] NULL,
[StatisticsUpdateType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_Statistics_StatisticsUpdateType] DEFAULT ('None'),
[ListOfChanges] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsOnlineOperation] [bit] NOT NULL CONSTRAINT [Def_Statistics_IsOnlineOperation] DEFAULT ((0)),
CONSTRAINT [PK_Statistics] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [StatisticsName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysDmDbStatsProperties]'
GO
IF OBJECT_ID(N'[DDI].[SysDmDbStatsProperties]', 'U') IS NULL
CREATE TABLE [DDI].[SysDmDbStatsProperties]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[stats_id] [int] NOT NULL,
[last_updated] [datetime2] NULL,
[rows] [bigint] NULL,
[rows_sampled] [bigint] NULL,
[steps] [int] NULL,
[unfiltered_rows] [bigint] NULL,
[modification_counter] [bigint] NULL,
CONSTRAINT [PK_SysDmDbStatsProperties] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [stats_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[Run_PartitionState]'
GO
IF OBJECT_ID(N'[DDI].[Run_PartitionState]', 'U') IS NULL
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
PRINT N'Creating [DDI].[IndexesNotInMetadata]'
GO
IF OBJECT_ID(N'[DDI].[IndexesNotInMetadata]', 'U') IS NULL
CREATE TABLE [DDI].[IndexesNotInMetadata]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [Def_IndexesNotInMetadata_DateInserted] DEFAULT (getdate()),
[DropSQLScript] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Ignore] [bit] NOT NULL CONSTRAINT [Def_IndexesNotInMetadata_Ignore] DEFAULT ((0)),
CONSTRAINT [PK_IndexesNotInMetadata] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [DateInserted])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[DefaultConstraintsNotInMetadata]'
GO
IF OBJECT_ID(N'[DDI].[DefaultConstraintsNotInMetadata]', 'U') IS NULL
CREATE TABLE [DDI].[DefaultConstraintsNotInMetadata]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CONSTRAINT [PK_DefaultConstraintsNotInMetadata] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[CheckConstraintsNotInMetadata]'
GO
IF OBJECT_ID(N'[DDI].[CheckConstraintsNotInMetadata]', 'U') IS NULL
CREATE TABLE [DDI].[CheckConstraintsNotInMetadata]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CheckDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDisabled] [bit] NOT NULL,
[CheckConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CONSTRAINT [PK_CheckConstraintsNotInMetadata] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[Log]'
GO
IF OBJECT_ID(N'[DDI].[Log]', 'U') IS NULL
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
CONSTRAINT [PK_Log] PRIMARY KEY NONCLUSTERED  (LogID),
CONSTRAINT [UQ_Log] UNIQUE NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber], [IndexOperation], [RunStatus], [TableChildOperationId], [LogDateTime])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[MappingSqlServerDMVToDDITables]'
GO
IF OBJECT_ID(N'[DDI].[MappingSqlServerDMVToDDITables]', 'U') IS NULL
CREATE TABLE [DDI].[MappingSqlServerDMVToDDITables]
(
[DDITableName] [sys].[sysname] NOT NULL,
[SQLServerObjectName] [sys].[sysname] NOT NULL,
[SQLServerObjectType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasDatabaseIdInOutput] [bit] NOT NULL,
[FunctionParameterList] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_MappingSqlServerDMVToDDITables] PRIMARY KEY NONCLUSTERED  ([DDITableName], [SQLServerObjectName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[CheckConstraints]'
GO
IF OBJECT_ID(N'[DDI].[CheckConstraints]', 'U') IS NULL
CREATE TABLE [DDI].[CheckConstraints]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDisabled] [bit] NOT NULL,
[CheckConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CONSTRAINT [PK_CheckConstraints] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [CheckConstraintName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Adding constraints to [DDI].[IndexColumnStorePartitions]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexColumnStorePartitions_OptionDataCompression]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexColumnStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexColumnStorePartitions] ADD CONSTRAINT [Chk_IndexColumnStorePartitions_OptionDataCompression] CHECK (([OptionDataCompression]='COLUMNSTORE_ARCHIVE' OR [OptionDataCompression]='COLUMNSTORE'))
GO
PRINT N'Adding constraints to [DDI].[IndexRowStorePartitions]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexRowStorePartitions_OptionDataCompression]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [Chk_IndexRowStorePartitions_OptionDataCompression] CHECK (([OptionDataCompression]='PAGE' OR [OptionDataCompression]='ROW' OR [OptionDataCompression]='NONE'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexRowStorePartitions_PartitionType]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexRowStorePartitions]', 'U'))
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [Chk_IndexRowStorePartitions_PartitionType] CHECK (([PartitionType]='RowStore'))
GO
PRINT N'Adding constraints to [DDI].[IndexesColumnStore]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_OptionDataCompression]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_OptionDataCompression] CHECK (([OptionDataCompression_Desired]='COLUMNSTORE_ARCHIVE' OR [OptionDataCompression_Desired]='COLUMNSTORE'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Def_IndexesColumnStore_StorageType_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Def_IndexesColumnStore_StorageType_Desired] CHECK (([StorageType_Desired]='PARTITION_SCHEME' OR [StorageType_Desired]='ROWS_FILEGROUP'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Def_IndexesColumnStore_StorageType_Actual]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Def_IndexesColumnStore_StorageType_Actual] CHECK (([StorageType_Actual]='PARTITION_SCHEME' OR [StorageType_Actual]='ROWS_FILEGROUP'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_FragmentationType]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_FragmentationType] CHECK (([FragmentationType]='Heavy' OR [FragmentationType]='Light' OR [FragmentationType]='None'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_AreReorgOptionsChanging]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_AreReorgOptionsChanging] CHECK (([AreReorgOptionsChanging]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_AreSetOptionsChanging]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_AreSetOptionsChanging] CHECK (([AreSetOptionsChanging]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_ColumnList]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_ColumnList] CHECK (([IsClustered_Desired]=(1) AND [ColumnList_Desired] IS NULL OR [IsClustered_Desired]=(0) AND [ColumnList_Desired] IS NOT NULL))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesColumnStore_Filter]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesColumnStore]', 'U'))
ALTER TABLE [DDI].[IndexesColumnStore] ADD CONSTRAINT [Chk_IndexesColumnStore_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL AND [IsClustered_Desired]=(0) OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
PRINT N'Adding constraints to [DDI].[IndexesRowStore]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_IsUniqueConstraint_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_IsUniqueConstraint_Desired] CHECK (([IsUniqueConstraint_Desired]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Indexes_FillFactor_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_Indexes_FillFactor_Desired] CHECK (([Fillfactor_Desired]>=(0) AND [Fillfactor_Desired]<=(100)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_OptionDataCompression_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_OptionDataCompression_Desired] CHECK (([OptionDataCompression_Desired]='PAGE' OR [OptionDataCompression_Desired]='ROW' OR [OptionDataCompression_Desired]='NONE'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_OptionDataCompressionDelay_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_OptionDataCompressionDelay_Desired] CHECK (([OptionDataCompressionDelay_Desired]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_OptionDataCompressionDelay_Actual]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_OptionDataCompressionDelay_Actual] CHECK (([OptionDataCompressionDelay_Actual]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Def_IndexesRowStore_StorageType_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Def_IndexesRowStore_StorageType_Desired] CHECK (([StorageType_Desired]='PARTITION_SCHEME' OR [StorageType_Desired]='ROWS_FILEGROUP'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Def_IndexesRowStore_StorageType_Actual]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Def_IndexesRowStore_StorageType_Actual] CHECK (([StorageType_Actual]='PARTITION_SCHEME' OR [StorageType_Actual]='ROWS_FILEGROUP'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_FragmentationType]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_FragmentationType] CHECK (([FragmentationType]='Heavy' OR [FragmentationType]='Light' OR [FragmentationType]='None'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_Filter]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL AND [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0) AND [IsClustered_Desired]=(0) AND [OptionStatisticsIncremental_Desired]=(0) OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_IncludedColumnsNotAllowed]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_IncludedColumnsNotAllowed] CHECK ((([IncludedColumnList_Desired] IS NOT NULL AND [IsClustered_Desired]=(0) AND [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0)) OR [IncludedColumnList_Desired] IS NULL))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_PKvsUQ]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_PKvsUQ] CHECK (([IsPrimaryKey_Desired]=(1) AND [IsUniqueConstraint_Desired]=(0) OR [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(1) OR [IsPrimaryKey_Desired]=(0) AND [IsUniqueConstraint_Desired]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_PrimaryKeyIsUnique]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_PrimaryKeyIsUnique] CHECK ((([IsPrimaryKey_Desired]=(1) AND [IsUnique_Desired]=(1)) OR [IsPrimaryKey_Desired]=(0)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_IndexesRowStore_UniqueConstraintIsUnique]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[IndexesRowStore]', 'U'))
ALTER TABLE [DDI].[IndexesRowStore] ADD CONSTRAINT [Chk_IndexesRowStore_UniqueConstraintIsUnique] CHECK ((([IsUniqueConstraint_Desired]=(1) AND [IsUnique_Desired]=(1)) OR [IsUniqueConstraint_Desired]=(0)))
GO
PRINT N'Adding constraints to [DDI].[PartitionFunctions]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_PartitionFunctions_BoundaryInterval]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[PartitionFunctions]', 'U'))
ALTER TABLE [DDI].[PartitionFunctions] ADD CONSTRAINT [Chk_PartitionFunctions_BoundaryInterval] CHECK (([BoundaryInterval]='Monthly' OR [BoundaryInterval]='Yearly'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_PartitionFunctions_SlidingWindow]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[PartitionFunctions]', 'U'))
ALTER TABLE [DDI].[PartitionFunctions] ADD CONSTRAINT [Chk_PartitionFunctions_SlidingWindow] CHECK (([UsesSlidingWindow]=(1) AND [SlidingWindowSize] IS NOT NULL OR [UsesSlidingWindow]=(0) AND [SlidingWindowSize] IS NULL))
GO
PRINT N'Adding constraints to [DDI].[Log]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Log_RunStatus]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Log]', 'U'))
ALTER TABLE [DDI].[Log] ADD CONSTRAINT [Chk_Log_RunStatus] CHECK (([RunStatus]='Error - Skipping...' OR [RunStatus]='Error - Retrying...' OR [RunStatus]='Error' OR [RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
PRINT N'Adding constraints to [DDI].[Queue]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Queue_IndexOperation]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Queue]', 'U'))
ALTER TABLE [DDI].[Queue] ADD CONSTRAINT [Chk_Queue_IndexOperation] CHECK (([IndexOperation]='Delay' OR [IndexOperation]='Update Statistics' OR [IndexOperation]='Create Statistics' OR [IndexOperation]='Drop Statistics' OR [IndexOperation]='Delete PartitionState Metadata' OR [IndexOperation]='Partition State Metadata Validation' OR [IndexOperation]='Resource Governor Settings' OR [IndexOperation]='Release Application Lock' OR [IndexOperation]='Get Application Lock' OR [IndexOperation]='Kill' OR [IndexOperation]='Clean Up Tables' OR [IndexOperation]='Turn Off DataSynch' OR [IndexOperation]='Turn On DataSynch' OR [IndexOperation]='Clear Queue of Other Tables' OR [IndexOperation]='Data Synch Trigger Revert Rename' OR [IndexOperation]='Free TempDB Space Validation' OR [IndexOperation]='Free Log Space Validation' OR [IndexOperation]='Free Data Space Validation' OR [IndexOperation]='Stop Processing' OR [IndexOperation]='Table Revert Rename' OR [IndexOperation]='Constraint Revert Rename' OR [IndexOperation]='Index Revert Rename' OR [IndexOperation]='Prior Error Validation SQL' OR [IndexOperation]='Partition Data Validation SQL' OR [IndexOperation]='Drop Data Synch Table' OR [IndexOperation]='Drop Data Synch Trigger' OR [IndexOperation]='Rename Data Synch Table' OR [IndexOperation]='Delete from Queue' OR [IndexOperation]='Update to In-Progress' OR [IndexOperation]='FinalValidation' OR [IndexOperation]='Temp Table SQL' OR [IndexOperation]='Drop Parent Old Table FKs' OR [IndexOperation]='Drop Ref Old Table FKs' OR [IndexOperation]='Add back Parent Table FKs' OR [IndexOperation]='Add back Ref Table FKs' OR [IndexOperation]='Disable CmdShell' OR [IndexOperation]='Enable CmdShell' OR [IndexOperation]='Rollback DDL' OR [IndexOperation]='Synch Updates' OR [IndexOperation]='Synch Inserts' OR [IndexOperation]='Synch Deletes' OR [IndexOperation]='Rename Existing Table Constraint' OR [IndexOperation]='Rename Existing Table Index' OR [IndexOperation]='Rename New Partitioned Prep Table Constraint' OR [IndexOperation]='Rename New Partitioned Prep Table Index' OR [IndexOperation]='Rename Existing Table' OR [IndexOperation]='Rename New Partitioned Prep Table' OR [IndexOperation]='Drop Table SQL' OR [IndexOperation]='Check Constraint SQL' OR [IndexOperation]='Commit Tran' OR [IndexOperation]='Begin Tran' OR [IndexOperation]='Switch Partitions SQL' OR [IndexOperation]='Partition Prep Table SQL' OR [IndexOperation]='Drop Ref FKs' OR [IndexOperation]='Recreate All FKs' OR [IndexOperation]='Loading Data' OR [IndexOperation]='Create Final Data Synch Trigger' OR [IndexOperation]='Create Final Data Synch Table' OR [IndexOperation]='Create Data Synch Trigger' OR [IndexOperation]='Prep Table SQL' OR [IndexOperation]='Alter Index' OR [IndexOperation]='Create Constraint' OR [IndexOperation]='Create Index' OR [IndexOperation]='Drop Index'))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Queue_RunStatus]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Queue]', 'U'))
ALTER TABLE [DDI].[Queue] ADD CONSTRAINT [Chk_Queue_RunStatus] CHECK (([RunStatus]='Finish' OR [RunStatus]='Running' OR [RunStatus]='Start'))
GO
PRINT N'Adding constraints to [DDI].[Statistics]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Statistics_SampleSize_Desired]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Statistics]', 'U'))
ALTER TABLE [DDI].[Statistics] ADD CONSTRAINT [Chk_Statistics_SampleSize_Desired] CHECK (([SampleSizePct_Desired]>=(0) AND [SampleSizePct_Desired]<=(100)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Statistics_SampleSize_Actual]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Statistics]', 'U'))
ALTER TABLE [DDI].[Statistics] ADD CONSTRAINT [Chk_Statistics_SampleSize_Actual] CHECK (([SampleSizePct_Actual]>=(0) AND [SampleSizePct_Actual]<=(100)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Statistics_Filter]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Statistics]', 'U'))
ALTER TABLE [DDI].[Statistics] ADD CONSTRAINT [Chk_Statistics_Filter] CHECK (([IsFiltered_Desired]=(1) AND [FilterPredicate_Desired] IS NOT NULL OR [IsFiltered_Desired]=(0) AND [FilterPredicate_Desired] IS NULL))
GO
PRINT N'Adding constraints to [DDI].[Tables]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_Tables_PartitioningSetup]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[Tables]', 'U'))
ALTER TABLE [DDI].[Tables] ADD CONSTRAINT [Chk_Tables_PartitioningSetup] CHECK (([IntendToPartition]=(1) AND [PartitionColumn] IS NOT NULL OR [IntendToPartition]=(0) AND [PartitionColumn] IS NULL))
GO
