using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysDataSpaces
    {
        public int database_id { get; set; }
        public string name { get; set; }
        public int data_space_id { get; set; }
        public string type { get; set; }
        public string type_desc { get; set; }
        public bool is_default { get; set; }
        public bool is_system { get; set; }
    }
}
