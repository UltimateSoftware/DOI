using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_FileGroupsHelper;
using PfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionsHelper;
using TablePartitioning = DOI.Tests.IntegrationTests.TablePartitioning;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwPartition_FileGroups : DOIBaseTest
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

        [TestCase("Yearly", "2016-01-01", 1)]
        [TestCase("Monthly", "2016-01-01", 12)]
        [Test]
        public void Views_vwPartitioning_FileGroups_MetadataIsAccurate(string boundaryInterval, string initialDate, int numOfFutureIntervals, bool usesSlidingWindow = false, int? slidingWindowSize = null)
        {
            var partitionFunctionName = string.Concat("pfTests", boundaryInterval);
            var partitionSchemeName = string.Concat("psTests", boundaryInterval);

            var testHelper = new TestHelper();
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

            //tear down...
            sqlHelper.Execute(testHelper.GetFilegroupSql(partitionSchemeName, "Drop"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysFilegroupsSql);

            //partition function metadata has already been created, so views should show the filegroups & files that need to be created, plus the fact that they are missing.
            TestHelper.AssertMetadata(boundaryInterval, 1);

            //create all needed storage containers
            sqlHelper.Execute(testHelper.GetFilegroupSql(partitionSchemeName, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysFilegroupsSql);

            //re-assert.  now the FileGroups should show up as not missing in the views.
            TestHelper.AssertMetadata(boundaryInterval, 0);


        }
    }
}
