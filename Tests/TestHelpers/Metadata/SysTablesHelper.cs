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
        public const string UserTableName = "Tables";


        public static List<SysTables> GetExpectedSysValues(string tableName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}
            WHERE name = '{tableName}'"));

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

        public static List<SysTables> GetActualSysValues(string tableName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{SysTableName} T 
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = T.database_id 
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{tableName}'"));

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

        public static List<Tables> GetActualUserValues(string tableName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT T.* 
            FROM DOI.{UserTableName} T 
            WHERE T.DatabaseName = '{DatabaseName}'
                AND T.TableName = '{tableName}'"));

            List<Tables> actualUserTables = new List<Tables>();

            foreach (var row in actual)
            {
                var columnValue = new Tables();

                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.PartitionColumn = row.First(x => x.First == "PartitionColumn").Second.ToString();
                columnValue.Storage_Desired = row.First(x => x.First == "Storage_Desired").Second.ToString();
                columnValue.Storage_Actual = row.First(x => x.First == "Storage_Actual").Second.ToString();
                columnValue.StorageType_Desired = row.First(x => x.First == "StorageType_Desired").Second.ToString();
                columnValue.StorageType_Actual = row.First(x => x.First == "StorageType_Actual").Second.ToString();
                columnValue.IntendToPartition = (bool)row.First(x => x.First == "IntendToPartition").Second;
                columnValue.ReadyToQueue = (bool)row.First(x => x.First == "ReadyToQueue").Second;
                columnValue.AreIndexesFragmented = (bool)row.First(x => x.First == "AreIndexesFragmented").Second;
                columnValue.AreIndexesBeingUpdated = (bool)row.First(x => x.First == "AreIndexesBeingUpdated").Second;
                columnValue.AreIndexesMissing = (bool)row.First(x => x.First == "AreIndexesMissing").Second;
                columnValue.IsClusteredIndexBeingDropped = (bool)row.First(x => x.First == "IsClusteredIndexBeingDropped").Second;
                columnValue.WhichUniqueConstraintIsBeingDropped = row.First(x => x.First == "WhichUniqueConstraintIsBeingDropped").Second.ToString();
                columnValue.IsStorageChanging = (bool)row.First(x => x.First == "IsStorageChanging").Second;
                columnValue.NeedsTransaction = (bool)row.First(x => x.First == "NeedsTransaction").Second;
                columnValue.AreStatisticsChanging = (bool)row.First(x => x.First == "AreStatisticsChanging").Second;
                columnValue.NewPartitionedPrepTableName = row.First(x => x.First == "NewPartitionedPrepTableName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();

                actualUserTables.Add(columnValue);
            }

            return actualUserTables;
        }


        //verify DOI Sys table data against expected values.
        public static void AssertSysMetadata(string tableName)
        {
            var expected = GetExpectedSysValues(tableName);

            Assert.AreEqual(1, expected.Count, "SysTableCount");

            var actual = GetActualSysValues(tableName);

            Assert.AreEqual(1, actual.Count);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.name == expectedRow.name);

                Assert.AreEqual(expectedRow.name, actualRow.name, "name");
                Assert.AreEqual(expectedRow.object_id, actualRow.object_id, "object_id");
                Assert.AreEqual(expectedRow.principal_id, actualRow.principal_id, "principal_id");
                Assert.AreEqual(expectedRow.schema_id, actualRow.schema_id, "schema_id");
                Assert.AreEqual(expectedRow.parent_object_id, actualRow.parent_object_id, "parent_object_id");
                Assert.AreEqual(expectedRow.type, actualRow.type, "type");
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc, "type_desc");
                Assert.AreEqual(expectedRow.create_date, actualRow.create_date, "create_date");
                Assert.AreEqual(expectedRow.modify_date, actualRow.modify_date, "modify_date");
                Assert.AreEqual(expectedRow.is_ms_shipped, actualRow.is_ms_shipped, "is_ms_shipped");
                Assert.AreEqual(expectedRow.is_published, actualRow.is_published, "is_published");
                Assert.AreEqual(expectedRow.is_schema_published, actualRow.is_schema_published, "is_schema_published");
                Assert.AreEqual(expectedRow.lob_data_space_id, actualRow.lob_data_space_id, "lob_data_space_id");
                Assert.AreEqual(expectedRow.filestream_data_space_id, actualRow.filestream_data_space_id, "filestream_data_space_id");
                Assert.AreEqual(expectedRow.max_column_id_used, actualRow.max_column_id_used, "max_column_id_used");
                Assert.AreEqual(expectedRow.lock_on_bulk_load, actualRow.lock_on_bulk_load, "lock_on_bulk_load");
                Assert.AreEqual(expectedRow.uses_ansi_nulls, actualRow.uses_ansi_nulls, "uses_ansi_nulls");
                Assert.AreEqual(expectedRow.is_replicated, actualRow.is_replicated, "is_replicated");
                Assert.AreEqual(expectedRow.has_replication_filter, actualRow.has_replication_filter, "has_replication_filter");
                Assert.AreEqual(expectedRow.is_merge_published, actualRow.is_merge_published, "is_merge_published");
                Assert.AreEqual(expectedRow.is_sync_tran_subscribed, actualRow.is_sync_tran_subscribed, "is_sync_tran_subscribed");
                Assert.AreEqual(expectedRow.has_unchecked_assembly_data, actualRow.has_unchecked_assembly_data, "has_unchecked_assembly_data");
                Assert.AreEqual(expectedRow.text_in_row_limit, actualRow.text_in_row_limit, "text_in_row_limit");
                Assert.AreEqual(expectedRow.large_value_types_out_of_row, actualRow.large_value_types_out_of_row, "large_value_types_out_of_row");
                Assert.AreEqual(expectedRow.is_tracked_by_cdc, actualRow.is_tracked_by_cdc, "is_tracked_by_cdc");
                Assert.AreEqual(expectedRow.lock_escalation, actualRow.lock_escalation, "lock_escalation");
                Assert.AreEqual(expectedRow.lock_escalation_desc, actualRow.lock_escalation_desc, "lock_escalation_desc");
                Assert.AreEqual(expectedRow.is_filetable, actualRow.is_filetable, "is_filetable");
                Assert.AreEqual(expectedRow.is_memory_optimized, actualRow.is_memory_optimized, "is_memory_optimized");
                Assert.AreEqual(expectedRow.durability, actualRow.durability, "durability");
                Assert.AreEqual(expectedRow.durability_desc, actualRow.durability_desc, "durability_desc");
                Assert.AreEqual(expectedRow.temporal_type, actualRow.temporal_type, "temporal_type");
                Assert.AreEqual(expectedRow.temporal_type_desc, actualRow.temporal_type_desc, "temporal_type_desc");
                Assert.AreEqual(expectedRow.history_table_id, actualRow.history_table_id, "history_table_id");
                Assert.AreEqual(expectedRow.is_remote_data_archive_enabled, actualRow.is_remote_data_archive_enabled, "is_remote_data_archive_enabled");
                Assert.AreEqual(expectedRow.is_external, actualRow.is_external, "is_external");
            }
        }

        public static void AssertUserMetadata(string tableName, string boundaryInterval)
        {
            var actual = GetActualUserValues(tableName);

            Assert.AreEqual(1, actual.Count, "UserTableCount");

            foreach (var actualRow in actual)
            {
                if (tableName == TableName)
                {
                    Assert.AreEqual(DatabaseName, actualRow.DatabaseName, "DatabaseName");
                    Assert.AreEqual("dbo", actualRow.SchemaName, "SchemaName");
                    Assert.AreEqual(TableName, actualRow.TableName, "TableName");
                    Assert.AreEqual(string.Empty, actualRow.PartitionColumn, "PartitionColumn");
                    Assert.AreEqual("PRIMARY", actualRow.Storage_Desired, "Storage_Desired");
                    Assert.AreEqual("PRIMARY", actualRow.Storage_Actual, "Storage_Actual");
                    Assert.AreEqual("ROWS_FILEGROUP", actualRow.StorageType_Desired, "StorageType_Desired");
                    Assert.AreEqual("ROWS_FILEGROUP", actualRow.StorageType_Actual, "StorageType_Actual");
                    Assert.AreEqual(false, actualRow.IntendToPartition, "IntendToPartition");
                    Assert.AreEqual(true, actualRow.ReadyToQueue, "ReadyToQueue");
                    Assert.AreEqual(false, actualRow.AreIndexesFragmented, "AreIndexesFragmented");
                    Assert.AreEqual(false, actualRow.AreIndexesBeingUpdated, "AreIndexesBeingUpdated");
                    Assert.AreEqual(false, actualRow.AreIndexesMissing, "AreIndexesMissing");
                    Assert.AreEqual(false, actualRow.IsClusteredIndexBeingDropped, "IsClusteredIndexBeingDropped");
                    Assert.AreEqual("None", actualRow.WhichUniqueConstraintIsBeingDropped, "WhichUniqueConstraintIsBeingDropped");
                    Assert.AreEqual(false, actualRow.NeedsTransaction, "NeedsTransaction");
                    Assert.AreEqual(false, actualRow.AreStatisticsChanging, "AreStatisticsChanging");
                    Assert.AreEqual(string.Empty, actualRow.NewPartitionedPrepTableName, "NewPartitionedPrepTableName");
                    Assert.AreEqual(string.Empty, actualRow.PartitionFunctionName, "PartitionFunctionName");
                }
                else if (tableName == TableName_Partitioned && boundaryInterval == "Yearly")
                {
                    Assert.AreEqual(DatabaseName, actualRow.DatabaseName, "DatabaseName");
                    Assert.AreEqual("dbo", actualRow.SchemaName, "SchemaName");
                    Assert.AreEqual(TableName_Partitioned, actualRow.TableName, "TableName");
                    Assert.AreEqual(PartitionColumnName, actualRow.PartitionColumn, "PartitionColumn");
                    Assert.AreEqual(PartitionSchemeNameYearly, actualRow.Storage_Desired, "Storage_Desired");
                    Assert.AreEqual(PartitionSchemeNameYearly, actualRow.Storage_Actual, "Storage_Actual");
                    Assert.AreEqual("PARTITION_SCHEME", actualRow.StorageType_Desired, "StorageType_Desired");
                    Assert.AreEqual("PARTITION_SCHEME", actualRow.StorageType_Actual, "StorageType_Actual");
                    Assert.AreEqual(true, actualRow.IntendToPartition, "IntendToPartition");
                    Assert.AreEqual(true, actualRow.ReadyToQueue, "ReadyToQueue");
                    Assert.AreEqual(false, actualRow.AreIndexesFragmented, "AreIndexesFragmented");
                    Assert.AreEqual(false, actualRow.AreIndexesBeingUpdated, "AreIndexesBeingUpdated");
                    Assert.AreEqual(false, actualRow.AreIndexesMissing, "AreIndexesMissing");
                    Assert.AreEqual(false, actualRow.IsClusteredIndexBeingDropped, "IsClusteredIndexBeingDropped");
                    Assert.AreEqual("None", actualRow.WhichUniqueConstraintIsBeingDropped, "WhichUniqueConstraintIsBeingDropped");
                    Assert.AreEqual(false, actualRow.NeedsTransaction, "NeedsTransaction");
                    Assert.AreEqual(false, actualRow.AreStatisticsChanging, "AreStatisticsChanging");
                    Assert.AreEqual(string.Concat(TableName_Partitioned, "_NewPartitionedTableFromPrep"), actualRow.NewPartitionedPrepTableName, "NewPartitionedPrepTableName");
                    Assert.AreEqual(PartitionFunctionNameYearly, actualRow.PartitionFunctionName, "PartitionFunctionName");
                }
                else if (tableName == TableName_Partitioned && boundaryInterval == "Monthly")
                {
                    Assert.AreEqual(DatabaseName, actualRow.DatabaseName, "DatabaseName");
                    Assert.AreEqual("dbo", actualRow.SchemaName, "SchemaName");
                    Assert.AreEqual(TableName_Partitioned, actualRow.TableName, "TableName");
                    Assert.AreEqual(PartitionColumnName, actualRow.PartitionColumn, "PartitionColumn");
                    Assert.AreEqual(PartitionSchemeNameMonthly, actualRow.Storage_Desired, "Storage_Desired");
                    Assert.AreEqual(PartitionSchemeNameMonthly, actualRow.Storage_Actual, "Storage_Actual");
                    Assert.AreEqual("PARTITION_SCHEME", actualRow.StorageType_Desired, "StorageType_Desired");
                    Assert.AreEqual("PARTITION_SCHEME", actualRow.StorageType_Actual, "StorageType_Actual");
                    Assert.AreEqual(true, actualRow.IntendToPartition, "IntendToPartition");
                    Assert.AreEqual(true, actualRow.ReadyToQueue, "ReadyToQueue");
                    Assert.AreEqual(false, actualRow.AreIndexesFragmented, "AreIndexesFragmented");
                    Assert.AreEqual(false, actualRow.AreIndexesBeingUpdated, "AreIndexesBeingUpdated");
                    Assert.AreEqual(false, actualRow.AreIndexesMissing, "AreIndexesMissing");
                    Assert.AreEqual(false, actualRow.IsClusteredIndexBeingDropped, "IsClusteredIndexBeingDropped");
                    Assert.AreEqual("None", actualRow.WhichUniqueConstraintIsBeingDropped, "WhichUniqueConstraintIsBeingDropped");
                    Assert.AreEqual(false, actualRow.NeedsTransaction, "NeedsTransaction");
                    Assert.AreEqual(false, actualRow.AreStatisticsChanging, "AreStatisticsChanging");
                    Assert.AreEqual(string.Concat(TableName_Partitioned, "_NewPartitionedTableFromPrep"), actualRow.NewPartitionedPrepTableName, "NewPartitionedPrepTableName");
                    Assert.AreEqual(PartitionFunctionNameMonthly, actualRow.PartitionFunctionName, "PartitionFunctionName");
                }
            }
        }
    }
}
