using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SysPartitionFunctionsHelper;
using TablePartitioning = DOI.Tests.IntegrationTests.TablePartitioning;
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
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionMetadataSql);
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionSql, 30, true, DatabaseName);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionSql, 30, true, DatabaseName);
        }

        [Test]
        public void RefreshMetadata_SysPartitionFunctions_MetadataIsAccurate()
        {
            //run refresh metadata
            
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysPartitionFunctionsSql);

            //and now they should match
            TestHelper.AssertSysMetadata();

            TestHelper.AssertUserMetadata();
        }
    }
}
