using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using Simple.Data.Ado.Schema;
using Models = DOI.Tests.Integration.Models;

namespace DOI.Tests.TestHelpers.Metadata
{
    public class SysStatsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysStats";
        public const string SqlServerDmvName = "sys.stats";
        public const string UserTableName = "Statistics";

        #region Get Values
            public static List<SysStats> GetExpectedSysValues()
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
                    columnValue.column_list = "TransactionUtcDt";

                    expectedSysStats.Add(columnValue);
                }

                return expectedSysStats;
            }

            public static List<SysStats> GetActualSysValues()
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

            public static List<Statistics> GetActualUserValues()
            {
                SqlHelper sqlHelper = new SqlHelper();
                var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
                SELECT ST.* 
                FROM DOI.[{UserTableName}] ST 
                WHERE ST.DatabaseName = '{DatabaseName}'
                    AND ST.TableName = '{TableName}'
                    AND ST.StatisticsName = '{StatsName}'"));

                List<Statistics> actualUserStats = new List<Statistics>();

                foreach (var row in actual)
                {
                    var columnValue = new Statistics();
                    columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                    columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                    columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                    columnValue.StatisticsName = row.First(x => x.First == "StatisticsName").Second.ToString();
                    columnValue.IsStatisticsMissingFromSQLServer = (bool)row.First(x => x.First == "IsStatisticsMissingFromSQLServer").Second;
                    columnValue.StatisticsColumnList_Desired = row.First(x => x.First == "StatisticsColumnList_Desired").Second.ToString();
                    columnValue.StatisticsColumnList_Actual = row.First(x => x.First == "StatisticsColumnList_Actual").Second.ToString();
                    columnValue.SampleSizePct_Desired = row.First(x => x.First == "SampleSizePct_Desired").Second.ObjectToInteger();
                    columnValue.SampleSizePct_Actual = row.First(x => x.First == "SampleSizePct_Actual").Second.ObjectToInteger();
                    columnValue.IsFiltered_Desired = (bool)row.First(x => x.First == "IsFiltered_Desired").Second;
                    columnValue.IsFiltered_Actual = (bool)row.First(x => x.First == "IsFiltered_Actual").Second;
                    columnValue.FilterPredicate_Desired = row.First(x => x.First == "FilterPredicate_Desired").Second.ToString();
                    columnValue.FilterPredicate_Actual = row.First(x => x.First == "FilterPredicate_Actual").Second.ToString();
                    columnValue.IsIncremental_Desired = (bool)row.First(x => x.First == "IsIncremental_Desired").Second;
                    columnValue.IsIncremental_Actual = (bool)row.First(x => x.First == "IsIncremental_Actual").Second;
                    columnValue.NoRecompute_Desired = (bool)row.First(x => x.First == "NoRecompute_Desired").Second;
                    columnValue.NoRecompute_Actual = (bool)row.First(x => x.First == "NoRecompute_Actual").Second;
                    columnValue.LowerSampleSizeToDesired = (bool)row.First(x => x.First == "LowerSampleSizeToDesired").Second;
                    columnValue.ReadyToQueue = (bool)row.First(x => x.First == "ReadyToQueue").Second;
                    columnValue.DoesSampleSizeNeedUpdate = (bool)row.First(x => x.First == "DoesSampleSizeNeedUpdate").Second;
                    columnValue.IsStatisticsMissing = (bool)row.First(x => x.First == "IsStatisticsMissing").Second;
                    columnValue.HasFilterChanged = (bool)row.First(x => x.First == "HasFilterChanged").Second; 
                    columnValue.HasIncrementalChanged = (bool)row.First(x => x.First == "HasIncrementalChanged").Second;
                    columnValue.HasNoRecomputeChanged = (bool)row.First(x => x.First == "HasNoRecomputeChanged").Second;
                    columnValue.NumRowsInTableUnfiltered = row.First(x => x.First == "NumRowsInTableUnfiltered").Second.ObjectToInteger();
                    columnValue.NumRowsInTableFiltered = row.First(x => x.First == "NumRowsInTableFiltered").Second.ObjectToInteger();
                    columnValue.NumRowsSampled = row.First(x => x.First == "NumRowsSampled").Second.ObjectToInteger();
                    columnValue.StatisticsLastUpdated = row.First(x => x.First == "StatisticsLastUpdated").Second.ObjectToDateTime();
                    columnValue.HistogramSteps = row.First(x => x.First == "HistogramSteps").Second.ObjectToInteger();
                    columnValue.StatisticsModCounter = row.First(x => x.First == "StatisticsModCounter").Second.ObjectToInteger();
                    columnValue.PersistedSamplePct = (double)row.First(x => x.First == "PersistedSamplePct").Second.ObjectToInteger();
                    columnValue.StatisticsUpdateType = row.First(x => x.First == "StatisticsUpdateType").Second.ToString();
                    columnValue.ListOfChanges = row.First(x => x.First == "ListOfChanges").Second.ToString();

                actualUserStats.Add(columnValue);
                }

                return actualUserStats;
            }
        #endregion


        //verify DOI Sys table data against expected values.

        #region Assert
            public static void AssertSysMetadata()
            {
                var expected = GetExpectedSysValues();

                Assert.AreEqual(1, expected.Count, "Expected RowCount");

                var actual = GetActualSysValues();

                Assert.AreEqual(1, actual.Count, "Actual RowCount");

                foreach (var expectedRow in expected)
                {
                    var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.object_id == expectedRow.object_id && x.stats_id == expectedRow.stats_id);

                    Assert.AreEqual(expectedRow.object_id, actualRow.object_id, "object_id");
                    Assert.AreEqual(expectedRow.name, actualRow.name, "name");
                    Assert.AreEqual(expectedRow.stats_id, actualRow.stats_id, "stats_id");
                    Assert.AreEqual(expectedRow.auto_created, actualRow.auto_created, "auto_created");
                    Assert.AreEqual(expectedRow.user_created, actualRow.user_created, "user_created");
                    Assert.AreEqual(expectedRow.no_recompute, actualRow.no_recompute, "no_recompute");
                    Assert.AreEqual(expectedRow.has_filter, actualRow.has_filter, "has_filter");
                    Assert.AreEqual(expectedRow.filter_definition, actualRow.filter_definition, "filter_definition");
                    Assert.AreEqual(expectedRow.is_temporary, actualRow.is_temporary, "is_temporary");
                    Assert.AreEqual(expectedRow.is_incremental, actualRow.is_incremental, "is_incremental");
                    Assert.AreEqual(expectedRow.column_list, actualRow.column_list, "column_list");
                }
            }

            public static void AssertUserMetadata()
            {
                var actual = GetActualUserValues();

                Assert.AreEqual(1, actual.Count);

                foreach (var row in actual)
                {
                    Assert.AreEqual(DatabaseName, row.DatabaseName);
                    Assert.AreEqual("dbo", row.SchemaName);
                    Assert.AreEqual(TableName, row.TableName);
                    Assert.AreEqual(StatsName, row.StatisticsName);
                    Assert.AreEqual(false, row.IsStatisticsMissingFromSQLServer);
                    Assert.AreEqual(row.StatisticsColumnList_Desired, row.StatisticsColumnList_Actual);
                    Assert.AreEqual(row.SampleSizePct_Desired, row.SampleSizePct_Actual);
                    Assert.AreEqual(row.IsFiltered_Desired, row.IsFiltered_Actual);
                    Assert.AreEqual(row.FilterPredicate_Desired, row.FilterPredicate_Actual);
                    Assert.AreEqual(row.IsIncremental_Desired, row.IsIncremental_Actual);
                    Assert.AreEqual(row.NoRecompute_Desired, row.NoRecompute_Actual);
                    Assert.AreEqual(false, row.LowerSampleSizeToDesired);
                    Assert.AreEqual(true, row.ReadyToQueue);
                    Assert.AreEqual(false, row.DoesSampleSizeNeedUpdate);
                    Assert.AreEqual(false, row.IsStatisticsMissing);
                    Assert.AreEqual(false, row.HasFilterChanged);
                    Assert.AreEqual(false, row.HasIncrementalChanged);
                    Assert.AreEqual(false, row.HasNoRecomputeChanged);
                    Assert.AreEqual(0, row.NumRowsInTableUnfiltered);
                    Assert.AreEqual(0, row.NumRowsInTableFiltered);
                    Assert.AreEqual(0, row.NumRowsSampled);
                    Assert.AreEqual(DateTime.MinValue, row.StatisticsLastUpdated);
                    Assert.AreEqual(0, row.HistogramSteps);
                    Assert.AreEqual(0, row.StatisticsModCounter);
                    Assert.AreEqual(0, row.PersistedSamplePct);
                    Assert.AreEqual("None", row.StatisticsUpdateType);
                    Assert.AreEqual(string.Empty, row.ListOfChanges);
                }
            }
        #endregion


    }
}
