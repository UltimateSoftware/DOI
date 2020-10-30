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
    public class SysStatsColumnsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysStatsColumns";
        public const string SqlServerDmvName = "sys.stats_columns";

        public static List<SysStatsColumns> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT SC.* 
            FROM {DatabaseName}.{SqlServerDmvName} SC   
                INNER JOIN {DatabaseName}.sys.stats ST ON ST.object_id = SC.object_id
                    AND ST.stats_id = SC.stats_id
            WHERE ST.name = '{StatsName}'"));

            List<SysStatsColumns> expectedSysStatsColumns = new List<SysStatsColumns>();

            foreach (var row in expected)
            {
                var columnValue = new SysStatsColumns();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.stats_id = row.First(x => x.First == "stats_id").Second.ObjectToInteger();
                columnValue.stats_column_id = row.First(x => x.First == "stats_column_id").Second.ObjectToInteger();
                columnValue.column_id = row.First(x => x.First == "column_id").Second.ObjectToInteger();

                expectedSysStatsColumns.Add(columnValue);
            }

            return expectedSysStatsColumns;
        }

        public static List<SysStatsColumns> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT SC.* 
            FROM DOI.DOI.{SysTableName} SC 
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = SC.database_id 
                INNER JOIN DOI.DOI.SysTables T ON T.database_id = SC.database_id
                    AND T.object_id = SC.object_id
                INNER JOIN DOI.DOI.SysStats ST ON ST.object_id = SC.object_id
                    AND ST.stats_id = SC.stats_id
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{TableName}'
                AND ST.name = '{StatsName}'"));

            List<SysStatsColumns> actualSysStatsColumns = new List<SysStatsColumns>();

            foreach (var row in actual)
            {
                var columnValue = new SysStatsColumns();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.stats_id = row.First(x => x.First == "stats_id").Second.ObjectToInteger();
                columnValue.stats_column_id = row.First(x => x.First == "stats_column_id").Second.ObjectToInteger();
                columnValue.column_id = row.First(x => x.First == "column_id").Second.ObjectToInteger();

                actualSysStatsColumns.Add(columnValue);
            }

            return actualSysStatsColumns;
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
                Assert.AreEqual(expectedRow.stats_column_id, actualRow.stats_column_id);
                Assert.AreEqual(expectedRow.column_id, actualRow.column_id);
            }
        }
    }
}
