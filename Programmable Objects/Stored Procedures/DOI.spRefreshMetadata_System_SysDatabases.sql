
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDatabases]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabases];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabases]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDatabases]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE DOI.SysDatabases
WHERE name = CASE WHEN @DatabaseName IS NULL THEN name ELSE @DatabaseName END 

INSERT INTO DOI.SysDatabases ([name], [database_id], [source_database_id], [owner_sid], [create_date], [compatibility_level], [collation_name], [user_access], [user_access_desc], [is_read_only], [is_auto_close_on], [is_auto_shrink_on], [state], [state_desc], [is_in_standby], [is_cleanly_shutdown], [is_supplemental_logging_enabled], [snapshot_isolation_state], [snapshot_isolation_state_desc], [is_read_committed_snapshot_on], [recovery_model], [recovery_model_desc], [page_verify_option], [page_verify_option_desc], [is_auto_create_stats_on], [is_auto_create_stats_incremental_on], [is_auto_update_stats_on], [is_auto_update_stats_async_on], [is_ansi_null_default_on], [is_ansi_nulls_on], [is_ansi_padding_on], [is_ansi_warnings_on], [is_arithabort_on], [is_concat_null_yields_null_on], [is_numeric_roundabort_on], [is_quoted_identifier_on], [is_recursive_triggers_on], [is_cursor_close_on_commit_on], [is_local_cursor_default], [is_fulltext_enabled], [is_trustworthy_on], [is_db_chaining_on], [is_parameterization_forced], [is_master_key_encrypted_by_server], [is_query_store_on], [is_published], [is_subscribed], [is_merge_published], [is_distributor], [is_sync_with_backup], [service_broker_guid], [is_broker_enabled], [log_reuse_wait], [log_reuse_wait_desc], [is_date_correlation_on], [is_cdc_enabled], [is_encrypted], [is_honor_broker_priority_on], [replica_id], [group_database_id], [resource_pool_id], [default_language_lcid], [default_language_name], [default_fulltext_language_lcid], [default_fulltext_language_name], [is_nested_triggers_on], [is_transform_noise_words_on], [two_digit_year_cutoff], [containment], [containment_desc], [target_recovery_time_in_seconds], [delayed_durability], [delayed_durability_desc], [is_memory_optimized_elevate_to_snapshot_on], [is_federation_member], [is_remote_data_archive_enabled], [is_mixed_page_allocation_on])
SELECT [name], [database_id], [source_database_id], [owner_sid], [create_date], [compatibility_level], [collation_name], [user_access], [user_access_desc], [is_read_only], [is_auto_close_on], [is_auto_shrink_on], [state], [state_desc], [is_in_standby], [is_cleanly_shutdown], [is_supplemental_logging_enabled], [snapshot_isolation_state], [snapshot_isolation_state_desc], [is_read_committed_snapshot_on], [recovery_model], [recovery_model_desc], [page_verify_option], [page_verify_option_desc], [is_auto_create_stats_on], [is_auto_create_stats_incremental_on], [is_auto_update_stats_on], [is_auto_update_stats_async_on], [is_ansi_null_default_on], [is_ansi_nulls_on], [is_ansi_padding_on], [is_ansi_warnings_on], [is_arithabort_on], [is_concat_null_yields_null_on], [is_numeric_roundabort_on], [is_quoted_identifier_on], [is_recursive_triggers_on], [is_cursor_close_on_commit_on], [is_local_cursor_default], [is_fulltext_enabled], [is_trustworthy_on], [is_db_chaining_on], [is_parameterization_forced], [is_master_key_encrypted_by_server], [is_query_store_on], [is_published], [is_subscribed], [is_merge_published], [is_distributor], [is_sync_with_backup], [service_broker_guid], [is_broker_enabled], [log_reuse_wait], [log_reuse_wait_desc], [is_date_correlation_on], [is_cdc_enabled], [is_encrypted], [is_honor_broker_priority_on], [replica_id], [group_database_id], [resource_pool_id], [default_language_lcid], [default_language_name], [default_fulltext_language_lcid], [default_fulltext_language_name], [is_nested_triggers_on], [is_transform_noise_words_on], [two_digit_year_cutoff], [containment], [containment_desc], [target_recovery_time_in_seconds], [delayed_durability], [delayed_durability_desc], [is_memory_optimized_elevate_to_snapshot_on], [is_federation_member], [is_remote_data_archive_enabled], [is_mixed_page_allocation_on]
FROM sys.databases
WHERE NAME = CASE WHEN @DatabaseName IS NULL THEN name ELSE @DatabaseName END 



GO