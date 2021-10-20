using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using NUnit.Framework;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwIndexesHelper;
using TestHelper_Indexes = DOI.Tests.TestHelpers.Metadata.IndexesHelper;
using PfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionsHelper;
using PsTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionSchemesHelper;
using FgTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_FileGroupsHelper;
using DbfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_DBFilesHelper;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwIndexes : DOIBaseTest
    {
        FgTestHelper fgTestHelper = new FgTestHelper();
        DbfTestHelper dbfTestHelper = new DbfTestHelper();
        PfTestHelper pfTestHelper = new PfTestHelper();
        PsTestHelper psTestHelper = new PsTestHelper();

        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
            //create a non-partitioned table and update its metadata to partition it.  then assert the metadata below.
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropTableMetadataSql);
            sqlHelper.Execute(TestHelper.DropPartitionedTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeMonthlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionMonthlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionedTableMetadataSql);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropFilegroup2Sql);
            //sqlHelper.Execute(fgTestHelper.GetFilegroupSql(null, "Drop"), 30, true, DatabaseName);
            //sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(null, "Drop"), 30, true, DatabaseName);
        }

        #region NeedsSpaceOnTempDBDrive Tests
        //test case for each IndexUpdateType and assert that NeedsSpaceOnTempDBDrive = 1 on CreateMissing, AlterRebuild, or Clustered index CreateDropExisting.
        [TestCase("CreateMissing", 0, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_CreateMissing_NC")]
        [TestCase("CreateMissing", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_CreateMissing_C")]
        [TestCase("CreateDropExisting", 0, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_CreateDropExisting_NC")]
        [TestCase("CreateDropExisting", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_CreateDropExisting_C")]
        [TestCase("AlterRebuild", 0, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_AlterRebuild_NC")]
        [TestCase("AlterRebuild", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_AlterRebuild_C")]
        [TestCase("AlterSet", 0, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_AlterSet_NC")]
        [TestCase("AlterSet", 1, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_AlterSet_C")]
        [TestCase("AlterRebuild-PartitionLevel", 0, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_AlterRebuildPartitionLevel_NC")]
        [TestCase("AlterRebuild-PartitionLevel", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_AlterRebuildPartitionLevel_C")]
        [TestCase("AlterReorganize", 0, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_AlterReorganize_NC")]
        [TestCase("AlterReorganize", 1, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_AlterReorganize_C")]
        [TestCase("AlterReorganize-PartitionLevel", 0, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_AlterReorganizePartitionLevel_NC")]
        [TestCase("AlterReorganize-PartitionLevel", 1, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_AlterReorganizePartitionLevel_C")]
        public void ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore(string indexUpdateType, int isClustered_Desired, int expectedNeedsSpaceOnTempDBDrive)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);


            var columnsToUpdateSql = TestHelper.GetColumnsToUpdateFromIndexTypeSql(indexUpdateType);

            sqlHelper.Execute(
                $@" UPDATE DOI.IndexesRowStore 
                        SET {columnsToUpdateSql},
                            IsClustered_Desired = {isClustered_Desired}
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{TestHelper.NCIndexName}'");

            var actualNeedsSpaceOnTempDBDrive = sqlHelper.ExecuteScalar<int>(
                $@" SELECT NeedsSpaceOnTempDBDrive 
                        FROM DOI.vwIndexes 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{TestHelper.NCIndexName}'");

            Assert.AreEqual(expectedNeedsSpaceOnTempDBDrive, actualNeedsSpaceOnTempDBDrive);
        }

        [TestCase("CreateMissing", 0, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_CreateMissing_NC")]
        [TestCase("CreateMissing", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_CreateMissing_C")]
        [TestCase("CreateDropExisting", 0, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_CreateDropExisting_NC")]
        [TestCase("CreateDropExisting", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_CreateDropExisting_C")]
        [TestCase("AlterRebuild", 0, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_AlterRebuild_NC")]
        [TestCase("AlterRebuild", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_AlterRebuild_C")]
        [TestCase("AlterRebuild-PartitionLevel", 0, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_AlterRebuildPartitionLevel_NC")]
        [TestCase("AlterRebuild-PartitionLevel", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_AlterRebuildPartitionLevel_C")]
        [TestCase("AlterReorganize", 0, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_AlterReorganize_NC")]
        [TestCase("AlterReorganize", 1, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_AlterReorganize_C")]
        [TestCase("AlterReorganize-PartitionLevel", 0, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_AlterReorganizePartitionLevel_NC")]
        [TestCase("AlterReorganize-PartitionLevel", 1, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_AlterReorganizePartitionLevel_C")]
        public void ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore(string indexUpdateType, int isClustered_Desired, int expectedNeedsSpaceOnTempDBDrive)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateNCCIIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCCIIndexMetadataSql);


            var columnsToUpdateSql = TestHelper.GetColumnsToUpdateFromIndexTypeSql(indexUpdateType);
            columnsToUpdateSql += string.Concat(isClustered_Desired == 1 ? ", ColumnList_Desired = NULL" : String.Empty);

            sqlHelper.Execute(
                $@" UPDATE DOI.IndexesColumnStore 
                        SET {columnsToUpdateSql},
                            IsClustered_Desired = {isClustered_Desired}
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{TestHelper.NCCIIndexName}'");

            var actualNeedsSpaceOnTempDBDrive = sqlHelper.ExecuteScalar<int>(
                $@" SELECT NeedsSpaceOnTempDBDrive 
                        FROM DOI.vwIndexes 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{TestHelper.NCCIIndexName}'");

            Assert.AreEqual(expectedNeedsSpaceOnTempDBDrive, actualNeedsSpaceOnTempDBDrive);
        }


        #endregion

        #region ListOfChanges Tests
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionAllowRowLocks", "0", "AllowRowLocks", TestName = "IndexUpdateTests_ListOfChanges_RowStore_AllowRowLocks")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionAllowPageLocks", "0", "AllowPageLocks", TestName = "IndexUpdateTests_ListOfChanges_RowStore_AllowPageLocks")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "IsClustered", "1", "Clustered", TestName = "IndexUpdateTests_ListOfChanges_RowStore_IsClustered")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionDataCompression", "ROW", "DataCompression", TestName = "IndexUpdateTests_ListOfChanges_RowStore_DataCompression")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "FillFactor", "50", "FillFactor", TestName = "IndexUpdateTests_ListOfChanges_RowStore_FillFactor")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "Filter", "1", "Filter", TestName = "IndexUpdateTests_ListOfChanges_RowStore_Filter")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "Storage", "Test1FG2", "Storage", TestName = "IndexUpdateTests_ListOfChanges_RowStore_Storage")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "Fragmentation", "Light", "Fragmentation:  Light", TestName = "IndexUpdateTests_ListOfChanges_RowStore_FragmentationLight")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "Fragmentation", "Heavy", "Fragmentation:  Heavy", TestName = "IndexUpdateTests_ListOfChanges_RowStore_FragmentationHeavy")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionIgnoreDupKey", "1", "IgnoreDupKey", TestName = "IndexUpdateTests_ListOfChanges_RowStore_IgnoreDupKey")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "IncludedColumnList", "IncludedColumn", "IncludedColumnList", TestName = "IndexUpdateTests_ListOfChanges_RowStore_IncludedColumnList")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "IsPrimaryKey", "1", "IsPrimaryKey, Uniqueness", TestName = "IndexUpdateTests_ListOfChanges_RowStore_IsPrimaryKey")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "KeyColumnList", "TempAId", "KeyColumnList", TestName = "IndexUpdateTests_ListOfChanges_RowStore_KeyColumnList")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionPadIndex", "0", "PadIndex", TestName = "IndexUpdateTests_ListOfChanges_RowStore_PadIndex")]
        [TestCase("DOIUnitTests", "TempA_Partitioned", "IDX_TempA_Partitioned", "PartitionFunction", "pfTestsYearly", "Partitioning, Storage", TestName = "IndexUpdateTests_ListOfChanges_RowStore_Partitioning")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "OptionStatisticsNoRecompute", "1", "StatisticsNoRecompute", TestName = "IndexUpdateTests_ListOfChanges_RowStore_StatisticsNoRecompute")]
        [TestCase("DOIUnitTests", "TempA_Partitioned", "IDX_TempA_Partitioned", "OptionStatisticsIncremental", "1", "StatisticsIncremental", TestName = "IndexUpdateTests_ListOfChanges_RowStore_StatisticsIncremental")]
        [TestCase("DOIUnitTests", "TempA", "IDX_TempA", "IsUnique", "1", "Uniqueness", TestName = "IndexUpdateTests_ListOfChanges_RowStore_Uniqueness")]

        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "IsClustered", "1", "Clustered", TestName = "IndexUpdateTests_ListOfChanges_ColumnStore_Clustered")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "ColumnList", "TempAId", "KeyColumnList", TestName = "IndexUpdateTests_ListOfChanges_ColumnStore_ColumnList")]
        [TestCase("DOIUnitTests", "TempA_Partitioned", "NCCI_TempA_Partitioned", "PartitionFunction", "pfTestsYearly", "Partitioning, Storage", TestName = "IndexUpdateTests_ListOfChanges_ColumnStore_Partitioning")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "Fragmentation", "Light", "Fragmentation:  Light", TestName = "IndexUpdateTests_ListOfChanges_ColumnStore_FragmentationLight")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "Fragmentation", "Heavy", "Fragmentation:  Heavy", TestName = "IndexUpdateTests_ListOfChanges_ColumnStore_FragmentationHeavy")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "Storage", "Test1FG2", "Storage", TestName = "IndexUpdateTests_ListOfChanges_ColumnStore_Storage")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "Filter", "1", "Filter", TestName = "IndexUpdateTests_ListOfChanges_ColumnStore_Filter")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "OptionDataCompressionDelay", "100", "CompressionDelay", TestName = "IndexUpdateTests_ListOfChanges_ColumnStore_CompressionDelay")]
        [TestCase("DOIUnitTests", "TempA", "NCCI_TempA", "OptionDataCompression", "COLUMNSTORE_ARCHIVE", "DataCompression", TestName = "IndexUpdateTests_ListOfChanges_ColumnStore_DataCompression")]
        public void IndexUpdateTests_ListOfChanges(string databaseName, string tableName, string indexName, string columnToUpdate, string newValue, string expectedListOfChanges)
        {
            //set up table and index.
            if (tableName == $"{TestHelper.TableName}")
            {
                sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
                sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);
                sqlHelper.Execute(TestHelper.CreateNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateNCCIIndexMetadataSql);
            }
            else if (tableName == $"{TestHelper.TableName_Partitioned}")
            {
                TestHelper_Indexes.CreatePartitioningContainerObjects(TestHelper.PartitionFunctionNameYearly);
                sqlHelper.Execute(TestHelper.CreatePartitionedTableYearlySql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreatePartitionedTableYearlyMetadataSql);
                sqlHelper.Execute(TestHelper.CreatePartitionedNCIndexYearlySql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreatePartitionedNCIndexYearlyMetadataSql);
                sqlHelper.Execute(TestHelper.CreatePartitionedNCCIIndexYearlySql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreatePartitionedNCCIIndexYearlyMetadataSql);
            }
            
            if (columnToUpdate == "Storage")
            {
                sqlHelper.Execute(TestHelper.CreateFilegroup2Sql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.RefreshMetadata_SysFilegroupsSql);
            }

            var indexType = indexName.Contains("IDX") ? "RowStore" : "ColumnStore";
            string setStatement = string.Empty;

            switch (columnToUpdate)
            {
                case "IsPrimaryKey":
                    setStatement = $"IsPrimaryKey_Desired = '{newValue}', IsUnique_Desired = '{newValue}'";
                    break;
                case "Fragmentation":
                    setStatement = $"FragmentationType = '{newValue}'";
                    break;
                case "Filter":
                    setStatement = "IsFiltered_Desired = 1, FilterPredicate_Desired = 'TransactionUtcDt > SYSDATETIME()'";
                    break;
                case "PartitionFunction":
                    setStatement = $"PartitionFunction_Desired = '{newValue}', PartitionColumn_Desired = '{TestHelper.PartitionColumnName}'";
                    break;
                case "IsClustered":
                    setStatement = indexType == "ColumnStore" ? $"{columnToUpdate}_Desired = '{newValue}', ColumnList_Desired = NULL" : $"{columnToUpdate}_Desired = '{newValue}'";
                    break;
                default:
                    setStatement = $"{columnToUpdate}_Desired = '{newValue}'";
                    break;
            }

            sqlHelper.Execute($@"
                UPDATE DOI.Indexes{indexType}
                SET {setStatement}
                WHERE DatabaseName = '{databaseName}' 
                    AND SchemaName = 'dbo' 
                    AND TableName = '{tableName}' 
                    AND IndexName = '{indexName}'", 120);

            if (columnToUpdate == "IsPrimaryKey")
            {
                sqlHelper.Execute($@"
                    UPDATE DOI.Indexes{indexType}
                    SET IsPrimaryKey_Desired = 0
                    WHERE DatabaseName = '{databaseName}' 
                        AND SchemaName = 'dbo' 
                        AND TableName = '{tableName}'
                        AND IndexName <> '{indexName}'");
            }
            else if (columnToUpdate == "IsClustered")
            {
                sqlHelper.Execute($@"
                    UPDATE DOI.Indexes{indexType}
                    SET IsClustered_Desired = 0
                    WHERE DatabaseName = '{databaseName}' 
                        AND SchemaName = 'dbo' 
                        AND TableName = '{tableName}'
                        AND IndexName <> '{indexName}'");
            }
            else if (columnToUpdate == "PartitionFunction")
            {
                sqlHelper.Execute($@"
                    UPDATE DOI.Tables
                    SET IntendToPartition = 1,
                        PartitionFunctionName = '{TestHelper.PartitionFunctionNameYearly}',
                        PartitionColumn = '{TestHelper.PartitionColumnName}'
                    WHERE DatabaseName = '{databaseName}' 
                        AND SchemaName = 'dbo' 
                        AND TableName = '{tableName}'");
            }
            
            sqlHelper.Execute(TestHelper.RefreshMetadata_All);

            var actualListOfChanges = sqlHelper.ExecuteScalar<string>($@"
                SELECT ListOfChanges 
                FROM DOI.vwIndexes
                WHERE DatabaseName = '{databaseName}' 
                    AND SchemaName = 'dbo' 
                    AND TableName = '{tableName}' 
                    AND IndexName = '{indexName}'");

            //only the correct change bit should be turned on.  All others should still be off.
            Assert.AreEqual(expectedListOfChanges, actualListOfChanges, "ListOfChanges");
        }
        #endregion

        #region IndexUpdateType Tests
        //test case for each combination of ChangeBitGroups and assert that the right IndexUpdateType is shown.
        [TestCase(1, 0, 0, 0, 0, "None", "CreateMissing", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_CreateMissing")]
        [TestCase(0, 1, 0, 0, 0, "None", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_CreateDropExisting")]
        [TestCase(0, 1, 1, 0, 0, "None", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_CreateDropExisting_NeedsPartitionLevelOperationsAlso")]
        [TestCase(0, 1, 1, 1, 0, "None", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_CreateDropExisting_NeedsPartitionLevelOperationsAndRebuildOnlyOptionsChangingAlso")]
        [TestCase(0, 1, 1, 1, 1, "None", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_CreateDropExisting_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso")]
        [TestCase(0, 1, 1, 1, 1, "Heavy", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_CreateDropExisting_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_HeavyFrag")]
        [TestCase(0, 1, 1, 1, 1, "Light", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_CreateDropExisting_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_LightFrag")]
        [TestCase(0, 1, 1, 1, 1, "Heavy", "CreateDropExisting", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_CreateDropExisting_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_HeavyFrag_CompressionChanging")]
        [TestCase(0, 1, 1, 1, 1, "Light", "CreateDropExisting", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_CreateDropExisting_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_LightFrag_CompressionChanging")]
        [TestCase(0, 0, 0, 0, 0, "Heavy", "AlterRebuild", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_HeavyFragOnly")]
        [TestCase(0, 0, 0, 0, 1, "Light", "AlterRebuild", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_LightFragAndSetOptions")]
        [TestCase(0, 0, 0, 1, 0, "None", "AlterRebuild", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_RebuildOnlyOptions")]
        [TestCase(0, 0, 0, 1, 0, "Heavy", "AlterRebuild", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_RebuildOnlyOptionsAndHeavyFrag")]
        [TestCase(0, 0, 0, 1, 1, "Light", "AlterRebuild", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_RebuildOnlyOptionsAndLightFragWithSetOptions")]
        [TestCase(0, 0, 0, 1, 1, "Light", "AlterRebuild", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_RebuildOnlyOptionsAndLightFragWithSetOptionsAndCompressionChanges")]
        [TestCase(0, 0, 0, 1, 1, "None", "AlterRebuild", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_RebuildOnlyOptionsAndNoFragWithSetOptions")]
        [TestCase(0, 0, 0, 1, 1, "None", "AlterRebuild", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_RebuildOnlyOptionsAndNoFragWithSetOptionsAndCompressionChanges")]
        [TestCase(0, 0, 0, 1, 1, "Heavy", "AlterRebuild", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_RebuildOnlyOptionsAndHeavyFragWithSetOptionsAndCompressionChanges")]
        [TestCase(0, 0, 0, 1, 0, "None", "AlterRebuild", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_RebuildOnlyOptionsAndNoFragAndCompressionChanges")]
        [TestCase(0, 0, 1, 0, 0, "Heavy", "AlterRebuild-PartitionLevel", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuildPartitionLevel_HeavyFragOnly")]
        [TestCase(0, 0, 1, 0, 0, "None", "AlterRebuild-PartitionLevel", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_CreateMissing_CompressionChangingOnly")]
        [TestCase(0, 0, 1, 0, 0, "Heavy", "AlterRebuild-PartitionLevel", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterRebuild_CreateMissing_HeavyFragAndCompressionchanging")]
        [TestCase(0, 0, 0, 0, 1, "None", "AlterSet", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterSet")]
        [TestCase(0, 0, 0, 0, 0, "Light", "AlterReorganize", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterReorg")]
        [TestCase(0, 0, 1, 0, 0, "Light", "AlterReorganize-PartitionLevel", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_AlterReorgPartitionLevel")]
        public void ViewTests_vwIndexes_IndexUpdateType_RowStore(
            int isIndexMissingFromSqlServer,
            int areDropRecreateOptionsChanging,
            int needsPartitionLevelOperations,
            int areRebuildOnlyOptionsChanging,
            int areSetOptionsChanging,
            string fragmentationType,
            string expectedIndexUpdateType,
            int isDataCompressionChanging)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);

            sqlHelper.Execute(
                $@" UPDATE DOI.IndexesRowStore 
                        SET IsIndexMissingFromSQLServer = {isIndexMissingFromSqlServer},
                            AreDropRecreateOptionsChanging = {areDropRecreateOptionsChanging},
                            NeedsPartitionLevelOperations = {needsPartitionLevelOperations},
                            AreRebuildOnlyOptionsChanging = {areRebuildOnlyOptionsChanging},
                            AreSetOptionsChanging = {areSetOptionsChanging},
                            FragmentationType = '{fragmentationType}',
                            IsDataCompressionChanging = {isDataCompressionChanging}
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{TestHelper.NCIndexName}'");

            var actualIndexUpdateType = sqlHelper.ExecuteScalar<string>(
                $@" SELECT IndexUpdateType 
                        FROM DOI.vwIndexes 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{TestHelper.NCIndexName}'");

            Assert.AreEqual(expectedIndexUpdateType, actualIndexUpdateType);
        }


        //test case for each combination of ChangeBitGroups and assert that the right IndexUpdateType is shown.
        [TestCase(1, 0, 0, 0, "None", "CreateMissing", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_CreateMissing")]
        [TestCase(0, 1, 0, 0, "None", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_CreateDropExisting")]
        [TestCase(0, 1, 1, 0, "None", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_CreateDropExisting_NeedsPartitionLevelOperationsAlso")]
        [TestCase(0, 1, 1, 1, "None", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_CreateDropExisting_NeedsPartitionLevelOperationsAndRebuildOnlyOptionsChangingAlso")]
        [TestCase(0, 1, 1, 1, "None", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_CreateDropExisting_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso")]
        [TestCase(0, 1, 1, 1, "Heavy", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_CreateDropExisting_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_HeavyFrag")]
        [TestCase(0, 1, 1, 1, "Light", "CreateDropExisting", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_CreateDropExisting_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_LightFrag")]
        [TestCase(0, 1, 1, 1, "Heavy", "CreateDropExisting", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_CreateDropExisting_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_HeavyFrag_CompressionChanging")]
        [TestCase(0, 1, 1, 1, "Light", "CreateDropExisting", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_CreateDropExisting_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_LightFrag_CompressionChanging")]
        [TestCase(0, 0, 0, 0, "Heavy", "AlterRebuild", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_AlterRebuild_HeavyFragOnly")]
        [TestCase(0, 0, 0, 1, "None", "AlterRebuild", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_AlterRebuild_RebuildOnlyOptions")]
        [TestCase(0, 0, 0, 1, "Heavy", "AlterRebuild", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_AlterRebuild_RebuildOnlyOptionsAndHeavyFrag")]
        [TestCase(0, 0, 0, 1, "None", "AlterRebuild", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_AlterRebuild_RebuildOnlyOptionsAndNoFragAndCompressionChanges")]
        [TestCase(0, 0, 1, 0, "Heavy", "AlterRebuild-PartitionLevel", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_AlterRebuildPartitionLevel_HeavyFragOnly")]
        [TestCase(0, 0, 1, 0, "None", "AlterRebuild-PartitionLevel", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_AlterRebuild_CreateMissing_CompressionChangingOnly")]
        [TestCase(0, 0, 1, 0, "Heavy", "AlterRebuild-PartitionLevel", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_AlterRebuild_CreateMissing_HeavyFragAndCompressionchanging")]
        [TestCase(0, 0, 0, 0, "Light", "AlterReorganize", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_AlterReorg")]
        [TestCase(0, 0, 1, 0, "Light", "AlterReorganize-PartitionLevel", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_AlterReorgPartitionLevel")]
        public void ViewTests_vwIndexes_IndexUpdateType_ColumnStore(
            int isIndexMissingFromSqlServer,
            int areDropRecreateOptionsChanging,
            int needsPartitionLevelOperations,
            int areRebuildOnlyOptionsChanging,
            string fragmentationType,
            string expectedIndexUpdateType,
            int isDataCompressionChanging)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateNCCIIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCCIIndexMetadataSql);

            sqlHelper.Execute(
                $@" UPDATE DOI.IndexesColumnStore 
                        SET IsIndexMissingFromSQLServer = {isIndexMissingFromSqlServer},
                            AreDropRecreateOptionsChanging = {areDropRecreateOptionsChanging},
                            NeedsPartitionLevelOperations = {needsPartitionLevelOperations},
                            AreRebuildOnlyOptionsChanging = {areRebuildOnlyOptionsChanging},
                            FragmentationType = '{fragmentationType}',
                            IsDataCompressionChanging = {isDataCompressionChanging}
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{TestHelper.NCCIIndexName}'");

            var actualIndexUpdateType = sqlHelper.ExecuteScalar<string>(
                $@" SELECT IndexUpdateType 
                        FROM DOI.vwIndexes 
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TestTableName1}'
                            AND IndexName = '{TestHelper.NCCIIndexName}'");

            Assert.AreEqual(expectedIndexUpdateType, actualIndexUpdateType);
        }

        #endregion

        #region SQLs should not be NULL Tests
        /*
         * test case for each...type of index and different combinations of data values for the options, partitioned vs. non-partitioned and assert that all the SQL fields have content, if appropriate:
         * 1. DropStatement
         * 2. CreateStatement
         * 3. AlterSetStatement
         * 4. AlterRebuildStatement
         * 5. AlterReorganizeStatement
         * 6. RenameIndexSQL
         * 7. RevertRenameIndexSQL
         * 8. CreatePKAsUniqueIndexSQL (PKs only, all others NULL)
         * 9. DropPKAsUniqueIndexSQL (PKs only, all others NULL)
         */
        #endregion
    }
}
