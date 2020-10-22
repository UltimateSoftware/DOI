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
    public class SysPartitionsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysPartitions";
        public const string SqlServerDmvName = "sys.partitions";

        public static List<SysPartitions> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT p.* 
            FROM {DatabaseName}.{SqlServerDmvName} p
                INNER JOIN {DatabaseName}.sys.indexes i ON i.object_id = p.object_id
                    AND i.index_id = p.index_id
                INNER JOIN {DatabaseName}.sys.tables t ON i.object_id = t.object_id
            WHERE t.name = '{TableName}'
                AND i.name = '{IndexName}'"));

            List<SysPartitions> expectedSysPartitions = new List<SysPartitions>();

            foreach (var row in expected)
            {
                var columnValue = new SysPartitions();
                columnValue.partition_id = row.First(x => x.First == "partition_id").Second.ObjectToInteger();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.index_id = row.First(x => x.First == "index_id").Second.ObjectToInteger();
                columnValue.partition_number = row.First(x => x.First == "partition_number").Second.ObjectToInteger();
                columnValue.hobt_id = row.First(x => x.First == "hobt_id").Second.ObjectToInteger();
                columnValue.rows = row.First(x => x.First == "rows").Second.ObjectToInteger();
                columnValue.filestream_filegroup_id = row.First(x => x.First == "filestream_filegroup_id").Second.ObjectToInteger();
                columnValue.data_compression = row.First(x => x.First == "data_compression").Second.ObjectToInteger();
                columnValue.data_compression_desc = row.First(x => x.First == "data_compression_desc").Second.ToString();

                expectedSysPartitions.Add(columnValue);
            }

            return expectedSysPartitions;
        }

        public static List<SysPartitions> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT P.* 
            FROM DOI.DOI.{SysTableName} P 
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = P.database_id 
                INNER JOIN DOI.DOI.SysIndexes I ON P.database_id = I.database_id
                    AND P.object_id = i.object_id
                    AND P.index_id = i.index_id
                INNER JOIN DOI.DOI.SysTables T ON I.database_id = T.database_id
                    AND I.object_id = T.object_id
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{TableName}'
                AND I.name = '{IndexName}'"));

            List<SysPartitions> actualSysPartitions = new List<SysPartitions>();

            foreach (var row in actual)
            {
                var columnValue = new SysPartitions();
                columnValue.partition_id = row.First(x => x.First == "partition_id").Second.ObjectToInteger();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.index_id = row.First(x => x.First == "index_id").Second.ObjectToInteger();
                columnValue.partition_number = row.First(x => x.First == "partition_number").Second.ObjectToInteger();
                columnValue.hobt_id = row.First(x => x.First == "hobt_id").Second.ObjectToInteger();
                columnValue.rows = row.First(x => x.First == "rows").Second.ObjectToInteger();
                columnValue.filestream_filegroup_id = row.First(x => x.First == "filestream_filegroup_id").Second.ObjectToInteger();
                columnValue.data_compression = row.First(x => x.First == "data_compression").Second.ObjectToInteger();
                columnValue.data_compression_desc = row.First(x => x.First == "data_compression_desc").Second.ToString();

                actualSysPartitions.Add(columnValue);
            }

            return actualSysPartitions;
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
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.object_id == expectedRow.object_id && x.index_id == expectedRow.index_id && x.partition_id == expectedRow.partition_id);

                Assert.AreEqual(expectedRow.partition_id, actualRow.partition_id);
                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.index_id, actualRow.index_id);
                Assert.AreEqual(expectedRow.partition_number, actualRow.partition_number);
                Assert.AreEqual(expectedRow.hobt_id, actualRow.hobt_id);
                Assert.AreEqual(expectedRow.rows, actualRow.rows);
                Assert.AreEqual(expectedRow.filestream_filegroup_id, actualRow.filestream_filegroup_id);
                Assert.AreEqual(expectedRow.data_compression, actualRow.data_compression);
                Assert.AreEqual(expectedRow.data_compression_desc, actualRow.data_compression_desc);
            }
        }
    }
}
