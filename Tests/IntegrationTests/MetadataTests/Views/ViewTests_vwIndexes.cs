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

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwIndexes : DOIBaseTest
    {
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
            //sqlHelper.Execute(fgTestHelper.GetFilegroupSql(null, "Drop"), 30, true, DatabaseName);
            //sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(null, "Drop"), 30, true, DatabaseName);
        }

        #region NeedsSpaceOnTempDBDrive Tests
        //test case for each IndexUpdateType and assert that NeedsSpaceOnTempDBDrive = 1 on CreateMissing, AlterRebuild, or Clustered index DropRecreate.
        [TestCase("CreateMissing", 0, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_CreateMissing_NC")]
        [TestCase("CreateMissing", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_CreateMissing_C")]
        [TestCase("DropRecreate", 0, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_DropRecreate_NC")]
        [TestCase("DropRecreate", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_RowStore_DropRecreate_C")]
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
        [TestCase("DropRecreate", 0, 0, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_DropRecreate_NC")]
        [TestCase("DropRecreate", 1, 1, TestName = "ViewTests_vwIndexes_NeedsSpaceOnTempDBDrive_ColumnStore_DropRecreate_C")]
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

        #region IsOnlineOperation Tests
        //test case for each IndexUpdateType and assert that IsOnlineOperation follows this logic:
        [TestCase("CreateMissing", "RowStore", 1, 1, TestName = "ViewTests_vwIndexes_IsOnlineOperation_RowStore_CreateMissing")]
        [TestCase("CreateMissing", "ColumnStore", 0, 1, TestName = "ViewTests_vwIndexes_IsOnlineOperation_ColumnStore_CreateMissing")]
        [TestCase("DropRecreate", "RowStore", 1, 0, TestName = "ViewTests_vwIndexes_IsOnlineOperation_RowStore_DropRecreate")]
        [TestCase("DropRecreate", "ColumnStore", 0, 0, TestName = "ViewTests_vwIndexes_IsOnlineOperation_ColumnStore_DropRecreate")]
        [TestCase("AlterRebuild", "RowStore", 1, 0, TestName = "ViewTests_vwIndexes_IsOnlineOperation_RowStore_AlterRebuild_HasLOBColumns")]
        [TestCase("AlterRebuild", "RowStore", 0, 1, TestName = "ViewTests_vwIndexes_IsOnlineOperation_RowStore_AlterRebuild_NoLOBColumns")]

        [TestCase("AlterRebuild", "ColumnStore", 0, 0, TestName = "ViewTests_vwIndexes_IsOnlineOperation_ColumnStore_AlterRebuild")]
        [TestCase("AlterRebuild-PartitionLevel", "RowStore", 1, 0, TestName = "ViewTests_vwIndexes_IsOnlineOperation_RowStore_AlterRebuild-PartitionLevel_HasLOBColumns")]
        [TestCase("AlterRebuild-PartitionLevel", "RowStore", 0, 1, TestName = "ViewTests_vwIndexes_IsOnlineOperation_RowStore_AlterRebuild-PartitionLevel_NoLOBColumns")]

        [TestCase("AlterRebuild-PartitionLevel", "ColumnStore", 0, 0, TestName = "ViewTests_vwIndexes_IsOnlineOperation_ColumnStore_AlterRebuild-PartitionLevel")]
        [TestCase("AlterReorganize", "RowStore", 1, 1, TestName = "ViewTests_vwIndexes_IsOnlineOperation_RowStore_AlterReorganize")]
        [TestCase("AlterReorganize", "ColumnStore", 0, 1, TestName = "ViewTests_vwIndexes_IsOnlineOperation_ColumnStore_AlterReorganize")]
        [TestCase("AlterReorganize-PartitionLevel", "RowStore", 1, 1, TestName = "ViewTests_vwIndexes_IsOnlineOperation_RowStore_AlterReorganize-PartitionLevel")]
        [TestCase("AlterReorganize-PartitionLevel", "ColumnStore", 0, 1, TestName = "ViewTests_vwIndexes_IsOnlineOperation_ColumnStore_AlterReorganize-PartitionLevel")]
        [TestCase("AlterSet", "RowStore", 1, 1, TestName = "ViewTests_vwIndexes_IsOnlineOperation_RowStore_AlterSet")]
        public void ViewTests_vwIndexes_IsOnlineOperation(string indexUpdateType, string indexType, int indexHasLobColumns, int expectedIsOnlineOperation)
        {
            //set up table and index.
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);

            var columnsToUpdateSql = TestHelper.GetColumnsToUpdateFromIndexTypeSql(indexUpdateType);
            var updateSql = string.Empty;
            var getActualIsOnlineOperationSql = string.Empty;

            if (indexType == "RowStore")
            {
                sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);
                updateSql = $@" UPDATE DOI.IndexesRowStore
                                SET {columnsToUpdateSql},
                                    IndexHasLOBColumns = {indexHasLobColumns}
                                WHERE DatabaseName = '{DatabaseName}' 
                                    AND TableName = '{TestTableName1}'
                                    AND IndexName = '{TestHelper.NCIndexName}'";
                getActualIsOnlineOperationSql = $@" SELECT IsOnlineOperation 
                                                    FROM DOI.vwIndexes 
                                                    WHERE DatabaseName = '{DatabaseName}' 
                                                        AND TableName = '{TestTableName1}'
                                                        AND IndexName = '{TestHelper.NCIndexName}'";
            }

            if (indexType == "ColumnStore")
            {
                sqlHelper.Execute(TestHelper.CreateNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.CreateNCCIIndexMetadataSql);
                updateSql = $@" UPDATE DOI.IndexesColumnStore
                                SET {columnsToUpdateSql}
                                WHERE DatabaseName = '{DatabaseName}' 
                                    AND TableName = '{TestTableName1}'
                                    AND IndexName = '{TestHelper.NCCIIndexName}'";
                getActualIsOnlineOperationSql = $@" SELECT IsOnlineOperation 
                                                    FROM DOI.vwIndexes 
                                                    WHERE DatabaseName = '{DatabaseName}' 
                                                        AND TableName = '{TestTableName1}'
                                                        AND IndexName = '{TestHelper.NCCIIndexName}'";
            }

            sqlHelper.Execute(updateSql);

            var actualIsOnlineOperation = sqlHelper.ExecuteScalar<int>(getActualIsOnlineOperationSql);

            Assert.AreEqual(expectedIsOnlineOperation, actualIsOnlineOperation);
        }

        #endregion

        #region ListOfChanges Tests
        //test case for each ChangeBit and assert that the ListOfChanges follows this logic:
        /*
         * 		--KEEP THE ORDER OF THE CASE STATEMENTS BELOW IN ALPHABETICAL ORDER!!!
		,STUFF(CASE WHEN AllIdx.IsAllowPageLocksChanging			= 1						THEN	', AllowPageLocks'								ELSE '' END
				+ CASE WHEN AllIdx.IsAllowRowLocksChanging			= 1						THEN	', AllowRowLocks'									ELSE '' END
				+ CASE WHEN AllIdx.IsClusteredChanging				= 1						THEN	', Clustered'									ELSE '' END
				+ CASE WHEN AllIdx.IsDataCompressionDelayChanging	= 1						THEN	', CompressionDelay'							ELSE '' END
				+ CASE WHEN AllIdx.IsDataCompressionChanging		= 1						THEN	', DataCompression'								ELSE '' END
				+ CASE WHEN AllIdx.IsFillfactorChanging				= 1						THEN	', FillFactor'									ELSE '' END
				+ CASE WHEN AllIdx.IsFilterChanging					= 1						THEN	', Filter'										ELSE '' END
				+ CASE WHEN AllIdx.FragmentationType				IN ('Heavy', 'Light')	THEN	', Fragmentation:  ' + AllIdx.FragmentationType	ELSE '' END 
				+ CASE WHEN AllIdx.IsIgnoreDupKeyChanging			= 1						THEN	', IgnoreDupKey'								ELSE '' END
				+ CASE WHEN AllIdx.IsIncludedColumnListChanging		= 1						THEN	', IncludedColumnList'							ELSE '' END
				+ CASE WHEN AllIdx.IsPrimaryKeyChanging				= 1						THEN	', IsPrimaryKey'								ELSE '' END
				+ CASE WHEN AllIdx.IsKeyColumnListChanging			= 1						THEN	', KeyColumnList'								ELSE '' END
				+ CASE WHEN AllIdx.IsPadIndexChanging				= 1						THEN	', PadIndex'									ELSE '' END
				+ CASE WHEN AllIdx.IsPartitioningChanging			= 1						THEN	', Partitioning'								ELSE '' END
				+ CASE WHEN AllIdx.IsStatisticsNoRecomputeChanging	= 1						THEN	', StatisticsNoRecompute'						ELSE '' END
				+ CASE WHEN AllIdx.IsStatisticsIncrementalChanging	= 1						THEN	', StatisticsIncremental'						ELSE '' END
				+ CASE WHEN AllIdx.IsUniquenessChanging				= 1						THEN	', Uniqueness'									ELSE '' END, 1, 2, SPACE(0)) AS ListOfChanges
         */
        #endregion

        #region IndexUpdateType Tests
        //test case for each combination of ChangeBitGroups and assert that the right IndexUpdateType is shown.
        [TestCase(1, 0, 0, 0, 0, "None", "CreateMissing", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_CreateMissing")]
        [TestCase(0, 1, 0, 0, 0, "None", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_DropRecreate")]
        [TestCase(0, 1, 1, 0, 0, "None", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_DropRecreate_NeedsPartitionLevelOperationsAlso")]
        [TestCase(0, 1, 1, 1, 0, "None", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_DropRecreate_NeedsPartitionLevelOperationsAndRebuildOnlyOptionsChangingAlso")]
        [TestCase(0, 1, 1, 1, 1, "None", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_DropRecreate_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso")]
        [TestCase(0, 1, 1, 1, 1, "Heavy", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_DropRecreate_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_HeavyFrag")]
        [TestCase(0, 1, 1, 1, 1, "Light", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_DropRecreate_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_LightFrag")]
        [TestCase(0, 1, 1, 1, 1, "Heavy", "DropRecreate", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_DropRecreate_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_HeavyFrag_CompressionChanging")]
        [TestCase(0, 1, 1, 1, 1, "Light", "DropRecreate", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_RowStore_DropRecreate_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_LightFrag_CompressionChanging")]
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
        [TestCase(0, 1, 0, 0, "None", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_DropRecreate")]
        [TestCase(0, 1, 1, 0, "None", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_DropRecreate_NeedsPartitionLevelOperationsAlso")]
        [TestCase(0, 1, 1, 1, "None", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_DropRecreate_NeedsPartitionLevelOperationsAndRebuildOnlyOptionsChangingAlso")]
        [TestCase(0, 1, 1, 1, "None", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_DropRecreate_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso")]
        [TestCase(0, 1, 1, 1, "Heavy", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_DropRecreate_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_HeavyFrag")]
        [TestCase(0, 1, 1, 1, "Light", "DropRecreate", 0, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_DropRecreate_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_LightFrag")]
        [TestCase(0, 1, 1, 1, "Heavy", "DropRecreate", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_DropRecreate_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_HeavyFrag_CompressionChanging")]
        [TestCase(0, 1, 1, 1, "Light", "DropRecreate", 1, TestName = "ViewTests_vwIndexes_IndexUpdateType_ColumnStore_DropRecreate_NeedsPartitionLevelOperationsAndAllOtherBitGroupsOnAlso_LightFrag_CompressionChanging")]
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
