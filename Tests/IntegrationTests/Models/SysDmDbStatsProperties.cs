using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysDmDbStatsProperties
    {
        public int database_id { get; set; }
        public int object_id { get; set; }
        public int stats_id { get; set; }
        public DateTime last_updated { get; set; }
        public int rows { get; set; }
        public int rows_sampled { get; set; }
        public int steps { get; set; }
        public int unfiltered_rows { get; set; }
        public int modification_counter { get; set; }
        public double persisted_sample_percent { get; set; }
}
}
