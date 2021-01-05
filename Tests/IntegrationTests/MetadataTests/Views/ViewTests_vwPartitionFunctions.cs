using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionsHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwPartitionFunctions : DOIBaseTest
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
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionMonthlySql, 30, true, DatabaseName); 
        }

        [TestCase("Yearly", "2016-01-01", 1)]
        [TestCase("Monthly", "2016-01-01", 12)]
        [Test]
        public void Views_vwPartitionFunctions_MetadataIsAccurate(string boundaryInterval, string initialDate, int numOfFutureIntervals, bool usesSlidingWindow = false, int? slidingWindowSize = null)
        {
            var partitionFunctionName = string.Concat("pfTests", boundaryInterval);
            var testHelper = new TestHelper();
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

            //create partition function
            sqlHelper.Execute(testHelper.GetPartitionFunctionSql(partitionFunctionName, "Create"), 30, true, DatabaseName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql); //refresh metadata again to show the partition function as existing on the server.

            //and now they should match
            TestHelper.AssertMetadata(boundaryInterval, DateTime.Parse(initialDate), numOfFutureIntervals);

            sqlHelper.Execute(testHelper.GetPartitionFunctionSql(partitionFunctionName, "Drop"), 30, true, DatabaseName);
        }
    }
}
