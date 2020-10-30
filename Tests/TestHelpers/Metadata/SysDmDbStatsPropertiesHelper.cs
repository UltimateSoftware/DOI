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
    public class SysDmDbStatsPropertiesHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysDmDbStatsProperties";
        public const string SqlServerDmvName = "sys.dm_db_stats_properties";

        public static List<SysDmDbStatsProperties> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"

            DECLARE @TableId INT = (SELECT object_id FROM {DatabaseName}.sys.tables WHERE name = '{TableName}')

            DECLARE @StatsId INT = (SELECT stats_id FROM {DatabaseName}.sys.stats WHERE object_id = @TableId AND name = '{StatsName}')

            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}(@TableId, @StatsId)"));

            List<SysDmDbStatsProperties> expectedSysDmDbStatsProperties = new List<SysDmDbStatsProperties>();

            foreach (var row in expected)
            {
                var columnValue = new SysDmDbStatsProperties();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.stats_id = row.First(x => x.First == "stats_id").Second.ObjectToInteger();
                columnValue.last_updated = row.First(x => x.First == "last_updated").Second.ObjectToDateTime();
                columnValue.rows = row.First(x => x.First == "rows").Second.ObjectToInteger();
                columnValue.rows_sampled = row.First(x => x.First == "rows_sampled").Second.ObjectToInteger();
                columnValue.steps = row.First(x => x.First == "steps").Second.ObjectToInteger();
                columnValue.unfiltered_rows = row.First(x => x.First == "unfiltered_rows").Second.ObjectToInteger();
                columnValue.modification_counter = row.First(x => x.First == "modification_counter").Second.ObjectToInteger();
                columnValue.persisted_sample_percent = row.First(x => x.First == "persisted_sample_percent").Second.ObjectToInteger();

                expectedSysDmDbStatsProperties.Add(columnValue);
            }

            return expectedSysDmDbStatsProperties;
        }

        public static List<SysDmDbStatsProperties> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT SP.* 
            FROM DOI.DOI.{SysTableName} SP
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = SP.database_id 
                INNER JOIN DOI.DOI.SysTables T ON T.database_id = SP.database_id
                    AND T.object_id = SP.object_id
                INNER JOIN DOI.DOI.SysStats ST ON ST.database_id = SP.database_id
                    AND ST.object_id = SP.object_id
                    AND ST.stats_id = SP.stats_id
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{TableName}'
                AND ST.name = '{StatsName}'"));

            List<SysDmDbStatsProperties> actualSysDmDbStatsProperties = new List<SysDmDbStatsProperties>();

            foreach (var row in actual)
            {
                var columnValue = new SysDmDbStatsProperties();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.stats_id = row.First(x => x.First == "stats_id").Second.ObjectToInteger();
                columnValue.last_updated = row.First(x => x.First == "last_updated").Second.ObjectToDateTime();
                columnValue.rows = row.First(x => x.First == "rows").Second.ObjectToInteger();
                columnValue.rows_sampled = row.First(x => x.First == "rows_sampled").Second.ObjectToInteger();
                columnValue.steps = row.First(x => x.First == "steps").Second.ObjectToInteger();
                columnValue.unfiltered_rows = row.First(x => x.First == "unfiltered_rows").Second.ObjectToInteger();
                columnValue.modification_counter = row.First(x => x.First == "modification_counter").Second.ObjectToInteger();
                columnValue.persisted_sample_percent = row.First(x => x.First == "persisted_sample_percent").Second.ObjectToInteger();

                actualSysDmDbStatsProperties.Add(columnValue);
            }

            return actualSysDmDbStatsProperties;
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
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.object_id == expectedRow.object_id && x.stats_id == expectedRow.stats_id);

                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.stats_id, actualRow.stats_id);
                Assert.AreEqual(expectedRow.last_updated, actualRow.last_updated);
                Assert.AreEqual(expectedRow.rows, actualRow.rows);
                Assert.AreEqual(expectedRow.rows_sampled, actualRow.rows_sampled);
                Assert.AreEqual(expectedRow.steps, actualRow.steps);
                Assert.AreEqual(expectedRow.unfiltered_rows, actualRow.unfiltered_rows);
                Assert.AreEqual(expectedRow.modification_counter, actualRow.modification_counter);
                Assert.AreEqual(expectedRow.persisted_sample_percent, actualRow.persisted_sample_percent);
            }
        }
    }
}
