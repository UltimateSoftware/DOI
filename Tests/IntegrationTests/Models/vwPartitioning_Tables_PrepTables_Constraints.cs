using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class vwPartitioning_Tables_PrepTables_Constraints
    {
        public string DatabaseName { get; set; }
        public string SchemaName { get; set; }
        public string ParentTableName { get; set; }
        public string PrepTableName { get; set; }
        public string NewPartitionedPrepTableName { get; set; }
        public string PartitionFunctionName { get; set; }
        public DateTime BoundaryValue { get; set; }
        public DateTime NextBoundaryValue { get; set; }
        public int IsNewPartitionedPrepTable { get; set; }
        public string ConstraintName { get; set; }
        public string ConstraintType { get; set; }
        public string CreateConstraintStatement { get; set; }
        public string RenameExistingTableConstraintSQL { get; set; }
        public string RenameNewPartitionedPrepTableConstraintSQL { get; set; }
        public string RevertRenameExistingTableConstraintSQL { get; set; }
        public string RevertRenameNewPartitionedPrepTableConstraintSQL { get; set; }
        public int RowNum { get; set; }
    }
}
