using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysStats
    {
        public int database_id { get; set; }
        public int object_id { get; set; }
        public string name { get; set; }
        public int stats_id { get; set; }
        public bool auto_created { get; set; }
        public bool user_created { get; set; }
        public bool no_recompute { get; set; }
        public bool has_filter { get; set; }
        public string filter_definition { get; set; }
        public bool is_temporary { get; set; }
        public bool is_incremental { get; set; }
        public string column_list { get; set; }
    }   
}
