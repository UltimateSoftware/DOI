using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.Integration.Models
{
    public class MetaDataTable
    {
        public string SchemaName { get; set; }

        public string TableName { get; set; }

        public string PartitionColumn { get; set; }

        public string NewStorage { get; set; }

        public bool UseBCPStrategy { get; set; }

        public bool IntendToPartition { get; set; }

        public bool EnableRunPartitioning { get; set; }

        public bool ReadyToQueue { get; set; }
    }
}
