using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.Models
{
    public class PartitionFunction
    {
        public string PartitionFuNamenctionName { get; set; }
        public string PartitionFunctionDataType { get; set; }
        public string BoundaryInterval { get; set; }
        public int NumOfFutureIntervals { get; set; }
        public DateTime InitialDate { get; set; }
        public bool UsesSlidingWindow { get; set; }
        public int SlidingWindowSize { get; set; }
        public bool IsDeprecated { get; set; }
        public string PartitionSchemeName { get; set; }
        public int NumOfCharsInSuffix { get; set; }
        public DateTime LastBoundaryDate { get; set; }
        public int NumOfTotalPartitionFunctionIntervals { get; set; }
        public int NumOfTotalPartitionSchemeIntervals { get; set; }
        public string MinValueOfDataType { get; set; }
    }
}
