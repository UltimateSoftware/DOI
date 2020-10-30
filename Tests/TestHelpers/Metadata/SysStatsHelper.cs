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
    public class SysStatsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysStats";
        public const string SqlServerDmvName = "sys.stats";

        public static List<SysStats> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}
            WHERE name = '{StatsName}'"));

            List<SysStats> expectedSysStats = new List<SysStats>();

            foreach (var row in expected)
            {
                var columnValue = new SysStats();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.stats_id = row.First(x => x.First == "stats_id").Second.ObjectToInteger();
                columnValue.auto_created = (bool)row.First(x => x.First == "auto_created").Second;
                columnValue.user_created = (bool)row.First(x => x.First == "user_created").Second;
                columnValue.no_recompute = (bool)row.First(x => x.First == "no_recompute").Second;
                columnValue.has_filter = (bool)row.First(x => x.First == "has_filter").Second;
                columnValue.filter_definition = row.First(x => x.First == "filter_definition").Second.ToString();
                columnValue.is_temporary = (bool)row.First(x => x.First == "is_temporary").Second;
                columnValue.is_incremental = (bool)row.First(x => x.First == "is_incremental").Second;

                expectedSysStats.Add(columnValue);
            }

            return expectedSysStats;
        }

        public static List<SysStats> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT ST.* 
            FROM DOI.DOI.{SysTableName} ST 
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = ST.database_id 
                INNER JOIN DOI.DOI.SysTables T ON T.database_id = ST.database_id
                    AND T.object_id = ST.object_id
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{TableName}'
                AND ST.name = '{StatsName}'"));

            List<SysStats> actualSysStats = new List<SysStats>();

            foreach (var row in actual)
            {
                var columnValue = new SysStats();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.stats_id = row.First(x => x.First == "stats_id").Second.ObjectToInteger();
                columnValue.auto_created = (bool)row.First(x => x.First == "auto_created").Second;
                columnValue.user_created = (bool)row.First(x => x.First == "user_created").Second;
                columnValue.no_recompute = (bool)row.First(x => x.First == "no_recompute").Second;
                columnValue.has_filter = (bool)row.First(x => x.First == "has_filter").Second;
                columnValue.filter_definition = row.First(x => x.First == "filter_definition").Second.ToString();
                columnValue.is_temporary = (bool)row.First(x => x.First == "is_temporary").Second;
                columnValue.is_incremental = (bool)row.First(x => x.First == "is_incremental").Second;
                columnValue.column_list = row.First(x => x.First == "column_list").Second.ToString();

                actualSysStats.Add(columnValue);
            }

            return actualSysStats;
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
                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.stats_id, actualRow.stats_id);
                Assert.AreEqual(expectedRow.auto_created, actualRow.auto_created);
                Assert.AreEqual(expectedRow.user_created, actualRow.user_created);
                Assert.AreEqual(expectedRow.no_recompute, actualRow.no_recompute);
                Assert.AreEqual(expectedRow.has_filter, actualRow.has_filter);
                Assert.AreEqual(expectedRow.filter_definition, actualRow.filter_definition);
                Assert.AreEqual(expectedRow.is_temporary, actualRow.is_temporary);
                Assert.AreEqual(expectedRow.is_incremental, actualRow.is_incremental);
            }
        }
    }
}
