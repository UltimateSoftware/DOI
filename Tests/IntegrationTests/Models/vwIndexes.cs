using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class vwIndexes
    {
        public string DatabaseName { get; set; }
        public string SchemaName { get; set; }
        public string TableName { get; set; }
        public string IndexName { get; set; }
        public bool IsIndexMissingFromSQLServer { get; set; }
        public int IsUnique_Desired { get; set; }
        public int IsUnique_Actual { get; set; }
        public int IsPrimaryKey_Desired { get; set; }
        public int IsPrimaryKey_Actual { get; set; }
        public int IsUniqueConstraint_Desired { get; set; }
        public int IsUniqueConstraint_Actual { get; set; }
        public bool IsClustered_Desired { get; set; }
        public bool IsClustered_Actual  { get; set; }
        public string KeyColumnList_Desired   { get; set; }
        public string KeyColumnList_Actual    { get; set; }
        public string IncludedColumnList_Desired  { get; set; }
        public string IncludedColumnList_Actual   { get; set; }
        public bool IsFiltered_Desired  { get; set; }
        public bool IsFiltered_Actual   { get; set; }
        public string FilterPredicate_Desired { get; set; }
        public string FilterPredicate_Actual  { get; set; }
        public int Fillfactor_Desired { get; set; }
        public int Fillfactor_Actual   { get; set; }
        public int OptionPadIndex_Desired  { get; set; }
        public int OptionPadIndex_Actual   { get; set; }
        public int OptionStatisticsNoRecompute_Desired { get; set; }
        public int OptionStatisticsNoRecompute_Actual  { get; set; }
        public int OptionStatisticsIncremental_Desired { get; set; }
        public int OptionStatisticsIncremental_Actual  { get; set; }
        public int OptionIgnoreDupKey_Desired  { get; set; }
        public int OptionIgnoreDupKey_Actual   { get; set; }
        public string OptionDataCompression_Desired   { get; set; }
        public string OptionDataCompression_Actual    { get; set; }
        public int OptionDataCompressionDelay_Desired  { get; set; }
        public int OptionDataCompressionDelay_Actual   { get; set; }
        public int OptionAllowRowLocks_Desired { get; set; }
        public int OptionAllowRowLocks_Actual  { get; set; }
        public int OptionAllowPageLocks_Desired    { get; set; }
        public int OptionAllowPageLocks_Actual { get; set; }
        public int OptionResumable_Desired { get; set; }
        public int OptionMaxDuration_Actual    { get; set; }
        public string PartitionFunction_Desired   { get; set; }
        public string PartitionFunction_Actual    { get; set; }
        public string Storage_Desired { get; set; }
        public string Storage_Actual  { get; set; }
        public int IsStorageChanging   { get; set; }
        public string StorageType_Desired { get; set; }
        public string StorageType_Actual  { get; set; }
        public string PartitionColumn_Desired { get; set; }
        public decimal IndexSizeMB_Actual { get; set; }
        public float Fragmentation { get; set; }
        public bool IntendToPartition   { get; set; }
        public bool NeedsPartitionLevelOperations   { get; set; }
        public int TotalPartitionsInIndex  { get; set; }
        public bool IndexMeetsMinimumSize   { get; set; }
        public string FragmentationType   { get; set; }
        public bool AreDropRecreateOptionsChanging  { get; set; }
        public bool AreRebuildOptionsChanging   { get; set; }
        public bool AreRebuildOnlyOptionsChanging   { get; set; }
        public bool AreReorgOptionsChanging { get; set; }
        public bool AreSetOptionsChanging   { get; set; }
        public int IsUniquenessChanging    { get; set; }
        public int IsPrimaryKeyChanging { get; set; }
        public bool IsKeyColumnListChanging { get; set; }
        public int IsIncludedColumnListChanging { get; set; }
        public bool IsFilterChanging    { get; set; }
        public bool IsClusteredChanging { get; set; }
        public bool IsPartitioningChanging  { get; set; }
        public int IsPadIndexChanging { get; set; }
        public int IsFillfactorChanging { get; set; }
        public int IsIgnoreDupKeyChanging { get; set; }
        public int IsStatisticsNoRecomputeChanging { get; set; }
        public int IsStatisticsIncrementalChanging { get; set; }
        public int IsAllowRowLocksChanging { get; set; }
        public int IsAllowPageLocksChanging { get; set; }
        public bool IsDataCompressionChanging   { get; set; }
        public int IsDataCompressionDelayChanging { get; set; }
        public int IndexHasLOBColumns { get; set; }
        public int NumPages_Actual { get; set; }
        public string IndexType   { get; set; }
        public bool IsIndexLarge    { get; set; }
        public string DriveLetter { get; set; }
        public string IndexUpdateType { get; set; }
        public string DropStatement   { get; set; }
        public string CreateStatement { get; set; }
        public string AlterSetStatement   { get; set; }
        public string AlterRebuildStatement   { get; set; }
        public string AlterReorganizeStatement    { get; set; }
        public string RenameIndexSQL  { get; set; }
        public string RevertRenameIndexSQL    { get; set; }
        public string CreatePKAsUniqueIndexSQL    { get; set; }
        public string DropPKAsUniqueIndexSQL  { get; set; }
        public int NeedsSpaceOnTempDBDrive { get; set; }
        public int IsOnlineOperation { get; set; }
        public string ListOfChanges   { get; set; }
    }
}
