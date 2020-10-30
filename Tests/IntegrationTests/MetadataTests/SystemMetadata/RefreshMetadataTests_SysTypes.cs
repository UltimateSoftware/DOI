using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SysTypesHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class RefreshMetadataTests_SysTypes : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.CreateUserDefinedTypeSql, 30, true, DatabaseName);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.DropUserDefinedTypeSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
        }

        [Test]
        public void RefreshMetadata_SysTypes_MetadataIsAccurate()
        {
            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTypesSql);

            //and now they should match
            TestHelper.AssertMetadata();
        }
    }
}
