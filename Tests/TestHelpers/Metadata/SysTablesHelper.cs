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
    public class SysTablesHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysTables";
        public const string SqlServerDmvName = "sys.tables";

        public static List<SysTables> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}
            WHERE name = '{TableName}'"));

            List<SysTables> expectedSysTables = new List<SysTables>();

            foreach (var row in expected)
            {
                var columnValue = new SysTables();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.principal_id = row.First(x => x.First == "principal_id").Second.ObjectToInteger();
                columnValue.schema_id = row.First(x => x.First == "schema_id").Second.ObjectToInteger();
                columnValue.parent_object_id = row.First(x => x.First == "parent_object_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.modify_date = row.First(x => x.First == "modify_date").Second.ObjectToDateTime();
                columnValue.is_ms_shipped = (bool)row.First(x => x.First == "is_ms_shipped").Second;
                columnValue.is_published = (bool)row.First(x => x.First == "is_published").Second;
                columnValue.is_schema_published = (bool)row.First(x => x.First == "is_schema_published").Second;
                columnValue.lob_data_space_id = row.First(x => x.First == "lob_data_space_id").Second.ObjectToInteger();
                columnValue.filestream_data_space_id = row.First(x => x.First == "filestream_data_space_id").Second.ObjectToInteger();
                columnValue.max_column_id_used = row.First(x => x.First == "max_column_id_used").Second.ObjectToInteger();
                columnValue.lock_on_bulk_load = (bool)row.First(x => x.First == "lock_on_bulk_load").Second;
                columnValue.uses_ansi_nulls = (bool)row.First(x => x.First == "uses_ansi_nulls").Second;
                columnValue.is_replicated = (bool)row.First(x => x.First == "is_replicated").Second;
                columnValue.has_replication_filter = (bool)row.First(x => x.First == "has_replication_filter").Second;
                columnValue.is_merge_published = (bool)row.First(x => x.First == "is_merge_published").Second;
                columnValue.is_sync_tran_subscribed = (bool)row.First(x => x.First == "is_sync_tran_subscribed").Second;
                columnValue.has_unchecked_assembly_data = (bool)row.First(x => x.First == "has_unchecked_assembly_data").Second;
                columnValue.text_in_row_limit = row.First(x => x.First == "text_in_row_limit").Second.ObjectToInteger();
                columnValue.large_value_types_out_of_row = (bool)row.First(x => x.First == "large_value_types_out_of_row").Second;
                columnValue.is_tracked_by_cdc = (bool)row.First(x => x.First == "is_tracked_by_cdc").Second;
                columnValue.lock_escalation = row.First(x => x.First == "lock_escalation").Second.ObjectToInteger();
                columnValue.lock_escalation_desc = row.First(x => x.First == "lock_escalation_desc").Second.ToString();
                columnValue.is_filetable = (bool)row.First(x => x.First == "is_filetable").Second;
                columnValue.is_memory_optimized = (bool)row.First(x => x.First == "is_memory_optimized").Second;
                columnValue.durability = row.First(x => x.First == "durability").Second.ObjectToInteger();
                columnValue.durability_desc = row.First(x => x.First == "durability_desc").Second.ToString();
                columnValue.temporal_type = row.First(x => x.First == "temporal_type").Second.ToString();
                columnValue.temporal_type_desc = row.First(x => x.First == "temporal_type_desc").Second.ToString();
                columnValue.history_table_id = row.First(x => x.First == "history_table_id").Second.ObjectToInteger();
                columnValue.is_remote_data_archive_enabled = (bool)row.First(x => x.First == "is_remote_data_archive_enabled").Second;
                columnValue.is_external = (bool)row.First(x => x.First == "is_external").Second;

                expectedSysTables.Add(columnValue);
            }

            return expectedSysTables;
        }

        public static List<SysTables> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{SysTableName} T 
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = T.database_id 
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{TableName}'"));

            List<SysTables> actualSysTables = new List<SysTables>();

            foreach (var row in actual)
            {
                var columnValue = new SysTables();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.principal_id = row.First(x => x.First == "principal_id").Second.ObjectToInteger();
                columnValue.schema_id = row.First(x => x.First == "schema_id").Second.ObjectToInteger();
                columnValue.parent_object_id = row.First(x => x.First == "parent_object_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.modify_date = row.First(x => x.First == "modify_date").Second.ObjectToDateTime();
                columnValue.is_ms_shipped = (bool)row.First(x => x.First == "is_ms_shipped").Second;
                columnValue.is_published = (bool)row.First(x => x.First == "is_published").Second;
                columnValue.is_schema_published = (bool)row.First(x => x.First == "is_schema_published").Second;
                columnValue.lob_data_space_id = row.First(x => x.First == "lob_data_space_id").Second.ObjectToInteger();
                columnValue.filestream_data_space_id = row.First(x => x.First == "filestream_data_space_id").Second.ObjectToInteger();
                columnValue.max_column_id_used = row.First(x => x.First == "max_column_id_used").Second.ObjectToInteger();
                columnValue.lock_on_bulk_load = (bool)row.First(x => x.First == "lock_on_bulk_load").Second;
                columnValue.uses_ansi_nulls = (bool)row.First(x => x.First == "uses_ansi_nulls").Second;
                columnValue.is_replicated = (bool)row.First(x => x.First == "is_replicated").Second;
                columnValue.has_replication_filter = (bool)row.First(x => x.First == "has_replication_filter").Second;
                columnValue.is_merge_published = (bool)row.First(x => x.First == "is_merge_published").Second;
                columnValue.is_sync_tran_subscribed = (bool)row.First(x => x.First == "is_sync_tran_subscribed").Second;
                columnValue.has_unchecked_assembly_data = (bool)row.First(x => x.First == "has_unchecked_assembly_data").Second;
                columnValue.text_in_row_limit = row.First(x => x.First == "text_in_row_limit").Second.ObjectToInteger();
                columnValue.large_value_types_out_of_row = (bool)row.First(x => x.First == "large_value_types_out_of_row").Second;
                columnValue.is_tracked_by_cdc = (bool)row.First(x => x.First == "is_tracked_by_cdc").Second;
                columnValue.lock_escalation = row.First(x => x.First == "lock_escalation").Second.ObjectToInteger();
                columnValue.lock_escalation_desc = row.First(x => x.First == "lock_escalation_desc").Second.ToString();
                columnValue.is_filetable = (bool)row.First(x => x.First == "is_filetable").Second;
                columnValue.is_memory_optimized = (bool)row.First(x => x.First == "is_memory_optimized").Second;
                columnValue.durability = row.First(x => x.First == "durability").Second.ObjectToInteger();
                columnValue.durability_desc = row.First(x => x.First == "durability_desc").Second.ToString();
                columnValue.temporal_type = row.First(x => x.First == "temporal_type").Second.ToString();
                columnValue.temporal_type_desc = row.First(x => x.First == "temporal_type_desc").Second.ToString();
                columnValue.history_table_id = row.First(x => x.First == "history_table_id").Second.ObjectToInteger();
                columnValue.is_remote_data_archive_enabled = (bool)row.First(x => x.First == "is_remote_data_archive_enabled").Second;
                columnValue.is_external = (bool)row.First(x => x.First == "is_external").Second;

                actualSysTables.Add(columnValue);
            }

            return actualSysTables;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            Assert.AreEqual(1, expected.Count);

            var actual = GetActualValues();

            Assert.AreEqual(1, actual.Count);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.name == expectedRow.name);

                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.principal_id, actualRow.principal_id);
                Assert.AreEqual(expectedRow.schema_id, actualRow.schema_id);
                Assert.AreEqual(expectedRow.parent_object_id, actualRow.parent_object_id);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.create_date, actualRow.create_date);
                Assert.AreEqual(expectedRow.modify_date, actualRow.modify_date);
                Assert.AreEqual(expectedRow.is_ms_shipped, actualRow.is_ms_shipped);
                Assert.AreEqual(expectedRow.is_published, actualRow.is_published);
                Assert.AreEqual(expectedRow.is_schema_published, actualRow.is_schema_published);
                Assert.AreEqual(expectedRow.lob_data_space_id, actualRow.lob_data_space_id);
                Assert.AreEqual(expectedRow.filestream_data_space_id, actualRow.filestream_data_space_id);
                Assert.AreEqual(expectedRow.max_column_id_used, actualRow.max_column_id_used);
                Assert.AreEqual(expectedRow.lock_on_bulk_load, actualRow.lock_on_bulk_load);
                Assert.AreEqual(expectedRow.uses_ansi_nulls, actualRow.uses_ansi_nulls);
                Assert.AreEqual(expectedRow.is_replicated, actualRow.is_replicated);
                Assert.AreEqual(expectedRow.has_replication_filter, actualRow.has_replication_filter);
                Assert.AreEqual(expectedRow.is_merge_published, actualRow.is_merge_published);
                Assert.AreEqual(expectedRow.is_sync_tran_subscribed, actualRow.is_sync_tran_subscribed);
                Assert.AreEqual(expectedRow.has_unchecked_assembly_data, actualRow.has_unchecked_assembly_data);
                Assert.AreEqual(expectedRow.text_in_row_limit, actualRow.text_in_row_limit);
                Assert.AreEqual(expectedRow.large_value_types_out_of_row, actualRow.large_value_types_out_of_row);
                Assert.AreEqual(expectedRow.is_tracked_by_cdc, actualRow.is_tracked_by_cdc);
                Assert.AreEqual(expectedRow.lock_escalation, actualRow.lock_escalation);
                Assert.AreEqual(expectedRow.lock_escalation_desc, actualRow.lock_escalation_desc);
                Assert.AreEqual(expectedRow.is_filetable, actualRow.is_filetable);
                Assert.AreEqual(expectedRow.is_memory_optimized, actualRow.is_memory_optimized);
                Assert.AreEqual(expectedRow.durability, actualRow.durability);
                Assert.AreEqual(expectedRow.durability_desc, actualRow.durability_desc);
                Assert.AreEqual(expectedRow.temporal_type, actualRow.temporal_type);
                Assert.AreEqual(expectedRow.temporal_type_desc, actualRow.temporal_type_desc);
                Assert.AreEqual(expectedRow.history_table_id, actualRow.history_table_id);
                Assert.AreEqual(expectedRow.is_remote_data_archive_enabled, actualRow.is_remote_data_archive_enabled);
                Assert.AreEqual(expectedRow.is_external, actualRow.is_external);
            }
        }
    }
}
