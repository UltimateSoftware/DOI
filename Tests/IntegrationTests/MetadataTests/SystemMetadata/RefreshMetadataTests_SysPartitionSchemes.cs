using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SysPartitionSchemesHelper;
using NUnit.Framework;


namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class RefreshMetadataTests_SysPartitionSchemes : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.CreateFilegroupSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateFilegroup2Sql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionSchemeSql, 30, true, DatabaseName);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropFilegroupSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropFilegroup2Sql, 30, true, DatabaseName);
        }

        [Test]
        public void RefreshMetadata_SysPartitionSchemes_MetadataIsAccurate()
        {
            //run refresh metadata

            sqlHelper.Execute(TestHelper.RefreshMetadata_SysPartitionSchemesSql);

            //and now they should match
            TestHelper.AssertMetadata();
        }
    }
}
