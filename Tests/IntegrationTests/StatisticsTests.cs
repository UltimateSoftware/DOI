using System.Collections.Generic;
using DOI.TestHelpers;
using DOI.Tests.Integration.Models;
using DOI.Tests.TestHelpers;
using NUnit.Framework;
using PaymentSolutions.TestHelpers.Attributes;
using TestHelper = DOI.Tests.TestHelpers;

namespace DOI.Tests.Integration
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class StatisticsTests
    {
        protected TestHelper.SqlHelper sqlHelper;
        protected const string StatisticsName = "ST_TempA_TempAId";
        protected const string TempTableName = "TempA";
        protected const string SchemaName = "dbo";

        [SetUp]
        public virtual void Setup()
        {
            this.sqlHelper = new TestHelper.SqlHelper();
            this.TearDown();
            sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_Setup.sql")), 120);
        }

        [TearDown]
        public virtual void TearDown()
        {
            sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_TearDown.sql")), 120);
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
        [TestCase("ST_TempA", "SampleSizePct=90", "Update Statistics", "SampleSize", TestName = "Changing sample Size", Ignore ="Test fails on CI")]
        [TestCase("ST_TempA", "IsIncremental = 1", "Update Statistics", "Incremental", TestName = "Changing isIncremental")]
        [TestCase("ST_TempA", "IsFiltered = 1, FilterPredicate = 'TempAId <> 0'", "DropRecreate Statistics", "Filter", TestName = "Changing filter")]
        [TestCase("ST_TempA", "NoRecompute = 1", "Update Statistics", "NoRecompute", TestName ="Changing isNoRecompute")]

        //2 settings:
        [TestCase("ST_TempA", "SampleSizePct=90, IsIncremental = 1", "Update Statistics", "Incremental, SampleSize", TestName = "Changing sample size and isIncremental", Ignore = "Test fails on CI")]
        [TestCase("ST_TempA", "SampleSizePct=90, IsFiltered = 1, FilterPredicate = 'TempAId <> 0'", "DropRecreate Statistics", "Filter, SampleSize", TestName = "Changing sample size and filter", Ignore = "Test fails on CI")]
        [TestCase("ST_TempA", "SampleSizePct=90, NoRecompute = 1", "Update Statistics", "NoRecompute, SampleSize", TestName = "Changing sample size and isNoRecompute", Ignore = "Test fails on CI")]
        [TestCase("ST_TempA", "IsFiltered = 1, FilterPredicate = 'TempAId <> 0', IsIncremental = 1", "DropRecreate Statistics", "Filter, Incremental", TestName = "Changing isIncremental and filter")]
        [TestCase("ST_TempA", "IsIncremental = 1, NoRecompute = 1", "Update Statistics", "Incremental, NoRecompute", TestName = "Changing isIncremental and isNoRecompute")]
        [TestCase("ST_TempA", "IsFiltered = 1, FilterPredicate = 'TempAId <> 0', NoRecompute = 1", "DropRecreate Statistics", "Filter, NoRecompute", TestName = "Changing filter and isNoRecompute")]

        //3 settings
        [TestCase("ST_TempA", "IsFiltered = 1, FilterPredicate = 'TempAId <> 0', IsIncremental = 1, SampleSizePct=90", "DropRecreate Statistics", "Filter, Incremental, SampleSize", TestName ="Changing sample size, isIncremental, and filter", Ignore = "Test fails on CI")]
        [TestCase("ST_TempA", "IsIncremental = 1, NoRecompute = 1, SampleSizePct=90", "Update Statistics", "Incremental, NoRecompute, SampleSize", TestName ="Changing sample size, isIncremental, and isNoRecompute", Ignore = "Test fails on CI")]
        [TestCase("ST_TempA", "IsFiltered = 1, FilterPredicate = 'TempAId <> 0', NoRecompute = 1, SampleSizePct=90", "DropRecreate Statistics", "Filter, NoRecompute, SampleSize", TestName ="Changing sample size, filter, and isNoRecompute", Ignore = "Test fails on CI")]
        [TestCase("ST_TempA", "IsFiltered = 1, FilterPredicate = 'TempAId <> 0', IsIncremental = 1, NoRecompute=1", "DropRecreate Statistics", "Filter, Incremental, NoRecompute", TestName ="Changing isIncremental, filter, and isNoRecompute")]

        //4 settings:
        [TestCase("ST_TempA", "IsFiltered = 1, FilterPredicate = 'TempAId <> 0', IsIncremental = 1, NoRecompute=1, SampleSizePct=90", "DropRecreate Statistics", "Filter, Incremental, NoRecompute, SampleSize", TestName ="Changing all 4 settings", Ignore = "Test fails on CI")]

        public void StatisticsUpdateStrategyTests(string statisticsName, string optionUpdateList, string expectedUpdateType, string expectedListOfChanges)
        {
            this.sqlHelper = new TestHelper.SqlHelper();

            if (optionUpdateList.Contains("SampleSize"))
            {                
                var bulkInsertFile = ResourceLoader.GetFullResourceFilePath("dbo.TempA.bcp");
                //load data and then create stats to get sample size to come down
                sqlHelper.Execute(
                    $@"BULK INSERT dbo.TempA FROM '{bulkInsertFile}' WITH (DATAFILETYPE = 'native')");

                sqlHelper.Execute(
                    $@"UPDATE STATISTICS dbo.TempA(ST_TempA_TempAId) WITH SAMPLE 20 PERCENT, INCREMENTAL = OFF");
            }

            //UpdateTypes do not match
            string actualUpdateType =
                sqlHelper.ExecuteScalar<string>(
                    $@"SELECT StatisticsUpdateType FROM DOI.vwStatistics WHERE SchemaName = '{
                            SchemaName
                        }' AND TableName = '{TempTableName}' AND StatisticsName = '{StatisticsName}'");
            Assert.AreNotEqual(expectedUpdateType, actualUpdateType);

            //change metadata
            sqlHelper.Execute(
                $@"UPDATE DOI.[Statistics] SET {optionUpdateList} WHERE StatisticsName = '{StatisticsName}'");

            //UpdateTypes now match
            actualUpdateType =
                sqlHelper.ExecuteScalar<string>(
                    $@"SELECT StatisticsUpdateType FROM DOI.vwStatistics WHERE SchemaName = '{
                            SchemaName
                        }' AND TableName = '{TempTableName}' AND StatisticsName = '{StatisticsName}'");

            Assert.AreEqual(expectedUpdateType, actualUpdateType);
        }

        [Test]
        [Quarantine("ULTI-388423: Flaky in CI.")]
        [TestCase("ST_TempA_TempAId", "Droprecreate Statistics", true, TestName = "DropRecreate")]
        [TestCase("ST_TempA_TempAId", "Create Statistics", true, TestName = "Create")]
        [TestCase("ST_TempA_TempAId", "Update Statistics", true, TestName = "Update")]
        [TestCase("ST_TempA_TempAId", "Update Statistics", false, TestName = "Not ReadyToQueue")]
        public void StatisticsRunTests(string statisticsName, string statisticsUpdateType, bool readyToQueue)
        {
            //create missing & update existing stats
            /*
             * 1. Assert vwStatistics for Before State
             * 2. Change Metadata
             * 3. Run Change
             * 3. Assert vwStatistics for After State
             * 
             */
            this.sqlHelper = new TestHelper.SqlHelper();
            List<Statistics> expectedStatisticsDetails;
            Statistics expectedStatisticsDetail;
            List<Statistics> actualStatisticsDetails;
            Statistics actualStatisticsDetail;

            sqlHelper.Execute(@"
            INSERT INTO DOI.IndexesRowStore
            (SchemaName, TableName, IndexName, IsUnique_Desired,IsPrimaryKey_Desired,IsUniqueConstraint_Desired,IsClustered_Desired,KeyColumnList_Desired,IncludedColumnList_Desired,IsFiltered_Desired,FilterPredicate,Fillfactor_Desired,OptionPadIndex_Desired,OptionStatisticsNoRecompute_Desired,OptionStatisticsIncremental_Desired,OptionIgnoreDupKey_Desired,OptionResumable_Desired,OptionMaxDuration_Desired,OptionAllowRowLocks_Desired,OptionAllowPageLocks_Desired,OptionDataCompression_Desired,Storage_Desired,PartitionColumn_Desired)
            VALUES(N'dbo', N'TempA', N'NIDX_TempA_Report2', 0, 0, 0, 0, N'TransactionUtcDt ASC', NULL, 0, NULL, 90, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 'NONE', 'PRIMARY', NULL)");

            string actualUpdateType =
                sqlHelper.ExecuteScalar<string>(
                    $@"SELECT StatisticsUpdateType FROM DOI.vwStatistics WHERE SchemaName = '{
                            SchemaName
                        }' AND TableName = '{TempTableName}' AND StatisticsName = '{StatisticsName}'");
            Assert.AreNotEqual(statisticsUpdateType, actualUpdateType);

            if (statisticsUpdateType == "DropRecreate Statistics")
            {
                sqlHelper.Execute(
                    $@"UPDATE DOI.[Statistics] SET IsFiltered = 1, FilterPredicate = 'TempAId <> 0' WHERE StatisticsName = '{
                            StatisticsName
                        }'");

                if (readyToQueue == false)
                {
                    sqlHelper.Execute(
                        $@"UPDATE DOI.[Statistics] SET ReadyToQueue = 0 WHERE StatisticsName = '{StatisticsName}'");

                    expectedStatisticsDetails =
                        new DataDrivenIndexTestHelper(new TestHelper.SqlHelper()).GetActualStatisticsDetails(StatisticsName); //if the table is not ready to queue, then we expect to see no changes.
                    expectedStatisticsDetail = expectedStatisticsDetails.Find(e => e.StatisticsName == StatisticsName);
                }
                else
                {
                    expectedStatisticsDetails =
                        new DataDrivenIndexTestHelper(new TestHelper.SqlHelper()).GetExpectedStatisticsDetails(StatisticsName);

                    expectedStatisticsDetail = expectedStatisticsDetails.Find(e => e.StatisticsName == StatisticsName);
                }

                actualUpdateType =
                    sqlHelper.ExecuteScalar<string>(
                        $@"SELECT StatisticsUpdateType FROM DOI.vwStatistics WHERE SchemaName = '{
                                SchemaName
                            }' AND TableName = '{TempTableName}' AND StatisticsName = '{StatisticsName}'");

                Assert.AreEqual(statisticsUpdateType, actualUpdateType);

                sqlHelper.Execute(
                    $@" DECLARE @BatchIdOUT UNIQUEIDENTIFIER;
                        EXEC DOI.spQueue 
                            @OnlineOperations = 0,
                            @IsBeingRunDuringADeployment = 1,
                            @BatchIdOUT = @BatchIdOUT OUTPUT

                        EXEC DOI.spRun
                            @OnlineOperations = 0,
                            @SchemaName = N'{SchemaName}',
                            @TableName = N'{TempTableName}',
                            @BatchId = @BatchIdOUT");

                //Assert that statistics is there...all values.
                actualStatisticsDetails =
                    new DataDrivenIndexTestHelper(new TestHelper.SqlHelper()).GetActualStatisticsDetails(StatisticsName);
                actualStatisticsDetail = actualStatisticsDetails.Find(a => a.StatisticsName == StatisticsName);

                AssertStatistics(expectedStatisticsDetail, actualStatisticsDetail);
            }
            else if (statisticsUpdateType == "Create Statistics")
            {
                sqlHelper.Execute($@"DROP STATISTICS {TempTableName}.{StatisticsName}");

                if (readyToQueue == false)
                {
                    sqlHelper.Execute(
                        $@"UPDATE DOI.[Statistics] SET ReadyToQueue = 0 WHERE StatisticsName = '{StatisticsName}'");

                    expectedStatisticsDetails =
                        new DataDrivenIndexTestHelper(new TestHelper.SqlHelper()).GetActualStatisticsDetails(StatisticsName); //if the table is not ready to queue, then we expect to see no changes.
                    expectedStatisticsDetail = expectedStatisticsDetails.Find(e => e.StatisticsName == StatisticsName);
                }
                else
                {
                    expectedStatisticsDetails =
                        new DataDrivenIndexTestHelper(new TestHelper.SqlHelper()).GetExpectedStatisticsDetails(StatisticsName);

                    expectedStatisticsDetail = expectedStatisticsDetails.Find(e => e.StatisticsName == StatisticsName);
                }

                actualUpdateType =
                    sqlHelper.ExecuteScalar<string>(
                        $@"SELECT StatisticsUpdateType FROM DOI.vwStatistics WHERE SchemaName = '{
                                SchemaName
                            }' AND TableName = '{TempTableName}' AND StatisticsName = '{StatisticsName}'");

                Assert.AreEqual(statisticsUpdateType, actualUpdateType);

                sqlHelper.Execute(
                    $@" DECLARE @BatchIdOUT UNIQUEIDENTIFIER;
                        EXEC DOI.spQueue 
                            @OnlineOperations = 1,
                            @IsBeingRunDuringADeployment = 0,
                            @BatchIdOUT = @BatchIdOUT OUTPUT

                        EXEC DOI.spRun
                            @OnlineOperations = 1,
                            @SchemaName = N'{SchemaName}',
                            @TableName = N'{TempTableName}',
                            @BatchId = @BatchIdOUT");

                //Assert that statistics is there...all values.
                actualStatisticsDetails =
                    new DataDrivenIndexTestHelper(new TestHelper.SqlHelper()).GetActualStatisticsDetails(StatisticsName);
                actualStatisticsDetail = actualStatisticsDetails.Find(a => a.StatisticsName == StatisticsName);

                AssertStatistics(expectedStatisticsDetail, actualStatisticsDetail);
            }
            else if (statisticsUpdateType == "Update Statistics")
            {
                sqlHelper.Execute(
                    $@"UPDATE DOI.[Statistics] SET NoRecompute = 1 WHERE StatisticsName = '{
                            StatisticsName
                        }'");

                if (readyToQueue == false)
                {
                    sqlHelper.Execute(
                        $@"UPDATE DOI.[Statistics] SET ReadyToQueue = 0 WHERE StatisticsName = '{StatisticsName}'");

                    expectedStatisticsDetails =
                        new DataDrivenIndexTestHelper(new TestHelper.SqlHelper()).GetActualStatisticsDetails(StatisticsName); //if the table is not ready to queue, then we expect to see no changes.
                    expectedStatisticsDetail = expectedStatisticsDetails.Find(e => e.StatisticsName == StatisticsName);
                }
                else
                {
                    expectedStatisticsDetails =
                        new DataDrivenIndexTestHelper(new TestHelper.SqlHelper()).GetExpectedStatisticsDetails(StatisticsName);

                    expectedStatisticsDetail = expectedStatisticsDetails.Find(e => e.StatisticsName == StatisticsName);
                }

                actualUpdateType =
                    sqlHelper.ExecuteScalar<string>(
                        $@"SELECT StatisticsUpdateType FROM DOI.vwStatistics WHERE SchemaName = '{
                                SchemaName
                            }' AND TableName = '{TempTableName}' AND StatisticsName = '{StatisticsName}'");

                Assert.AreEqual(statisticsUpdateType, actualUpdateType);

                sqlHelper.Execute(
                    $@" DECLARE @BatchIdOUT UNIQUEIDENTIFIER;
                        EXEC DOI.spQueue 
                            @OnlineOperations = 1,
                            @IsBeingRunDuringADeployment = 0,
                            @BatchIdOUT = @BatchIdOUT OUTPUT

                        EXEC DOI.spRun
                            @OnlineOperations = 1,
                            @SchemaName = N'{SchemaName}',
                            @TableName = N'{TempTableName}',
                            @BatchId = @BatchIdOUT");

                //Assert that statistics is there...all values.
                actualStatisticsDetails =
                    new DataDrivenIndexTestHelper(new TestHelper.SqlHelper()).GetActualStatisticsDetails(StatisticsName);
                actualStatisticsDetail = actualStatisticsDetails.Find(a => a.StatisticsName == StatisticsName);

                AssertStatistics(expectedStatisticsDetail, actualStatisticsDetail);
            }
        }

        public void AssertStatistics(Statistics expectedStatisticsDetail, Statistics actualStatisticsDetail)
        {
            Assert.NotNull(actualStatisticsDetail, "actualStatisticsDetail");

            Assert.AreEqual(expectedStatisticsDetail.SchemaName, actualStatisticsDetail.SchemaName, "Stat SchemaName");
            Assert.AreEqual(expectedStatisticsDetail.TableName, actualStatisticsDetail.TableName, "Stat TableName");
            Assert.AreEqual(expectedStatisticsDetail.StatisticsName, actualStatisticsDetail.StatisticsName, "Stat StatisticsName");
            Assert.AreEqual(expectedStatisticsDetail.StatisticsColumnList, actualStatisticsDetail.StatisticsColumnList, "Stat StatisticsColumnList");
            Assert.AreEqual(expectedStatisticsDetail.SampleSizePct, actualStatisticsDetail.SampleSizePct, "Stat SampleSizePct");
            Assert.AreEqual(expectedStatisticsDetail.IsFiltered, actualStatisticsDetail.IsFiltered, "Stat IsFiltered");
            Assert.AreEqual(expectedStatisticsDetail.FilterPredicate, actualStatisticsDetail.FilterPredicate, "Stat FilterPredicate");
            Assert.AreEqual(expectedStatisticsDetail.IsIncremental, actualStatisticsDetail.IsIncremental, "Stat IsIncremental");
            Assert.AreEqual(expectedStatisticsDetail.NoRecompute, actualStatisticsDetail.NoRecompute, "Stat NoRecompute");
        }
    }
}