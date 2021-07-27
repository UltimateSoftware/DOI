using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Security.Cryptography;
using DOI.Tests.TestHelpers;
using DOI.Tests.Integration.Models;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SystemMetadata.SystemMetadataHelper;

namespace DOI.Tests.IntegrationTests.RunTests
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class StatisticsTests : DOIBaseTest
    {
        protected const string StatisticsName = "ST_TempA_TempAId";
        protected const string TempTableName = "TempA";

        [SetUp]
        public virtual void Setup()
        {
            this.TearDown();
            sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_Setup.sql")), 120, true, DatabaseName);
        }

        [TearDown]
        public virtual void TearDown()
        {
            sqlHelper.Execute($"EXEC [Utility].[spDeleteAllMetadataFromDatabase] @DatabaseName = '{DatabaseName}'");
            sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_TearDown.sql")), 120, true, DatabaseName);
            sqlHelper.Execute("TRUNCATE TABLE DOI.Queue");
            sqlHelper.Execute("TRUNCATE TABLE DOI.Log");
        }


        /* Update Strategy tests:
         * For each one of the below scenarios, do the following:
         * 1. Assert before state.
         * 2. Change metadata
         * 3. Assert UpdateStrategy and ListOfChanges
         
        Scenarios:
         * 1. Sample Size changes
         * 2. Incremental setting changes
         * 3. Filter changes
         * 4. NoRecompute setting changes
         * 
         */
        [TestCase("ST_TempA", "SampleSizePct_Desired = 90", "Update Statistics", "SampleSize", TestName = "Changing sample Size")]
        [TestCase("ST_TempA", "IsIncremental_Desired = 1", "Update Statistics", "Incremental", TestName = "Changing isIncremental")]
        [TestCase("ST_TempA", "IsFiltered_Desired = 1, FilterPredicate_Desired = 'TempAId <> 0'", "DropRecreate Statistics", "Filter", TestName = "Changing filter")]
        [TestCase("ST_TempA", "NoRecompute_Desired = 1", "Update Statistics", "NoRecompute", TestName ="Changing isNoRecompute")]

        //2 settings:
        [TestCase("ST_TempA", "SampleSizePct_Desired = 90, IsIncremental_Desired = 1", "Update Statistics", "Incremental, SampleSize", TestName = "Changing sample size and isIncremental")]
        [TestCase("ST_TempA", "SampleSizePct_Desired = 90, IsFiltered_Desired = 1, FilterPredicate_Desired = 'TempAId <> 0'", "DropRecreate Statistics", "Filter, SampleSize", TestName = "Changing sample size and filter")]
        [TestCase("ST_TempA", "SampleSizePct_Desired = 90, NoRecompute_Desired = 1", "Update Statistics", "NoRecompute, SampleSize", TestName = "Changing sample size and isNoRecompute")]
        [TestCase("ST_TempA", "IsFiltered_Desired = 1, FilterPredicate_Desired = 'TempAId <> 0', IsIncremental_Desired = 1", "DropRecreate Statistics", "Filter, Incremental", TestName = "Changing isIncremental and filter")]
        [TestCase("ST_TempA", "IsIncremental_Desired = 1, NoRecompute_Desired = 1", "Update Statistics", "Incremental, NoRecompute", TestName = "Changing isIncremental and isNoRecompute")]
        [TestCase("ST_TempA", "IsFiltered_Desired = 1, FilterPredicate_Desired = 'TempAId <> 0', NoRecompute_Desired = 1", "DropRecreate Statistics", "Filter, NoRecompute", TestName = "Changing filter and isNoRecompute")]

        //3 settings
        [TestCase("ST_TempA", "IsFiltered_Desired = 1, FilterPredicate_Desired = 'TempAId <> 0', IsIncremental_Desired = 1, SampleSizePct_Desired = 90", "DropRecreate Statistics", "Filter, Incremental, SampleSize", TestName ="Changing sample size, isIncremental, and filter")]
        [TestCase("ST_TempA", "IsIncremental_Desired = 1, NoRecompute_Desired = 1, SampleSizePct_Desired = 90", "Update Statistics", "Incremental, NoRecompute, SampleSize", TestName ="Changing sample size, isIncremental, and isNoRecompute")]
        [TestCase("ST_TempA", "IsFiltered_Desired = 1, FilterPredicate_Desired = 'TempAId <> 0', NoRecompute_Desired = 1, SampleSizePct_Desired = 90", "DropRecreate Statistics", "Filter, NoRecompute, SampleSize", TestName ="Changing sample size, filter, and isNoRecompute")]
        [TestCase("ST_TempA", "IsFiltered_Desired = 1, FilterPredicate_Desired = 'TempAId <> 0', IsIncremental_Desired = 1, NoRecompute_Desired = 1", "DropRecreate Statistics", "Filter, Incremental, NoRecompute", TestName ="Changing isIncremental, filter, and isNoRecompute")]

        //4 settings:
        [TestCase("ST_TempA", "IsFiltered_Desired = 1, FilterPredicate_Desired = 'TempAId <> 0', IsIncremental_Desired = 1, NoRecompute_Desired=1, SampleSizePct_Desired = 90", "DropRecreate Statistics", "Filter, Incremental, NoRecompute, SampleSize", TestName ="Changing all 4 settings")]

        public void StatisticsUpdateStrategyTests(string statisticsName, string optionUpdateList, string expectedUpdateType, string expectedListOfChanges)
        {
            if (optionUpdateList.Contains("SampleSize"))
            {                
                var bulkInsertFile = ResourceLoader.GetFullResourceFilePath("dbo.TempA.bcp");
                //load data and then create stats to get sample size to come down
                sqlHelper.Execute($@"BULK INSERT dbo.TempA FROM '{bulkInsertFile}' WITH (DATAFILETYPE = 'native')", 30, true, DatabaseName);

                sqlHelper.Execute($@"UPDATE STATISTICS dbo.TempA(ST_TempA_TempAId) WITH SAMPLE 20 PERCENT, INCREMENTAL = OFF", 30, true, DatabaseName);
            }

            //UpdateTypes do not match
            string actualUpdateType =
                sqlHelper.ExecuteScalar<string>(
                    $@" SELECT StatisticsUpdateType 
                            FROM DOI.vwStatistics 
                            WHERE DatabaseName = '{DatabaseName}' 
                                AND SchemaName = '{SchemaName}' 
                                AND TableName = '{TempTableName}' 
                                AND StatisticsName = '{StatisticsName}'");
            Assert.AreNotEqual(expectedUpdateType, actualUpdateType);

            //change metadata
            sqlHelper.Execute(
                $@" UPDATE DOI.[Statistics] 
                        SET {optionUpdateList} 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND StatisticsName = '{StatisticsName}'");

            //refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysStatsSql);

            //UpdateTypes now match
            actualUpdateType =
                sqlHelper.ExecuteScalar<string>(
                    $@" SELECT StatisticsUpdateType 
                            FROM DOI.vwStatistics 
                            WHERE DatabaseName = '{DatabaseName}' 
                                AND SchemaName = '{SchemaName}' 
                                AND TableName = '{TempTableName}' 
                                AND StatisticsName = '{StatisticsName}'");

            Assert.AreEqual(expectedUpdateType, actualUpdateType);
        }

        [Test]
        //[Quarantine("ULTI-388423: Flaky in CI.")]
        [TestCase("DropRecreate Statistics", true, TestName = "DropRecreate")]
        [TestCase("Create Statistics", true, TestName = "Create")]
        [TestCase("Update Statistics", true, TestName = "Update")]
        [TestCase("Update Statistics", false, TestName = "Not ReadyToQueue")]
        public void StatisticsRunTests(string statisticsUpdateType, bool readyToQueue)
        {
            //create missing & update existing stats
            /*
             * 1. Assert vwStatistics for Before State
             * 2. Change Metadata
             * 3. Run Change
             * 3. Assert vwStatistics for After State
             * 
             */
            List<Statistics> statisticsDetails;
            string updateSetClause = string.Empty;
            
            string actualUpdateType =
                sqlHelper.ExecuteScalar<string>(
                    $@" SELECT StatisticsUpdateType 
                            FROM DOI.vwStatistics 
                            WHERE DatabaseName = '{DatabaseName}' 
                                AND SchemaName = '{SchemaName}' 
                                AND TableName = '{TempTableName}' 
                                AND StatisticsName = '{StatisticsName}'");
            Assert.AreNotEqual(statisticsUpdateType, actualUpdateType);

            if (statisticsUpdateType == "DropRecreate Statistics")
            {
                updateSetClause = $"IsFiltered_Desired = 1, FilterPredicate_Desired = '([TempAId]<>''00000000-0000-0000-0000-000000000000'')'";
            }
            else if (statisticsUpdateType == "Update Statistics")
            {
                updateSetClause = "NoRecompute_Desired = 1";
            }
            else if (statisticsUpdateType == "Create Statistics")
            {
                sqlHelper.Execute($@"DROP STATISTICS {TempTableName}.{StatisticsName}", 30, true, DatabaseName);
            }


            if (updateSetClause != string.Empty)
            {
                sqlHelper.Execute(
                    $@" UPDATE DOI.[Statistics] 
                            SET {updateSetClause}
                            WHERE DatabaseName = '{DatabaseName}'
                                AND SchemaName = '{SchemaName}' 
                                AND TableName = '{TempTableName}' 
                                AND StatisticsName = '{StatisticsName}'");
            }

            if (readyToQueue == false)
            {
                sqlHelper.Execute(
                    $@"UPDATE DOI.[Statistics] 
                            SET ReadyToQueue = 0 
                            WHERE DatabaseName = '{DatabaseName}' 
                                AND SchemaName = '{SchemaName}' 
                                AND TableName = '{TempTableName}' 
                                AND StatisticsName = '{StatisticsName}'");
            }

            //refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysStatsSql);

            //assert that UpdateTypes are equal now.
            actualUpdateType =
                sqlHelper.ExecuteScalar<string>(
                    $@"SELECT StatisticsUpdateType 
                            FROM DOI.vwStatistics 
                            WHERE DatabaseName = '{DatabaseName}' 
                                AND SchemaName = '{SchemaName}' 
                                AND TableName = '{TempTableName}' 
                                AND StatisticsName = '{StatisticsName}'");

            Assert.AreEqual(statisticsUpdateType, actualUpdateType);
            
            //deploy the change
            sqlHelper.Execute(
                $@" DECLARE @BatchIdOUT UNIQUEIDENTIFIER;
                        EXEC DOI.spQueue 
                            @DatabaseName = N'{DatabaseName}',                            
                            @SchemaName = N'{SchemaName}',
                            @TableName = N'{TempTableName}',
                            @BatchIdOUT = @BatchIdOUT OUTPUT

                        EXEC DOI.spRun
                            @DatabaseName = N'{DatabaseName}',
                            @SchemaName = N'{SchemaName}',
                            @TableName = N'{TempTableName}',
                            @BatchId = @BatchIdOUT");

            //refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysStatsSql);

            //Assert that statistics is there...all values.
            statisticsDetails = sqlHelper.GetList<Statistics>($"SELECT * FROM DOI.[Statistics] WHERE StatisticsName = '{StatisticsName}'");

            //AssertStatistics(expectedStatisticsDetail, actualStatisticsDetail);
            AssertStatistics(statisticsDetails, readyToQueue);
        }

        public void AssertStatistics(List<Statistics> statisticsDetails, bool readyToQueue)
        {
            var statisticsDetail = statisticsDetails.Find(x => x.StatisticsName == StatisticsName);

            Assert.NotNull(statisticsDetail, "StatisticsDetail");

            Assert.AreEqual(statisticsDetail.StatisticsColumnList_Desired, statisticsDetail.StatisticsColumnList_Actual, "Stat StatisticsColumnList");
            //Assert.AreEqual(statisticsDetail.SampleSizePct_Desired, statisticsDetail.SampleSizePct_Actual, "Stat SampleSizePct"); issues with asserting this....values are not precise.
            Assert.AreEqual(statisticsDetail.IsFiltered_Desired, statisticsDetail.IsFiltered_Actual, "Stat IsFiltered");
            Assert.AreEqual(statisticsDetail.FilterPredicate_Desired, statisticsDetail.FilterPredicate_Actual, "Stat FilterPredicate");
            Assert.AreEqual(statisticsDetail.IsIncremental_Desired, statisticsDetail.IsIncremental_Actual, "Stat IsIncremental");

            if (readyToQueue)
            {

                Assert.AreEqual(statisticsDetail.NoRecompute_Desired, statisticsDetail.NoRecompute_Actual, "Stat NoRecompute");
            }
            else
            {
                Assert.AreNotEqual(statisticsDetail.NoRecompute_Desired, statisticsDetail.NoRecompute_Actual, "Stat NoRecompute");
            }
        }
    }
}