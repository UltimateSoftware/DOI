using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysAllocationUnits
    {
        public int database_id { get; set; }

        public int allocation_unit_id { get; set; }

        public int type { get; set; }

        public string type_desc { get; set; }

        public string container_id { get; set; }

        public int data_space_id { get; set; }

        public int total_pages { get; set; }

        public int used_pages { get; set; }

        public int data_pages { get; set; }
    }
}
