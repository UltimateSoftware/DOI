using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.IndexPartitionsHelper;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using NUnit.Framework;
using NUnit.Framework.Internal;

namespace DOI.Tests.IntegrationTests.MetadataTests
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class RefreshMetadataTests_IndexPartitions : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
            sqlHelper.Execute(TestHelper.CreateFilegroupSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateFilegroup2Sql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateDatabaseFiles_PartitionedSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlyMetadataSql);
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionSchemeYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionedTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionedTableMetadataSql);
            sqlHelper.Execute(TestHelper.InsertOneRowIntoEachPartitionSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionedIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionedIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreatePartitionedColumnStoreIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionedColumnStoreIndexMetadataSql);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropPartitionedTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropDatabaseFiles_PartitionedSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropFilegroup2Sql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropFilegroupSql, 30, true, DatabaseName);
        }

        [Test]
        public void RefreshMetadata_IndexPartitions_RowStore_Inserts()
        {
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysIndexesPartitionsSql);

            //assert that the partitions inserted into IndexPartitions_RowStore are what we expect.
            TestHelper.AssertUserMetadata_RowStore();
        }

        [Test]
        public void RefreshMetadata_IndexPartitions_ColumnStore_Inserts()
        {
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysIndexesPartitionsSql);

            //assert that the partitions inserted into IndexPartitions_ColumnStore are what we expect.
            TestHelper.AssertUserMetadata_ColumnStore();
        }
    }
}
