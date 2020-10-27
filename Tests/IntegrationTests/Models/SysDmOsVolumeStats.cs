using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysDmOsVolumeStats
    {
        public int database_id { get; set; }
        public int file_id { get; set; }
        public string volume_mount_point { get; set; }
        public string volume_id { get; set; }
        public string logical_volume_name { get; set; }
        public string file_system_type { get; set; }
        public int total_bytes { get; set; }
        public int available_bytes { get; set; }
        public int supports_compression { get; set; }
        public int supports_alternate_streams { get; set; }
        public int supports_sparse_files { get; set; }
        public int is_read_only { get; set; }
        public int is_compressed { get; set; }
    }
}
