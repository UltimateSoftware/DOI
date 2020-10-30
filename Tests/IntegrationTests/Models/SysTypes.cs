using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysTypes
    {
        public int database_id { get; set; }
        public string name { get; set; }
        public int system_type_id { get; set; }
        public int user_type_id { get; set; }
        public int schema_id { get; set; }
        public int principal_id { get; set; }
        public int max_length { get; set; }
        public int precision { get; set; }
        public int scale { get; set; }
        public string collation_name { get; set; }
        public bool is_nullable { get; set; }
        public bool is_user_defined { get; set; }
        public bool is_assembly_type { get; set; }
        public int default_object_id { get; set; }
        public int rule_object_id { get; set; }
        public bool is_table_type { get; set; }
    }
}
