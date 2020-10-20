using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SysAllocationUnitsHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class RefreshMetadataTests_SysAllocationUnits : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute($"EXEC [Utility].[spDeleteAllMetadataFromDatabase] @DatabaseName = '{DatabaseName}'");
            sqlHelper.Execute(TestHelper.CreateTableSql);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute($"EXEC [Utility].[spDeleteAllMetadataFromDatabase] @DatabaseName = '{DatabaseName}'");
        }

        [Test]
        public void RefreshMetadata_SysAllocationUnits_MetadataIsAccurate()
        {
            //assert that sql server DMV does not match SysAllocationUnits table.
            TestHelper.AssertSysAllocationUnitsMetadata();

            //run refresh metadata
            sqlHelper.Execute(TestHelper.SysAllocationUnits_RefreshMetadata);

            //and now they should match
            TestHelper.AssertSysAllocationUnitsMetadata();
        }
    }
}