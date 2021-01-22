using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.IntegrationTests.Models;
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

        #region IndexIsMissing Tests

        #endregion

        #region IndexNumRows Tests

        #endregion

        #region IndexSizing Tests



        #endregion

        #region IndexFragmentation Tests

        #endregion

        #region MyRegion



        #endregion

        #region IndexPartitionFunction Tests

        

        #endregion

        #region ChangeBits Tests
        //update index, and make sure the change bit was set correctly.
        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_AllowPageLocksChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_AllowPageLocksChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_AllowPageLocksChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_AllowPageLocksChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionAllowPageLocks_Desired = 0 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsAllowPageLocksChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_AllowRowLocksChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_AllowRowLocksChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_AllowRowLocksChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_AllowRowLocksChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionAllowRowLocks_Desired = 0 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsAllowRowLocksChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_IsClusteredChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_IsClusteredChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_IsClusteredChanging_RowStore_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_ChangeBits_IsClusteredChanging_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_ChangeBits_IsClusteredChanging_ColumnStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IsClusteredChanging(string databaseName, string tableName, string indexName)
        {
            var isClusteredSetting = (indexName == TestHelper.CIndexName || indexName == TestHelper.CCIIndexName)? "0" : "1";

            if (indexName == TestHelper.CCIIndexName)
            {
                sqlHelper.Execute(TestHelper.DropCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.DropCIndexMetadataSql);
                sqlHelper.Execute(TestHelper.DropNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.DropNCCIndexMetadataSql);
                sqlHelper.Execute(TestHelper.CreateCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateCCIIndexMetadataSql);
            }

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

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_DataCompressionChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_DataCompressionChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_DataCompressionChanging_RowStore_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_ChangeBits_DataCompressionChanging_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_ChangeBits_DataCompressionChanging_ColumnStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_DataCompressionChanging(string databaseName, string tableName, string indexName)
        {
            if (indexName == TestHelper.CCIIndexName)
            {
                sqlHelper.Execute(TestHelper.DropCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.DropCIndexMetadataSql);
                sqlHelper.Execute(TestHelper.DropNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.DropNCCIndexMetadataSql);
                sqlHelper.Execute(TestHelper.CreateCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateCCIIndexMetadataSql);
            }

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
            if (indexName == TestHelper.CCIIndexName)
            {
                sqlHelper.Execute(TestHelper.DropCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.DropNCCIIndexSql, 30, true, DatabaseName);

                sqlHelper.Execute(TestHelper.CreateCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateCCIIndexMetadataSql);
            }

            //all change bits should be off
            TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesColumnStore SET OptionDataCompressionDelay_Desired = 10 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexColumnStoreChangeBits(indexName, "Post", "IsDataCompressionDelayChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_FillFactorChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_FillFactorChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_FillFactorChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_FillFactorChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");


            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET FillFactor_Desired = 50 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsFillfactorChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_FilterChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_FilterChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_FilterChanging_RowStore_NonClustered")]
        [TestCase("DOIUnitTests", "TempA", "CCI_TempA", TestName = "IndexUpdateTests_ChangeBits_FilterChanging_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", TestName = "IndexUpdateTests_ChangeBits_FilterChanging_ColumnStore_NonClustered")]

        //need a NC, non-PK index for this.
        //need negative assertions for the 2 above indexes, which fail on this error:  "The UPDATE statement conflicted with the CHECK constraint "Chk_IndexesRowStore_Filter". The conflict occurred in database "DOI", table "DOI.IndexesRowStore".The statement has been terminated."
        public void IndexUpdateTests_ChangeBits_FilterChanging(string databaseName, string tableName, string indexName)
        {
            if (indexName == TestHelper.CCIIndexName)
            {
                sqlHelper.Execute(TestHelper.DropCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.DropCIndexMetadataSql);
                sqlHelper.Execute(TestHelper.DropNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.DropNCCIndexMetadataSql);
                sqlHelper.Execute(TestHelper.CreateCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateCCIIndexMetadataSql);
            }

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

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_IgnoreDupKeyChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_IgnoreDupKeyChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_IgnoreDupKeyChanging_RowStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_IgnoreDupKeyChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionIgnoreDupKey_Desired = 1 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsIgnoreDupKeyChanging");
        }


        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_IncludedColumnListChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_IncludedColumnListChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_IncludedColumnListChanging_RowStore_NonClustered")]
        //need negative assertions for the 2 above indexes, which fail on this error:  "The UPDATE statement conflicted with the CHECK constraint "Chk_IndexesRowStore_IncludedColumnsNotAllowed". The conflict occurred in database "DOI", table "DOI.IndexesRowStore".The statement has been terminated."
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
            if (indexName == TestHelper.CCIIndexName)
            {
                sqlHelper.Execute(TestHelper.DropCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.DropCIndexMetadataSql);
                sqlHelper.Execute(TestHelper.DropNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.DropNCCIndexMetadataSql);
                sqlHelper.Execute(TestHelper.CreateCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateCCIIndexMetadataSql);
            }

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

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyChanging_RowStore_NonClustered")]
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

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyAndIsUniqueChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyAndIsUniqueChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_IsPrimaryKeyAndIsUniqueChanging_RowStore_NonClustered")]
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

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_KeyColumnListChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_KeyColumnListChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_KeyColumnListChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_KeyColumnListChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET KeyColumnList_Desired = 'TempAId, TransactionUtcDt' WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsKeyColumnListChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_PadIndexChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_PadIndexChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_PadIndexChanging_RowStore_NonClustered")]
        public void IndexUpdateTests_ChangeBits_PadIndexChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");


            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionPadIndex_Desired = 0 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsPadIndexChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_StatisticsNoRecomputeChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_StatisticsNoRecomputeChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_StatisticsNoRecomputeChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_StatisticsNoRecomputeChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");


            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionStatisticsNoRecompute_Desired = 1 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsStatisticsNoRecomputeChanging");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_StatisticsIncrementalChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_StatisticsIncrementalChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_StatisticsIncrementalChanging_RowStore_NonClustered")]

        public void IndexUpdateTests_ChangeBits_StatisticsIncrementalChanging(string databaseName, string tableName, string indexName)
        {
            //all change bits should be off
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Pre");

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionStatisticsIncremental_Desired = 1 WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            //only the correct change bit should be turned on.  All others should still be off.
            TestHelper.AssertIndexRowStoreChangeBits(indexName, "Post", "IsStatisticsIncrementalChanging");
        }


        [TestCase("DOIUnitTests", "TempA", "CDX_TempA_TempAId", TestName = "IndexUpdateTests_ChangeBits_UniquenessChanging_RowStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "PK_TempA", TestName = "IndexUpdateTests_ChangeBits_UniquenessChanging_RowStore_PKNonClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA_TransactionUtcDt", TestName = "IndexUpdateTests_ChangeBits_UniquenessChanging_RowStore_NonClustered")]

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

        //still need partitioning

        #endregion

        #region ChangeBitGroups Tests
        //different combinations of updates should set the 5 change bit groups correctly.
/*        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", "OptionAllowPageLocks=0, OptionDataCompression='ROW', OptionIgnoreDupKey=1, OptionPadIndex=0, OptionStatisticsNoRecompute=1", "AlterRebuild", "AllowPageLocks, DataCompression, IgnoreDupKey, PadIndex, StatisticsNoRecompute", TestName = "IndexUpdateClassification_Tests_AlterRebuild_AllowPageLocks_DataCompression_IgnoreDupKey_PadIndex_StatisticsNoRecompute")]
        public void IndexUpdateTests_ChangeBitGroups_DropRecreate(string databaseName, string tableName, string indexName, string optionUpdateList, string updateType, string listOfChanges)
        {
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);


            if (optionUpdateList != null)
            {
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            var indexRow = this.dataDrivenIndexTestHelper.GetIndexViews(tableName).Find(x => x.IndexName == indexName);
            Assert.AreEqual(updateType, indexRow.IndexUpdateType, "indexUpdateType");
            Assert.AreEqual(listOfChanges, indexRow.ListOfChanges, "listOfChanges");
        }
        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", "OptionAllowPageLocks=0, OptionDataCompression='ROW', OptionIgnoreDupKey=1, OptionPadIndex=0, OptionStatisticsNoRecompute=1", "AlterRebuild", "AllowPageLocks, DataCompression, IgnoreDupKey, PadIndex, StatisticsNoRecompute", TestName = "IndexUpdateClassification_Tests_AlterRebuild_AllowPageLocks_DataCompression_IgnoreDupKey_PadIndex_StatisticsNoRecompute")]
        public void IndexUpdateTests_ChangeBitGroups_AlterRebuild(string databaseName, string tableName, string indexName, string optionUpdateList, string updateType, string listOfChanges)
        {
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);


            if (optionUpdateList != null)
            {
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            var indexRow = this.dataDrivenIndexTestHelper.GetIndexViews(tableName).Find(x => x.IndexName == indexName);
            Assert.AreEqual(updateType, indexRow.IndexUpdateType, "indexUpdateType");
            Assert.AreEqual(listOfChanges, indexRow.ListOfChanges, "listOfChanges");
        }
        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", "OptionAllowPageLocks=0, OptionDataCompression='ROW', OptionIgnoreDupKey=1, OptionPadIndex=0, OptionStatisticsNoRecompute=1", "AlterRebuild", "AllowPageLocks, DataCompression, IgnoreDupKey, PadIndex, StatisticsNoRecompute", TestName = "IndexUpdateClassification_Tests_AlterRebuild_AllowPageLocks_DataCompression_IgnoreDupKey_PadIndex_StatisticsNoRecompute")]
        public void IndexUpdateTests_ChangeBitGroups_AlterReorganize(string databaseName, string tableName, string indexName, string optionUpdateList, string updateType, string listOfChanges)
        {
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);


            if (optionUpdateList != null)
            {
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            var indexRow = this.dataDrivenIndexTestHelper.GetIndexViews(tableName).Find(x => x.IndexName == indexName);
            Assert.AreEqual(updateType, indexRow.IndexUpdateType, "indexUpdateType");
            Assert.AreEqual(listOfChanges, indexRow.ListOfChanges, "listOfChanges");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", "OptionAllowPageLocks=0, OptionDataCompression='ROW', OptionIgnoreDupKey=1, OptionPadIndex=0, OptionStatisticsNoRecompute=1", "AlterRebuild", "AllowPageLocks, DataCompression, IgnoreDupKey, PadIndex, StatisticsNoRecompute", TestName = "IndexUpdateClassification_Tests_AlterRebuild_AllowPageLocks_DataCompression_IgnoreDupKey_PadIndex_StatisticsNoRecompute")]
        public void IndexUpdateTests_ChangeBitGroups_AlterSet(string databaseName, string tableName, string indexName, string optionUpdateList, string updateType, string listOfChanges)
        {
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);


            if (optionUpdateList != null)
            {
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            var indexRow = this.dataDrivenIndexTestHelper.GetIndexViews(tableName).Find(x => x.IndexName == indexName);
            Assert.AreEqual(updateType, indexRow.IndexUpdateType, "indexUpdateType");
            Assert.AreEqual(listOfChanges, indexRow.ListOfChanges, "listOfChanges");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", "OptionAllowPageLocks=0, OptionDataCompression='ROW', OptionIgnoreDupKey=1, OptionPadIndex=0, OptionStatisticsNoRecompute=1", "AlterRebuild", "AllowPageLocks, DataCompression, IgnoreDupKey, PadIndex, StatisticsNoRecompute", TestName = "IndexUpdateClassification_Tests_AlterRebuild_AllowPageLocks_DataCompression_IgnoreDupKey_PadIndex_StatisticsNoRecompute")]
        public void IndexUpdateTests_ChangeBitGroups_NoChange(string databaseName, string tableName, string indexName, string optionUpdateList, string updateType, string listOfChanges)
        {
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);


            if (optionUpdateList != null)
            {
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            var indexRow = this.dataDrivenIndexTestHelper.GetIndexViews(tableName).Find(x => x.IndexName == indexName);
            Assert.AreEqual(updateType, indexRow.IndexUpdateType, "indexUpdateType");
            Assert.AreEqual(listOfChanges, indexRow.ListOfChanges, "listOfChanges");
        }
*/
        #endregion

        #region StrategyClassification Tests
/*
        //for the diff combinations of change bit values, make sure it chooses the right strategy
        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", "OptionAllowPageLocks=0, OptionDataCompression='ROW', OptionIgnoreDupKey=1, OptionPadIndex=0, OptionStatisticsNoRecompute=1", "AlterRebuild", "AllowPageLocks, DataCompression, IgnoreDupKey, PadIndex, StatisticsNoRecompute", TestName = "IndexUpdateClassification_Tests_AlterRebuild_AllowPageLocks_DataCompression_IgnoreDupKey_PadIndex_StatisticsNoRecompute")]
        public void IndexUpdateStrategyClassification_Tests_DropRecreate(string databaseName, string tableName, string indexName, string optionUpdateList, string updateType, string listOfChanges)
        {
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);


            if (optionUpdateList != null)
            {
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            var indexRow = this.dataDrivenIndexTestHelper.GetIndexViews(tableName).Find(x => x.IndexName == indexName);
            Assert.AreEqual(updateType, indexRow.IndexUpdateType, "indexUpdateType");
            Assert.AreEqual(listOfChanges, indexRow.ListOfChanges, "listOfChanges");
        }
        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", "OptionAllowPageLocks=0, OptionDataCompression='ROW', OptionIgnoreDupKey=1, OptionPadIndex=0, OptionStatisticsNoRecompute=1", "AlterRebuild", "AllowPageLocks, DataCompression, IgnoreDupKey, PadIndex, StatisticsNoRecompute", TestName = "IndexUpdateClassification_Tests_AlterRebuild_AllowPageLocks_DataCompression_IgnoreDupKey_PadIndex_StatisticsNoRecompute")]
        public void IndexUpdateClassification_Tests_AlterRebuild(string databaseName, string tableName, string indexName, string optionUpdateList, string updateType, string listOfChanges)
        {
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);


            if (optionUpdateList != null)
            {
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            var indexRow = this.dataDrivenIndexTestHelper.GetIndexViews(tableName).Find(x => x.IndexName == indexName);
            Assert.AreEqual(updateType, indexRow.IndexUpdateType, "indexUpdateType");
            Assert.AreEqual(listOfChanges, indexRow.ListOfChanges, "listOfChanges");
        }
        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", "OptionAllowPageLocks=0, OptionDataCompression='ROW', OptionIgnoreDupKey=1, OptionPadIndex=0, OptionStatisticsNoRecompute=1", "AlterRebuild", "AllowPageLocks, DataCompression, IgnoreDupKey, PadIndex, StatisticsNoRecompute", TestName = "IndexUpdateClassification_Tests_AlterRebuild_AllowPageLocks_DataCompression_IgnoreDupKey_PadIndex_StatisticsNoRecompute")]
        public void IndexUpdateClassification_Tests_AlterReorganize(string databaseName, string tableName, string indexName, string optionUpdateList, string updateType, string listOfChanges)
        {
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);


            if (optionUpdateList != null)
            {
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            var indexRow = this.dataDrivenIndexTestHelper.GetIndexViews(tableName).Find(x => x.IndexName == indexName);
            Assert.AreEqual(updateType, indexRow.IndexUpdateType, "indexUpdateType");
            Assert.AreEqual(listOfChanges, indexRow.ListOfChanges, "listOfChanges");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", "OptionAllowPageLocks=0, OptionDataCompression='ROW', OptionIgnoreDupKey=1, OptionPadIndex=0, OptionStatisticsNoRecompute=1", "AlterRebuild", "AllowPageLocks, DataCompression, IgnoreDupKey, PadIndex, StatisticsNoRecompute", TestName = "IndexUpdateClassification_Tests_AlterRebuild_AllowPageLocks_DataCompression_IgnoreDupKey_PadIndex_StatisticsNoRecompute")]
        public void IndexUpdateClassification_Tests_AlterSet(string databaseName, string tableName, string indexName, string optionUpdateList, string updateType, string listOfChanges)
        {
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);


            if (optionUpdateList != null)
            {
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            var indexRow = this.dataDrivenIndexTestHelper.GetIndexViews(tableName).Find(x => x.IndexName == indexName);
            Assert.AreEqual(updateType, indexRow.IndexUpdateType, "indexUpdateType");
            Assert.AreEqual(listOfChanges, indexRow.ListOfChanges, "listOfChanges");
        }

        [TestCase("DOIUnitTests", "TempA", "CDX_TempA", "OptionAllowPageLocks=0, OptionDataCompression='ROW', OptionIgnoreDupKey=1, OptionPadIndex=0, OptionStatisticsNoRecompute=1", "AlterRebuild", "AllowPageLocks, DataCompression, IgnoreDupKey, PadIndex, StatisticsNoRecompute", TestName = "IndexUpdateClassification_Tests_AlterRebuild_AllowPageLocks_DataCompression_IgnoreDupKey_PadIndex_StatisticsNoRecompute")]
        public void IndexUpdateClassification_Tests_NoChanges(string databaseName, string tableName, string indexName, string optionUpdateList, string updateType, string listOfChanges)
        {
            sqlHelper.Execute(TestHelper.CreateIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateIndexSql, 30, true, DatabaseName);


            if (optionUpdateList != null)
            {
                sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET {optionUpdateList} WHERE DatabaseName = '{databaseName}' AND SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'", 120);
            }

            var indexRow = this.dataDrivenIndexTestHelper.GetIndexViews(tableName).Find(x => x.IndexName == indexName);
            Assert.AreEqual(updateType, indexRow.IndexUpdateType, "indexUpdateType");
            Assert.AreEqual(listOfChanges, indexRow.ListOfChanges, "listOfChanges");
        }*/
        #endregion

        #region IndexSizeEstimate Tests

        

        #endregion
    }
}
