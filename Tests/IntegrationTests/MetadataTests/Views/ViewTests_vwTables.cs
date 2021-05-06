using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwTablesHelper;
using PfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionsHelper;
using PsTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionSchemesHelper;
using FgTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_FileGroupsHelper;
using DbfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_DBFilesHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwTables : DOIBaseTest
    {
        FgTestHelper fgTestHelper = new FgTestHelper();
        DbfTestHelper dbfTestHelper = new DbfTestHelper();
        PfTestHelper pfTestHelper = new PfTestHelper();
        PsTestHelper psTestHelper = new PsTestHelper();

        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropPartitionedTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeMonthlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionMonthlySql, 30, true, DatabaseName);
        }

        [Test]
        public void Views_vwTables_UnPartitionedTableMetadataIsAccurate()
        {
            var testHelper = new TestHelper();
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql);//refresh metadata after metadata insert

            //create partition function
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql); //refresh metadata again to show the partition function as existing on the server.

            //and now they should match
            TestHelper.AssertMetadata(TestHelper.TableName);
        }

        [Test]
        public void Views_vwTables_PartitionedTableYearlyMetadataIsAccurate()
        {
            //Setup
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlyMetadataSql);//create partition function metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);  //refresh metadata after metadata insert

            sqlHelper.Execute(pfTestHelper.GetPartitionFunctionSql(TestHelper.PartitionFunctionNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql); //refresh metadata again to show the partition function as existing on the server.

            //create all needed storage containers
            sqlHelper.Execute(fgTestHelper.GetFilegroupSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabaseFilesSql);

            //create partition scheme
            sqlHelper.Execute(psTestHelper.GetPartitionSchemeSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysPartitionSchemesSql);

            sqlHelper.Execute(TestHelper.CreatePartitionedTableYearlyMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql);//refresh metadata after metadata insert

            //create partition function
            sqlHelper.Execute(TestHelper.CreatePartitionedTableYearlySql, 30, true, DatabaseName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql); //refresh metadata again to show the partition function as existing on the server.

            //and now they should match
            TestHelper.AssertMetadata(TestHelper.TableName_Partitioned);
        }

        [Test]
        public void Views_vwTables_PartitionedTableMonthlyMetadataIsAccurate()
        {
            //Setup
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionMonthlyMetadataSql);//create partition function metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);  //refresh metadata after metadata insert

            sqlHelper.Execute(pfTestHelper.GetPartitionFunctionSql(TestHelper.PartitionFunctionNameMonthly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql); //refresh metadata again to show the partition function as existing on the server.

            //create all needed storage containers
            sqlHelper.Execute(fgTestHelper.GetFilegroupSql(TestHelper.PartitionSchemeNameMonthly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(TestHelper.PartitionSchemeNameMonthly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabaseFilesSql);

            //create partition scheme
            sqlHelper.Execute(psTestHelper.GetPartitionSchemeSql(TestHelper.PartitionSchemeNameMonthly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysPartitionSchemesSql);

            sqlHelper.Execute(TestHelper.CreatePartitionedTableMonthlyMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql);//refresh metadata after metadata insert

            //create partition function
            sqlHelper.Execute(TestHelper.CreatePartitionedTableMonthlySql, 30, true, DatabaseName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql); //refresh metadata again to show the partition function as existing on the server.

            //and now they should match
            TestHelper.AssertMetadata(TestHelper.TableName_Partitioned);
        }

        //change bit tests.
        //AreIndexesFragmented
        [TestCase("IDX_TempA", "None", false, TestName = "ViewTests_vwTables_AreIndexesFragmented_RowStore_NoFrag")]
        [TestCase("IDX_TempA", "Light", true, TestName = "ViewTests_vwTables_AreIndexesFragmented_RowStore_LightFrag")]
        [TestCase("IDX_TempA", "Heavy", true, TestName = "ViewTests_vwTables_AreIndexesFragmented_RowStore_HeavyFrag")]
        [TestCase("NCCI_TempA", "None", false, TestName = "ViewTests_vwTables_AreIndexesFragmented_ColumnStore_NoFrag")]
        [TestCase("NCCI_TempA", "Light", true, TestName = "ViewTests_vwTables_AreIndexesFragmented_ColumnStore_LightFrag")]
        [TestCase("NCCI_TempA", "Heavy", true, TestName = "ViewTests_vwTables_AreIndexesFragmented_ColumnStore_HeavyFrag")]

        public void ViewTests_vwTables_AreIndexesFragmented(string indexName, string fragmentationType, bool expectedAreIndexesFragmented)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateNCCIIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCCIIndexMetadataSql);

            string indexType = String.Empty;

            switch (indexName)
            {
                case "IDX_TempA":
                    indexType = "RowStore";
                    break;
                case "NCCI_TempA":
                    indexType = "ColumnStore";
                    break;
            }

            sqlHelper.Execute(
                $@" UPDATE DOI.Indexes{indexType}
                        SET FragmentationType = '{fragmentationType}'
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{indexName}'");

            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData @DatabaseName = '{DatabaseName}'");

            var actualAreIndexesFragmented = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT AreIndexesFragmented 
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(expectedAreIndexesFragmented, actualAreIndexesFragmented);
        }

        //AreIndexesBeingUpdated:  update each bit group to test
        [TestCase("NCCI_TempA", "IsIndexMissingFromSQLServer", true, TestName = "ViewTests_vwTables_AreIndexesBeingUpdated_ColumnStore_IndexMissing")]
        [TestCase("NCCI_TempA", "AreDropRecreateOptionsChanging", true, TestName = "ViewTests_vwTables_AreIndexesBeingUpdated_ColumnStore_DropRecreate")]
        [TestCase("NCCI_TempA", "AreRebuildOnlyOptionsChanging", true, TestName = "ViewTests_vwTables_AreIndexesBeingUpdated_ColumnStore_RebuildOnly")]
        [TestCase("NCCI_TempA", "AreSetOptionsChanging", true, TestName = "ViewTests_vwTables_AreIndexesBeingUpdated_ColumnStore_Set")]
        [TestCase("IDX_TempA", "IsIndexMissingFromSQLServer", true, TestName = "ViewTests_vwTables_AreIndexesBeingUpdated_RowStore_IndexMissing")]
        [TestCase("IDX_TempA", "AreDropRecreateOptionsChanging", true, TestName = "ViewTests_vwTables_AreIndexesBeingUpdated_RowStore_DropRecreate")]
        [TestCase("IDX_TempA", "AreRebuildOnlyOptionsChanging", true, TestName = "ViewTests_vwTables_AreIndexesBeingUpdated_RowStore_RebuildOnly")]
        [TestCase("IDX_TempA", "AreReorgOptionsChanging", true, TestName = "ViewTests_vwTables_AreIndexesBeingUpdated_RowStore_Reorg")]
        [TestCase("IDX_TempA", "AreSetOptionsChanging", true, TestName = "ViewTests_vwTables_AreIndexesBeingUpdated_RowStore_Set")]

        public void ViewTests_vwTables_AreIndexesBeingUpdated(string indexName, string columnToUpdate, bool newValue)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);
            sqlHelper.Execute(TestHelper.CreateNCCIIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCCIIndexMetadataSql);

            string indexType = String.Empty;

            var actualAreIndexesBeingUpdated = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT AreIndexesBeingUpdated
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(false, actualAreIndexesBeingUpdated);


            switch (indexName)
            {
                case "IDX_TempA":
                    indexType = "RowStore";
                    break;
                case "NCCI_TempA":
                    indexType = "ColumnStore";
                    break;
            }

            if (columnToUpdate == "AreReorgOptionsChanging")
            {
                sqlHelper.Execute(
                    $@" UPDATE DOI.Indexes{indexType}
                        SET FragmentationType = 'Light'
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{indexName}'");
            }
            else
            {
                sqlHelper.Execute(
                    $@" UPDATE DOI.Indexes{indexType}
                        SET {columnToUpdate} = '{newValue}'
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{indexName}'");
            }


            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData @DatabaseName = '{DatabaseName}'");

            actualAreIndexesBeingUpdated = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT AreIndexesBeingUpdated
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(true, actualAreIndexesBeingUpdated);
        }


        //AreIndexesMissing
        [TestCase("IDX_TempA", TestName = "ViewTests_vwTables_AreIndexesMissing_RowStore_Reorg")]
        [TestCase("NCCI_TempA", TestName = "ViewTests_vwTables_AreIndexesMissing_RowStore_Set")]
        public void ViewTests_vwTables_AreIndexesMissing(string indexName)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);

            if (indexName == "IDX_TempA")
            {
                sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);
            }
            else if (indexName == "NCCI_TempA")
            {
                sqlHelper.Execute(TestHelper.CreateNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateNCCIIndexMetadataSql);
            }

            var actualAreIndexesMissing = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT AreIndexesMissing 
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(false, actualAreIndexesMissing);

            if (indexName == "IDX_TempA")
            {
                sqlHelper.Execute(TestHelper.DropNCIndexSql, 30, true, DatabaseName);
            }
            else if (indexName == "NCCI_TempA")
            {
                sqlHelper.Execute(TestHelper.DropNCCIIndexSql, 30, true, DatabaseName);
            }


            sqlHelper.Execute(TestHelper.RefreshMetadata_All);

            actualAreIndexesMissing = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT AreIndexesMissing
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(true, actualAreIndexesMissing);
        }


        //IsClusteredIndexBeingDropped...update 
        [TestCase("RowStore", TestName = "ViewTests_vwTables_IsClusteredIndexBeingDropped_RowStore")]
        [TestCase("ColumnStore", TestName = "ViewTests_vwTables_IsClusteredIndexBeingDropped_ColumnStore")]
        public void ViewTests_vwTables_IsClusteredIndexBeingDropped(string indexType)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);

            if (indexType == "RowStore")
            {
                sqlHelper.Execute(TestHelper.CreateCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateCIndexMetadataSql);
            }
            else if (indexType == "ColumnStore")
            {
                sqlHelper.Execute(TestHelper.CreateCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateCCIIndexMetadataSql);
            }

            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            var actualIsClusteredIndexBeingDropped = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT IsClusteredIndexBeingDropped
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(false, actualIsClusteredIndexBeingDropped);

            sqlHelper.Execute($@"
                UPDATE DOI.Indexes{indexType}
                SET AreDropRecreateOptionsChanging = 1
                WHERE DatabaseName = '{DatabaseName}' 
                    AND TableName = '{TestTableName1}'
                    AND IndexName = '{(indexType == "RowStore" ? TestHelper.CIndexName : TestHelper.CCIIndexName)}'");

            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData @DatabaseName = '{DatabaseName}'");

            actualIsClusteredIndexBeingDropped = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT IsClusteredIndexBeingDropped
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(true, actualIsClusteredIndexBeingDropped);
        }


        //WhichUniqueConstraintIsBeingDropped
        [TestCase("PrimaryKey", "PK", TestName = "ViewTests_vwTables_WhichUniqueConstraintIsBeingDropped_PrimaryKey")]
        [TestCase("UniqueKey", "UQ", TestName = "ViewTests_vwTables_WhichUniqueConstraintIsBeingDropped_UniqueKey")]
        [TestCase("BothKeys", "Both", TestName = "ViewTests_vwTables_WhichUniqueConstraintIsBeingDropped_BothKeys")]

        public void ViewTests_vwTables_WhichUniqueConstraintIsBeingDropped(string keyType, string expectedValue)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);

            if (keyType != "PrimaryKey")
            {
                sqlHelper.Execute(TestHelper.CreateUQIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateUQIndexMetadataSql);
            }

            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            var actualWhichUniqueConstraintIsBeingDropped = sqlHelper.ExecuteScalar<string>(
                $@" SELECT WhichUniqueConstraintIsBeingDropped
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual("None", actualWhichUniqueConstraintIsBeingDropped);

            if (keyType == "PrimaryKey")
            {
                sqlHelper.Execute($@"
                UPDATE DOI.IndexesRowStore
                SET AreDropRecreateOptionsChanging = 1
                WHERE DatabaseName = '{DatabaseName}' 
                    AND TableName = '{TestTableName1}'
                    AND IndexName = '{TestHelper.PKIndexName}'");
            }
            else if (keyType == "UniqueKey")
            {
                sqlHelper.Execute($@"
                UPDATE DOI.IndexesRowStore
                SET AreDropRecreateOptionsChanging = 1
                WHERE DatabaseName = '{DatabaseName}' 
                    AND TableName = '{TestTableName1}'
                    AND IndexName = '{TestHelper.UQIndexName}'");
            }
            else if (keyType == "BothKeys")
            {
                sqlHelper.Execute($@"
                UPDATE DOI.IndexesRowStore
                SET AreDropRecreateOptionsChanging = 1
                WHERE DatabaseName = '{DatabaseName}' 
                    AND TableName = '{TestTableName1}'
                    AND IndexName IN ('{TestHelper.PKIndexName}', '{TestHelper.UQIndexName}')");
            }

            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData @DatabaseName = '{DatabaseName}'");

            actualWhichUniqueConstraintIsBeingDropped = sqlHelper.ExecuteScalar<string>(
                $@" SELECT WhichUniqueConstraintIsBeingDropped
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(expectedValue, actualWhichUniqueConstraintIsBeingDropped);
        }


        //IsStorageChanging
        [TestCase("RowStore", TestName = "ViewTests_vwTables_IsStorageChanging_RowStore")]
        [TestCase("ColumnStore", TestName = "ViewTests_vwTables_IsStorageChanging_ColumnStore")]
        public void ViewTests_vwTables_IsStorageChanging(string indexType)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);

            if (indexType == "RowStore")
            {
                sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);
            }
            else if (indexType == "ColumnStore")
            {
                sqlHelper.Execute(TestHelper.CreateNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateNCCIIndexMetadataSql);
            }

            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            var actualIsStorageChanging = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT IsStorageChanging
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(false, actualIsStorageChanging);

            sqlHelper.Execute($@"
                UPDATE DOI.Indexes{indexType}
                SET IsStorageChanging = 1
                WHERE DatabaseName = '{DatabaseName}' 
                    AND TableName = '{TestTableName1}'
                    AND IndexName = '{(indexType == "RowStore" ? TestHelper.NCIndexName : TestHelper.NCCIIndexName)}'");

            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData @DatabaseName = '{DatabaseName}'");

            actualIsStorageChanging = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT IsStorageChanging
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(true, actualIsStorageChanging);
        }


        //NeedsTransaction
        [TestCase("RowStore", TestName = "ViewTests_vwTables_NeedsTransaction_RowStore")]
        [TestCase("ColumnStore", TestName = "ViewTests_vwTables_NeedsTransaction_ColumnStore")]
        public void ViewTests_vwTables_NeedsTransaction(string indexType)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);

            if (indexType == "RowStore")
            {
                sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);
            }
            else if (indexType == "ColumnStore")
            {
                sqlHelper.Execute(TestHelper.CreateNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateNCCIIndexMetadataSql);
            }

            sqlHelper.Execute(TestHelper.RefreshMetadata_SysIndexesSql);

            var actualNeedsTransaction = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT NeedsTransaction
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(false, actualNeedsTransaction);

            sqlHelper.Execute($@"
                UPDATE DOI.Indexes{indexType}
                SET AreDropRecreateOptionsChanging = 1
                WHERE DatabaseName = '{DatabaseName}' 
                    AND TableName = '{TestTableName1}'
                    AND IndexName = '{(indexType == "RowStore" ? TestHelper.NCIndexName : TestHelper.NCCIIndexName)}'");

            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData @DatabaseName = '{DatabaseName}'");

            actualNeedsTransaction = sqlHelper.ExecuteScalar<bool>(
                $@" SELECT NeedsTransaction
                        FROM DOI.vwTables 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'");

            Assert.AreEqual(true, actualNeedsTransaction);
        }


        //AreStatisticsChanging
    }
}
