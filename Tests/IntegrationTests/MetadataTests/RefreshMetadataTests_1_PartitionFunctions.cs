using System;
using System.Data.SqlTypes;
using DOI.Tests.Integration;
using DOI.Tests.Integration.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;
using Helper = DOI.Tests.TestHelpers.Metadata.StorageContainers.PartitionFunctions.PartitionFunctionHelper;

namespace DOI.Tests.IntegrationTests.MetadataTests
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]

    public class RefreshMetadataTests1PartitionFunctions : DOIBaseTest
    {
        Helper helper = new Helper();
        
        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(Helper.PartitionFunction_TearDown_Metadata);
        }


        [TestCase("DOIUnitTests", "pfMonthlyTest", "Monthly", "2018-06-01", "2")]
        [TestCase("DOIUnitTests", "pfYearlyTest", "Yearly", "2018-01-01", "1")]
        [Test]
        public void RefreshMetadata_PartitionFunctions_MetadataIsAccurate(string databaseName, string partitionFunctionName, string boundaryInterval, DateTime initialDate, int numOfFutureIntervals_Desired)
        {
            // 1. Check that the user-supplied partition function metadata is correct.
            sqlHelper.Execute(Helper.SetupPartitionFunctionMetadataSql(databaseName, partitionFunctionName, boundaryInterval, initialDate, numOfFutureIntervals_Desired));

            sqlHelper.Execute(Helper.PartitionFunction_RefreshMetadata);

            helper.AssertPartitionFunctionsMetadata(databaseName, boundaryInterval, initialDate, numOfFutureIntervals_Desired);
        }
    }
}