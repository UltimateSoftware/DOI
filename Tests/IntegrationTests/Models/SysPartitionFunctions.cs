using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysPartitionFunctions
    {
        public int database_id { get; set; }
        public string name { get; set; }
        public int function_id { get; set; }
        public string type { get; set; }
        public string type_desc   { get; set; }
        public int fanout { get; set; }
        public bool boundary_value_on_right { get; set; }
        public bool is_system { get; set; }
        public DateTime create_date { get; set; }
        public DateTime modify_date { get; set; }
    }
}
