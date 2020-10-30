using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysStatsColumns
    {
        public int database_id { get; set; }
        public int object_id { get; set; }
        public int stats_id { get; set; }
        public int stats_column_id { get; set; }
        public int column_id { get; set; }
    }
}
