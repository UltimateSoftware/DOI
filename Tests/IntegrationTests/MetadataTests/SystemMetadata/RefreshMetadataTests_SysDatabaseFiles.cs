using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SysDatabaseFilesHelper;
using NUnit.Framework;


namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class RefreshMetadataTests_SysDatabaseFiles : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.CreateDatabaseFileSql, 30, true, DatabaseName);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropDatabaseFileSql, 30, true, DatabaseName);
        }

        [Test]
        public void RefreshMetadata_SysDatabaseFiles_MetadataIsAccurate()
        {
            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabaseFilesSql);

            //and now they should match
            TestHelper.AssertMetadata();
        }
    }
}
