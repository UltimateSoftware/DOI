using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.IndexesHelper;
using NUnit.Framework;
using NUnit.Framework.Internal;

namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class RefreshMetadataTests_Indexes : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
            sqlHelper.Execute(TestHelper.CreateSchemaSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSQl);

        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropIndexSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.DropTableSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.DropSchemaSql, 30, true, "DOIUnitTests");
        }
        [TestCase(true, TestName = "RefreshMetadata_SysIndexes_MetadataIsAccurate_EmptyTable")]
        [TestCase(false, TestName = "RefreshMetadata_SysIndexes_MetadataIsAccurate_NonEmptyTable")]
        [Test]
        public void RefreshMetadata_SysIndexes_MetadataIsAccurate(bool emptyTable)
        {
            if (!emptyTable)
            {
                sqlHelper.Execute(TestHelper.InsertOneRowIntoTableSql);
            }

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //and now they should match
            TestHelper.AssertSysMetadata();
            TestHelper.AssertUserMetadata();
        }

        //test also index with included columns, LOB columns.
    }
}
