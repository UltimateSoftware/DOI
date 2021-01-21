using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class IndexesRowStore
    {
        public string DatabaseName { get; set; }
        public string SchemaName { get; set; }
        public string TableName { get; set; }
        public string IndexName { get; set; }
        public bool IsIndexMissingFromSQLServer { get; set; }
        public bool IsUnique_Desired { get; set; }
        public bool? IsUnique_Actual { get; set; }
        public bool IsPrimaryKey_Desired { get; set; }
        public bool? IsPrimaryKey_Actual { get; set; }
        public bool IsUniqueConstraint_Desired { get; set; }
        public bool? IsUniqueConstraint_Actual { get; set; }
        public bool IsClustered_Desired { get; set; }
        public bool? IsClustered_Actual { get; set; }
        public string KeyColumnList_Desired { get; set; }
        public string KeyColumnList_Actual { get; set; }
        public string IncludedColumnList_Desired { get; set; }
        public string IncludedColumnList_Actual { get; set; }
        public bool IsFiltered_Desired { get; set; }
        public bool? IsFiltered_Actual { get; set; }
        public string FilterPredicate_Desired { get; set; }
        public string FilterPredicate_Actual { get; set; }
        public int Fillfactor_Desired { get; set; }
        public int Fillfactor_Actual { get; set; }
        public bool OptionPadIndex_Desired { get; set; }
        public bool? OptionPadIndex_Actual { get; set; }
        public bool OptionStatisticsNoRecompute_Desired { get; set; }
        public bool? OptionStatisticsNoRecompute_Actual { get; set; }
        public bool OptionStatisticsIncremental_Desired { get; set; }
        public bool? OptionStatisticsIncremental_Actual { get; set; }
        public bool OptionIgnoreDupKey_Desired { get; set; }
        public bool? OptionIgnoreDupKey_Actual { get; set; }
        public int OptionResumable_Desired { get; set; }
        public int OptionResumable_Actual { get; set; }
        public int OptionMaxDuration_Desired { get; set; }
        public int OptionMaxDuration_Actual { get; set; }
        public bool OptionAllowRowLocks_Desired { get; set; }
        public bool? OptionAllowRowLocks_Actual { get; set; }
        public bool OptionAllowPageLocks_Desired { get; set; }
        public bool? OptionAllowPageLocks_Actual { get; set; }
        public string OptionDataCompression_Desired { get; set; }
        public string OptionDataCompression_Actual { get; set; }
        public string Storage_Desired { get; set; }
        public string Storage_Actual { get; set; }
        public string StorageType_Desired { get; set; }
        public string StorageType_Actual { get; set; }
        public string PartitionFunction_Desired { get; set; }
        public string PartitionFunction_Actual { get; set; }
        public string PartitionColumn_Desired { get; set; }
        public string PartitionColumn_Actual { get; set; }
        public Int64 NumRows_Actual { get; set; }
        public int AllColsInTableSize_Estimated { get; set; }
        public int NumFixedKeyCols_Estimated { get; set; }
        public int NumVarKeyCols_Estimated { get; set; }
        public int NumKeyCols_Estimated { get; set; }
        public int NumFixedInclCols_Estimated { get; set; }
        public int NumVarInclCols_Estimated { get; set; }
        public int NumInclCols_Estimated { get; set; }
        public int NumFixedCols_Estimated { get; set; }
        public int NumVarCols_Estimated { get; set; }
        public int NumCols_Estimated { get; set; }
        public int FixedKeyColsSize_Estimated { get; set; }
        public int VarKeyColsSize_Estimated { get; set; }
        public int KeyColsSize_Estimated { get; set; }
        public int FixedInclColsSize_Estimated { get; set; }
        public int VarInclColsSize_Estimated { get; set; }
        public int InclColsSize_Estimated { get; set; }
        public int FixedColsSize_Estimated { get; set; }
        public int VarColsSize_Estimated { get; set; }
        public int ColsSize_Estimated { get; set; }
        public int PKColsSize_Estimated { get; set; }
        public int NullBitmap_Estimated { get; set; }
        public int Uniqueifier_Estimated { get; set; }
        public int TotalRowSize_Estimated { get; set; }
        public int NonClusteredIndexRowLocator_Estimated { get; set; }
        public int NumRowsPerPage_Estimated { get; set; }
        public int NumFreeRowsPerPage_Estimated { get; set; }
        public int NumLeafPages_Estimated { get; set; }
        public decimal LeafSpaceUsed_Estimated { get; set; }
        public decimal LeafSpaceUsedMB_Estimated { get; set; }
        public int NumNonLeafLevelsInIndex_Estimated { get; set; }
        public int NumIndexPages_Estimated { get; set; }
        public decimal IndexSizeMB_Actual_Estimated { get; set; }
        public decimal IndexSizeMB_Actual { get; set; }
        public string DriveLetter { get; set; }
        public bool IsIndexLarge { get; set; }
        public bool IndexMeetsMinimumSize { get; set; }
        public double Fragmentation { get; set; }
        public string FragmentationType { get; set; }
        public bool AreDropRecreateOptionsChanging { get; set; }
        public bool AreRebuildOptionsChanging { get; set; }
        public bool AreRebuildOnlyOptionsChanging { get; set; }
        public bool AreReorgOptionsChanging { get; set; }
        public bool AreSetOptionsChanging { get; set; }
        public bool IsUniquenessChanging { get; set; }
        public bool IsPrimaryKeyChanging { get; set; }
        public bool IsKeyColumnListChanging { get; set; }
        public bool IsIncludedColumnListChanging { get; set; }
        public bool IsFilterChanging { get; set; }
        public bool IsClusteredChanging { get; set; }
        public bool IsPartitioningChanging { get; set; }
        public bool IsPadIndexChanging { get; set; }
        public bool IsFillfactorChanging { get; set; }
        public bool IsIgnoreDupKeyChanging { get; set; }
        public bool IsStatisticsNoRecomputeChanging { get; set; }
        public bool IsStatisticsIncrementalChanging { get; set; }
        public bool IsAllowRowLocksChanging { get; set; }
        public bool IsAllowPageLocksChanging { get; set; }
        public bool IsDataCompressionChanging { get; set; }
        public bool IsStorageChanging { get; set; }
        public bool IndexHasLOBColumns { get; set; }
        public int NumPages_Actual { get; set; }
        public int TotalPartitionsInIndex { get; set; }
        public bool NeedsPartitionLevelOperations { get; set; }
    }
}
