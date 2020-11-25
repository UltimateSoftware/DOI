using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionPartitionsHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwPartitionFunctionPartitions : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlyMetadataSql);
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionMonthlyMetadataSql);

            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlySql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionMonthlySql, 30, true, "DOIUnitTests");
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.DropPartitionFunctionMonthlySql, 30, true, "DOIUnitTests");

        }

        [TestCase("Yearly", "2016-01-01", 1)]
        [TestCase("Monthly", "2016-01-01", 12)]
        [Test]
        public void Views_vwPartitionFunctionPartitions_MetadataIsAccurate(string boundaryInterval, string initialDate, int numOfFutureIntervals, bool usesSlidingWindow = false, int? slidingWindowSize = null)
        {
            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);

            //and now they should match
            TestHelper.AssertMetadata(boundaryInterval, DateTime.Parse(initialDate), numOfFutureIntervals);
        }
    }
}
