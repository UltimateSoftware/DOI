﻿-- <Migration ID="34c17dd7-07bb-4639-9759-e17109d3ebbc" TransactionHandling="Custom" />
IF OBJECT_ID('[DDI].[MappingSqlServerDMVToDDITables]') IS NULL
CREATE TABLE [DDI].[MappingSqlServerDMVToDDITables]
(
[DDITableName] [sys].[sysname] NOT NULL,
[SQLServerObjectName] [sys].[sysname] NOT NULL,
[SQLServerObjectType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasDatabaseIdInOutput] [bit] NOT NULL,
[DatabaseOutputString] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FunctionParameterList] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FunctionParentDMV] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_MappingSqlServerDMVToDDITables] PRIMARY KEY NONCLUSTERED  ([DDITableName], [SQLServerObjectName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DDI].[SysDatabases]') IS NULL
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
IF OBJECT_ID('[DDI].[SysDatabaseFiles]') IS NULL
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
CONSTRAINT [UQ_SysDatabaseFiles_Name] UNIQUE NONCLUSTERED  ([database_id], [name]),
CONSTRAINT [UQ_SysDatabaseFiles_PhysicalName] UNIQUE NONCLUSTERED  ([database_id], [physical_name])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DDI].[SysDataSpaces]') IS NULL
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
IF OBJECT_ID('[DDI].[SysDefaultConstraints]') IS NULL
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
IF OBJECT_ID('[DDI].[SysDestinationDataSpaces]') IS NULL
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
IF OBJECT_ID('[DDI].[SysDmDbStatsProperties]') IS NULL
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
[persisted_sample_percent] [float] NULL,
CONSTRAINT [PK_SysDmDbStatsProperties] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [stats_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DDI].[SysDmOsVolumeStats]') IS NULL
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
IF OBJECT_ID('[DDI].[SysFilegroups]') IS NULL
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
IF OBJECT_ID('[DDI].[SysForeignKeyColumns]') IS NULL
CREATE TABLE [DDI].[SysForeignKeyColumns]
(
[database_id] [int] NOT NULL,
[constraint_object_id] [int] NOT NULL,
[constraint_column_id] [int] NOT NULL,
[parent_object_id] [int] NOT NULL,
[parent_column_id] [int] NOT NULL,
[referenced_object_id] [int] NOT NULL,
[referenced_column_id] [int] NOT NULL,
CONSTRAINT [PK_SysForeignKeyColumns] PRIMARY KEY NONCLUSTERED  ([database_id], [constraint_object_id], [constraint_column_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DDI].[SysForeignKeys]') IS NULL
CREATE TABLE [DDI].[SysForeignKeys]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[object_id] [int] NOT NULL,
[principal_id] [int] NULL,
[schema_id] [int] NOT NULL,
[parent_object_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NOT NULL,
[modify_date] [datetime] NOT NULL,
[is_ms_shipped] [bit] NOT NULL,
[is_published] [bit] NOT NULL,
[is_schema_published] [bit] NOT NULL,
[referenced_object_id] [int] NULL,
[key_index_id] [int] NULL,
[is_disabled] [bit] NOT NULL,
[is_not_for_replication] [bit] NOT NULL,
[is_not_trusted] [bit] NOT NULL,
[delete_referential_action] [tinyint] NULL,
[delete_referential_action_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_referential_action] [tinyint] NULL,
[update_referential_action_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_system_named] [bit] NOT NULL,
[ParentColumnList_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferencedColumnList_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeploymentTime] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_SysForeignKeys] PRIMARY KEY NONCLUSTERED  ([database_id], [name])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('DDI.Chk_SysForeignKeys_DeploymentTime','C') IS NULL
ALTER TABLE [DDI].[SysForeignKeys] ADD CONSTRAINT [Chk_SysForeignKeys_DeploymentTime] CHECK (([DeploymentTime]='Deployment' OR [DeploymentTime]='Job'))
GO
IF OBJECT_ID('[DDI].[SysIndexColumns]') IS NULL
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
IF OBJECT_ID('[DDI].[SysIndexes]') IS NULL
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
IF OBJECT_ID('[DDI].[SysIndexPhysicalStats]') IS NULL
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
IF OBJECT_ID('[DDI].[SysMasterFiles]') IS NULL
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
IF OBJECT_ID('[DDI].[SysPartitionFunctions]') IS NULL
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
IF OBJECT_ID('[DDI].[SysPartitionRangeValues]') IS NULL
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
IF OBJECT_ID('[DDI].[SysPartitions]') IS NULL
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
CONSTRAINT [UQ_SysPartitions] UNIQUE NONCLUSTERED  ([database_id], [object_id], [index_id], [partition_number])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DDI].[SysPartitionSchemes]') IS NULL
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
IF OBJECT_ID('[DDI].[SysSchemas]') IS NULL
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
IF OBJECT_ID('[DDI].[SysStats]') IS NULL
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
IF OBJECT_ID('[DDI].[SysStatsColumns]') IS NULL
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
IF OBJECT_ID('[DDI].[SysTables]') IS NULL
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
IF OBJECT_ID('[DDI].[SysTriggers]') IS NULL
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
IF OBJECT_ID('[DDI].[SysTypes]') IS NULL
CREATE TABLE [DDI].[SysTypes]
(
[DatabaseName] [sys].[sysname] NOT NULL,
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
CONSTRAINT [PK_SysTypes] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [user_type_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
IF OBJECT_ID('[DDI].[SysColumns]') IS NULL
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
IF OBJECT_ID('[DDI].[SysAllocationUnits]') IS NULL
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
IF OBJECT_ID('[DDI].[SysCheckConstraints]') IS NULL
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
