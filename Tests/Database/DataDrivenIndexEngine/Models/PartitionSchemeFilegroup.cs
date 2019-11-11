using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.Models
{
    public class PartitionSchemeFilegroup
    {
        public int DestinationFilegroupId { get; set; }
        public string PartitionSchemeName { get; set; }
        public string DataSpaceType { get; set; }
        public string FilegroupName { get; set; }
    }
}
