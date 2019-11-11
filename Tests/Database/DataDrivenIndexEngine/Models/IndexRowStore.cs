using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.Models
{
    public class IndexRowStore
    {
        public string SchemaName { get; set; }

        public string TableName { get; set; }

        public string IndexName { get; set; }

        public bool IsUnique { get; set; }

        public bool IsPrimaryKey { get; set; }

        public bool IsUniqueConstraint { get; set; }

        public bool IsClustered { get; set; }

        public string KeyColumnList { get; set; }

        public string IncludedColumnList { get; set; }

        public bool IsFiltered { get; set; }

        public string FilterPredicate { get; set; }

        public string Fillfactor { get; set; }

        public bool OptionPadIndex { get; set; }

        public bool OptionStatisticsNoRecompute { get; set; }

        public bool OptionStatisticsIncremental { get; set; }

        public bool OptionIgnoreDupKey { get; set; }

        public bool OptionResumable { get; set; }

        public string OptionMaxDuration { get; set; }

        public bool OptionAllowRowLocks { get; set; }

        public bool OptionAllowPageLocks { get; set; }

        public string OptionDataCompression { get; set; }

        public string NewStorage { get; set; }

        public string PartitionColumn { get; set; }
    }

    public class IndexColumnStore
    {
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
