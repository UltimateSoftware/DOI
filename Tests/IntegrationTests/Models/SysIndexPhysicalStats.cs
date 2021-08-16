using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysIndexPhysicalStats
    {
        public int database_id { get; set; }
        public int object_id { get; set; }
        public int index_id { get; set; }
        public int partition_number { get; set; }
        public string index_type_desc { get; set; }
        public string alloc_unit_type_desc { get; set; }
        public int index_depth { get; set; }
        public int index_level { get; set; }
        public double avg_fragmentation_in_percent { get; set; }
        public int fragment_count { get; set; }
        public double avg_fragment_size_in_pages { get; set; }
        public int page_count { get; set; }
        public double? avg_page_space_used_in_percent { get; set; }
        public int record_count { get; set; }
        public int ghost_record_count { get; set; }
        public int version_ghost_record_count { get; set; }
        public int min_record_size_in_bytes { get; set; }
        public int max_record_size_in_bytes { get; set; }
        public double avg_record_size_in_bytes { get; set; }
        public int forwarded_record_count { get; set; }
        public int compressed_page_count { get; set; }
        public int hobt_id { get; set; }
        public int columnstore_delete_buffer_state { get; set; }
        public string columnstore_delete_buffer_state_desc { get; set; }
    }
}
