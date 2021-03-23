using System.Collections.Generic;
using System.Diagnostics;
using DOI.Tests.Integration.Models;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;

namespace DOI.Tests.IntegrationTests.RunTests.Maintenance
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class LowFragmentationTests
    {
        protected const string TempTableName = "TempA";
        protected const int MinimumFragmentation = 5;
        protected const int MaximumFragmentation = 30;
        protected const int MinimumIndexPages = 5; private SqlHelper sqlHelper;
        protected DataDrivenIndexTestHelper dataDrivenIndexTestHelper;
        protected TempARepository tempARepository;

        [OneTimeSetUp]
        public void OneTimeSetup()
        {
            this.sqlHelper = new SqlHelper();
            this.OneTimeTearDown();
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_Setup.sql")), 120);
            this.dataDrivenIndexTestHelper = new DataDrivenIndexTestHelper(this.sqlHelper);
            this.tempARepository = new TempARepository(this.sqlHelper);
            this.sqlHelper.Execute($"UPDATE DOI.DOISettings SET SettingValue = {MinimumIndexPages} WHERE SettingName = 'MinNumPagesForIndexDefrag'");

            this.dataDrivenIndexTestHelper.CreateIndex("NIDX_TempA_Report");
            var watch = Stopwatch.StartNew();

            // Add items until fragmentation is above 5%.
            do
            {
                this.dataDrivenIndexTestHelper.AddRowsToTempA(700);

                var indexName = "NIDX_TempA_Report";
                var minimumPageSize = this.sqlHelper.ExecuteScalar<int>("SELECT CAST(SettingValue AS INT) FROM DOI.DOISettings WHERE SettingName = 'MinNumPagesForIndexDefrag'");

                if (this.dataDrivenIndexTestHelper.GetIndexViews(TempTableName).Exists(i => i.Fragmentation >= MinimumFragmentation && i.Fragmentation < MaximumFragmentation && i.NumPages_Actual > minimumPageSize && i.IndexName == indexName))
                {
                    break;
                }

                Assert.Greater(180000, watch.ElapsedMilliseconds, "Test timed out.");
            }
            while (true);
        }

        [OneTimeTearDown]
        public void OneTimeTearDown()
        {
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_TearDown.sql")), 120);
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_User_3_DOISettings");
        }

        [SetUp]
        public void SetupFragmentation()
        {
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("FragmentationTests_Setup.sql")), 120);
        }

        [TestCase(null, null, "AlterReorganize", TestName = "LowFragmentation no changes to index")]
        [TestCase("OptionIgnoreDupKey", "1", "AlterRebuild", TestName = "LowFragmentation changing OptionIgnoreDupKey")]
        [TestCase("OptionStatisticsNoRecompute", "1", "AlterRebuild", TestName = "LowFragmentation changing OptionStatisticsNoRecompute")]
        [TestCase("OptionStatisticsIncremental", "1", "AlterRebuild", TestName = "LowFragmentation changing OptionStatisticsIncremental")]
        [TestCase("OptionAllowRowLocks", "0", "AlterRebuild", TestName = "LowFragmentation changing OptionAllowRowLocks")]
        [TestCase("OptionAllowPageLocks", "0", "AlterRebuild", TestName = "LowFragmentation changing OptionAllowPageLocks")]
        public void LowFragmentationShouldTriggerAlterIndexReorganizeUnlessSpecificPropertiesAreModified(string propertyName, string propertyValue, string indexUpdateType)
        {
            var indexName = "NIDX_TempA_Report";

            // Fragmentation needs to be between 5% and 30% and TotalPages is configurable
            vwIndexes indexToReorganize = null;
            indexToReorganize = this.dataDrivenIndexTestHelper.GetIndexViews(TempTableName).Find(i => i.Fragmentation >= MinimumFragmentation && i.NumPages_Actual > MinimumIndexPages && i.IndexName == indexName);

            // Update property
            if (!string.IsNullOrEmpty(propertyName))
            {
                this.sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET [{propertyName}] = '{propertyValue}' WHERE SchemaName = 'dbo' AND TableName = '{TempTableName}' AND IndexName = '{indexName}'", 120);
                indexToReorganize = this.dataDrivenIndexTestHelper.GetIndexViews(TempTableName).Find(i => i.Fragmentation >= MinimumFragmentation && i.NumPages_Actual > MinimumIndexPages && i.IndexName == indexName);
            }

            Assert.IsFalse(indexToReorganize.Fragmentation > MaximumFragmentation, "Check if exceeds maximumFragmentation. Might be a flaky test.");
            Assert.IsNotNull(indexToReorganize, "Index exist that meet alter index fragmentation");
            Assert.AreEqual(indexUpdateType, indexToReorganize.IndexUpdateType, "IndexUpdateType");
        }
    }
}
