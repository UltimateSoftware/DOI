using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysDefaultConstraints
    {
        public int database_id { get; set; }
        public string name { get; set; }
        public int object_id { get; set; }
        public int principal_id { get; set; }
        public int parent_object_id { get; set; }
        public int schema_id { get; set; }
        public string type { get; set; }
        public string type_desc { get; set; }
        public DateTime create_date { get; set; }
        public DateTime modify_date { get; set; }
        public bool is_ms_shipped { get; set; }
        public bool is_published { get; set; }
        public bool is_schema_published { get; set; }
        public int parent_column_id { get; set; }
        public string definition { get; set; }
        public bool is_system_named { get; set; }
    }
}