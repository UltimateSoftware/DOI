using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysIndexes
    {
        public int database_id { get; set; }
        public int object_id { get; set; }
        public string name { get; set; }
        public int index_id { get; set; }
        public int type { get; set; }
        public string type_desc { get; set; }
        public bool is_unique { get; set; }
        public int data_space_id { get; set; }
        public bool ignore_dup_key { get; set; }
        public bool is_primary_key { get; set; }
        public bool is_unique_constraint { get; set; }
        public int fill_factor { get; set; }
        public bool is_padded { get; set; }
        public bool is_disabled { get; set; }
        public bool is_hypothetical { get; set; }
        public bool allow_row_locks { get; set; }
        public bool allow_page_locks { get; set; }
        public bool has_filter { get; set; }
        public string filter_definition { get; set; }
        public int compression_delay { get; set; }
        public string key_column_list { get; set; }
        public string included_column_list { get; set; }
        public bool has_LOB_columns { get; set; }
    }
}
