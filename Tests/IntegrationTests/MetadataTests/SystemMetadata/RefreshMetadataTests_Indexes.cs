using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.IntegrationTests.Models;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.IndexesHelper;
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
    public class RefreshMetadataTests_Indexes : DOIBaseTest
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

        #region PartitioningMetadata Tests

        [TestCase("pfTestsYearly", "CDX_TempA", TestName = "PartitioningUserMetadata_RowStore_Clustered_Yearly")]
        [TestCase("pfTestsYearly", "IDX_TempA", TestName = "PartitioningUserMetadata_RowStore_NonClustered_Yearly")]
        [TestCase("pfTestsYearly", "PK_TempA", TestName = "PartitioningUserMetadata_RowStore_PK_Yearly")]
        [TestCase("pfTestsMonthly", "CDX_TempA", TestName = "PartitioningUserMetadata_RowStore_Clustered_Monthly")]
        [TestCase("pfTestsMonthly", "IDX_TempA", TestName = "PartitioningUserMetadata_RowStore_NonClustered_Monthly")]
        [TestCase("pfTestsMonthly", "PK_TempA", TestName = "PartitioningUserMetadata_RowStore_PK_Monthly")]
        [Test]
        public void PartitioningUserMetadata_RowStore(string partitionFunctionName, string indexName)
        {
            TestHelper.CreatePartitioningContainerObjects(partitionFunctionName);

            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);

            //update metadata to partition the table and indexes
            TestHelper.UpdateTableMetadataForPartitioning(TestTableName1, partitionFunctionName, TestHelper.PartitionColumnName, indexName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesPartitionsSql);

            //and now they should match
            TestHelper.AssertUserMetadata_Partitioning_RowStore(partitionFunctionName, indexName);
        }



        [TestCase("pfTestsYearly", "CCI_TempA", TestName = "PartitioningUserMetadata_ColumnStore_Clustered_Yearly")]
        [TestCase("pfTestsYearly", "NCCI_TempA", TestName = "PartitioningUserMetadata_ColumnStore_NonClustered_Yearly")]
        [TestCase("pfTestsMonthly", "CCI_TempA", TestName = "PartitioningUserMetadata_ColumnStore_Clustered_Monthly")]
        [TestCase("pfTestsMonthly", "NCCI_TempA", TestName = "PartitioningUserMetadata_ColumnStore_NonClustered_Monthly")]
        [Test]
        public void PartitioningUserMetadata_ColumnStore(string partitionFunctionName, string indexName)
        {
            if (indexName == TestHelper.CCIIndexName)
            {
                TestHelper.ReclusterTableWithColumnStore(indexName);
            }

            TestHelper.CreatePartitioningContainerObjects(partitionFunctionName);

            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);
            
            //update metadata to partition the table and indexes
            TestHelper.UpdateTableMetadataForPartitioning(TestTableName1, partitionFunctionName, TestHelper.PartitionColumnName, indexName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesPartitionsSql);

            //and now they should match
            TestHelper.AssertUserMetadata_Partitioning_ColumnStore(partitionFunctionName, indexName);
        }


        #endregion

        #region IndexIsMissing Tests
        //update index, and make sure the change bit was set correctly.
        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_IndexIsMissing_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_IndexIsMissing_RowStore_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_IndexIsMissing_RowStore_PK")]

        public void IndexUpdateTests_IndexIsMissing_RowStore(string databaseName, string tableName, string indexName)
        {
            string dropIndexSql = string.Empty;
            string createIndexSql = string.Empty;


            switch (indexName)
            {
                case TestHelper.CIndexName:
                    dropIndexSql = TestHelper.DropCIndexSql;
                    createIndexSql = TestHelper.CreateCIndexSql;
                    break;
                case TestHelper.NCIndexName:
                    dropIndexSql = TestHelper.DropNCIndexSql;
                    createIndexSql = TestHelper.CreateNCIndexSql;
                    break;
                case TestHelper.PKIndexName:
                    dropIndexSql = TestHelper.DropPKIndexSql;
                    createIndexSql = TestHelper.CreatePKIndexSql;
                    break;
            }

            //drop index
            sqlHelper.Execute(dropIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            // Assert that index is missing, then add index, then assert that index is no longer missing.
            var indexIsMissingInMetadataTable = sqlHelper.ExecuteScalar<bool>(
                $"SELECT IsIndexMissingFromSQLServer FROM DOI.IndexesRowStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            var indexIsMissingInSqlServer = sqlHelper.ExecuteScalar<string>($"SELECT i.name FROM sys.indexes i INNER JOIN sys.tables t ON t.object_id = i.object_id INNER JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'dbo' AND t.name = '{tableName}' AND i.name = '{indexName}'", 30, true, databaseName);

            Assert.AreEqual(true, indexIsMissingInMetadataTable, "IndexIsMissingInMetadataBeforeItIsCreated");
            Assert.IsNull(indexIsMissingInSqlServer, "IndexIsMissingInSqlServerBeforeItIsCreated");

            //create index
            sqlHelper.Execute(createIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            // Assert that index is no longer missing.
            indexIsMissingInMetadataTable = sqlHelper.ExecuteScalar<bool>(
                $"SELECT IsIndexMissingFromSQLServer FROM DOI.IndexesRowStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            indexIsMissingInSqlServer = sqlHelper.ExecuteScalar<string>($"SELECT i.name FROM sys.indexes i INNER JOIN sys.tables t ON t.object_id = i.object_id INNER JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'dbo' AND t.name = '{tableName}' AND i.name = '{indexName}'", 30, true, databaseName);

            Assert.AreEqual(false, indexIsMissingInMetadataTable, "IndexIsNotMissingInMetadataAfterItIsCreated");
            Assert.AreEqual(indexName, indexIsMissingInSqlServer, "IndexIsNotMissingInSqlServerAfterItIsCreated");

            //Assert vwTables isIndexMissingFlag
        }

        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_IndexIsMissing_ColumnStore_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_IndexIsMissing_ColumnStore_Clustered")]

        public void IndexUpdateTests_IndexIsMissing_ColumnStore(string databaseName, string tableName, string indexName)
        {
            string dropIndexSql = string.Empty;
            string createIndexSql = string.Empty;


            switch (indexName)
            {
                case TestHelper.CCIIndexName:
                    
                    dropIndexSql = string.Concat(TestHelper.DropCIndexSql, ";", TestHelper.DropCCIIndexSql);
                    sqlHelper.Execute(TestHelper.CreateCCIIndexMetadataSql);
                    createIndexSql = TestHelper.CreateCCIIndexSql;
                    sqlHelper.Execute(TestHelper.DropNCCIIndexSql, 30, true, DatabaseName);
                    break;
                case TestHelper.NCCIIndexName:
                    dropIndexSql = TestHelper.DropNCCIIndexSql;
                    createIndexSql = TestHelper.CreateNCCIIndexSql;
                    break;
            }

            //drop index
            sqlHelper.Execute(dropIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            // Assert that index is missing, then add index, then assert that index is no longer missing.
            var indexIsMissingInMetadataTable = sqlHelper.ExecuteScalar<bool>(
                $"SELECT IsIndexMissingFromSQLServer FROM DOI.IndexesColumnStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            var indexIsMissingInSqlServer = sqlHelper.ExecuteScalar<string>($"SELECT i.name FROM sys.indexes i INNER JOIN sys.tables t ON t.object_id = i.object_id INNER JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'dbo' AND t.name = '{tableName}' AND i.name = '{indexName}'", 30, true, databaseName);

            Assert.AreEqual(true, indexIsMissingInMetadataTable, "IndexIsMissingInMetadataBeforeItIsCreated");
            Assert.IsNull(indexIsMissingInSqlServer, "IndexIsMissingInSqlServerBeforeItIsCreated");

            //create index
            sqlHelper.Execute(createIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            // Assert that index is no longer missing.
            indexIsMissingInMetadataTable = sqlHelper.ExecuteScalar<bool>(
                $"SELECT IsIndexMissingFromSQLServer FROM DOI.IndexesRowStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            indexIsMissingInSqlServer = sqlHelper.ExecuteScalar<string>($"SELECT i.name FROM sys.indexes i INNER JOIN sys.tables t ON t.object_id = i.object_id INNER JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'dbo' AND t.name = '{tableName}' AND i.name = '{indexName}'", 30, true, databaseName);

            Assert.AreEqual(false, indexIsMissingInMetadataTable, "IndexIsNotMissingInMetadataAfterItIsCreated");
            Assert.AreEqual(indexName, indexIsMissingInSqlServer, "IndexIsNotMissingInSqlServerAfterItIsCreated");

            //Assert vwTables isIndexMissingFlag
        }
        #endregion

        #region IndexNumRows Tests
        //nonfiltered
        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_IndexNumRows_RowStore_Unfiltered_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_IndexNumRows_RowStore_Unfiltered_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_IndexNumRows_RowStore_Unfiltered_PK")]
        public void IndexUpdateTests_IndexNumRows_RowStore_Unfiltered(string databaseName, string tableName, string indexName)
        {
            // Assert that index has 0 rows
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            var indexRowCount = sqlHelper.ExecuteScalar<long>(
                $"SELECT NumRows_Actual FROM DOI.IndexesRowStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.AreEqual(0, indexRowCount, "IndexNumRowsShouldBeZero");

            //add data
            var tempaId = Guid.NewGuid();
            sqlHelper.Execute($@"INSERT INTO dbo.{tableName} VALUES ('{tempaId}', SYSDATETIME(), 'TEST', 'TEST')", 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            // Assert NumRows is updated correctly.
            indexRowCount = sqlHelper.ExecuteScalar<long>(
                $"SELECT NumRows_Actual FROM DOI.IndexesRowStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.AreEqual(1, indexRowCount, "IndexNumRowsShouldBe1");
        }

        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_IndexNumRows_ColumnStore_Filtered_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_IndexNumRows_ColumnStore_Filtered_NonClustered")]
        public void IndexUpdateTests_IndexNumRows_ColumnStore_Unfiltered(string databaseName, string tableName, string indexName)
        {
            if (indexName == "CCI_TempA")
            {
                sqlHelper.Execute(TestHelper.DropCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.DropNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateCCIIndexMetadataSql);
                sqlHelper.Execute(TestHelper.CreateCCIIndexSql, 30, true, DatabaseName);
            }

            // Assert that index has 0 rows
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            var indexRowCount = sqlHelper.ExecuteScalar<long>(
                $"SELECT NumRows_Actual FROM DOI.IndexesColumnStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.AreEqual(0, indexRowCount, "IndexNumRowsShouldBeZero");

            //add data
            var tempaId = Guid.NewGuid();
            sqlHelper.Execute($@"INSERT INTO dbo.{tableName} VALUES ('{tempaId}', SYSDATETIME(), 'TEST', 'TEST')", 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            // Assert NumRows is updated correctly.
            indexRowCount = sqlHelper.ExecuteScalar<long>(
                $"SELECT NumRows_Actual FROM DOI.IndexesColumnStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.AreEqual(1, indexRowCount, "IndexNumRowsShouldBe1");
        }

        //filtered
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_IndexNumRows_RowStore_Filtered")]
        public void IndexUpdateTests_IndexNumRows_RowStore_Filtered(string databaseName, string tableName, string indexName)
        {
            //set up filter metadata
            var filterSql = $"TempAId <> ''{Guid.Empty}'";
            sqlHelper.Execute($@"
                UPDATE DOI.IndexesRowStore 
                SET IsFiltered_Desired = 1, 
                    FilterPredicate_Desired = '{filterSql}''
                WHERE DatabaseName = '{DatabaseName}' 
                    AND TableName = '{tableName}' 
                    AND IndexName = '{indexName}'");


            sqlHelper.Execute(TestHelper.DropNCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateFilteredNCIndexSql, 30, true, DatabaseName);

            // Assert that index has 0 rows
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            var indexRowCount = sqlHelper.ExecuteScalar<long>(
                $"SELECT NumRows_Actual FROM DOI.IndexesRowStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.AreEqual(0, indexRowCount, "IndexNumRowsShouldBeZero");

            //add data, 1 row that passes the filter and one that doesn't
            var tempaId = Guid.NewGuid();
            sqlHelper.Execute($@"INSERT INTO dbo.{tableName} VALUES ('{tempaId}', SYSDATETIME(), 'TEST', 'TEST')", 30, true, DatabaseName);
            sqlHelper.Execute($@"INSERT INTO dbo.{tableName} VALUES ('{Guid.Empty}', SYSDATETIME(), 'TEST', 'TEST')", 30, true, DatabaseName);

            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            // Assert NumRows is updated correctly.
            indexRowCount = sqlHelper.ExecuteScalar<long>(
                $"SELECT NumRows_Actual FROM DOI.IndexesRowStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.AreEqual(1, indexRowCount, "IndexNumRowsShouldBe1");
        }

        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_IndexNumRows_ColumnStore_Filtered_NonClustered")]
        public void IndexUpdateTests_IndexNumRows_ColumnStore_Filtered(string databaseName, string tableName, string indexName)
        {
            //set up filter metadata
            var filterSql = $"TempAId <> ''{Guid.Empty}'";
            sqlHelper.Execute($@"
                UPDATE DOI.IndexesColumnStore 
                SET IsFiltered_Desired = 1, 
                    FilterPredicate_Desired = '{filterSql}''
                WHERE DatabaseName = '{DatabaseName}' 
                    AND TableName = '{tableName}' 
                    AND IndexName = '{indexName}'");


            sqlHelper.Execute(TestHelper.DropNCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateFilteredNCIndexSql, 30, true, DatabaseName);

            // Assert that index has 0 rows
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            var indexRowCount = sqlHelper.ExecuteScalar<long>(
                $"SELECT NumRows_Actual FROM DOI.IndexesColumnStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.AreEqual(0, indexRowCount, "IndexNumRowsShouldBeZero");

            //add data, 1 row that passes the filter and one that doesn't
            var tempaId = Guid.NewGuid();
            sqlHelper.Execute($@"INSERT INTO dbo.{tableName} VALUES ('{tempaId}', SYSDATETIME(), 'TEST', 'TEST')", 30, true, DatabaseName);
            sqlHelper.Execute($@"INSERT INTO dbo.{tableName} VALUES ('{Guid.Empty}', SYSDATETIME(), 'TEST', 'TEST')", 30, true, DatabaseName);

            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            // Assert NumRows is updated correctly.
            indexRowCount = sqlHelper.ExecuteScalar<long>(
                $"SELECT NumRows_Actual FROM DOI.IndexesColumnStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.AreEqual(1, indexRowCount, "IndexNumRowsShouldBe1");
        }
        #endregion

        #region IndexSizing Tests
        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_IndexSizing_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_IndexSizing_RowStore_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_IndexSizing_RowStore_PK")]
        public void IndexUpdateTests_IndexSizing_RowStore(string databaseName, string tableName, string indexName)
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //assert that the size is 0.
            var indexSizeMB = sqlHelper.ExecuteScalar<decimal>(
                $"SELECT IndexSizeMB_Actual FROM DOI.IndexesRowStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.AreEqual(0, indexSizeMB, "IndexWithNoDataHas0Size");
            //add 1 row of data
            sqlHelper.Execute(TestHelper.InsertOneRowIntoTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //assert size > 0
            indexSizeMB = sqlHelper.ExecuteScalar<decimal>(
                $"SELECT IndexSizeMB_Actual FROM DOI.IndexesRowStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.Greater(indexSizeMB, 0, "IndexWithDataHasSizeGreaterThan0");
        }

        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_IndexSizing_ColumnStore_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_IndexSizing_ColumnStore_Clustered")]
        public void IndexUpdateTests_IndexSizing_ColumnStore(string databaseName, string tableName, string indexName)
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);
            
            //assert that the size is 0.
            var indexSizeMB = sqlHelper.ExecuteScalar<decimal>(
                $"SELECT IndexSizeMB_Actual FROM DOI.IndexesColumnStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.AreEqual(0, indexSizeMB, "IndexWithNoDataHas0Size");
            //add 1 row of data
            sqlHelper.Execute(TestHelper.InsertOneRowIntoTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //assert size > 0
            indexSizeMB = sqlHelper.ExecuteScalar<decimal>(
                    $"SELECT IndexSizeMB_Actual FROM DOI.IndexesColumnStore WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");

            Assert.Greater(indexSizeMB, 0, "IndexWithDataHasSizeGreaterThan0");
        }


        #endregion

        #region IndexFragmentation Tests



        //Assert vwTables AreIndexesFragmented flag.
        #endregion

        #region ChangeBits Tests
        //update index, and make sure the change bit was set correctly.
        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_AllowPageLocksChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_AllowPageLocksChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_AllowPageLocksChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_AllowPageLocksChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionAllowPageLocks_Desired = 0 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsAllowPageLocksChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_AllowRowLocksChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_AllowRowLocksChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_AllowRowLocksChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_AllowRowLocksChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionAllowRowLocks_Desired = 0 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsAllowRowLocksChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_IsClusteredChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_IsClusteredChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_IsClusteredChanging_RowStore_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_ChangeBits_IsClusteredChanging_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_ChangeBits_IsClusteredChanging_ColumnStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IsClusteredChanging(string databaseName, string tableName, string indexName)
        {
            var isClusteredSetting = (indexName == TestHelper.CIndexName || indexName == TestHelper.CCIIndexName)? "0" : "1";

            TestHelper.ReclusterTableWithColumnStore(indexName);

            //all change bits should be off
            if (indexName == TestHelper.CCIIndexName || indexName == TestHelper.NCCIIndexName)
            {
                TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Pre");
                sqlHelper.Execute($"UPDATE DOI.IndexesColumnStore SET IsClustered_Desired = {isClusteredSetting}, ColumnList_Desired = NULL WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }
            else
            {
                TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET IsClustered_Desired = {isClusteredSetting} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            if (indexName == TestHelper.CCIIndexName || indexName == TestHelper.NCCIIndexName)
            {
                TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Post", "IsClusteredChanging");
            }
            else
            {
                TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsClusteredChanging");
            }
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_DataCompressionChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_DataCompressionChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_DataCompressionChanging_RowStore_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_ChangeBits_DataCompressionChanging_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_ChangeBits_DataCompressionChanging_ColumnStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_DataCompressionChanging(string databaseName, string tableName, string indexName)
        {
            TestHelper.ReclusterTableWithColumnStore(indexName);

            //all change bits should be off
            if (indexName == TestHelper.CCIIndexName || indexName == TestHelper.NCCIIndexName)
            {
                TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Pre");
                sqlHelper.Execute($"UPDATE DOI.IndexesColumnStore SET OptionDataCompression_Desired = 'COLUMNSTORE_ARCHIVE' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }
            else
            {
                TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionDataCompression_Desired = 'NONE' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            if (indexName == TestHelper.CCIIndexName || indexName == TestHelper.NCCIIndexName)
            {
                TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Post", "IsDataCompressionChanging");
            }
            else
            {
                TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsDataCompressionChanging");
            }
        }

        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_ChangeBits_DataCompressionDelayChanging_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_ChangeBits_DataCompressionDelayChanging_ColumnStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_DataCompressionDelayChanging(string databaseName, string tableName, string indexName)
        {
            TestHelper.ReclusterTableWithColumnStore(indexName);

            //all change bits should be off
            TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesColumnStore SET OptionDataCompressionDelay_Desired = 10 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Post", "IsDataCompressionDelayChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_FillFactorChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_FillFactorChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_FillFactorChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_FillFactorChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");


            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET FillFactor_Desired = 50 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsFillfactorChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_FilterChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_FilterChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_FilterChanging_RowStore_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_ChangeBits_FilterChanging_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_ChangeBits_FilterChanging_ColumnStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_FilterChanging(string databaseName, string tableName, string indexName)
        {
            TestHelper.ReclusterTableWithColumnStore(indexName);

            var updateSql = string.Empty;

            //all change bits should be off
            if (indexName == TestHelper.CCIIndexName || indexName == TestHelper.NCCIIndexName)
            {
                TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Pre");
                updateSql = $"UPDATE DOI.IndexesColumnStore SET IsFiltered_Desired = 1, FilterPredicate_Desired = 'TransactionUtcDt > SYSDATETIME()' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'";
            }
            else
            {
                TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");
                updateSql = $"UPDATE DOI.IndexesRowStore SET IsFiltered_Desired = 1, FilterPredicate_Desired = 'TransactionUtcDt > SYSDATETIME()' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'";
            }

            if (indexName == "PK_TempA" || indexName == TestHelper.CIndexName) //PK or Clustered indexes can't have filters.
            {
                Exception ex = Assert.Throws<SqlException>(() => sqlHelper.Execute(updateSql, 120));
                Assert.That(ex.Message, Is.EqualTo("The UPDATE statement conflicted with the CHECK constraint \"Chk_IndexesRowStore_Filter\". The conflict occurred in database \"DOI\", table \"DOI.IndexesRowStore\".\r\nThe statement has been terminated."));
            }
            else if (indexName == TestHelper.CCIIndexName) //PK or Clustered indexes can't have filters.
            {
                Exception ex = Assert.Throws<SqlException>(() => sqlHelper.Execute(updateSql, 120));
                Assert.That(ex.Message, Is.EqualTo("The UPDATE statement conflicted with the CHECK constraint \"Chk_IndexesColumnStore_Filter\". The conflict occurred in database \"DOI\", table \"DOI.IndexesColumnStore\".\r\nThe statement has been terminated."));
            }


            if (indexName == TestHelper.NCIndexName)
            {
                sqlHelper.Execute(updateSql, 120);
                sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);
                //only the correct change bit should be turned on.  All others should still be off.
                TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsFilterChanging");
            }
            else if (indexName == TestHelper.NCCIIndexName)
            {
                sqlHelper.Execute(updateSql, 120);
                sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);
                //only the correct change bit should be turned on.  All others should still be off.
                TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Post", "IsFilterChanging");
            }
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_IgnoreDupKeyChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_IgnoreDupKeyChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_IgnoreDupKeyChanging_RowStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IgnoreDupKeyChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionIgnoreDupKey_Desired = 1 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsIgnoreDupKeyChanging");
        }


        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_IncludedColumnListChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_IncludedColumnListChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_IncludedColumnListChanging_RowStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IncludedColumnListChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            var updateSql = $"UPDATE DOI.IndexesRowStore SET IncludedColumnList_Desired = 'IncludedColumn' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'";

            if (indexName == "PK_TempA" || indexName == TestHelper.CIndexName) //PK or Clustered indexes can't have filters.
            {
                Exception ex = Assert.Throws<SqlException>(() => sqlHelper.Execute(updateSql, 120));
                Assert.That(ex.Message, Is.EqualTo("The UPDATE statement conflicted with the CHECK constraint \"Chk_IndexesRowStore_IncludedColumnsNotAllowed\". The conflict occurred in database \"DOI\", table \"DOI.IndexesRowStore\".\r\nThe statement has been terminated."));
            }
            else
            {
                sqlHelper.Execute(updateSql, 120);
                sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

                //only the correct change bit should be turned on.  All others should still be off.
                TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsIncludedColumnListChanging");
            }
        }

        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_ChangeBits_ColumnListChanging_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_ChangeBits_ColumnListChanging_ColumnStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_ColumnListChanging(string databaseName, string tableName, string indexName)
        {
            TestHelper.ReclusterTableWithColumnStore(indexName);

            //all change bits should be off
            TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Pre");

            var updateSql = $"UPDATE DOI.IndexesColumnStore SET ColumnList_Desired = 'IncludedColumn' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'";

            if (indexName == TestHelper.CCIIndexName) //CCIs must have all columns in them, so this column is not updatable.
            {
                Exception ex = Assert.Throws<SqlException>(() => sqlHelper.Execute(updateSql, 120));
                Assert.That(ex.Message, Is.EqualTo("The UPDATE statement conflicted with the CHECK constraint \"Chk_IndexesColumnStore_ClusteredColumnListIsNull\". The conflict occurred in database \"DOI\", table \"DOI.IndexesColumnStore\".\r\nThe statement has been terminated."));
            }
            else
            {
                sqlHelper.Execute(updateSql, 120);
                sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

                //only the correct change bit should be turned on.  All others should still be off.
                TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Post", "IsColumnListChanging");
            }
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyChanging_RowStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IsPrimaryKeyChanging(string databaseName, string tableName, string indexName)
        {
            var pkSetting = indexName == "PK_TempA" ? "0" : "1";

            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            var updateSql = $"UPDATE DOI.IndexesRowStore SET IsPrimaryKey_Desired = {pkSetting} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'";

            if (indexName != "PK_TempA") //PKs must be set to unique
            {
                Exception ex = Assert.Throws<SqlException>(() => sqlHelper.Execute(updateSql, 120));
                Assert.That(ex.Message, Is.EqualTo("The UPDATE statement conflicted with the CHECK constraint \"Chk_IndexesRowStore_PrimaryKeyIsUnique\". The conflict occurred in database \"DOI\", table \"DOI.IndexesRowStore\".\r\nThe statement has been terminated."));
            }
            else
            {
                sqlHelper.Execute(updateSql, 120);
                sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

                //only the correct change bit should be turned on.  All others should still be off.
                TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsPrimaryKeyChanging");
            }
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyAndIsUniqueChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyAndIsUniqueChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyAndIsUniqueChanging_RowStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IsPrimaryKeyAndIsUniqueChanging(string databaseName, string tableName, string indexName)
        {
            var setting = indexName == "PK_TempA" ? "0" : "1";

            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            var updateSql = $"UPDATE DOI.IndexesRowStore SET IsPrimaryKey_Desired = {setting}, IsUnique_Desired = {setting} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'";

            sqlHelper.Execute(updateSql, 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            var indexRow = TestHelper.GetActualUserValues_RowStore(indexName).Find(x => x.IndexName == indexName);

            //only the correct change bit should be turned on.  All others should still be off.
            Assert.AreEqual(false, indexRow.IsAllowPageLocksChanging, "IsAllowPageLocksChanging");
            Assert.AreEqual(false, indexRow.IsAllowRowLocksChanging, "IsAllowRowLocksChanging");
            Assert.AreEqual(false, indexRow.IsClusteredChanging, "IsClusteredChanging");
            Assert.AreEqual(false, indexRow.IsDataCompressionChanging, "IsDataCompressionChanging");
            Assert.AreEqual(false, indexRow.IsFillfactorChanging, "IsFillfactorChanging");
            Assert.AreEqual(false, indexRow.IsFilterChanging, "IsFilterChanging");
            Assert.AreEqual("None", indexRow.FragmentationType, "IndexFragmentation");
            Assert.AreEqual(false, indexRow.IsIgnoreDupKeyChanging, "IsIgnoreDupKeyChanging");
            Assert.AreEqual(false, indexRow.IsIncludedColumnListChanging, "IsIncludedColumnListChanging");
            Assert.AreEqual(true, indexRow.IsPrimaryKeyChanging, "IsPrimaryKeyChanging");
            Assert.AreEqual(false, indexRow.IsKeyColumnListChanging, "IsKeyColumnListChanging");
            Assert.AreEqual(false, indexRow.IsPadIndexChanging, "IsPadIndexChanging");
            Assert.AreEqual(false, indexRow.IsPartitioningChanging, "IsPartitioningChanging");
            Assert.AreEqual(false, indexRow.IsStatisticsNoRecomputeChanging, "IsStatisticsNoRecomputeChanging");
            Assert.AreEqual(false, indexRow.IsStatisticsIncrementalChanging, "IsStatisticsIncrementalChanging");
            Assert.AreEqual(true, indexRow.IsUniquenessChanging, "IsUniquenessChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_KeyColumnListChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_KeyColumnListChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_KeyColumnListChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_KeyColumnListChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET KeyColumnList_Desired = 'TempAId, TransactionUtcDt' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsKeyColumnListChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_PadIndexChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_PadIndexChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_PadIndexChanging_RowStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_PadIndexChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");


            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionPadIndex_Desired = 0 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsPadIndexChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_StatisticsNoRecomputeChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_StatisticsNoRecomputeChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_StatisticsNoRecomputeChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_StatisticsNoRecomputeChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");


            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionStatisticsNoRecompute_Desired = 1 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsStatisticsNoRecomputeChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_StatisticsIncrementalChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_StatisticsIncrementalChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_StatisticsIncrementalChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_StatisticsIncrementalChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionStatisticsIncremental_Desired = 1 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsStatisticsIncrementalChanging");
        }


        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_UniquenessChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_UniquenessChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_UniquenessChanging_RowStore_NonClustered")]

        //need negative assertion for the PK above, which fails with this error:  The UPDATE statement conflicted with the CHECK constraint "Chk_IndexesRowStore_PrimaryKeyIsUnique". The conflict occurred in database "DOI", table "DOI.IndexesRowStore".The statement has been terminated."
        public void IndexUpdateTests_ChangeBits_UniquenessChanging(string databaseName, string tableName, string indexName)
        {
            var isUniqueSetting = indexName == "PK_TempA" ? "0" : "1";

            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            var updateSql = $"UPDATE DOI.IndexesRowStore SET IsUnique_Desired = {isUniqueSetting} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'";

            if (indexName == "PK_TempA") //PKs must be set to unique
            {
                Exception ex = Assert.Throws<SqlException>(() => sqlHelper.Execute(updateSql, 120));
                Assert.That(ex.Message, Is.EqualTo("The UPDATE statement conflicted with the CHECK constraint \"Chk_IndexesRowStore_PrimaryKeyIsUnique\". The conflict occurred in database \"DOI\", table \"DOI.IndexesRowStore\".\r\nThe statement has been terminated."));
            }
            else
            {
                sqlHelper.Execute(updateSql, 120);
                sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsUniquenessChanging");
            }
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_StorageChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_StorageChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_StorageChanging_RowStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IsStorageChanging_RowStore(string databaseName, string tableName, string indexName)
        {
            sqlHelper.Execute(TestHelper.CreateFilegroup2Sql);

            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET Storage_Desired = '{TestHelper.Filegroup2Name}' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
 
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionedTablesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsStorageChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_ChangeBits_StorageChanging_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_ChangeBits_StorageChanging_ColumnStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IsStorageChanging_ColumnStore(string databaseName, string tableName, string indexName)
        {
            TestHelper.ReclusterTableWithColumnStore(indexName);
            sqlHelper.Execute(TestHelper.CreateFilegroup2Sql);

            //all change bits should be off
            TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesColumnStore SET Storage_Desired = '{TestHelper.Filegroup2Name}' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute($"UPDATE DOI.Tables SET Storage_Desired = '{TestHelper.Filegroup2Name}' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}'");
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionedTablesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Post", "IsStorageChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", TestName = "IndexUpdateTests_ChangeBits_PartitioningChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_PartitioningChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", TestName = "IndexUpdateTests_ChangeBits_PartitioningChanging_RowStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IsPartitioningChanging_RowStore(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            //create partition function
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlyMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);
            sqlHelper.Execute(pfTestHelper.GetPartitionFunctionSql(TestHelper.PartitionFunctionNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);

            //create all needed storage containers
            sqlHelper.Execute(fgTestHelper.GetFilegroupSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabaseFilesSql);

            //create partition scheme
            sqlHelper.Execute(psTestHelper.GetPartitionSchemeSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysPartitionSchemesSql);

            //action
            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET Storage_Desired = '{TestHelper.PartitionSchemeNameYearly}', PartitionFunction_Desired = '{TestHelper.PartitionFunctionNameYearly}', PartitionColumn_Desired = '{TestHelper.PartitionColumnName}' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute($"UPDATE DOI.Tables SET IntendToPartition = 1, PartitionFunctionName = '{TestHelper.PartitionFunctionNameYearly}', PartitionColumn = '{TestHelper.PartitionColumnName}' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsPartitioningChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_ChangeBits_PartitioningChanging_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_ChangeBits_PartitioningChanging_ColumnStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IsPartitioningChanging_ColumnStore(string databaseName, string tableName, string indexName)
        {
            TestHelper.ReclusterTableWithColumnStore(indexName);
            //all change bits should be off
            TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Pre");

            //create partition function
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlyMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);
            sqlHelper.Execute(pfTestHelper.GetPartitionFunctionSql(TestHelper.PartitionFunctionNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);

            //create all needed storage containers
            sqlHelper.Execute(fgTestHelper.GetFilegroupSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabaseFilesSql);

            //create partition scheme
            sqlHelper.Execute(psTestHelper.GetPartitionSchemeSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysPartitionSchemesSql);

            //action
            sqlHelper.Execute($"UPDATE DOI.IndexesColumnStore SET PartitionFunction_Desired = '{TestHelper.PartitionFunctionNameYearly}', PartitionColumn_Desired = '{TestHelper.PartitionColumnName}' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute($"UPDATE DOI.Tables SET IntendToPartition = 1, PartitionColumn = '{TestHelper.PartitionColumnName}', PartitionFunctionName = '{TestHelper.PartitionFunctionNameYearly}' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Post", "IsPartitioningChanging");
        }

        #endregion

        #region ChangeBitGroups Tests
        //different combinations of updates should set the 5 change bit groups correctly.
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "KeyColumnList_Desired = 'TempAId'", TestName = "IndexUpdateTests_ChangeBitGroups_DropRecreate_RowStore_KeyColumnList")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "IsUnique_Desired = 1", TestName = "IndexUpdateTests_ChangeBitGroups_DropRecreate_RowStore_IsUnique")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "IncludedColumnList_Desired = 'TempAId'", TestName = "IndexUpdateTests_ChangeBitGroups_DropRecreate_RowStore_IncludedColumnList")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "IsFiltered_Desired = 1, FilterPredicate_Desired = 'TransactionUtcDt > SYSDATETIME()'", TestName = "IndexUpdateTests_ChangeBitGroups_DropRecreate_RowStore_IsFiltered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "IsClustered_Desired = 1", TestName = "IndexUpdateTests_ChangeBitGroups_DropRecreate_RowStore_IsClustered")]
        //[TestCase("DOIUnitTests", "TempA", "IDX_TempA", "Storage_Desired = 'psTestsYearly', StorageType_Desired = 'PARTITION_SCHEME'", TestName = "IndexUpdateTests_ChangeBitGroups_DropRecreate_RowStore_Partitioning")]

        public void IndexUpdateTests_ChangeBitGroups_DropRecreate_RowStore(string databaseName, string tableName, string indexName, string optionUpdateList)
        {
            var indexRow = TestHelper.GetActualUserValues_RowStore(indexName).Find(x => x.IndexName == indexName);

            //assert that the BitGroup = false
            Assert.AreEqual(false, indexRow.AreDropRecreateOptionsChanging, "AreDropRecreateOptionsChanging, Pre-Change");

            //if partitioning is changing, update the partition flag on Tables.  NEED METHOD FOR THIS, TO SET UP ALL PARTITIONING OBJECTS.
            if (optionUpdateList.Contains("Storage_Desired"))
            {
                sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlySql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlyMetadataSql);
                sqlHelper.Execute(TestHelper.CreatePartitionSchemeYearlySql, 30, true, DatabaseName);

                sqlHelper.Execute($"UPDATE DOI.Tables SET IntendToPartition = 1, PartitionColumn = 'TransactionUtcDt', PartitionFunctionName = '{TestHelper.PartitionFunctionNameYearly}' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}'", 120);
                sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql);
            }

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            indexRow = TestHelper.GetActualUserValues_RowStore(indexName).Find(x => x.IndexName == indexName);

            //BitGroup should now = true
            Assert.AreEqual(true,  indexRow.AreDropRecreateOptionsChanging, "AreDropRecreateOptionsChanging, Post-Change");
        }

        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "ColumnList_Desired = 'TempAId'", TestName = "IndexUpdateTests_ChangeBitGroups_DropRecreate_ColumnStore_ColumnList")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "IsFiltered_Desired = 1, FilterPredicate_Desired = 'TransactionUtcDt > SYSDATETIME()'", TestName = "IndexUpdateTests_ChangeBitGroups_DropRecreate_ColumnStore_IsFiltered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "ColumnList_Desired = NULL, IsClustered_Desired = 1", TestName = "IndexUpdateTests_ChangeBitGroups_DropRecreate_ColumnStore_IsClustered")]
        //[TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "Storage_Desired = 'psTestsYearly', StorageType_Desired = 'PARTITION_SCHEME'", TestName = "IndexUpdateTests_ChangeBitGroups_DropRecreate_ColumnStore_Partitioning")]

        public void IndexUpdateTests_ChangeBitGroups_DropRecreate_ColumnStore(string databaseName, string tableName, string indexName, string optionUpdateList)
        {
            var indexRow = TestHelper.GetActualUserValues_ColumnStore(indexName).Find(x => x.IndexName == indexName);

            //assert that the BitGroup = false
            Assert.AreEqual(false, indexRow.AreDropRecreateOptionsChanging, "AreDropRecreateOptionsChanging, Pre-Change");

            sqlHelper.Execute($"UPDATE DOI.IndexesColumnStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            indexRow = TestHelper.GetActualUserValues_ColumnStore(indexName).Find(x => x.IndexName == indexName);

            //BitGroup should now = true
            Assert.AreEqual(true, indexRow.AreDropRecreateOptionsChanging, "AreDropRecreateOptionsChanging, Post-Change");
        }

        /*rebuilds = PadIndex, FillFactor, IgnoreDupKey, StatisticsNoRecompute, StatisticsIncremental, AllowRowLocks, AllowPageLocks, DataCompression,
            rebuild only = PadIndex, FillFactor, StatisticsIncremental, DataCompression
        WHAT ABOUT FRAG > 30%?
         THERE MAY BE AN ISSUE HERE BETWEEN 'REBUILD' AND 'REBUILD ONLY' OPTIONS IN vwIndexes.  I think the logic is wrong.*/
         [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionAllowPageLocks_Desired=0", TestName = "IndexUpdateTests_ChangeBitGroups_AlterRebuild_RowStore_OptionAllowPageLocks")]
         [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionAllowRowLocks_Desired=0", TestName = "IndexUpdateTests_ChangeBitGroups_AlterRebuild_RowStore_OptionAllowRowLocks")]
         [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionDataCompression_Desired='ROW'", TestName = "IndexUpdateTests_ChangeBitGroups_AlterRebuild_RowStore_OptionDataCompression")]
         [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionIgnoreDupKey_Desired=1", TestName = "IndexUpdateTests_ChangeBitGroups_AlterRebuild_RowStore_OptionIgnoreDupKey")]
         [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionPadIndex_Desired=0", TestName = "IndexUpdateTests_ChangeBitGroups_AlterRebuild_RowStore_OptionPadIndex")]
         [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionStatisticsNoRecompute_Desired=1", TestName = "IndexUpdateTests_ChangeBitGroups_AlterRebuild_RowStore_OptionStatisticsNoRecompute")]
         //[TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionStatisticsIncremental_Desired=0", TestName = "IndexUpdateTests_ChangeBitGroups_AlterRebuild_RowStore_OptionStatisticsIncremental")]
         [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "FillFactor_Desired=50", TestName = "IndexUpdateTests_ChangeBitGroups_AlterRebuild_RowStore_FillFactor_Desired")]
        public void IndexUpdateTests_ChangeBitGroups_AlterRebuild_RowStore(string databaseName, string tableName, string indexName, string optionUpdateList)
        {
            var indexRow = TestHelper.GetActualUserValues_RowStore(indexName).Find(x => x.IndexName == indexName);

            //assert that the BitGroup = false
            Assert.AreEqual(false, indexRow.AreRebuildOptionsChanging, "AreRebuildOptionsChanging, Pre-Change");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            indexRow = TestHelper.GetActualUserValues_RowStore(indexName).Find(x => x.IndexName == indexName);

            //BitGroup should now = true
            Assert.AreEqual(true, indexRow.AreRebuildOptionsChanging, "AreRebuildOptionsChanging, Post-Change");
        }

        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "OptionDataCompression_Desired='COLUMNSTORE_ARCHIVE'", TestName = "IndexUpdateTests_ChangeBitGroups_AlterRebuild_ColumnStore_OptionDataCompression")]
        public void IndexUpdateTests_ChangeBitGroups_AlterRebuild_ColumnStore(string databaseName, string tableName, string indexName, string optionUpdateList)
        {
            var indexRow = TestHelper.GetActualUserValues_ColumnStore(indexName).Find(x => x.IndexName == indexName);

            //assert that the BitGroup = false
            Assert.AreEqual(false, indexRow.AreRebuildOptionsChanging, "AreRebuildOptionsChanging, Pre-Change");

            sqlHelper.Execute($"UPDATE DOI.IndexesColumnStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            indexRow = TestHelper.GetActualUserValues_ColumnStore(indexName).Find(x => x.IndexName == indexName);

            //BitGroup should now = true
            Assert.AreEqual(true, indexRow.AreRebuildOptionsChanging, "AreRebuildOptionsChanging, Post-Change");
        }

        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionAllowRowLocks_Desired=0", TestName = "IndexUpdateTests_ChangeBitGroups_AlterSet_RowStore_OptionAllowRowLocks")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionAllowPageLocks_Desired=0", TestName = "IndexUpdateTests_ChangeBitGroups_AlterSet_RowStore_OptionAllowPageLocks")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionIgnoreDupKey_Desired=1", TestName = "IndexUpdateTests_ChangeBitGroups_AlterSet_RowStore_OptionIgnoreDupKey")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionStatisticsNoRecompute_Desired=1", TestName = "IndexUpdateTests_ChangeBitGroups_AlterSet_RowStore_OptionStatisticsNoRecompute")]

        public void IndexUpdateTests_ChangeBitGroups_AlterSet_RowStore(string databaseName, string tableName, string indexName, string optionUpdateList)

        {
            var indexRow = TestHelper.GetActualUserValues_RowStore(indexName).Find(x => x.IndexName == indexName);

            Assert.AreEqual(false, indexRow.AreSetOptionsChanging, "AreSetOptionsChanging, Post-Change");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            indexRow = TestHelper.GetActualUserValues_RowStore(indexName).Find(x => x.IndexName == indexName);

            //BitGroup should now = true
            Assert.AreEqual(true, indexRow.AreSetOptionsChanging, "AreSetOptionsChanging, Post-Change");
        }

        #endregion

        #region IndexSizeEstimate Tests



        #endregion
    }
}
