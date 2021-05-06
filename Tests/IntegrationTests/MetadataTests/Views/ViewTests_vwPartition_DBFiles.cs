using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_DBFilesHelper;
using PfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionsHelper;
using FgTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_FileGroupsHelper;
using DbfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_DBFilesHelper;
using TablePartitioning = DOI.Tests.IntegrationTests.RunTests.TablePartitioning;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwPartition_DBFiles : DOIBaseTest
    {
        FgTestHelper fgTestHelper = new FgTestHelper();
        DbfTestHelper dbfTestHelper = new DbfTestHelper();

        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
        }

        [TearDown]
        public void TearDown()
        {
            string dropDbFilesYearlySql = dbfTestHelper.GetDBFilesSql(SystemMetadataHelper.PartitionSchemeNameYearly, "Drop");
            string dropDbFilegroupsYearlySql = fgTestHelper.GetFilegroupSql(SystemMetadataHelper.PartitionSchemeNameYearly, "Drop");
            string dropDbFilesMonthlySql = dbfTestHelper.GetDBFilesSql(SystemMetadataHelper.PartitionSchemeNameMonthly, "Drop");
            string dropDbFilegroupsMonthlySql = fgTestHelper.GetFilegroupSql(SystemMetadataHelper.PartitionSchemeNameMonthly, "Drop");

            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.DropPartitionFunctionMonthlySql, 30, true, "DOIUnitTests");

            if (dropDbFilesYearlySql != null)
            {
                sqlHelper.Execute(dropDbFilesYearlySql);
            }
            if (dropDbFilegroupsYearlySql != null)
            {
                sqlHelper.Execute(dropDbFilegroupsYearlySql);
            }
            if (dropDbFilesMonthlySql != null)
            {
                sqlHelper.Execute(dropDbFilesMonthlySql);
            }
            if (dropDbFilegroupsMonthlySql != null)
            {
                sqlHelper.Execute(dropDbFilegroupsMonthlySql);
            }
        }

        [TestCase("Yearly", "2016-01-01", 1)]
        [TestCase("Monthly", "2016-01-01", 12)]
        [Test]
        public void Views_vwPartitioning_DBFiles_MetadataIsAccurate(string boundaryInterval, string initialDate, int numOfFutureIntervals, bool usesSlidingWindow = false, int? slidingWindowSize = null)
        {
            var partitionFunctionName = string.Concat("pfTests", boundaryInterval);
            var partitionSchemeName = string.Concat("psTests", boundaryInterval);

            string metadataSql = "";

            if (boundaryInterval == "Yearly")
            {
                metadataSql = TestHelper.CreatePartitionFunctionYearlyMetadataSql;
            }
            else if (boundaryInterval == "Monthly")
            {
                metadataSql = TestHelper.CreatePartitionFunctionMonthlyMetadataSql;
            }

            sqlHelper.Execute(metadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);//refresh metadata after metadata insert

            //tear down...
            sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(partitionSchemeName, "Drop"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysFilegroupsSql);

            //partition function metadata has already been created, so views should show the filegroups & files that need to be created, plus the fact that they are missing.
            TestHelper.AssertMetadata(boundaryInterval, 1);

            //create all needed storage containers
            sqlHelper.Execute(fgTestHelper.GetFilegroupSql(partitionSchemeName, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(partitionSchemeName, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysFilegroupsSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabaseFilesSql);

            //re-assert.  now the FileGroups should show up as not missing in the views.
            TestHelper.AssertMetadata(boundaryInterval, 0);
        }

    }
}
