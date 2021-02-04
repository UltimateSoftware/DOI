using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class vwPartitioning_Tables_PrepTables_Indexes
    {
        public string DatabaseName { get; set; }
        public string SchemaName { get; set; }
        public string ParentTableName { get; set; }
        public string ParentIndexName { get; set; }
        public bool IsIndexMissingFromSQLServer { get; set; }
        public string PrepTableName { get; set; }
        public string PrepTableIndexName { get; set; }
        public string PartitionFunctionName { get; set; }
        public DateTime BoundaryValue { get; set; }
        public DateTime NextBoundaryValue { get; set; }
        public int IsNewPartitionedPrepTable { get; set; }
        public string Storage_Actual { get; set; }
        public string StorageType_Actual { get; set; }
        public string Storage_Desired { get; set; }
        public string StorageType_Desired { get; set; }
        public string PrepTableFilegroup { get; set; }
        public decimal IndexSizeMB_Actual { get; set; }
        public string IndexType { get; set; }
        public bool IsClustered_Actual { get; set; }
        public int RowNum { get; set; }
        public string PrepTableIndexCreateSQL { get; set; }
        public string OrigCreateSQL { get; set; }
        public string RenameExistingTableIndexSQL { get; set; }
        public string RevertRenameExistingTableIndexSQL { get; set; }
        public string RenameNewPartitionedPrepTableIndexSQL { get; set; }
        public string RevertRenameNewPartitionedPrepTableIndexSQL { get; set; }
    }
}
