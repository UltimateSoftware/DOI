using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SysPartitionFunctionsHelper;
using TablePartitioning = DOI.Tests.IntegrationTests.RunTests.TablePartitioning;
using NUnit.Framework;


namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class RefreshMetadataTests_SysPartitionFunctions : DOIBaseTest
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

        [TestCase("Yearly", TestName = "RefreshMetadata_SysPartitionFunctions_MetadataIsAccurate_Yearly")]
        [TestCase("Monthly", TestName = "RefreshMetadata_SysPartitionFunctions_MetadataIsAccurate_Monthly")]
        [Test]
        public void RefreshMetadata_SysPartitionFunctions_MetadataIsAccurate(string boundaryInterval)
        {
            string partitionFunctionName = string.Concat("pfTests", boundaryInterval);

            if (boundaryInterval == "Yearly")
            {
                sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlyMetadataSql);
                sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlySql, 30, true, DatabaseName);
            }
            else if (boundaryInterval == "Monthly")
            {
                sqlHelper.Execute(TestHelper.CreatePartitionFunctionMonthlyMetadataSql);
                sqlHelper.Execute(TestHelper.CreatePartitionFunctionMonthlySql, 30, true, DatabaseName);
            }
            
            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);

            //and now they should match
            TestHelper.AssertSysMetadata(partitionFunctionName);

            TestHelper.AssertUserMetadata(partitionFunctionName);
        }
    }
}
