using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.IntegrationTests.Models;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.IndexPartitionsHelper;
using PfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionsHelper;
using PsTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionSchemesHelper;
using FgTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_FileGroupsHelper;
using DbfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_DBFilesHelper;
using NUnit.Framework;
using NUnit.Framework.Internal;

namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class RefreshMetadataTests_IndexPartitions : DOIBaseTest
    {
        FgTestHelper fgTestHelper = new FgTestHelper();
        DbfTestHelper dbfTestHelper = new DbfTestHelper();
        PfTestHelper pfTestHelper = new PfTestHelper();
        PsTestHelper psTestHelper = new PsTestHelper();

        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
            sqlHelper.Execute(TestHelper.CreateSchemaSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateCIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateNCCIIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCCIIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropNCCIIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropSchemaSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropFilegroup2Sql);
        }
        [TestCase(true, TestName = "RefreshMetadata_SysIndexes_RowStore_MetadataIsAccurate_EmptyTable")]
        [TestCase(false, TestName = "RefreshMetadata_SysIndexes_RowStore_MetadataIsAccurate_NonEmptyTable")]
        [Test]
        public void RefreshMetadata_SysIndexPartitions_RowStore_MetadataIsAccurate(bool emptyTable)
        {
            if (!emptyTable)
            {
                sqlHelper.Execute(TestHelper.InsertOneRowIntoTableSql, 30, true, DatabaseName);
            }

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesPartitionsSql);

            //and now they should match
            TestHelper.AssertSysMetadata();
            TestHelper.AssertUserMetadata_RowStore();
        }

        [TestCase(true, 0, 0, 0.00, TestName = "RefreshMetadata_SysIndexes_ColumnStore_MetadataIsAccurate_EmptyTable")]
        [TestCase(false, 9, 1, 0.07, TestName = "RefreshMetadata_SysIndexes_ColumnStore_MetadataIsAccurate_NonEmptyTable")]
        [Test]
        public void RefreshMetadata_SysIndexPartitions_ColumnStore_MetadataIsAccurate(bool emptyTable, int expectedNumPages, int expectedNumRows, decimal expectedIndexSizeMB)
        {
            if (!emptyTable)
            {
                sqlHelper.Execute(TestHelper.InsertOneRowIntoTableSql, 30, true, DatabaseName);
            }

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesPartitionsSql);

            //and now they should match
            TestHelper.AssertSysMetadata();
            TestHelper.AssertUserMetadata_ColumnStore(expectedNumPages, expectedNumRows, expectedIndexSizeMB);
        }
    }
}
