using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using Simple.Data.Ado.Schema;
using Models = DOI.Tests.Integration.Models;

namespace DOI.Tests.TestHelpers.Metadata
{
    public class IndexesHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysIndexes";
        public const string SqlServerDmvName = "sys.indexes";
        public const string UserTableName_RowStore = "IndexesRowStore"; 
        public const string UserTableName_ColumnStore = "IndexesColumnStore";


        public static List<SysIndexes> GetExpectedSysValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}
            WHERE name = '{CIndexName}'"));

            List<SysIndexes> expectedSysIndexes = new List<SysIndexes>();

            foreach (var row in expected)
            {
                var columnValue = new SysIndexes();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.index_id = row.First(x => x.First == "index_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ObjectToInteger();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.is_unique = (bool) row.First(x => x.First == "is_unique").Second;
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.ignore_dup_key = (bool) row.First(x => x.First == "ignore_dup_key").Second;
                columnValue.is_primary_key = (bool) row.First(x => x.First == "is_primary_key").Second;
                columnValue.is_unique_constraint = (bool) row.First(x => x.First == "is_unique_constraint").Second;
                columnValue.fill_factor = row.First(x => x.First == "fill_factor").Second.ObjectToInteger();
                columnValue.is_padded = (bool) row.First(x => x.First == "is_padded").Second;
                columnValue.is_disabled = (bool) row.First(x => x.First == "is_disabled").Second;
                columnValue.is_hypothetical = (bool) row.First(x => x.First == "is_hypothetical").Second;
                columnValue.allow_row_locks = (bool) row.First(x => x.First == "allow_row_locks").Second;
                columnValue.allow_page_locks = (bool) row.First(x => x.First == "allow_page_locks").Second;
                columnValue.has_filter = (bool) row.First(x => x.First == "has_filter").Second;
                columnValue.filter_definition = row.First(x => x.First == "filter_definition").Second.ToString();
                columnValue.compression_delay = row.First(x => x.First == "compression_delay").Second.ObjectToInteger();
                columnValue.key_column_list = "TempAId ASC";
                columnValue.included_column_list = String.Empty;
                columnValue.has_LOB_columns = false;


                expectedSysIndexes.Add(columnValue);
            }

            return expectedSysIndexes;
        }

        public static List<SysIndexes> GetActualSysValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT I.* 
            FROM DOI.DOI.{SysTableName} I 
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = I.database_id 
                INNER JOIN DOI.DOI.SysTables T ON T.database_id = I.database_id
                    AND T.object_id = I.object_id
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{TableName}'
                AND I.name = '{CIndexName}'"));

            List<SysIndexes> actualSysIndexes = new List<SysIndexes>();

            foreach (var row in actual)
            {
                var columnValue = new SysIndexes();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.index_id = row.First(x => x.First == "index_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ObjectToInteger();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.is_unique = (bool) row.First(x => x.First == "is_unique").Second;
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.ignore_dup_key = (bool) row.First(x => x.First == "ignore_dup_key").Second;
                columnValue.is_primary_key = (bool) row.First(x => x.First == "is_primary_key").Second;
                columnValue.is_unique_constraint = (bool) row.First(x => x.First == "is_unique_constraint").Second;
                columnValue.fill_factor = row.First(x => x.First == "fill_factor").Second.ObjectToInteger();
                columnValue.is_padded = (bool) row.First(x => x.First == "is_padded").Second;
                columnValue.is_disabled = (bool) row.First(x => x.First == "is_disabled").Second;
                columnValue.is_hypothetical = (bool) row.First(x => x.First == "is_hypothetical").Second;
                columnValue.allow_row_locks = (bool) row.First(x => x.First == "allow_row_locks").Second;
                columnValue.allow_page_locks = (bool) row.First(x => x.First == "allow_page_locks").Second;
                columnValue.has_filter = (bool) row.First(x => x.First == "has_filter").Second;
                columnValue.filter_definition = row.First(x => x.First == "filter_definition").Second.ToString();
                columnValue.compression_delay = row.First(x => x.First == "compression_delay").Second.ObjectToInteger();
                columnValue.key_column_list = row.First(x => x.First == "key_column_list").Second.ToString();
                columnValue.included_column_list = row.First(x => x.First == "included_column_list").Second.ToString();
                columnValue.has_LOB_columns = (bool)row.First(x => x.First == "has_LOB_columns").Second;

                actualSysIndexes.Add(columnValue);
            }

            return actualSysIndexes;
        }

        private static bool? GetNullableBooleanFromDB(object x)
        {
            return x == DBNull.Value ? null : (bool?) x;
        }
        public static void AssertIndexRowStoreChangeBits(string indexName, string preOrPostChange, string bitToAssert = null)
        {
            var indexRow = GetActualUserValues_RowStore(indexName).Find(x => x.IndexName == indexName);

            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsAllowPageLocksChanging") ? true : false, indexRow.IsAllowPageLocksChanging, "IsAllowPageLocksChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsAllowRowLocksChanging") ? true : false, indexRow.IsAllowRowLocksChanging, "IsAllowRowLocksChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsClusteredChanging") ? true : false, indexRow.IsClusteredChanging, "IsClusteredChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsDataCompressionChanging") ? true : false, indexRow.IsDataCompressionChanging, "IsDataCompressionChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsFillfactorChanging") ? true : false, indexRow.IsFillfactorChanging, "IsFillfactorChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsFilterChanging") ? true : false, indexRow.IsFilterChanging, "IsFilterChanging");
            Assert.AreEqual("None", indexRow.FragmentationType, "IndexFragmentation");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsIgnoreDupKeyChanging") ? true : false, indexRow.IsIgnoreDupKeyChanging, "IsIgnoreDupKeyChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsIncludedColumnListChanging") ? true : false, indexRow.IsIncludedColumnListChanging, "IsIncludedColumnListChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsPrimaryKeyChanging") ? true : false, indexRow.IsPrimaryKeyChanging, "IsPrimaryKeyChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsKeyColumnListChanging") ? true : false, indexRow.IsKeyColumnListChanging, "IsKeyColumnListChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsPadIndexChanging") ? true : false, indexRow.IsPadIndexChanging, "IsPadIndexChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsPartitioningChanging") ? true : false, indexRow.IsPartitioningChanging, "IsPartitioningChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsStatisticsNoRecomputeChanging") ? true : false, indexRow.IsStatisticsNoRecomputeChanging, "IsStatisticsNoRecomputeChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsStatisticsIncrementalChanging") ? true : false, indexRow.IsStatisticsIncrementalChanging, "IsStatisticsIncrementalChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsUniquenessChanging") ? true : false, indexRow.IsUniquenessChanging, "IsUniquenessChanging");
        }

        public static void AssertIndexColumnStoreChangeBits(string indexName, string preOrPostChange, string bitToAssert = null)
        {
            var indexRow = GetActualUserValues_ColumnStore(indexName).Find(x => x.IndexName == indexName);

            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsClusteredChanging") ? true : false, indexRow.IsClusteredChanging, "IsClusteredChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsColumnListChanging") ? true : false, indexRow.IsColumnListChanging, "IsColumnListChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsDataCompressionChanging") ? true : false, indexRow.IsDataCompressionChanging, "IsDataCompressionChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsDataCompressionDelayChanging") ? true : false, indexRow.IsDataCompressionDelayChanging, "IsDataCompressionDelayChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsFilterChanging") ? true : false, indexRow.IsFilterChanging, "IsFilterChanging");
            Assert.AreEqual((preOrPostChange == "Post" && bitToAssert == "IsPartitioningChanging") ? true : false, indexRow.IsPartitioningChanging, "IsPartitioningChanging");
            Assert.AreEqual("None", indexRow.FragmentationType, "IndexFragmentation");
        }


        public static List<IndexesRowStore> GetActualUserValues_RowStore(string indexName = CIndexName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT *
            FROM DOI.DOI.{UserTableName_RowStore} 
            WHERE DatabaseName = '{DatabaseName}'
                AND TableName = '{TableName}'
                AND IndexName = '{indexName}'"));

            List<IndexesRowStore> actualIndexesRowStore = new List<IndexesRowStore>();

            foreach (var row in actual)
            {
                var columnValue = new IndexesRowStore();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.IndexName = row.First(x => x.First == "IndexName").Second.ToString();
                columnValue.IsIndexMissingFromSQLServer = (bool)row.First(x => x.First == "IsIndexMissingFromSQLServer").Second;
                columnValue.IsUnique_Desired = (bool)row.First(x => x.First == "IsUnique_Desired").Second;
                columnValue.IsUnique_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "IsUnique_Actual").Second);
                columnValue.IsPrimaryKey_Desired = (bool)row.First(x => x.First == "IsPrimaryKey_Desired").Second;
                columnValue.IsPrimaryKey_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "IsPrimaryKey_Actual").Second);
                columnValue.IsUniqueConstraint_Desired = (bool)row.First(x => x.First == "IsUniqueConstraint_Desired").Second;
                columnValue.IsUniqueConstraint_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "IsUniqueConstraint_Actual").Second);
                columnValue.IsClustered_Desired = (bool)row.First(x => x.First == "IsClustered_Desired").Second;
                columnValue.IsClustered_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "IsClustered_Actual").Second);
                columnValue.KeyColumnList_Desired = row.First(x => x.First == "KeyColumnList_Desired").Second.ToString();
                columnValue.KeyColumnList_Actual = row.First(x => x.First == "KeyColumnList_Actual").Second.ToString();
                columnValue.IncludedColumnList_Desired = row.First(x => x.First == "IncludedColumnList_Desired").Second.ToString();
                columnValue.IncludedColumnList_Actual = row.First(x => x.First == "IncludedColumnList_Actual").Second.ToString();
                columnValue.IsFiltered_Desired = (bool)row.First(x => x.First == "IsFiltered_Desired").Second;
                columnValue.IsFiltered_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "IsFiltered_Actual").Second);
                columnValue.FilterPredicate_Desired = row.First(x => x.First == "FilterPredicate_Desired").Second.ToString();
                columnValue.FilterPredicate_Actual = row.First(x => x.First == "FilterPredicate_Actual").Second.ToString();
                columnValue.Fillfactor_Desired = row.First(x => x.First == "Fillfactor_Desired").Second.ObjectToInteger();
                columnValue.Fillfactor_Actual = row.First(x => x.First == "Fillfactor_Actual").Second.ObjectToInteger();
                columnValue.OptionPadIndex_Desired = (bool)row.First(x => x.First == "OptionPadIndex_Desired").Second;
                columnValue.OptionPadIndex_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "OptionPadIndex_Actual").Second);
                columnValue.OptionStatisticsNoRecompute_Desired = (bool)row.First(x => x.First == "OptionStatisticsNoRecompute_Desired").Second;
                columnValue.OptionStatisticsNoRecompute_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "OptionStatisticsNoRecompute_Actual").Second);
                columnValue.OptionStatisticsIncremental_Desired = (bool)row.First(x => x.First == "OptionStatisticsIncremental_Desired").Second;
                columnValue.OptionStatisticsIncremental_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "OptionStatisticsIncremental_Actual").Second);
                columnValue.OptionIgnoreDupKey_Desired = (bool)row.First(x => x.First == "OptionIgnoreDupKey_Desired").Second;
                columnValue.OptionIgnoreDupKey_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "OptionIgnoreDupKey_Actual").Second);
                columnValue.OptionResumable_Desired = row.First(x => x.First == "OptionResumable_Desired").Second.ObjectToInteger();
                columnValue.OptionResumable_Actual = row.First(x => x.First == "OptionResumable_Actual").Second.ObjectToInteger();
                columnValue.OptionMaxDuration_Desired = row.First(x => x.First == "OptionMaxDuration_Desired").Second.ObjectToInteger();
                columnValue.OptionMaxDuration_Actual = row.First(x => x.First == "OptionMaxDuration_Actual").Second.ObjectToInteger();
                columnValue.OptionAllowRowLocks_Desired = (bool)row.First(x => x.First == "OptionAllowRowLocks_Desired").Second;
                columnValue.OptionAllowRowLocks_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "OptionAllowRowLocks_Actual").Second);
                columnValue.OptionAllowPageLocks_Desired = (bool)row.First(x => x.First == "OptionAllowPageLocks_Desired").Second;
                columnValue.OptionAllowPageLocks_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "OptionAllowPageLocks_Actual").Second);
                columnValue.OptionDataCompression_Desired = row.First(x => x.First == "OptionDataCompression_Desired").Second.ToString();
                columnValue.OptionDataCompression_Actual = row.First(x => x.First == "OptionDataCompression_Actual").Second.ToString();
                columnValue.Storage_Desired = row.First(x => x.First == "Storage_Desired").Second.ToString();
                columnValue.Storage_Actual = row.First(x => x.First == "Storage_Actual").Second.ToString();
                columnValue.StorageType_Desired = row.First(x => x.First == "StorageType_Desired").Second.ToString();
                columnValue.StorageType_Actual = row.First(x => x.First == "StorageType_Actual").Second.ToString();
                columnValue.PartitionFunction_Desired = row.First(x => x.First == "PartitionFunction_Desired").Second.ToString();
                columnValue.PartitionFunction_Actual = row.First(x => x.First == "PartitionFunction_Actual").Second.ToString();
                columnValue.PartitionColumn_Desired = row.First(x => x.First == "PartitionColumn_Desired").Second.ToString();
                columnValue.PartitionColumn_Actual = row.First(x => x.First == "PartitionColumn_Actual").Second.ToString();
                columnValue.NumRows_Actual = row.First(x => x.First == "NumRows_Actual").Second.ObjectToInteger();
                columnValue.AllColsInTableSize_Estimated = row.First(x => x.First == "AllColsInTableSize_Estimated").Second.ObjectToInteger();
                columnValue.NumFixedKeyCols_Estimated = row.First(x => x.First == "NumFixedKeyCols_Estimated").Second.ObjectToInteger();
                columnValue.NumVarKeyCols_Estimated = row.First(x => x.First == "NumVarKeyCols_Estimated").Second.ObjectToInteger();
                columnValue.NumKeyCols_Estimated = row.First(x => x.First == "NumKeyCols_Estimated").Second.ObjectToInteger();
                columnValue.NumFixedInclCols_Estimated = row.First(x => x.First == "NumFixedInclCols_Estimated").Second.ObjectToInteger();
                columnValue.NumVarInclCols_Estimated = row.First(x => x.First == "NumVarInclCols_Estimated").Second.ObjectToInteger();
                columnValue.NumInclCols_Estimated = row.First(x => x.First == "NumInclCols_Estimated").Second.ObjectToInteger();
                columnValue.NumFixedCols_Estimated = row.First(x => x.First == "NumFixedCols_Estimated").Second.ObjectToInteger();
                columnValue.NumVarCols_Estimated = row.First(x => x.First == "NumVarCols_Estimated").Second.ObjectToInteger();
                columnValue.NumCols_Estimated = row.First(x => x.First == "NumCols_Estimated").Second.ObjectToInteger();
                columnValue.FixedKeyColsSize_Estimated = row.First(x => x.First == "FixedKeyColsSize_Estimated").Second.ObjectToInteger();
                columnValue.VarKeyColsSize_Estimated = row.First(x => x.First == "VarKeyColsSize_Estimated").Second.ObjectToInteger();
                columnValue.KeyColsSize_Estimated = row.First(x => x.First == "KeyColsSize_Estimated").Second.ObjectToInteger();
                columnValue.FixedInclColsSize_Estimated = row.First(x => x.First == "FixedInclColsSize_Estimated").Second.ObjectToInteger();
                columnValue.VarInclColsSize_Estimated = row.First(x => x.First == "VarInclColsSize_Estimated").Second.ObjectToInteger();
                columnValue.InclColsSize_Estimated = row.First(x => x.First == "InclColsSize_Estimated").Second.ObjectToInteger();
                columnValue.FixedColsSize_Estimated = row.First(x => x.First == "FixedColsSize_Estimated").Second.ObjectToInteger();
                columnValue.VarColsSize_Estimated = row.First(x => x.First == "VarColsSize_Estimated").Second.ObjectToInteger();
                columnValue.ColsSize_Estimated = row.First(x => x.First == "ColsSize_Estimated").Second.ObjectToInteger();
                columnValue.PKColsSize_Estimated = row.First(x => x.First == "PKColsSize_Estimated").Second.ObjectToInteger();
                columnValue.NullBitmap_Estimated = row.First(x => x.First == "NullBitmap_Estimated").Second.ObjectToInteger();
                columnValue.Uniqueifier_Estimated = row.First(x => x.First == "Uniqueifier_Estimated").Second.ObjectToInteger();
                columnValue.TotalRowSize_Estimated = row.First(x => x.First == "TotalRowSize_Estimated").Second.ObjectToInteger();
                columnValue.NonClusteredIndexRowLocator_Estimated = row.First(x => x.First == "NonClusteredIndexRowLocator_Estimated").Second.ObjectToInteger();
                columnValue.NumRowsPerPage_Estimated = row.First(x => x.First == "NumRowsPerPage_Estimated").Second.ObjectToInteger();
                columnValue.NumFreeRowsPerPage_Estimated = row.First(x => x.First == "NumFreeRowsPerPage_Estimated").Second.ObjectToInteger();
                columnValue.NumLeafPages_Estimated = row.First(x => x.First == "NumLeafPages_Estimated").Second.ObjectToInteger();
                columnValue.LeafSpaceUsed_Estimated = row.First(x => x.First == "LeafSpaceUsed_Estimated").Second.ObjectToDecimal();
                columnValue.LeafSpaceUsedMB_Estimated = row.First(x => x.First == "LeafSpaceUsedMB_Estimated").Second.ObjectToDecimal();
                columnValue.NumNonLeafLevelsInIndex_Estimated = row.First(x => x.First == "NumNonLeafLevelsInIndex_Estimated").Second.ObjectToInteger();
                columnValue.NumIndexPages_Estimated = row.First(x => x.First == "NumIndexPages_Estimated").Second.ObjectToInteger();
                columnValue.IndexSizeMB_Actual_Estimated = row.First(x => x.First == "IndexSizeMB_Actual_Estimated").Second.ObjectToDecimal();
                columnValue.IndexSizeMB_Actual = row.First(x => x.First == "IndexSizeMB_Actual").Second.ObjectToDecimal();
                columnValue.DriveLetter = row.First(x => x.First == "DriveLetter").Second.ToString();
                columnValue.IsIndexLarge = (bool)row.First(x => x.First == "IsIndexLarge").Second;
                columnValue.IndexMeetsMinimumSize = (bool)row.First(x => x.First == "IndexMeetsMinimumSize").Second;
                columnValue.Fragmentation = (double)row.First(x => x.First == "Fragmentation").Second;
                columnValue.FragmentationType = row.First(x => x.First == "FragmentationType").Second.ToString();
                columnValue.AreDropRecreateOptionsChanging = (bool)row.First(x => x.First == "AreDropRecreateOptionsChanging").Second;
                columnValue.AreRebuildOptionsChanging = (bool)row.First(x => x.First == "AreRebuildOptionsChanging").Second;
                columnValue.AreRebuildOnlyOptionsChanging = (bool)row.First(x => x.First == "AreRebuildOnlyOptionsChanging").Second;
                columnValue.AreReorgOptionsChanging = (bool)row.First(x => x.First == "AreReorgOptionsChanging").Second;
                columnValue.AreSetOptionsChanging = (bool)row.First(x => x.First == "AreSetOptionsChanging").Second;
                columnValue.IsUniquenessChanging = (bool)row.First(x => x.First == "IsUniquenessChanging").Second;
                columnValue.IsPrimaryKeyChanging = (bool)row.First(x => x.First == "IsPrimaryKeyChanging").Second;
                columnValue.IsKeyColumnListChanging = (bool)row.First(x => x.First == "IsKeyColumnListChanging").Second;
                columnValue.IsIncludedColumnListChanging = (bool)row.First(x => x.First == "IsIncludedColumnListChanging").Second;
                columnValue.IsFilterChanging = (bool)row.First(x => x.First == "IsFilterChanging").Second;
                columnValue.IsClusteredChanging = (bool)row.First(x => x.First == "IsClusteredChanging").Second;
                columnValue.IsPartitioningChanging = (bool)row.First(x => x.First == "IsPartitioningChanging").Second;
                columnValue.IsPadIndexChanging = (bool)row.First(x => x.First == "IsPadIndexChanging").Second;
                columnValue.IsFillfactorChanging = (bool)row.First(x => x.First == "IsFillfactorChanging").Second;
                columnValue.IsIgnoreDupKeyChanging = (bool)row.First(x => x.First == "IsIgnoreDupKeyChanging").Second;
                columnValue.IsStatisticsNoRecomputeChanging = (bool)row.First(x => x.First == "IsStatisticsNoRecomputeChanging").Second;
                columnValue.IsStatisticsIncrementalChanging = (bool)row.First(x => x.First == "IsStatisticsIncrementalChanging").Second;
                columnValue.IsAllowRowLocksChanging = (bool)row.First(x => x.First == "IsAllowRowLocksChanging").Second;
                columnValue.IsAllowPageLocksChanging = (bool)row.First(x => x.First == "IsAllowPageLocksChanging").Second;
                columnValue.IsDataCompressionChanging = (bool)row.First(x => x.First == "IsDataCompressionChanging").Second;
                columnValue.IsStorageChanging = (bool)row.First(x => x.First == "IsStorageChanging").Second;
                columnValue.IndexHasLOBColumns = (bool)row.First(x => x.First == "IndexHasLOBColumns").Second;
                columnValue.NumPages_Actual = row.First(x => x.First == "NumPages_Actual").Second.ObjectToInteger();
                columnValue.TotalPartitionsInIndex = row.First(x => x.First == "TotalPartitionsInIndex").Second.ObjectToInteger();
                columnValue.NeedsPartitionLevelOperations = (bool)row.First(x => x.First == "NeedsPartitionLevelOperations").Second;

                actualIndexesRowStore.Add(columnValue);
            }

            return actualIndexesRowStore;
        }

        public static List<IndexesColumnStore> GetActualUserValues_ColumnStore(string indexName = NCCIIndexName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT *
            FROM DOI.DOI.{UserTableName_ColumnStore} 
            WHERE DatabaseName = '{DatabaseName}'
                AND TableName = '{TableName}'
                AND IndexName = '{indexName}'"));

            List<IndexesColumnStore> actualIndexesColumnStore = new List<IndexesColumnStore>();

            foreach (var row in actual)
            {
                var columnValue = new IndexesColumnStore();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.IndexName = row.First(x => x.First == "IndexName").Second.ToString();
                columnValue.IsIndexMissingFromSQLServer = (bool)row.First(x => x.First == "IsIndexMissingFromSQLServer").Second;
                columnValue.IsClustered_Desired = (bool)row.First(x => x.First == "IsClustered_Desired").Second;
                columnValue.IsClustered_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "IsClustered_Actual").Second);
                columnValue.ColumnList_Desired = row.First(x => x.First == "ColumnList_Desired").Second.ToString();
                columnValue.ColumnList_Actual = row.First(x => x.First == "ColumnList_Actual").Second.ToString();
                columnValue.IsFiltered_Desired = (bool)row.First(x => x.First == "IsFiltered_Desired").Second;
                columnValue.IsFiltered_Actual = GetNullableBooleanFromDB(row.First(x => x.First == "IsFiltered_Actual").Second);
                columnValue.FilterPredicate_Desired = row.First(x => x.First == "FilterPredicate_Desired").Second.ToString();
                columnValue.FilterPredicate_Actual = row.First(x => x.First == "FilterPredicate_Actual").Second.ToString();
                columnValue.OptionDataCompression_Desired = row.First(x => x.First == "OptionDataCompression_Desired").Second.ToString();
                columnValue.OptionDataCompression_Actual = row.First(x => x.First == "OptionDataCompression_Actual").Second.ToString();
                columnValue.OptionDataCompressionDelay_Desired = row.First(x => x.First == "OptionDataCompressionDelay_Desired").Second.ObjectToInteger();
                columnValue.OptionDataCompressionDelay_Actual = row.First(x => x.First == "OptionDataCompressionDelay_Actual").Second.ObjectToInteger(); 
                columnValue.Storage_Desired = row.First(x => x.First == "Storage_Desired").Second.ToString();
                columnValue.Storage_Actual = row.First(x => x.First == "Storage_Actual").Second.ToString();
                columnValue.StorageType_Desired = row.First(x => x.First == "StorageType_Desired").Second.ToString();
                columnValue.StorageType_Actual = row.First(x => x.First == "StorageType_Actual").Second.ToString();
                columnValue.PartitionFunction_Desired = row.First(x => x.First == "PartitionFunction_Desired").Second.ToString();
                columnValue.PartitionFunction_Actual = row.First(x => x.First == "PartitionFunction_Actual").Second.ToString();
                columnValue.PartitionColumn_Desired = row.First(x => x.First == "PartitionColumn_Desired").Second.ToString();
                columnValue.PartitionColumn_Actual = row.First(x => x.First == "PartitionColumn_Actual").Second.ToString();
                columnValue.AllColsInTableSize_Estimated = row.First(x => x.First == "AllColsInTableSize_Estimated").Second.ObjectToInteger();
                columnValue.NumFixedCols_Estimated = row.First(x => x.First == "NumFixedCols_Estimated").Second.ObjectToInteger();
                columnValue.NumVarCols_Estimated = row.First(x => x.First == "NumVarCols_Estimated").Second.ObjectToInteger();
                columnValue.NumCols_Estimated = row.First(x => x.First == "NumCols_Estimated").Second.ObjectToInteger();
                columnValue.FixedColsSize_Estimated = row.First(x => x.First == "FixedColsSize_Estimated").Second.ObjectToInteger();
                columnValue.VarColsSize_Estimated = row.First(x => x.First == "VarColsSize_Estimated").Second.ObjectToInteger();
                columnValue.ColsSize_Estimated = row.First(x => x.First == "ColsSize_Estimated").Second.ObjectToInteger();
                columnValue.NumRows_Actual = row.First(x => x.First == "NumRows_Actual").Second.ObjectToInteger();
                columnValue.IndexSizeMB_Actual = row.First(x => x.First == "IndexSizeMB_Actual").Second.ObjectToDecimal();
                columnValue.DriveLetter = row.First(x => x.First == "DriveLetter").Second.ToString();
                columnValue.IsIndexLarge = (bool)row.First(x => x.First == "IsIndexLarge").Second;
                columnValue.IndexMeetsMinimumSize = (bool)row.First(x => x.First == "IndexMeetsMinimumSize").Second;
                columnValue.Fragmentation = (double)row.First(x => x.First == "Fragmentation").Second;
                columnValue.FragmentationType = row.First(x => x.First == "FragmentationType").Second.ToString();
                columnValue.AreDropRecreateOptionsChanging = (bool)row.First(x => x.First == "AreDropRecreateOptionsChanging").Second;
                columnValue.AreRebuildOptionsChanging = (bool)row.First(x => x.First == "AreRebuildOptionsChanging").Second;
                columnValue.AreRebuildOnlyOptionsChanging = (bool)row.First(x => x.First == "AreRebuildOnlyOptionsChanging").Second;
                columnValue.AreReorgOptionsChanging = (bool)row.First(x => x.First == "AreReorgOptionsChanging").Second;
                columnValue.AreSetOptionsChanging = (bool)row.First(x => x.First == "AreSetOptionsChanging").Second;
                columnValue.IsColumnListChanging = (bool)row.First(x => x.First == "IsColumnListChanging").Second;
                columnValue.IsFilterChanging = (bool)row.First(x => x.First == "IsFilterChanging").Second;
                columnValue.IsClusteredChanging = (bool)row.First(x => x.First == "IsClusteredChanging").Second;
                columnValue.IsPartitioningChanging = (bool)row.First(x => x.First == "IsPartitioningChanging").Second;
                columnValue.IsDataCompressionChanging = (bool)row.First(x => x.First == "IsDataCompressionChanging").Second;
                columnValue.IsDataCompressionDelayChanging = (bool)row.First(x => x.First == "IsDataCompressionDelayChanging").Second;
                columnValue.IsStorageChanging = (bool)row.First(x => x.First == "IsStorageChanging").Second;
                columnValue.NumPages_Actual = row.First(x => x.First == "NumPages_Actual").Second.ObjectToInteger();
                columnValue.TotalPartitionsInIndex = row.First(x => x.First == "TotalPartitionsInIndex").Second.ObjectToInteger();
                columnValue.NeedsPartitionLevelOperations = (bool)row.First(x => x.First == "NeedsPartitionLevelOperations").Second;

                actualIndexesColumnStore.Add(columnValue);
            }

            return actualIndexesColumnStore;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertSysMetadata()
        {
            var expected = GetExpectedSysValues();

            Assert.AreEqual(1, expected.Count);

            var actual = GetActualSysValues();

            Assert.AreEqual(1, actual.Count);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.object_id == expectedRow.object_id && x.index_id == expectedRow.index_id);

                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.index_id, actualRow.index_id);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.is_unique, actualRow.is_unique);
                Assert.AreEqual(expectedRow.data_space_id, actualRow.data_space_id);
                Assert.AreEqual(expectedRow.ignore_dup_key, actualRow.ignore_dup_key);
                Assert.AreEqual(expectedRow.is_primary_key, actualRow.is_primary_key);
                Assert.AreEqual(expectedRow.is_unique_constraint, actualRow.is_unique_constraint);
                switch (expectedRow.fill_factor)
                {
                    case 0:
                        Assert.AreEqual(100, actualRow.fill_factor); //fill factors are translated from 0 to 100 in our system.
                        break;
                    default:
                        Assert.AreEqual(expectedRow.fill_factor, actualRow.fill_factor);
                        break;
                }
                Assert.AreEqual(expectedRow.is_padded, actualRow.is_padded);
                Assert.AreEqual(expectedRow.is_disabled, actualRow.is_disabled);
                Assert.AreEqual(expectedRow.is_hypothetical, actualRow.is_hypothetical);
                Assert.AreEqual(expectedRow.allow_row_locks, actualRow.allow_row_locks);
                Assert.AreEqual(expectedRow.allow_page_locks, actualRow.allow_page_locks);
                Assert.AreEqual(expectedRow.has_filter, actualRow.has_filter);
                Assert.AreEqual(expectedRow.filter_definition, actualRow.filter_definition);
                Assert.AreEqual(expectedRow.compression_delay, actualRow.compression_delay);
                Assert.AreEqual(expectedRow.key_column_list, actualRow.key_column_list);
                Assert.AreEqual(expectedRow.included_column_list, actualRow.included_column_list);
                Assert.AreEqual(expectedRow.has_LOB_columns, actualRow.has_LOB_columns);
            }
        }

        public static void AssertUserMetadata_RowStore()
        {
            var actual = GetActualUserValues_RowStore();

            Assert.AreEqual(1, actual.Count);

            foreach (var row in actual)
            {
                Assert.AreEqual(false, row.IsIndexMissingFromSQLServer, "IsIndexMissingFromSQLServer");
                Assert.AreEqual(row.IsUnique_Desired, row.IsUnique_Actual, "IsUnique_Actual");
                Assert.AreEqual(row.IsPrimaryKey_Desired, row.IsPrimaryKey_Actual, "IsPrimaryKey_Actual");
                Assert.AreEqual(row.IsUniqueConstraint_Desired, row.IsUniqueConstraint_Actual, "IsUniqueConstraint_Actual");
                Assert.AreEqual(row.IsClustered_Desired, row.IsClustered_Actual, "IsClustered_Actual");
                Assert.AreEqual(row.KeyColumnList_Desired, row.KeyColumnList_Actual, "KeyColumnList_Actual");
                Assert.AreEqual(row.IncludedColumnList_Desired, row.IncludedColumnList_Actual, "IncludedColumnList_Actual");
                Assert.AreEqual(row.IsFiltered_Desired, row.IsFiltered_Actual, "IsFiltered_Actual");
                Assert.AreEqual(row.FilterPredicate_Desired, row.FilterPredicate_Actual, "FilterPredicate_Actual");
                Assert.AreEqual(row.Fillfactor_Desired, row.Fillfactor_Actual, "Fillfactor_Actual");
                Assert.AreEqual(row.OptionPadIndex_Desired, row.OptionPadIndex_Actual, "OptionPadIndex_Actual");
                Assert.AreEqual(row.OptionStatisticsNoRecompute_Desired, row.OptionStatisticsNoRecompute_Actual, "OptionStatisticsNoRecompute_Actual");
                Assert.AreEqual(row.OptionStatisticsIncremental_Desired, row.OptionStatisticsIncremental_Actual, "OptionStatisticsIncremental_Actual");
                Assert.AreEqual(row.OptionIgnoreDupKey_Desired, row.OptionIgnoreDupKey_Actual, "OptionIgnoreDupKey_Actual");
                Assert.AreEqual(row.OptionResumable_Desired, row.OptionResumable_Actual, "OptionResumable_Actual");
                Assert.AreEqual(row.OptionMaxDuration_Desired, row.OptionMaxDuration_Actual, "OptionMaxDuration_Actual");
                Assert.AreEqual(row.OptionAllowRowLocks_Desired, row.OptionAllowRowLocks_Actual, "OptionAllowRowLocks_Actual");
                Assert.AreEqual(row.OptionAllowPageLocks_Desired, row.OptionAllowPageLocks_Actual, "OptionAllowPageLocks_Actual");
                Assert.AreEqual(row.OptionDataCompression_Desired, row.OptionDataCompression_Actual, "OptionDataCompression_Actual");
                Assert.AreEqual(row.Storage_Desired, row.Storage_Actual, "Storage_Actual");
                Assert.AreEqual(row.StorageType_Desired, row.StorageType_Actual, "StorageType_Actual");
                Assert.AreEqual(row.PartitionFunction_Desired, row.PartitionFunction_Actual, "PartitionFunction_Actual");
                Assert.AreEqual(row.PartitionColumn_Desired, row.PartitionColumn_Actual, "PartitionColumn_Actual");
                Assert.AreEqual(0, row.AllColsInTableSize_Estimated, "AllColsInTableSize_Estimated"); 
                Assert.AreEqual(0, row.NumFixedKeyCols_Estimated, "NumFixedKeyCols_Estimated");
                Assert.AreEqual(0, row.NumVarKeyCols_Estimated, "NumVarKeyCols_Estimated");
                Assert.AreEqual(0, row.NumKeyCols_Estimated, "NumKeyCols_Estimated");
                Assert.AreEqual(0, row.NumFixedInclCols_Estimated, "NumFixedInclCols_Estimated");
                Assert.AreEqual(0, row.NumVarInclCols_Estimated, "NumVarInclCols_Estimated");
                Assert.AreEqual(0, row.NumInclCols_Estimated, "NumInclCols_Estimated");
                Assert.AreEqual(0, row.NumFixedCols_Estimated, "NumFixedCols_Estimated");
                Assert.AreEqual(0, row.NumVarCols_Estimated, "NumVarCols_Estimated");
                Assert.AreEqual(0, row.NumCols_Estimated, "NumCols_Estimated");
                Assert.AreEqual(0, row.FixedKeyColsSize_Estimated, "FixedKeyColsSize_Estimated");
                Assert.AreEqual(0, row.VarKeyColsSize_Estimated, "VarKeyColsSize_Estimated");
                Assert.AreEqual(0, row.KeyColsSize_Estimated, "KeyColsSize_Estimated");
                Assert.AreEqual(0, row.FixedInclColsSize_Estimated, "FixedInclColsSize_Estimated");
                Assert.AreEqual(0, row.VarInclColsSize_Estimated, "VarInclColsSize_Estimated");
                Assert.AreEqual(0, row.InclColsSize_Estimated, "InclColsSize_Estimated");
                Assert.AreEqual(0, row.FixedColsSize_Estimated, "FixedColsSize_Estimated");
                Assert.AreEqual(0, row.VarColsSize_Estimated, "VarColsSize_Estimated");
                Assert.AreEqual(0, row.ColsSize_Estimated, "ColsSize_Estimated");
                Assert.AreEqual(16, row.PKColsSize_Estimated, "PKColsSize_Estimated");
                Assert.AreEqual(2, row.NullBitmap_Estimated, "NullBitmap_Estimated");
                //Assert.AreEqual(0, row.Uniqueifier_Estimated, "Uniqueifier_Estimated");
                Assert.AreEqual(15, row.TotalRowSize_Estimated, "TotalRowSize_Estimated");
                Assert.AreEqual(0, row.NonClusteredIndexRowLocator_Estimated, "NonClusteredIndexRowLocator_Estimated");
                Assert.AreEqual(476, row.NumRowsPerPage_Estimated, "NumRowsPerPage_Estimated");
                Assert.AreEqual(0, row.NumFreeRowsPerPage_Estimated, "NumFreeRowsPerPage_Estimated");
                Assert.AreEqual(0, row.NumLeafPages_Estimated, "NumLeafPages_Estimated");
                Assert.AreEqual(0.00m, row.LeafSpaceUsed_Estimated, "LeafSpaceUsed_Estimated");
                Assert.AreEqual(0.00m, row.LeafSpaceUsedMB_Estimated, "LeafSpaceUsedMB_Estimated");
                Assert.AreEqual(1, row.NumNonLeafLevelsInIndex_Estimated, "NumNonLeafLevelsInIndex_Estimated");
                Assert.AreEqual(1, row.NumIndexPages_Estimated, "NumIndexPages_Estimated");
                Assert.AreEqual(0.01m, row.IndexSizeMB_Actual_Estimated, "IndexSizeMB_Actual_Estimated");
                //Assert.AreEqual(0, row.IndexSizeMB_Actual, "IndexSizeMB_Actual");
                Assert.AreEqual("C", row.DriveLetter, "DriveLetter");
                Assert.AreEqual(false, row.IsIndexLarge, "IsIndexLarge");
                Assert.AreEqual(false, row.IndexMeetsMinimumSize, "IndexMeetsMinimumSize");
                Assert.AreEqual(0, row.Fragmentation, "Fragmentation");
                Assert.AreEqual("None", row.FragmentationType, "FragmentationType");
                Assert.AreEqual(false, row.AreDropRecreateOptionsChanging, "AreDropRecreateOptionsChanging");
                Assert.AreEqual(false, row.AreRebuildOptionsChanging, "AreRebuildOptionsChanging"); 
                Assert.AreEqual(false, row.AreRebuildOnlyOptionsChanging, "AreRebuildOnlyOptionsChanging");
                Assert.AreEqual(false, row.AreReorgOptionsChanging, "AreReorgOptionsChanging"); 
                Assert.AreEqual(false, row.AreSetOptionsChanging, "AreSetOptionsChanging");
                Assert.AreEqual(false, row.IsUniquenessChanging, "IsUniquenessChanging"); 
                Assert.AreEqual(false, row.IsPrimaryKeyChanging, "IsPrimaryKeyChanging");
                Assert.AreEqual(false, row.IsKeyColumnListChanging, "IsKeyColumnListChanging"); 
                Assert.AreEqual(false, row.IsIncludedColumnListChanging, "IsIncludedColumnListChanging");
                Assert.AreEqual(false, row.IsFilterChanging, "IsFilterChanging"); 
                Assert.AreEqual(false, row.IsClusteredChanging, "IsClusteredChanging");
                Assert.AreEqual(false, row.IsPartitioningChanging, "IsPartitioningChanging"); 
                Assert.AreEqual(false, row.IsPadIndexChanging, "IsPadIndexChanging");
                Assert.AreEqual(false, row.IsFillfactorChanging, "IsFillfactorChanging"); 
                Assert.AreEqual(false, row.IsIgnoreDupKeyChanging, "IsIgnoreDupKeyChanging");
                Assert.AreEqual(false, row.IsStatisticsNoRecomputeChanging, "IsStatisticsNoRecomputeChanging"); 
                Assert.AreEqual(false, row.IsStatisticsIncrementalChanging, "IsStatisticsIncrementalChanging");
                Assert.AreEqual(false, row.IsAllowRowLocksChanging, "IsAllowRowLocksChanging");
                Assert.AreEqual(false, row.IsAllowPageLocksChanging, "IsAllowPageLocksChanging");
                Assert.AreEqual(false, row.IsDataCompressionChanging, "IsDataCompressionChanging"); 
                Assert.AreEqual(false, row.IsStorageChanging, "IsStorageChanging");
                Assert.AreEqual(false, row.IndexHasLOBColumns, "IndexHasLOBColumns");
                //Assert.AreEqual(0, row.NumPages_Actual, "NumPages_Actual");
                Assert.AreEqual(0, row.TotalPartitionsInIndex, "TotalPartitionsInIndex");
                Assert.AreEqual(false, row.NeedsPartitionLevelOperations, "NeedsPartitionLevelOperations");
            }
        }

        public static void AssertUserMetadata_ColumnStore(int expectedNumPages, int expectedNumRows, decimal expectedIndexSizeMB)
        {
            var actual = GetActualUserValues_ColumnStore();

            Assert.AreEqual(1, actual.Count);

            foreach (var row in actual)
            {
                Assert.AreEqual(false, row.IsIndexMissingFromSQLServer, "IsIndexMissingFromSQLServer");
                Assert.AreEqual(row.IsClustered_Desired, row.IsClustered_Actual, "IsClustered_Actual");
                Assert.AreEqual(row.ColumnList_Desired, row.ColumnList_Actual, "ColumnList_Actual");
                Assert.AreEqual(row.IsFiltered_Desired, row.IsFiltered_Actual, "IsFiltered_Actual");
                Assert.AreEqual(row.FilterPredicate_Desired, row.FilterPredicate_Actual, "FilterPredicate_Actual");
                Assert.AreEqual(row.OptionDataCompression_Desired, row.OptionDataCompression_Actual, "OptionDataCompression_Actual");
                Assert.AreEqual(row.OptionDataCompressionDelay_Desired, row.OptionDataCompressionDelay_Actual, "OptionDataCompressionDelay_Actual");
                Assert.AreEqual(row.Storage_Desired, row.Storage_Actual, "Storage_Actual");
                Assert.AreEqual(row.StorageType_Desired, row.StorageType_Actual, "StorageType_Actual");
                Assert.AreEqual(row.PartitionFunction_Desired, row.PartitionFunction_Actual, "PartitionFunction_Actual");
                Assert.AreEqual(row.PartitionColumn_Desired, row.PartitionColumn_Actual, "PartitionColumn_Actual");
                Assert.AreEqual(0, row.AllColsInTableSize_Estimated, "AllColsInTableSize_Estimated");
                Assert.AreEqual(0, row.NumFixedCols_Estimated, "NumFixedCols_Estimated");
                Assert.AreEqual(0, row.NumVarCols_Estimated, "NumVarCols_Estimated");
                Assert.AreEqual(0, row.NumCols_Estimated, "NumCols_Estimated");
                Assert.AreEqual(0, row.FixedColsSize_Estimated, "FixedColsSize_Estimated");
                Assert.AreEqual(0, row.VarColsSize_Estimated, "VarColsSize_Estimated");
                Assert.AreEqual(0, row.ColsSize_Estimated, "ColsSize_Estimated");
                Assert.AreEqual(expectedNumRows, row.NumRows_Actual, "NumRows_Actual");
                //Assert.AreEqual(expectedIndexSizeMB, row.IndexSizeMB_Actual, "IndexSizeMB_Actual");
                Assert.AreEqual("C", row.DriveLetter, "DriveLetter");
                Assert.AreEqual(false, row.IsIndexLarge, "IsIndexLarge");
                Assert.AreEqual(false, row.IndexMeetsMinimumSize, "IndexMeetsMinimumSize");
                Assert.AreEqual(0, row.Fragmentation, "Fragmentation");
                Assert.AreEqual("None", row.FragmentationType, "FragmentationType");
                Assert.AreEqual(false, row.AreDropRecreateOptionsChanging, "AreDropRecreateOptionsChanging");
                Assert.AreEqual(false, row.AreRebuildOptionsChanging, "AreRebuildOptionsChanging");
                Assert.AreEqual(false, row.AreRebuildOnlyOptionsChanging, "AreRebuildOnlyOptionsChanging");
                Assert.AreEqual(false, row.AreReorgOptionsChanging, "AreReorgOptionsChanging");
                Assert.AreEqual(false, row.AreSetOptionsChanging, "AreSetOptionsChanging");
                Assert.AreEqual(false, row.IsFilterChanging, "IsFilterChanging");
                Assert.AreEqual(false, row.IsClusteredChanging, "IsClusteredChanging");
                Assert.AreEqual(false, row.IsPartitioningChanging, "IsPartitioningChanging");
                Assert.AreEqual(false, row.IsDataCompressionChanging, "IsDataCompressionChanging");
                Assert.AreEqual(false, row.IsDataCompressionDelayChanging, "IsDataCompressionDelayChanging");
                Assert.AreEqual(false, row.IsStorageChanging, "IsStorageChanging");
                //Assert.AreEqual(expectedNumPages, row.NumPages_Actual, "NumPages_Actual");
                Assert.AreEqual(0, row.TotalPartitionsInIndex, "TotalPartitionsInIndex");
                Assert.AreEqual(false, row.NeedsPartitionLevelOperations, "NeedsPartitionLevelOperations");
            }
        }

        public static void ReclusterTableWithColumnStore(string indexName)
        {
            SqlHelper sqlHelper = new SqlHelper();

            if (indexName == CCIIndexName)
            {
                sqlHelper.Execute(DropCIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(DropCIndexMetadataSql);
                sqlHelper.Execute(DropNCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(DropNCCIndexMetadataSql);
                sqlHelper.Execute(CreateCCIIndexSql, 30, true, DatabaseName);
                sqlHelper.Execute(CreateCCIIndexMetadataSql);
            }
        }
    }
}
