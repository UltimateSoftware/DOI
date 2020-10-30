using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysIndexColumns
    {
        public int database_id { get; set; }
        public int object_id { get; set; }
        public int index_id { get; set; }
        public int index_column_id { get; set; }
        public int column_id { get; set; }
        public int key_ordinal { get; set; }
        public int partition_ordinal { get; set; }
        public bool is_descending_key { get; set; }
        public bool is_included_column { get; set; }
    }
}
