using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class vwPartitioning_Tables_PrepTables_Partitions
    {
        public string DatabaseName { get; set; }
        public string SchemaName { get; set; }
        public string ParentTableName { get; set; }
        public string PartitionFunctionName { get; set; }
        public string NewPartitionedPrepTableName { get; set; }
        public string UnPartitionedPrepTableName { get; set; }
        public DateTime PartitionFunctionValue { get; set; }
        public DateTime NextPartitionFunctionValue { get; set; }
        public string PartitionDataValidationSQL { get; set; }
        public string PartitionSwitchSQL { get; set; }
        public string DropTableSQL { get; set; }
        public long PartitionNumber { get; set; }
    }
}
