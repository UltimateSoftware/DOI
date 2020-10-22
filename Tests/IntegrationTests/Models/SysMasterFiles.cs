using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysMasterFiles
    {
        public int database_id { get; set; }

        public int file_id { get; set; }
        public string file_guid { get; set; }
        public int type { get; set; }
        public string type_desc { get; set; }
        public int data_space_id { get; set; }
        public string name { get; set; }
        public string physical_name { get; set; }
        public int state { get; set; }
        public string state_desc { get; set; }
        public int size { get; set; }
        public int max_size { get; set; }
        public int growth { get; set; }
        public bool is_media_read_only { get; set; }
        public bool is_read_only { get; set; }
        public bool is_sparse { get; set; }
        public bool is_percent_growth { get; set; }
        public bool is_name_reserved { get; set; }
        public decimal create_lsn { get; set; }
        public decimal drop_lsn { get; set; }
        public decimal read_only_lsn { get; set; }
        public decimal read_write_lsn { get; set; }
        public decimal differential_base_lsn { get; set; }
        public string differential_base_guid { get; set; }
        public DateTime differential_base_time { get; set; }
        public decimal redo_start_lsn { get; set; }
        public string redo_start_fork_guid { get; set; }
        public decimal redo_target_lsn { get; set; }
        public string redo_target_fork_guid { get; set; }
        public decimal backup_lsn { get; set; }
        public int credential_id { get; set; }
    }
}
