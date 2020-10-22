using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysTables
    {
        public int database_id { get; set; }
        public string name { get; set; }
        public int object_id { get; set; }
        public int principal_id { get; set; }
        public int schema_id { get; set; }
        public int parent_object_id { get; set; }
        public string type { get; set; }
        public string type_desc { get; set; }
        public DateTime create_date { get; set; }
        public DateTime modify_date { get; set; }
        public bool is_ms_shipped { get; set; }
        public bool is_published { get; set; }
        public bool is_schema_published { get; set; }
        public int lob_data_space_id { get; set; }
        public int filestream_data_space_id { get; set; }
        public int max_column_id_used { get; set; }
        public bool lock_on_bulk_load { get; set; }
        public bool uses_ansi_nulls { get; set; }
        public bool is_replicated { get; set; }
        public bool has_replication_filter { get; set; }
        public bool is_merge_published { get; set; }
        public bool is_sync_tran_subscribed { get; set; }
        public bool has_unchecked_assembly_data { get; set; }
        public int text_in_row_limit { get; set; }
        public bool large_value_types_out_of_row { get; set; }
        public bool is_tracked_by_cdc { get; set; }
        public int lock_escalation { get; set; }
        public string lock_escalation_desc { get; set; }
        public bool is_filetable { get; set; }
        public bool is_memory_optimized { get; set; }
        public int durability { get; set; }
        public string durability_desc { get; set; }
        public string temporal_type { get; set; }
        public string temporal_type_desc { get; set; }
        public int history_table_id { get; set; }
        public bool is_remote_data_archive_enabled { get; set; }
        public bool is_external { get; set; }
    }
}