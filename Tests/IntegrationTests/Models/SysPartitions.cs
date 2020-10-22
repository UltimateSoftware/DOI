using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysPartitions
    {
        public int database_id { get; set; }
        public int partition_id { get; set; }
        public int object_id { get; set; }
        public int index_id { get; set; }
        public int partition_number { get; set; }
        public int hobt_id { get; set; }
        public int rows { get; set; }
        public int filestream_filegroup_id { get; set; }
        public int data_compression { get; set; }
        public string data_compression_desc { get; set; }
    }
}
