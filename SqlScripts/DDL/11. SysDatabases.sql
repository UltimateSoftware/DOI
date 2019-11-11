USE DDI
GO

DROP TABLE DDI.SysDatabases
GO

CREATE TABLE DDI.SysDatabases (
    name	                                    sysname,
    database_id	                                int NOT NULL,
    source_database_id	                        int NULL,
    owner_sid	                                varbinary(85) NULL,
    create_date	                                datetime NOT NULL,
    compatibility_level	                        tinyint NOT NULL,
    collation_name	                            sysname,
    user_access	                                tinyint NULL,
    user_access_desc	                        nvarchar(60) NULL,
    is_read_only	                            bit NULL,
    is_auto_close_on	                        bit NOT NULL,
    is_auto_shrink_on	                        bit NULL,
    state	                                    tinyint NULL,
    state_desc	                                nvarchar(60) NULL,
    is_in_standby	                            bit NULL,
    is_cleanly_shutdown	                        bit NULL,
    is_supplemental_logging_enabled	            bit NULL,
    snapshot_isolation_state	                tinyint NULL,
    snapshot_isolation_state_desc	            nvarchar(60) NULL,
    is_read_committed_snapshot_on	            bit NULL,
    recovery_model	                            tinyint NULL,
    recovery_model_desc	                        nvarchar(60) NULL,
    page_verify_option	                        tinyint NULL,
    page_verify_option_desc	                    nvarchar(60) NULL,
    is_auto_create_stats_on	                    bit NULL,
    is_auto_create_stats_incremental_on	        bit NULL,
    is_auto_update_stats_on	                    bit NULL,
    is_auto_update_stats_async_on	            bit NULL,
    is_ansi_null_default_on	                    bit NULL,
    is_ansi_nulls_on	                        bit NULL,
    is_ansi_padding_on	                        bit NULL,
    is_ansi_warnings_on	                        bit NULL,
    is_arithabort_on	                        bit NULL,
    is_concat_null_yields_null_on	            bit NULL,
    is_numeric_roundabort_on	                bit NULL,
    is_quoted_identifier_on	                    bit NULL,
    is_recursive_triggers_on	                bit NULL,
    is_cursor_close_on_commit_on	            bit NULL,
    is_local_cursor_default	                    bit NULL,
    is_fulltext_enabled	                        bit NULL,
    is_trustworthy_on	                        bit NULL,
    is_db_chaining_on	                        bit NULL,
    is_parameterization_forced	                bit NULL,
    is_master_key_encrypted_by_server	        bit NOT NULL,
    is_query_store_on	                        bit NULL,
    is_published	                            bit NOT NULL,
    is_subscribed	                            bit NOT NULL,
    is_merge_published	                        bit NOT NULL,
    is_distributor	                            bit NOT NULL,
    is_sync_with_backup	                        bit NOT NULL,
    service_broker_guid	                        uniqueidentifier NOT NULL,
    is_broker_enabled	                        bit NOT NULL,
    log_reuse_wait	                            tinyint NULL,
    log_reuse_wait_desc	                        nvarchar(60) NULL,
    is_date_correlation_on	                    bit NOT NULL,
    is_cdc_enabled	                            bit NOT NULL,
    is_encrypted	                            bit NULL,
    is_honor_broker_priority_on	                bit NULL,
    replica_id	                                uniqueidentifier NULL,
    group_database_id	                        uniqueidentifier NULL,
    resource_pool_id	                        int NULL,
    default_language_lcid	                    smallint NULL,
    default_language_name	                    nvarchar(128) NULL,
    default_fulltext_language_lcid	            int NULL,
    default_fulltext_language_name              nvarchar(128) NULL,
    is_nested_triggers_on                       bit NULL,
    is_transform_noise_words_on	                bit NULL,
    two_digit_year_cutoff	                    smallint NULL,
    containment	                                tinyint NULL,
    containment_desc	                        nvarchar(60) NULL,
    target_recovery_time_in_seconds	            int NULL,
    delayed_durability	                        int NULL,
    delayed_durability_desc	                    nvarchar(60) NULL,
    is_memory_optimized_elevate_to_snapshot_on	bit NULL,
    is_federation_member	                    bit NULL,
    is_remote_data_archive_enabled	            bit NULL,
    is_mixed_page_allocation_on	                bit NULL

    CONSTRAINT PK_SysDatabases
        PRIMARY KEY NONCLUSTERED (database_id)
)
WITH (MEMORY_OPTIMIZED = ON)
GO

SELECT *
INTO #SysDatabases
FROM sys.databases
GO
INSERT INTO DDI.SysDatabases
SELECT * FROM #SysDatabases
GO
DROP TABLE #SysDatabases
GO
