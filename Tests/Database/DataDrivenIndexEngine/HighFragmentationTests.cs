using System.Diagnostics;
using NUnit.Framework;
using TaxHub.TestHelpers;
using Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.Models;
using TestHelper = DDI.TestHelpers;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class HighFragmentationTests
    {
        protected TestHelper.SqlHelper sqlHelper;
        protected DataDrivenIndexTestHelper dataDrivenIndexTestHelper;
        protected TempARepository tempARepository;
        protected const string TempTableName = "TempA";
        protected const int MinimumFragmentation = 31;
        protected const int MinimumIndexPages = 5;

        [OneTimeSetUp]
        public void OneTimeSetup()
        {
            this.sqlHelper = new TestHelper.SqlHelper();
            this.OneTimeTearDown();
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_Setup.sql")), 120);
            this.dataDrivenIndexTestHelper = new DataDrivenIndexTestHelper(sqlHelper);
            this.tempARepository = new TempARepository(sqlHelper);
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
            this.dataDrivenIndexTestHelper.CreateIndex("PK_TempA");
            this.dataDrivenIndexTestHelper.CreateIndex("PK_TempB");
            this.dataDrivenIndexTestHelper.CreateIndex("CCI_TempB_Report");
            this.dataDrivenIndexTestHelper.CreateIndex("CDX_TempA");
            this.dataDrivenIndexTestHelper.CreateIndex("NCCI_TempA_Report");
            this.dataDrivenIndexTestHelper.CreateIndex("NIDX_TempA_Report");
        }

        [TestCase(MinimumIndexPages, TestName = "High Fragmentation")]
        [Test]
        public void HighFragmentationShouldTriggerAlterIndexRebuild(int minimumNumPages)
        {
            //Fragmentation needs to be above 30% and TotalPages is configurable
            sqlHelper.Execute($"UPDATE dbo.SystemSettings SET SettingValue = {minimumNumPages} WHERE SettingName = 'MinNumPagesForIndexDefrag'");
            IndexView indexToReorganize = null;
            var watch = Stopwatch.StartNew();

            //Add items until fragmentation is >= 31%.
            do
            {
                this.dataDrivenIndexTestHelper.AddRowsToTempA(2000);

                var indexRows = this.dataDrivenIndexTestHelper.GetIndexViews(TempTableName);

                if (indexRows.Exists(i => i.IndexFragmentation >= MinimumFragmentation && i.TotalPages > minimumNumPages))
                {
                    indexToReorganize = indexRows.Find(i => i.IndexFragmentation >= MinimumFragmentation && i.TotalPages >= minimumNumPages);
                    break;
                }
                Assert.Greater(180000, watch.ElapsedMilliseconds, "Test timed out.");
            }
            while (true); 

            Assert.IsNotNull(indexToReorganize, "Index exist that meet alter index fragmentation");
            Assert.AreEqual("AlterRebuild", indexToReorganize.IndexUpdateType, "IndexUpdateType");
        }
    }
}
