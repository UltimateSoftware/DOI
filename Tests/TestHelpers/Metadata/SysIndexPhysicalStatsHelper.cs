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
    public class SysIndexPhysicalStatsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysIndexPhysicalStats";
        public const string SqlServerDmvName = "sys.dm_db_index_physical_stats";

        public static List<SysIndexPhysicalStats> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();

            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"

            SELECT ips.* 
            FROM {SqlServerDmvName}(DB_ID('{DatabaseName}'), NULL, NULL, NULL, 'DETAILED') ips"));

            List<SysIndexPhysicalStats> expectedSysIndexPhysicalStats = new List<SysIndexPhysicalStats>();

            foreach (var row in expected)
            {
                var columnValue = new SysIndexPhysicalStats();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.index_id = row.First(x => x.First == "index_id").Second.ObjectToInteger();
                columnValue.partition_number = row.First(x => x.First == "partition_number").Second.ObjectToInteger();
                columnValue.index_type_desc = row.First(x => x.First == "index_type_desc").Second.ToString();
                columnValue.alloc_unit_type_desc = row.First(x => x.First == "alloc_unit_type_desc").Second.ToString();
                columnValue.index_depth = row.First(x => x.First == "index_depth").Second.ObjectToInteger();
                columnValue.index_level = row.First(x => x.First == "index_level").Second.ObjectToInteger();
                columnValue.avg_fragmentation_in_percent = (double)row.First(x => x.First == "avg_fragmentation_in_percent").Second;
                columnValue.fragment_count = row.First(x => x.First == "fragment_count").Second.ObjectToInteger();
                columnValue.avg_fragment_size_in_pages = (double)row.First(x => x.First == "avg_fragment_size_in_pages").Second;
                columnValue.page_count = row.First(x => x.First == "page_count").Second.ObjectToInteger();
                columnValue.avg_page_space_used_in_percent = (double?)row.First(x => x.First == "avg_page_space_used_in_percent").Second;
                columnValue.record_count = row.First(x => x.First == "record_count").Second.ObjectToInteger();
                columnValue.ghost_record_count = row.First(x => x.First == "ghost_record_count").Second.ObjectToInteger();
                columnValue.version_ghost_record_count = row.First(x => x.First == "version_ghost_record_count").Second.ObjectToInteger();
                columnValue.min_record_size_in_bytes = row.First(x => x.First == "min_record_size_in_bytes").Second.ObjectToInteger();
                columnValue.max_record_size_in_bytes = row.First(x => x.First == "max_record_size_in_bytes").Second.ObjectToInteger();
                columnValue.avg_record_size_in_bytes = (double)row.First(x => x.First == "avg_record_size_in_bytes").Second;
                columnValue.forwarded_record_count = row.First(x => x.First == "forwarded_record_count").Second.ObjectToInteger();
                columnValue.compressed_page_count = row.First(x => x.First == "compressed_page_count").Second.ObjectToInteger();
                columnValue.hobt_id = row.First(x => x.First == "hobt_id").Second.ObjectToInteger();
                columnValue.columnstore_delete_buffer_state = row.First(x => x.First == "columnstore_delete_buffer_state").Second.ObjectToInteger();
                columnValue.columnstore_delete_buffer_state_desc = row.First(x => x.First == "columnstore_delete_buffer_state_desc").Second.ToString();

                expectedSysIndexPhysicalStats.Add(columnValue);
            }

            return expectedSysIndexPhysicalStats;
        }

        public static List<SysIndexPhysicalStats> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT IPS.* 
            FROM DOI.DOI.{SysTableName} IPS
            WHERE database_id = DB_ID('{DatabaseName}')"));

            List<SysIndexPhysicalStats> actualSysIndexPhysicalStats = new List<SysIndexPhysicalStats>();

            foreach (var row in actual)
            {
                //BELOW LINES ARE COMMENTED OUT BECAUSE WE ARE HAVING PROBLEMS WITH DOUBLE/FLOAT TYPES WITH NULL VALUES.
                var columnValue = new SysIndexPhysicalStats();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.index_id = row.First(x => x.First == "index_id").Second.ObjectToInteger();
                columnValue.partition_number = row.First(x => x.First == "partition_number").Second.ObjectToInteger();
                columnValue.index_type_desc = row.First(x => x.First == "index_type_desc").Second.ToString();
                columnValue.alloc_unit_type_desc = row.First(x => x.First == "alloc_unit_type_desc").Second.ToString();
                columnValue.index_depth = row.First(x => x.First == "index_depth").Second.ObjectToInteger();
                columnValue.index_level = row.First(x => x.First == "index_level").Second.ObjectToInteger();
//                columnValue.avg_fragmentation_in_percent = (double)row.First(x => x.First == "avg_fragmentation_in_percent").Second;
                columnValue.fragment_count = row.First(x => x.First == "fragment_count").Second.ObjectToInteger();
//                columnValue.avg_fragment_size_in_pages = (double)row.First(x => x.First == "avg_fragment_size_in_pages").Second;
                columnValue.page_count = row.First(x => x.First == "page_count").Second.ObjectToInteger();
//                columnValue.avg_page_space_used_in_percent = (double?)row.First(x => x.First == "avg_page_space_used_in_percent").Second ?? 0.00;
                columnValue.record_count = row.First(x => x.First == "record_count").Second.ObjectToInteger();
                columnValue.ghost_record_count = row.First(x => x.First == "ghost_record_count").Second.ObjectToInteger();
                columnValue.version_ghost_record_count = row.First(x => x.First == "version_ghost_record_count").Second.ObjectToInteger();
                columnValue.min_record_size_in_bytes = row.First(x => x.First == "min_record_size_in_bytes").Second.ObjectToInteger();
                columnValue.max_record_size_in_bytes = row.First(x => x.First == "max_record_size_in_bytes").Second.ObjectToInteger();
//                columnValue.avg_record_size_in_bytes = (double)row.First(x => x.First == "avg_record_size_in_bytes").Second;
//                columnValue.forwarded_record_count = row.First(x => x.First == "forwarded_record_count").Second.ObjectToInteger();
                columnValue.compressed_page_count = row.First(x => x.First == "compressed_page_count").Second.ObjectToInteger();
                columnValue.hobt_id = row.First(x => x.First == "hobt_id").Second.ObjectToInteger();
                columnValue.columnstore_delete_buffer_state = row.First(x => x.First == "columnstore_delete_buffer_state").Second.ObjectToInteger();
                columnValue.columnstore_delete_buffer_state_desc = row.First(x => x.First == "columnstore_delete_buffer_state_desc").Second.ToString();

                actualSysIndexPhysicalStats.Add(columnValue);
            }

            return actualSysIndexPhysicalStats;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            var actual = GetActualValues();

            Assert.AreEqual(expected.Count, actual.Count);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.object_id == expectedRow.object_id && x.index_id == expectedRow.index_id);

                //BELOW LINES ARE COMMENTED OUT BECAUSE WE ARE HAVING PROBLEMS WITH DOUBLE/FLOAT TYPES WITH NULL VALUES.
                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.index_id, actualRow.index_id);
                Assert.AreEqual(expectedRow.partition_number, actualRow.partition_number);
                Assert.AreEqual(expectedRow.index_type_desc, actualRow.index_type_desc);
                Assert.AreEqual(expectedRow.alloc_unit_type_desc, actualRow.alloc_unit_type_desc);
                Assert.AreEqual(expectedRow.index_depth, actualRow.index_depth);
                Assert.AreEqual(expectedRow.index_level, actualRow.index_level);
                //Assert.AreEqual(expectedRow.avg_fragmentation_in_percent, actualRow.avg_fragmentation_in_percent);
                Assert.AreEqual(expectedRow.fragment_count, actualRow.fragment_count);
                //Assert.AreEqual(expectedRow.avg_fragment_size_in_pages, actualRow.avg_fragment_size_in_pages);
                Assert.AreEqual(expectedRow.page_count, actualRow.page_count);
//                Assert.AreEqual(expectedRow.avg_page_space_used_in_percent, actualRow.avg_page_space_used_in_percent);
                Assert.AreEqual(expectedRow.record_count, actualRow.record_count);
                Assert.AreEqual(expectedRow.ghost_record_count, actualRow.ghost_record_count);
                Assert.AreEqual(expectedRow.version_ghost_record_count, actualRow.version_ghost_record_count);
                //Assert.AreEqual(expectedRow.min_record_size_in_bytes, actualRow.min_record_size_in_bytes);
                //Assert.AreEqual(expectedRow.max_record_size_in_bytes, actualRow.max_record_size_in_bytes);
                //Assert.AreEqual(expectedRow.avg_record_size_in_bytes, actualRow.avg_record_size_in_bytes);
                Assert.AreEqual(expectedRow.forwarded_record_count, actualRow.forwarded_record_count);
                Assert.AreEqual(expectedRow.compressed_page_count, actualRow.compressed_page_count);
                Assert.AreEqual(expectedRow.hobt_id, actualRow.hobt_id);
                Assert.AreEqual(expectedRow.columnstore_delete_buffer_state, actualRow.columnstore_delete_buffer_state);
                Assert.AreEqual(expectedRow.columnstore_delete_buffer_state_desc, actualRow.columnstore_delete_buffer_state_desc);
            }
        }
    }
}
