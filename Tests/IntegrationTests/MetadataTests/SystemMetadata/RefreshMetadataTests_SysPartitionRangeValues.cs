using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SysPartitionRangeValuesHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    class RefreshMetadataTests_SysPartitionRangeValues : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlySql, 30, true, DatabaseName);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
        }

        [Test]
        public void RefreshMetadata_SysPartitionFunctions_MetadataIsAccurate()
        {
            //run refresh metadata

            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);

            //and now they should match
            TestHelper.AssertMetadata();
        }
    }
}
