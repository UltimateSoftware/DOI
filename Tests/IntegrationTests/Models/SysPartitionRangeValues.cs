using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysPartitionRangeValues
    {
        public int database_id { get; set; }
        public int function_id { get; set; }
        public int boundary_id { get; set; }
        public int parameter_id { get; set; }
        public DateTime value { get; set; }
    }
}
