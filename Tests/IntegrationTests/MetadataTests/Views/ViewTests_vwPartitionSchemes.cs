using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionSchemesHelper;
using PfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionsHelper;
using FgTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_FileGroupsHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwPartitionSchemes : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
        }

        #region Helper Methods



        #endregion


        [TestCase("Yearly", "2016-01-01", 1)]
        [TestCase("Monthly", "2016-01-01", 12)]
        [Test]
        public void Views_vwPartitionSchemes_MetadataIsAccurate(string boundaryInterval, string initialDate, int numOfFutureIntervals, bool usesSlidingWindow = false, int? slidingWindowSize = null)
        {
            //set up
            var partitionFunctionName = string.Concat("pfTests", boundaryInterval);
            var partitionSchemeName = string.Concat("psTests", boundaryInterval);
            var testHelper = new TestHelper();
            var fGTestHelper = new FgTestHelper();
            var pfTestHelper = new PfTestHelper();

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

            sqlHelper.Execute(fGTestHelper.GetFilegroupSql(partitionSchemeName, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(pfTestHelper.GetPartitionFunctionSql(partitionFunctionName, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(testHelper.GetPartitionSchemeSql(partitionSchemeName, "Create"), 30, true, DatabaseName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysPartitionSchemesSql);

            //and now they should match
            TestHelper.AssertMetadata(boundaryInterval, DateTime.Parse(initialDate), numOfFutureIntervals);

            //tear down
            sqlHelper.Execute(testHelper.GetPartitionSchemeSql(partitionSchemeName, "Drop"), 30, true, DatabaseName);
            sqlHelper.Execute(pfTestHelper.GetPartitionFunctionSql(partitionFunctionName, "Drop"), 30, true, DatabaseName);
            sqlHelper.Execute(fGTestHelper.GetFilegroupSql(partitionSchemeName, "Drop"), 30, true, DatabaseName);
        }

    }
}
