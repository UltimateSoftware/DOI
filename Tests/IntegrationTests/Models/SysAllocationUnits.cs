using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.Integration.Models
{
    public class SysAllocationUnits
    {
        public int database_id { get; set; }

        public Int64 allocation_unit_id { get; set; }

        public Int16 type { get; set; }

        public string type_desc { get; set; }

        public string container_id { get; set; }

        public int data_space_id { get; set; }

        public Int64 total_pages { get; set; }

        public Int64 used_pages { get; set; }

        public Int64 data_pages { get; set; }
    }
}
