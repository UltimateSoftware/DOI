using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class IndexColumnStore
    {
        public string DatabaseName { get; set; }

        public string SchemaName { get; set; }

        public string TableName { get; set; }

        public string IndexName { get; set; }

        public bool IsClustered { get; set; }

        public string KeyColumnList { get; set; }

        public bool IsFiltered { get; set; }

        public string FilterPredicate { get; set; }

        public string OptionDataCompression { get; set; }

        public string OptionCompressionDelay { get; set; }

        public string NewStorage { get; set; }

        public string PartitionColumn { get; set; }
    }
}