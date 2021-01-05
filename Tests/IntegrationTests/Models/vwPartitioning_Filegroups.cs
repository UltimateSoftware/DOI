using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class vwPartitioning_Filegroups
    {
        public string DatabaseName { get; set; }
        public string PartitionFunctionName { get; set; }
        public string PartitionSchemeName { get; set; }
        public DateTime BoundaryValue { get; set; }
        public DateTime NextBoundaryValue { get; set; }
        public string FileGroupName { get; set; }
        public string AddFileGroupSQL { get; set; }
        public int IsFileGroupMissing { get; set; }
    }
}
