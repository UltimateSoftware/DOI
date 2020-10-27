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
    public class SysDmOsVolumeStatsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysDmOsVolumeStats";
        public const string SqlServerDmvName = "sys.dm_os_volume_stats";

        public static List<SysDmOsVolumeStats> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {SqlServerDmvName}(DB_ID('{DatabaseName}'), 1)
            UNION ALL
            SELECT * 
            FROM {SqlServerDmvName}(DB_ID('{DatabaseName}'), 2)
            UNION ALL
            SELECT * 
            FROM {SqlServerDmvName}(DB_ID('{DatabaseName}'), 3)
            ORDER BY file_id"));

            List<SysDmOsVolumeStats> expectedSysDmOsVolumnStats = new List<SysDmOsVolumeStats>();

            foreach (var row in expected)
            {
                var columnValue = new SysDmOsVolumeStats();
                columnValue.file_id = row.First(x => x.First == "file_id").Second.ObjectToInteger();
                columnValue.volume_mount_point = row.First(x => x.First == "volume_mount_point").Second.ToString();
                columnValue.volume_id = row.First(x => x.First == "volume_id").Second.ToString();
                columnValue.logical_volume_name = row.First(x => x.First == "logical_volume_name").Second.ToString();
                columnValue.file_system_type = row.First(x => x.First == "file_system_type").Second.ToString();
                columnValue.total_bytes = row.First(x => x.First == "total_bytes").Second.ObjectToInteger();
                columnValue.available_bytes = row.First(x => x.First == "available_bytes").Second.ObjectToInteger();
                columnValue.supports_compression = row.First(x => x.First == "supports_compression").Second.ObjectToInteger();
                columnValue.supports_alternate_streams = row.First(x => x.First == "supports_alternate_streams").Second.ObjectToInteger();
                columnValue.supports_sparse_files = row.First(x => x.First == "supports_sparse_files").Second.ObjectToInteger();
                columnValue.is_compressed = row.First(x => x.First == "is_compressed").Second.ObjectToInteger();

                expectedSysDmOsVolumnStats.Add(columnValue);
            }

            return expectedSysDmOsVolumnStats;
        }

        public static List<SysDmOsVolumeStats> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT T.* 
            FROM DOI.{SysTableName} T 
                INNER JOIN DOI.SysDatabases D ON T.database_id = D.database_id
            WHERE D.name = '{DatabaseName}'
            ORDER BY file_id"));

            List<SysDmOsVolumeStats> actualSysDmOsVolumnStats = new List<SysDmOsVolumeStats>();

            foreach (var row in actual)
            {
                var columnValue = new SysDmOsVolumeStats();
                columnValue.file_id = row.First(x => x.First == "file_id").Second.ObjectToInteger();
                columnValue.volume_mount_point = row.First(x => x.First == "volume_mount_point").Second.ToString();
                columnValue.volume_id = row.First(x => x.First == "volume_id").Second.ToString();
                columnValue.logical_volume_name = row.First(x => x.First == "logical_volume_name").Second.ToString();
                columnValue.file_system_type = row.First(x => x.First == "file_system_type").Second.ToString();
                columnValue.total_bytes = row.First(x => x.First == "total_bytes").Second.ObjectToInteger();
                columnValue.available_bytes = row.First(x => x.First == "available_bytes").Second.ObjectToInteger();
                columnValue.supports_compression = row.First(x => x.First == "supports_compression").Second.ObjectToInteger();
                columnValue.supports_alternate_streams = row.First(x => x.First == "supports_alternate_streams").Second.ObjectToInteger();
                columnValue.supports_sparse_files = row.First(x => x.First == "supports_sparse_files").Second.ObjectToInteger();
                columnValue.is_compressed = row.First(x => x.First == "is_compressed").Second.ObjectToInteger();

                actualSysDmOsVolumnStats.Add(columnValue);
            }

            return actualSysDmOsVolumnStats;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            Assert.AreEqual(expected.Count, 3);

            var actual = GetActualValues();

            Assert.AreEqual(actual.Count, 3);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.file_id == expectedRow.file_id);

                Assert.AreEqual(expectedRow.file_id, actualRow.file_id);
                Assert.AreEqual(expectedRow.database_id, actualRow.database_id);
                Assert.AreEqual(expectedRow.volume_mount_point, actualRow.volume_mount_point);
                Assert.AreEqual(expectedRow.volume_id, actualRow.volume_id);
                Assert.AreEqual(expectedRow.logical_volume_name, actualRow.logical_volume_name);
                Assert.AreEqual(expectedRow.file_system_type, actualRow.file_system_type);
                Assert.AreEqual(expectedRow.total_bytes, actualRow.total_bytes);
                Assert.AreEqual(expectedRow.available_bytes, actualRow.available_bytes);
                Assert.AreEqual(expectedRow.supports_compression, actualRow.supports_compression);
                Assert.AreEqual(expectedRow.supports_alternate_streams, actualRow.supports_alternate_streams);
                Assert.AreEqual(expectedRow.supports_sparse_files, actualRow.supports_sparse_files);
                Assert.AreEqual(expectedRow.is_read_only, actualRow.is_read_only);
                Assert.AreEqual(expectedRow.is_compressed, actualRow.is_compressed);
            }
        }
    }
}
