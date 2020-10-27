using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysDestinationDataSpaces
    {
        public int database_id { get; set; }
        public int partition_scheme_id { get; set; }
        public int destination_id { get; set; }
        public int data_space_id { get; set; }
    }
}
