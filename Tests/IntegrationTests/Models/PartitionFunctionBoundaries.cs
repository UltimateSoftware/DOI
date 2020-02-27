using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.Integration.Models
{
    public class PartitionFunctionBoundary
    {
        public string DatabaseName { get; set; }
        public string Name { get; set; }
        public string Type { get; set; }
        public bool BoundaryValueOnRight { get; set; }
        public int BoundaryId { get; set; }
        public DateTime Value { get; set; }
    }
}
