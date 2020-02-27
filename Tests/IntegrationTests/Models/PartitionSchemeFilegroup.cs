using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.Integration.Models
{
    public class PartitionSchemeFilegroup
    {
        public string DatabaseName { get; set; }
        public int DestinationFilegroupId { get; set; }
        public string PartitionSchemeName { get; set; }
        public string DataSpaceType { get; set; }
        public string FilegroupName { get; set; }
    }
}
