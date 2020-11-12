using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class IndexPartitionsRowStore
    {
        public string DatabaseName { get; set; }
        public string SchemaName { get; set; }
        public string TableName { get; set; }
        public string IndexName { get; set; }
        public int PartitionNumber { get; set; }
        public bool OptionResumable { get; set; }
        public int OptionMaxDuration { get; set; }
        public string OptionDataCompression { get; set; }
        public int NumRows { get; set; }
        public int TotalPages { get; set; }
        public string PartitionType { get; set; }
        public decimal TotalIndexPartitionSizeInMB { get; set; }
        public double Fragmentation { get; set; }
        public string DataFileName { get; set; }
        public string DriveLetter { get; set; }
        public string PartitionUpdateType { get; set; }
    }
}
