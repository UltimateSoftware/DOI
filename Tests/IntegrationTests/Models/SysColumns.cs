using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysColumns
    {
        public int database_id { get; set; }
        public int object_id { get; set; }
        public string name { get; set; }
        public int column_id { get; set; }
        public int system_type_id { get; set; }
        public int user_type_id { get; set; }
        public int max_length { get; set; }
        public int precision { get; set; }
        public int scale { get; set; }
        public string collation_name { get; set; }
        public bool is_nullable { get; set; }
        public bool is_ansi_padded { get; set; }
        public bool is_rowguidcol { get; set; }
        public bool is_identity { get; set; }
        public bool is_computed { get; set; }
        public bool is_filestream { get; set; }
        public bool is_replicated { get; set; }
        public bool is_non_sql_subscribed { get; set; }
        public bool is_merge_published { get; set; }
        public bool is_dts_replicated { get; set; }
        public bool is_xml_document { get; set; }
        public int xml_collection_id { get; set; }
        public int default_object_id { get; set; }
        public int rule_object_id { get; set; }
        public bool is_sparse { get; set; }
        public bool is_column_set { get; set; }
        public int generated_always_type { get; set; }
        public string generated_always_type_desc { get; set; }
        public int encryption_type { get; set; }
        public string encryption_type_desc { get; set; }
        public string encryption_algorithm_name { get; set; }
        public int column_encryption_key_id { get; set; }
        public string column_encryption_key_database_name { get; set; }
        public bool is_hidden { get; set; }
        public bool is_masked { get; set; }
    }
}
