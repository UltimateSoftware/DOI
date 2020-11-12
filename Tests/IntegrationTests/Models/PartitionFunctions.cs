using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class PartitionFunctions
    {
        public string DatabaseName { get; set; }
        public string PartitionFunctionName { get; set; }
        public string PartitionFunctionDataType { get; set; }
        public string BoundaryInterval { get; set; }
        public int NumOfFutureIntervals { get; set; }
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
    }
}
