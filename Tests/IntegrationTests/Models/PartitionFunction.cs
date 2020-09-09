using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.Integration.Models
{
    public class PartitionFunction
    {
        public string DatabaseName { get; set; }
        public string PartitionFunctionName { get; set; }
        public string PartitionFunctionDataType { get; set; }
        public string BoundaryInterval { get; set; }
        public int NumOfFutureIntervals_Desired { get; set; }
        public int NumOfFutureIntervals_Actual { get; set; }
        public DateTime InitialDate { get; set; }
        public bool UsesSlidingWindow { get; set; }
        public int? SlidingWindowSize { get; set; }
        public bool IsDeprecated { get; set; }
        public string PartitionSchemeName { get; set; }
        public int? NumOfCharsInSuffix { get; set; }
        public DateTime LastBoundaryDate { get; set; }
        public int? NumOfTotalPartitionFunctionIntervals { get; set; }
        public int? NumOfTotalPartitionSchemeIntervals { get; set; }
        public string MinValueOfDataType { get; set; }
        public bool IsPartitionFunctionMissing { get; set; }
        public bool IsPartitionSchemeMissing { get; set; }
        public string NextUsedFileGroupName { get; set; }
        public string CreatePartitionFunctionSQL { get; set; }
        public string CreatePartitionSchemeSQL { get; set; }
}
}
