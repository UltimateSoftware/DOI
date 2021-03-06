using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SysCheckConstraintsHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class RefreshMetadataTests_SysCheckConstraints : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.CreateCheckConstraintSql, 30, true, "DOIUnitTests");
            
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropCheckConstraintSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.DropTableSql, 30, true, "DOIUnitTests");
        }

        [Test]
        public void RefreshMetadata_SysCheckConstraints_MetadataIsAccurate()
        {
            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysCheckConstraintsSql);

            //and now they should match
            TestHelper.AssertMetadata();
        }
    }
}
