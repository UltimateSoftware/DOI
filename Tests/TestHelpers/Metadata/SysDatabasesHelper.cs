using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using Models = DOI.Tests.Integration.Models;

namespace DOI.Tests.TestHelpers.Metadata
{
    public class SysDatabasesHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysDatabases";
        public const string SqlServerDmvName = "sys.Databases";

        public static List<SysDatabases> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {SqlServerDmvName} T 
            WHERE T.name = '{DatabaseName}'"));

            List<SysDatabases> expectedSysDatabases = new List<SysDatabases>();
            
            foreach (var row in expected)
            {
                var columnValue = new SysDatabases();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.database_id = row.First(x => x.First == "database_id").Second.ObjectToInteger();
                columnValue.source_database_id = row.First(x => x.First == "source_database_id").Second.ObjectToInteger();
                columnValue.owner_sid = (byte[])row.First(x => x.First == "owner_sid").Second;
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.compatibility_level = row.First(x => x.First == "compatibility_level").Second.ObjectToInteger();
                columnValue.collation_name = row.First(x => x.First == "collation_name").Second.ToString();
                columnValue.user_access = row.First(x => x.First == "user_access").Second.ObjectToInteger();
                columnValue.user_access_desc = row.First(x => x.First == "user_access_desc").Second.ToString();
                columnValue.is_read_only = (bool)row.First(x => x.First == "is_read_only").Second;
                columnValue.is_auto_close_on = (bool)row.First(x => x.First == "is_auto_close_on").Second;
                columnValue.is_auto_shrink_on = (bool)row.First(x => x.First == "is_auto_shrink_on").Second;
                columnValue.state = row.First(x => x.First == "state").Second.ObjectToInteger();
                columnValue.state_desc = row.First(x => x.First == "state_desc").Second.ToString();
                columnValue.is_in_standby = row.First(x => x.First == "is_in_standby").Second.ObjectToInteger();
                columnValue.is_cleanly_shutdown = (bool)row.First(x => x.First == "is_cleanly_shutdown").Second;
                columnValue.is_supplemental_logging_enabled = (bool)row.First(x => x.First == "is_supplemental_logging_enabled").Second;
                columnValue.snapshot_isolation_state = row.First(x => x.First == "snapshot_isolation_state").Second.ObjectToInteger();
                columnValue.snapshot_isolation_state_desc = row.First(x => x.First == "snapshot_isolation_state_desc").Second.ToString();
                columnValue.is_read_committed_snapshot_on = (bool)row.First(x => x.First == "is_read_committed_snapshot_on").Second;
                columnValue.recovery_model = row.First(x => x.First == "recovery_model").Second.ObjectToInteger();
                columnValue.recovery_model_desc = row.First(x => x.First == "recovery_model_desc").Second.ToString();
                columnValue.page_verify_option = row.First(x => x.First == "page_verify_option").Second.ObjectToInteger();
                columnValue.page_verify_option_desc = row.First(x => x.First == "page_verify_option_desc").Second.ToString();
                columnValue.is_auto_create_stats_on = (bool)row.First(x => x.First == "is_auto_create_stats_on").Second;
                columnValue.is_auto_create_stats_incremental_on = (bool)row.First(x => x.First == "is_auto_create_stats_incremental_on").Second;
                columnValue.is_auto_update_stats_on = (bool)row.First(x => x.First == "is_auto_update_stats_on").Second;
                columnValue.is_auto_update_stats_async_on = (bool)row.First(x => x.First == "is_auto_update_stats_async_on").Second;
                columnValue.is_ansi_null_default_on = (bool)row.First(x => x.First == "is_ansi_null_default_on").Second;
                columnValue.is_ansi_nulls_on = (bool)row.First(x => x.First == "is_ansi_nulls_on").Second;
                columnValue.is_ANSI_PADDING_on = (bool)row.First(x => x.First == "is_ANSI_PADDING_on".ToLower()).Second;
                columnValue.is_ansi_warnings_on = (bool)row.First(x => x.First == "is_ansi_warnings_on").Second;
                columnValue.is_arithabort_on = (bool)row.First(x => x.First == "is_arithabort_on").Second;
                columnValue.is_concat_null_yields_null_on = (bool)row.First(x => x.First == "is_concat_null_yields_null_on").Second;
                columnValue.is_numeric_roundabort_on = (bool)row.First(x => x.First == "is_numeric_roundabort_on").Second;
                columnValue.is_quoted_identifier_on = (bool)row.First(x => x.First == "is_quoted_identifier_on").Second;
                columnValue.is_recursive_triggers_on = (bool)row.First(x => x.First == "is_recursive_triggers_on").Second;
                columnValue.is_cursor_close_on_commit_on = (bool)row.First(x => x.First == "is_cursor_close_on_commit_on").Second;
                columnValue.is_local_cursor_default = (bool)row.First(x => x.First == "is_local_cursor_default").Second;
                columnValue.is_fulltext_enabled = (bool)row.First(x => x.First == "is_fulltext_enabled").Second;
                columnValue.is_trustworthy_on = (bool)row.First(x => x.First == "is_trustworthy_on").Second;
                columnValue.is_db_chaining_on = (bool)row.First(x => x.First == "is_db_chaining_on").Second;
                columnValue.is_parameterization_forced = (bool)row.First(x => x.First == "is_parameterization_forced").Second;
                columnValue.is_master_key_encrypted_by_server = (bool)row.First(x => x.First == "is_master_key_encrypted_by_server").Second;
                columnValue.is_query_store_on = (bool)row.First(x => x.First == "is_query_store_on").Second;
                columnValue.is_published = (bool)row.First(x => x.First == "is_published").Second;
                columnValue.is_subscribed = (bool)row.First(x => x.First == "is_subscribed").Second;
                columnValue.is_merge_published = (bool)row.First(x => x.First == "is_merge_published").Second;
                columnValue.is_distributor = (bool)row.First(x => x.First == "is_distributor").Second;
                columnValue.is_sync_with_backup = (bool)row.First(x => x.First == "is_sync_with_backup").Second;
                columnValue.service_broker_guid = row.First(x => x.First == "service_broker_guid").Second.ToString();
                columnValue.is_broker_enabled = (bool)row.First(x => x.First == "is_broker_enabled").Second;
                columnValue.log_reuse_wait = row.First(x => x.First == "log_reuse_wait").Second.ObjectToInteger();
                columnValue.log_reuse_wait_desc = row.First(x => x.First == "log_reuse_wait_desc").Second.ToString();
                columnValue.is_date_correlation_on = (bool)row.First(x => x.First == "is_date_correlation_on").Second;
                columnValue.is_cdc_enabled = (bool)row.First(x => x.First == "is_cdc_enabled").Second;
                columnValue.is_encrypted = (bool)row.First(x => x.First == "is_encrypted").Second;
                columnValue.is_honor_broker_priority_on = (bool)row.First(x => x.First == "is_honor_broker_priority_on").Second;
                columnValue.replica_id = row.First(x => x.First == "replica_id").Second.ToString();
                columnValue.group_database_id = row.First(x => x.First == "group_database_id").Second.ToString();
                columnValue.resource_pool_id = row.First(x => x.First == "resource_pool_id").Second.ObjectToInteger();
                columnValue.default_language_lcid = row.First(x => x.First == "default_language_lcid").Second.ObjectToInteger();
                columnValue.default_language_name = row.First(x => x.First == "default_language_name").Second.ToString();
                columnValue.default_fulltext_language_lcid = row.First(x => x.First == "default_fulltext_language_lcid").Second.ObjectToInteger();
                columnValue.default_fulltext_language_name = row.First(x => x.First == "default_fulltext_language_name").Second.ToString();
                columnValue.is_nested_triggers_on = (bool)row.First(x => x.First == "is_nested_triggers_on").Second;
                columnValue.is_transform_noise_words_on = (bool)row.First(x => x.First == "is_transform_noise_words_on").Second;
                columnValue.two_digit_year_cutoff = row.First(x => x.First == "two_digit_year_cutoff").Second.ObjectToInteger();
                columnValue.containment = row.First(x => x.First == "containment").Second.ObjectToInteger();
                columnValue.containment_desc = row.First(x => x.First == "containment_desc").Second.ToString();
                columnValue.target_recovery_time_in_seconds = row.First(x => x.First == "target_recovery_time_in_seconds").Second.ObjectToInteger();
                columnValue.delayed_durability = row.First(x => x.First == "delayed_durability").Second.ObjectToInteger();
                columnValue.delayed_durability_desc = row.First(x => x.First == "delayed_durability_desc").Second.ToString();
                columnValue.is_memory_optimized_elevate_to_snapshot_on = (bool)row.First(x => x.First == "is_memory_optimized_elevate_to_snapshot_on").Second;
                columnValue.is_federation_member = (bool)row.First(x => x.First == "is_federation_member").Second;
                columnValue.is_remote_data_archive_enabled = (bool)row.First(x => x.First == "is_remote_data_archive_enabled").Second;
                columnValue.is_mixed_page_allocation_on = (bool)row.First(x => x.First == "is_mixed_page_allocation_on").Second;

                expectedSysDatabases.Add(columnValue);
            }

            return expectedSysDatabases;
        }

        public static List<SysDatabases> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.{SysTableName} T 
            WHERE T.name = '{DatabaseName}'"));

            List<SysDatabases> actualSysDatabases = new List<SysDatabases>();

            foreach (var row in actual)
            {
                var columnValue = new SysDatabases();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.database_id = row.First(x => x.First == "database_id").Second.ObjectToInteger();
                columnValue.source_database_id = row.First(x => x.First == "source_database_id").Second.ObjectToInteger();
                columnValue.owner_sid = (byte[])row.First(x => x.First == "owner_sid").Second;
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.compatibility_level = row.First(x => x.First == "compatibility_level").Second.ObjectToInteger();
                columnValue.collation_name = row.First(x => x.First == "collation_name").Second.ToString();
                columnValue.user_access = row.First(x => x.First == "user_access").Second.ObjectToInteger();
                columnValue.user_access_desc = row.First(x => x.First == "user_access_desc").Second.ToString();
                columnValue.is_read_only = (bool)row.First(x => x.First == "is_read_only").Second;
                columnValue.is_auto_close_on = (bool)row.First(x => x.First == "is_auto_close_on").Second;
                columnValue.is_auto_shrink_on = (bool)row.First(x => x.First == "is_auto_shrink_on").Second;
                columnValue.state = row.First(x => x.First == "state").Second.ObjectToInteger();
                columnValue.state_desc = row.First(x => x.First == "state_desc").Second.ToString();
                columnValue.is_in_standby = row.First(x => x.First == "is_in_standby").Second.ObjectToInteger();
                columnValue.is_cleanly_shutdown = (bool)row.First(x => x.First == "is_cleanly_shutdown").Second;
                columnValue.is_supplemental_logging_enabled = (bool)row.First(x => x.First == "is_supplemental_logging_enabled").Second;
                columnValue.snapshot_isolation_state = row.First(x => x.First == "snapshot_isolation_state").Second.ObjectToInteger();
                columnValue.snapshot_isolation_state_desc = row.First(x => x.First == "snapshot_isolation_state_desc").Second.ToString();
                columnValue.is_read_committed_snapshot_on = (bool)row.First(x => x.First == "is_read_committed_snapshot_on").Second;
                columnValue.recovery_model = row.First(x => x.First == "recovery_model").Second.ObjectToInteger();
                columnValue.recovery_model_desc = row.First(x => x.First == "recovery_model_desc").Second.ToString();
                columnValue.page_verify_option = row.First(x => x.First == "page_verify_option").Second.ObjectToInteger();
                columnValue.page_verify_option_desc = row.First(x => x.First == "page_verify_option_desc").Second.ToString();
                columnValue.is_auto_create_stats_on = (bool)row.First(x => x.First == "is_auto_create_stats_on").Second;
                columnValue.is_auto_create_stats_incremental_on = (bool)row.First(x => x.First == "is_auto_create_stats_incremental_on").Second;
                columnValue.is_auto_update_stats_on = (bool)row.First(x => x.First == "is_auto_update_stats_on").Second;
                columnValue.is_auto_update_stats_async_on = (bool)row.First(x => x.First == "is_auto_update_stats_async_on").Second;
                columnValue.is_ansi_null_default_on = (bool)row.First(x => x.First == "is_ansi_null_default_on").Second;
                columnValue.is_ansi_nulls_on = (bool)row.First(x => x.First == "is_ansi_nulls_on").Second;
                columnValue.is_ANSI_PADDING_on = (bool)row.First(x => x.First == "is_ANSI_PADDING_on").Second;
                columnValue.is_ansi_warnings_on = (bool)row.First(x => x.First == "is_ansi_warnings_on").Second;
                columnValue.is_arithabort_on = (bool)row.First(x => x.First == "is_arithabort_on").Second;
                columnValue.is_concat_null_yields_null_on = (bool)row.First(x => x.First == "is_concat_null_yields_null_on").Second;
                columnValue.is_numeric_roundabort_on = (bool)row.First(x => x.First == "is_numeric_roundabort_on").Second;
                columnValue.is_quoted_identifier_on = (bool)row.First(x => x.First == "is_quoted_identifier_on").Second;
                columnValue.is_recursive_triggers_on = (bool)row.First(x => x.First == "is_recursive_triggers_on").Second;
                columnValue.is_cursor_close_on_commit_on = (bool)row.First(x => x.First == "is_cursor_close_on_commit_on").Second;
                columnValue.is_local_cursor_default = (bool)row.First(x => x.First == "is_local_cursor_default").Second;
                columnValue.is_fulltext_enabled = (bool)row.First(x => x.First == "is_fulltext_enabled").Second;
                columnValue.is_trustworthy_on = (bool)row.First(x => x.First == "is_trustworthy_on").Second;
                columnValue.is_db_chaining_on = (bool)row.First(x => x.First == "is_db_chaining_on").Second;
                columnValue.is_parameterization_forced = (bool)row.First(x => x.First == "is_parameterization_forced").Second;
                columnValue.is_master_key_encrypted_by_server = (bool)row.First(x => x.First == "is_master_key_encrypted_by_server").Second;
                columnValue.is_query_store_on = (bool)row.First(x => x.First == "is_query_store_on").Second;
                columnValue.is_published = (bool)row.First(x => x.First == "is_published").Second;
                columnValue.is_subscribed = (bool)row.First(x => x.First == "is_subscribed").Second;
                columnValue.is_merge_published = (bool)row.First(x => x.First == "is_merge_published").Second;
                columnValue.is_distributor = (bool)row.First(x => x.First == "is_distributor").Second;
                columnValue.is_sync_with_backup = (bool)row.First(x => x.First == "is_sync_with_backup").Second;
                columnValue.service_broker_guid = row.First(x => x.First == "service_broker_guid").Second.ToString();
                columnValue.is_broker_enabled = (bool)row.First(x => x.First == "is_broker_enabled").Second;
                columnValue.log_reuse_wait = row.First(x => x.First == "log_reuse_wait").Second.ObjectToInteger();
                columnValue.log_reuse_wait_desc = row.First(x => x.First == "log_reuse_wait_desc").Second.ToString();
                columnValue.is_date_correlation_on = (bool)row.First(x => x.First == "is_date_correlation_on").Second;
                columnValue.is_cdc_enabled = (bool)row.First(x => x.First == "is_cdc_enabled").Second;
                columnValue.is_encrypted = (bool)row.First(x => x.First == "is_encrypted").Second;
                columnValue.is_honor_broker_priority_on = (bool)row.First(x => x.First == "is_honor_broker_priority_on").Second;
                columnValue.replica_id = row.First(x => x.First == "replica_id").Second.ToString();
                columnValue.group_database_id = row.First(x => x.First == "group_database_id").Second.ToString();
                columnValue.resource_pool_id = row.First(x => x.First == "resource_pool_id").Second.ObjectToInteger();
                columnValue.default_language_lcid = row.First(x => x.First == "default_language_lcid").Second.ObjectToInteger();
                columnValue.default_language_name = row.First(x => x.First == "default_language_name").Second.ToString();
                columnValue.default_fulltext_language_lcid = row.First(x => x.First == "default_fulltext_language_lcid").Second.ObjectToInteger();
                columnValue.default_fulltext_language_name = row.First(x => x.First == "default_fulltext_language_name").Second.ToString();
                columnValue.is_nested_triggers_on = (bool)row.First(x => x.First == "is_nested_triggers_on").Second;
                columnValue.is_transform_noise_words_on = (bool)row.First(x => x.First == "is_transform_noise_words_on").Second;
                columnValue.two_digit_year_cutoff = row.First(x => x.First == "two_digit_year_cutoff").Second.ObjectToInteger();
                columnValue.containment = row.First(x => x.First == "containment").Second.ObjectToInteger();
                columnValue.containment_desc = row.First(x => x.First == "containment_desc").Second.ToString();
                columnValue.target_recovery_time_in_seconds = row.First(x => x.First == "target_recovery_time_in_seconds").Second.ObjectToInteger();
                columnValue.delayed_durability = row.First(x => x.First == "delayed_durability").Second.ObjectToInteger();
                columnValue.delayed_durability_desc = row.First(x => x.First == "delayed_durability_desc").Second.ToString();
                columnValue.is_memory_optimized_elevate_to_snapshot_on = (bool)row.First(x => x.First == "is_memory_optimized_elevate_to_snapshot_on").Second;
                columnValue.is_federation_member = (bool)row.First(x => x.First == "is_federation_member").Second;
                columnValue.is_remote_data_archive_enabled = (bool)row.First(x => x.First == "is_remote_data_archive_enabled").Second;
                columnValue.is_mixed_page_allocation_on = (bool)row.First(x => x.First == "is_mixed_page_allocation_on").Second;

                actualSysDatabases.Add(columnValue);
            }

            return actualSysDatabases;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            Assert.AreEqual(expected.Count, 1);

            var actual = GetActualValues();

            Assert.AreEqual(actual.Count, 1);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id);

                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.database_id, actualRow.database_id);
                Assert.AreEqual(expectedRow.source_database_id, actualRow.source_database_id);
                Assert.AreEqual(expectedRow.owner_sid, actualRow.owner_sid);
                Assert.AreEqual(expectedRow.create_date, actualRow.create_date);
                Assert.AreEqual(expectedRow.compatibility_level, actualRow.compatibility_level);
                Assert.AreEqual(expectedRow.collation_name, actualRow.collation_name);
                Assert.AreEqual(expectedRow.user_access, actualRow.user_access);
                Assert.AreEqual(expectedRow.user_access_desc, actualRow.user_access_desc);
                Assert.AreEqual(expectedRow.is_read_only, actualRow.is_read_only);
                Assert.AreEqual(expectedRow.is_auto_close_on, actualRow.is_auto_close_on);
                Assert.AreEqual(expectedRow.is_auto_shrink_on, actualRow.is_auto_shrink_on);
                Assert.AreEqual(expectedRow.state, actualRow.state);
                Assert.AreEqual(expectedRow.state_desc, actualRow.state_desc);
                Assert.AreEqual(expectedRow.is_in_standby, actualRow.is_in_standby);
                Assert.AreEqual(expectedRow.is_cleanly_shutdown, actualRow.is_cleanly_shutdown);
                Assert.AreEqual(expectedRow.is_supplemental_logging_enabled, actualRow.is_supplemental_logging_enabled);
                Assert.AreEqual(expectedRow.snapshot_isolation_state, actualRow.snapshot_isolation_state);
                Assert.AreEqual(expectedRow.snapshot_isolation_state_desc, actualRow.snapshot_isolation_state_desc);
                Assert.AreEqual(expectedRow.is_read_committed_snapshot_on, actualRow.is_read_committed_snapshot_on);
                Assert.AreEqual(expectedRow.recovery_model, actualRow.recovery_model);
                Assert.AreEqual(expectedRow.recovery_model_desc, actualRow.recovery_model_desc);
                Assert.AreEqual(expectedRow.page_verify_option, actualRow.page_verify_option);
                Assert.AreEqual(expectedRow.page_verify_option_desc, actualRow.page_verify_option_desc);
                Assert.AreEqual(expectedRow.is_auto_create_stats_on, actualRow.is_auto_create_stats_on);
                Assert.AreEqual(expectedRow.is_auto_create_stats_incremental_on, actualRow.is_auto_create_stats_incremental_on);
                Assert.AreEqual(expectedRow.is_auto_update_stats_on, actualRow.is_auto_update_stats_on);
                Assert.AreEqual(expectedRow.is_auto_update_stats_async_on, actualRow.is_auto_update_stats_async_on);
                Assert.AreEqual(expectedRow.is_ansi_null_default_on, actualRow.is_ansi_null_default_on);
                Assert.AreEqual(expectedRow.is_ansi_nulls_on, actualRow.is_ansi_nulls_on);
                Assert.AreEqual(expectedRow.is_ANSI_PADDING_on, actualRow.is_ANSI_PADDING_on);
                Assert.AreEqual(expectedRow.is_ansi_warnings_on, actualRow.is_ansi_warnings_on);
                Assert.AreEqual(expectedRow.is_arithabort_on, actualRow.is_arithabort_on);
                Assert.AreEqual(expectedRow.is_concat_null_yields_null_on, actualRow.is_concat_null_yields_null_on);
                Assert.AreEqual(expectedRow.is_numeric_roundabort_on, actualRow.is_numeric_roundabort_on);
                Assert.AreEqual(expectedRow.is_quoted_identifier_on, actualRow.is_quoted_identifier_on);
                Assert.AreEqual(expectedRow.is_recursive_triggers_on, actualRow.is_recursive_triggers_on);
                Assert.AreEqual(expectedRow.is_cursor_close_on_commit_on, actualRow.is_cursor_close_on_commit_on);
                Assert.AreEqual(expectedRow.is_local_cursor_default, actualRow.is_local_cursor_default);
                Assert.AreEqual(expectedRow.is_fulltext_enabled, actualRow.is_fulltext_enabled);
                Assert.AreEqual(expectedRow.is_trustworthy_on, actualRow.is_trustworthy_on);
                Assert.AreEqual(expectedRow.is_db_chaining_on, actualRow.is_db_chaining_on);
                Assert.AreEqual(expectedRow.is_parameterization_forced, actualRow.is_parameterization_forced);
                Assert.AreEqual(expectedRow.is_master_key_encrypted_by_server, actualRow.is_master_key_encrypted_by_server);
                Assert.AreEqual(expectedRow.is_query_store_on, actualRow.is_query_store_on);
                Assert.AreEqual(expectedRow.is_published, actualRow.is_published);
                Assert.AreEqual(expectedRow.is_subscribed, actualRow.is_subscribed);
                Assert.AreEqual(expectedRow.is_merge_published, actualRow.is_merge_published);
                Assert.AreEqual(expectedRow.is_distributor, actualRow.is_distributor);
                Assert.AreEqual(expectedRow.is_sync_with_backup, actualRow.is_sync_with_backup);
                Assert.AreEqual(expectedRow.service_broker_guid, actualRow.service_broker_guid);
                Assert.AreEqual(expectedRow.is_broker_enabled, actualRow.is_broker_enabled);
                Assert.AreEqual(expectedRow.log_reuse_wait, actualRow.log_reuse_wait);
                Assert.AreEqual(expectedRow.log_reuse_wait_desc, actualRow.log_reuse_wait_desc);
                Assert.AreEqual(expectedRow.is_date_correlation_on, actualRow.is_date_correlation_on);
                Assert.AreEqual(expectedRow.is_cdc_enabled, actualRow.is_cdc_enabled);
                Assert.AreEqual(expectedRow.is_encrypted, actualRow.is_encrypted);
                Assert.AreEqual(expectedRow.is_honor_broker_priority_on, actualRow.is_honor_broker_priority_on);
                Assert.AreEqual(expectedRow.replica_id, actualRow.replica_id);
                Assert.AreEqual(expectedRow.group_database_id, actualRow.group_database_id);
                Assert.AreEqual(expectedRow.resource_pool_id, actualRow.resource_pool_id);
                Assert.AreEqual(expectedRow.default_language_lcid, actualRow.default_language_lcid);
                Assert.AreEqual(expectedRow.default_language_name, actualRow.default_language_name);
                Assert.AreEqual(expectedRow.default_fulltext_language_lcid, actualRow.default_fulltext_language_lcid);
                Assert.AreEqual(expectedRow.default_fulltext_language_name, actualRow.default_fulltext_language_name);
                Assert.AreEqual(expectedRow.is_nested_triggers_on, actualRow.is_nested_triggers_on);
                Assert.AreEqual(expectedRow.is_transform_noise_words_on, actualRow.is_transform_noise_words_on);
                Assert.AreEqual(expectedRow.two_digit_year_cutoff, actualRow.two_digit_year_cutoff);
                Assert.AreEqual(expectedRow.containment, actualRow.containment);
                Assert.AreEqual(expectedRow.containment_desc, actualRow.containment_desc);
                Assert.AreEqual(expectedRow.target_recovery_time_in_seconds, actualRow.target_recovery_time_in_seconds);
                Assert.AreEqual(expectedRow.delayed_durability, actualRow.delayed_durability);
                Assert.AreEqual(expectedRow.delayed_durability_desc, actualRow.delayed_durability_desc);
                Assert.AreEqual(expectedRow.is_memory_optimized_elevate_to_snapshot_on, actualRow.is_memory_optimized_elevate_to_snapshot_on);
                Assert.AreEqual(expectedRow.is_federation_member, actualRow.is_federation_member);
                Assert.AreEqual(expectedRow.is_remote_data_archive_enabled, actualRow.is_remote_data_archive_enabled);
                Assert.AreEqual(expectedRow.is_mixed_page_allocation_on, actualRow.is_mixed_page_allocation_on);
            }
        }
    }
}