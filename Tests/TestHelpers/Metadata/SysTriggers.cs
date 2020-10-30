using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.TestHelpers.Metadata
{
    public class SysTriggers
    {
        public int database_id { get; set; }
        public string name { get; set; }
        public int object_id { get; set; }
        public int parent_class { get; set; }
        public string parent_class_desc { get; set; }
        public int parent_id { get; set; }
        public string type { get; set; }
        public string type_desc { get; set; }
        public DateTime create_date { get; set; }
        public DateTime modify_date { get; set; }
        public bool is_ms_shipped { get; set; }
        public bool is_disabled { get; set; }
        public bool is_not_for_replication { get; set; }
        public bool is_instead_of_trigger { get; set; }
    }
}
