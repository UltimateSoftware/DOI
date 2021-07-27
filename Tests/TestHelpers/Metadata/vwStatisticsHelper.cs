using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using Simple.Data.Ado.Schema;

namespace DOI.Tests.TestHelpers.Metadata
{
    public class vwStatisticsHelper : SystemMetadataHelper
    {
        public const string UserTableName = "[Statistics]";
        public const string ViewName = "vwStatistics";

        public static List<Statistics> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{UserTableName} T
            WHERE T.DatabaseName = '{DatabaseName}'
                AND T.TableName = '{TableName}'"));

            List<Statistics> expectedvwStatistics = new List<Statistics>();

            foreach (var row in expected)
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

                expectedvwStatistics.Add(columnValue);
            }

            return expectedvwStatistics;
        }

        public static List<vwStatistics> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{ViewName} 
            WHERE DatabaseName = '{DatabaseName}'
                AND TableName = '{TableName}'"));


            List<vwStatistics> actualvwStatistics = new List<vwStatistics>();

            foreach (var row in actual)
            {
                var columnValue = new vwStatistics();
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

                actualvwStatistics.Add(columnValue);
            }

            return actualvwStatistics;
        }

        //verify DOI view data against expected values.
        public static void AssertMetadata()
        {
            SqlHelper sqlHelper = new SqlHelper();

            var expected = GetExpectedValues();
            var actual = GetActualValues();

            Assert.IsTrue(actual.Count > 0, "RowsReturned");
            Assert.IsTrue(expected.Count == actual.Count, "MatchingRowCounts");

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.TableName == expectedRow.TableName && x.StatisticsName == expectedRow.StatisticsName);

                Assert.AreEqual(expectedRow.SchemaName, actualRow.SchemaName, "SchemaName");
                Assert.AreEqual(expectedRow.IsStatisticsMissingFromSQLServer, actualRow.IsStatisticsMissingFromSQLServer, "IsStatisticsMissingFromSQLServer");
                Assert.AreEqual(expectedRow.StatisticsColumnList_Desired, actualRow.StatisticsColumnList_Desired, "StatisticsColumnList_Desired");
                Assert.AreEqual(expectedRow.StatisticsColumnList_Actual, actualRow.StatisticsColumnList_Actual, "StatisticsColumnList_Actual");
                Assert.AreEqual(expectedRow.SampleSizePct_Desired, actualRow.SampleSizePct_Desired, "SampleSizePct_Desired");
                Assert.AreEqual(expectedRow.SampleSizePct_Actual, actualRow.SampleSizePct_Actual, "SampleSizePct_Actual");
                Assert.AreEqual(expectedRow.IsFiltered_Desired, actualRow.IsFiltered_Desired, "IsFiltered_Desired");
                Assert.AreEqual(expectedRow.IsFiltered_Actual, actualRow.IsFiltered_Actual, "IsFiltered_Actual");
                Assert.AreEqual(expectedRow.FilterPredicate_Desired, actualRow.FilterPredicate_Desired, "FilterPredicate_Desired");
                Assert.AreEqual(expectedRow.FilterPredicate_Actual, actualRow.FilterPredicate_Actual, "FilterPredicate_Actual");
                Assert.AreEqual(expectedRow.IsIncremental_Desired, actualRow.IsIncremental_Desired, "IsIncremental_Desired");
                Assert.AreEqual(expectedRow.IsIncremental_Actual, actualRow.IsIncremental_Actual, "IsIncremental_Actual");
                Assert.AreEqual(expectedRow.IsIncremental_Actual, actualRow.IsIncremental_Actual, "IsIncremental_Actual");
                Assert.AreEqual(expectedRow.NoRecompute_Actual, actualRow.NoRecompute_Actual, "NoRecompute_Actual");
                Assert.AreEqual(expectedRow.LowerSampleSizeToDesired, actualRow.LowerSampleSizeToDesired, "LowerSampleSizeToDesired");
                Assert.AreEqual(expectedRow.ReadyToQueue, actualRow.ReadyToQueue, "ReadyToQueue");
                Assert.AreEqual(expectedRow.DoesSampleSizeNeedUpdate, actualRow.DoesSampleSizeNeedUpdate, "DoesSampleSizeNeedUpdate");
                Assert.AreEqual(expectedRow.IsStatisticsMissing, actualRow.IsStatisticsMissing, "IsStatisticsMissing");
                Assert.AreEqual(expectedRow.HasFilterChanged, actualRow.HasFilterChanged, "HasFilterChanged");
                Assert.AreEqual(expectedRow.HasIncrementalChanged, actualRow.HasIncrementalChanged, "HasIncrementalChanged");
                Assert.AreEqual(expectedRow.HasNoRecomputeChanged, actualRow.HasNoRecomputeChanged, "HasNoRecomputeChanged");
                Assert.AreEqual(expectedRow.NumRowsInTableUnfiltered, actualRow.NumRowsInTableUnfiltered, "NumRowsInTableUnfiltered");
                Assert.AreEqual(expectedRow.NumRowsInTableFiltered, actualRow.NumRowsInTableFiltered, "NumRowsInTableFiltered");
                Assert.AreEqual(expectedRow.NumRowsSampled, actualRow.NumRowsSampled, "NumRowsSampled");
                Assert.AreEqual(expectedRow.StatisticsLastUpdated, actualRow.StatisticsLastUpdated, "StatisticsLastUpdated");
                Assert.AreEqual(expectedRow.HistogramSteps, actualRow.HistogramSteps, "HistogramSteps");
                Assert.AreEqual(expectedRow.StatisticsModCounter, actualRow.StatisticsModCounter, "StatisticsModCounter");
                Assert.AreEqual(expectedRow.PersistedSamplePct, actualRow.PersistedSamplePct, "PersistedSamplePct");
                Assert.AreEqual(expectedRow.StatisticsUpdateType, actualRow.StatisticsUpdateType, "StatisticsUpdateType");
                Assert.AreEqual(expectedRow.ListOfChanges, actualRow.ListOfChanges, "ListOfChanges");
            }
        }
    }
}
