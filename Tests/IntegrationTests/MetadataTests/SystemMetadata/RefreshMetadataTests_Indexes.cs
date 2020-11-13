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
            sqlHelper.Execute(TestHelper.CreateSchemaSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateColumnStoreIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateColumnStoreIndexMetadataSql);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropColumnStoreIndex, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropSchemaSql, 30, true, DatabaseName);
        }
        [TestCase(true, TestName = "RefreshMetadata_SysIndexes_RowStore_MetadataIsAccurate_EmptyTable")]
        [TestCase(false, TestName = "RefreshMetadata_SysIndexes_RowStore_MetadataIsAccurate_NonEmptyTable")]
        [Test]
        public void RefreshMetadata_SysIndexes_RowStore_MetadataIsAccurate(bool emptyTable)
        {
            if (!emptyTable)
            {
                sqlHelper.Execute(TestHelper.InsertOneRowIntoTableSql, 30, true, DatabaseName);
            }

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //and now they should match
            TestHelper.AssertSysMetadata();
            TestHelper.AssertUserMetadata_RowStore();
        }

        [TestCase(true, 0, 0, 0.00, TestName = "RefreshMetadata_SysIndexes_ColumnStore_MetadataIsAccurate_EmptyTable")]
        [TestCase(false, 9, 1, 0.07, TestName = "RefreshMetadata_SysIndexes_ColumnStore_MetadataIsAccurate_NonEmptyTable")]
        [Test]
        public void RefreshMetadata_SysIndexes_ColumnStore_MetadataIsAccurate(bool emptyTable, int expectedNumPages, int expectedNumRows, decimal expectedIndexSizeMB)
        {
            if (!emptyTable)
            {
                sqlHelper.Execute(TestHelper.InsertOneRowIntoTableSql, 30, true, DatabaseName);
            }

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //and now they should match
            TestHelper.AssertSysMetadata();
            TestHelper.AssertUserMetadata_ColumnStore(expectedNumPages, expectedNumRows, expectedIndexSizeMB);
        }

        //test also index with included columns, LOB columns.
        //test index partition metadata insert.
    }
}
