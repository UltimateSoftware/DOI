using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class IndexesColumnStore
    {
        public string DatabaseName { get; set; }
        public string SchemaName { get; set; }
        public string TableName { get; set; }
        public string IndexName { get; set; }
        public bool IsIndexMissingFromSQLServer { get; set; }
        public bool IsClustered_Desired { get; set; }
        public bool IsClustered_Actual { get; set; }
        public string ColumnList_Desired { get; set; }
        public string ColumnList_Actual { get; set; }
        public bool IsFiltered_Desired { get; set; }
        public bool IsFiltered_Actual { get; set; }
        public string FilterPredicate_Desired { get; set; }
        public string FilterPredicate_Actual { get; set; }
        public string OptionDataCompression_Desired { get; set; }
        public string OptionDataCompression_Actual { get; set; }
        public int OptionDataCompressionDelay_Desired { get; set; }
        public int OptionDataCompressionDelay_Actual { get; set; }
        public string Storage_Desired { get; set; }
        public string Storage_Actual { get; set; }
        public string StorageType_Desired { get; set; }
        public string StorageType_Actual { get; set; }
        public string PartitionFunction_Desired { get; set; }
        public string PartitionFunction_Actual { get; set; }
        public string PartitionColumn_Desired { get; set; }
        public string PartitionColumn_Actual { get; set; }
        public int AllColsInTableSize_Estimated { get; set; }
        public int NumFixedCols_Estimated { get; set; }
        public int NumVarCols_Estimated { get; set; }
        public int NumCols_Estimated { get; set; }
        public int FixedColsSize_Estimated { get; set; }
        public int VarColsSize_Estimated { get; set; }
        public int ColsSize_Estimated { get; set; }
        public int NumRows_Actual { get; set; }
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
        public bool IsColumnListChanging { get; set; }
        public bool IsFilterChanging { get; set; }
        public bool IsClusteredChanging { get; set; }
        public bool IsPartitioningChanging { get; set; }
        public bool IsDataCompressionChanging { get; set; }
        public bool IsDataCompressionDelayChanging { get; set; }
        public bool IsStorageChanging { get; set; }
        public int NumPages_Actual { get; set; }
        public int TotalPartitionsInIndex { get; set; }
        public bool NeedsPartitionLevelOperations { get; set; }
    }
}