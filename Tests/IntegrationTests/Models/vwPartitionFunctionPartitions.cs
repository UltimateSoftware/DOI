using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class vwPartitionFunctionPartitions
    {
        public string DatabaseName { get; set; }
        public string PartitionFunctionName { get; set; }
        public string PartitionSchemeName { get; set; }
        public string BoundaryInterval { get; set; }
        public bool UsesSlidingWindow { get; set; }
        public int SlidingWindowSize { get; set; }
        public bool IsDeprecated { get; set; }
        public string NextUsedFileGroupName { get; set; }
        public DateTime BoundaryValue { get; set; }
        public DateTime NextBoundaryValue { get; set; }
        public int DateDiffs { get; set; }
        public int PartitionNumber { get; set; }
        public string FileGroupName { get; set; }
        public int IsSlidingWindowActivePartition { get; set; }
        public int IncludeInPartitionFunction { get; set; }
        public int IncludeInPartitionScheme { get; set; }
        public int IsPartitionMissing { get; set; }
        public string AddFileGroupSQL { get; set; }
        public string AddFileSQL { get; set; }
        public string PartitionFunctionSplitSQL { get; set; }
        public string SetFilegroupToNextUsedSQL { get; set; }
        public string PrepTableNameSuffix { get; set; }
    }
}
