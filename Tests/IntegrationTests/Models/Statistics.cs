using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.Integration.Models
{
    public class Statistics
    {
        public string SchemaName { get; set; }
        public string TableName { get; set; }
        public string StatisticsName { get; set; }
        public string StatisticsColumnList { get; set; }
        public int SampleSizePct { get; set; }
        public bool IsFiltered { get; set; }
        public string FilterPredicate { get; set; }
        public bool IsIncremental { get; set; }
        public bool NoRecompute { get; set; }
    }
}