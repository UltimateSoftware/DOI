using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class vwPartitioning_DBFiles
    {
        private string DatabaseName { get; set; }
        private string PartitionFunctionName { get; set; }
        private string PartitionSchemeName { get; set; }
        private string BoundaryValue { get; set; }
        private string NextBoundaryValue { get; set; }
        private string DBFileName { get; set; }
        private string AddFileSQL { get; set; }
        private string IsDBFileMissing { get; set; }
    }
}
