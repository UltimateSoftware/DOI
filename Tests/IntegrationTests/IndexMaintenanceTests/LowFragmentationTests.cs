using System.Collections.Generic;
using System.Diagnostics;
using DDI.Tests.Integration.Models;
using NUnit.Framework;
using DDI.TestHelpers;
using DDI.Tests.TestHelpers;

namespace DDI.Tests.Integration
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class LowFragmentationTests
    {
        private SqlHelper sqlHelper;
        protected DataDrivenIndexTestHelper dataDrivenIndexTestHelper;
        protected TempARepository tempARepository;
        protected const string TempTableName = "TempA";
        protected const int MinimumFragmentation = 5;
        protected const int MaximumFragmentation = 30;
        protected const int MinimumIndexPages = 5;

        [OneTimeSetUp]
        public void OneTimeSetup()
        {
            this.sqlHelper = new SqlHelper();
            this.OneTimeTearDown();
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_Setup.sql")), 120);
            this.dataDrivenIndexTestHelper = new DataDrivenIndexTestHelper(sqlHelper);
            this.tempARepository = new TempARepository(sqlHelper);
            this.sqlHelper.Execute($"UPDATE dbo.SystemSettings SET SettingValue = {MinimumIndexPages} WHERE SettingName = 'MinNumPagesForIndexDefrag'");

            this.dataDrivenIndexTestHelper.CreateIndex("NIDX_TempA_Report");
            var watch = Stopwatch.StartNew();

            // Add items until fragmentation is above 5%.
            do
            {
                this.dataDrivenIndexTestHelper.AddRowsToTempA(700);

                var indexName = "NIDX_TempA_Report";
                var minimumPageSize = sqlHelper.ExecuteScalar<int>("SELECT CAST(SettingValue AS INT) FROM dbo.SystemSettings WHERE SettingName = 'MinNumPagesForIndexDefrag'");

                if (this.dataDrivenIndexTestHelper.GetIndexViews(TempTableName).Exists(i => i.IndexFragmentation >= MinimumFragmentation && i.IndexFragmentation < MaximumFragmentation && i.TotalPages > minimumPageSize && i.IndexName == indexName))
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
            sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_TearDown.sql")), 120);
            sqlHelper.Execute($"EXEC Utility.spDDI_RefreshMetadata_SystemSettings");
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
            IndexView indexToReorganize = null;
            indexToReorganize = this.dataDrivenIndexTestHelper.GetIndexViews(TempTableName).Find(i => i.IndexFragmentation >= MinimumFragmentation && i.TotalPages > MinimumIndexPages && i.IndexName == indexName);

            // Update property
            if (!string.IsNullOrEmpty(propertyName))
            {
                sqlHelper.Execute($"UPDATE Utility.IndexesRowStore SET [{propertyName}] = '{propertyValue}' WHERE SchemaName = 'dbo' AND TableName = '{TempTableName}' AND IndexName = '{indexName}'", 120);
                indexToReorganize = this.dataDrivenIndexTestHelper.GetIndexViews(TempTableName).Find(i => i.IndexFragmentation >= MinimumFragmentation && i.TotalPages > MinimumIndexPages && i.IndexName == indexName);
            }

            Assert.IsFalse(indexToReorganize.IndexFragmentation > MaximumFragmentation, "Check if exceeds maximumFragmentation. Might be a flaky test.");
            Assert.IsNotNull(indexToReorganize, "Index exist that meet alter index fragmentation");
            Assert.AreEqual(indexUpdateType, indexToReorganize.IndexUpdateType, "IndexUpdateType");
        }
    }
}
