using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.Integration.Models
{
    public class IndexView
    {
        public string DatabaseName { get; set; }

        public string SchemaName { get; set; }

        public string TableName { get; set; }

        public string IndexName { get; set; }

        public string IndexType { get; set; }

        public bool IsClustered { get; set; }

        public bool IsIndexMissing { get; set; }

        public bool IsIndexStorageChanging { get; set; }

        public bool AreDropRecreateOptionsChanging { get; set; }

        public bool AreRebuildOptionsChanging { get; set; }

        public bool AreReorgOptionsChanging { get; set; }

        public bool AreSetOptionsChanging { get; set; }

        public bool IsUniquenessChanging { get; set; }

        public bool IsPrimaryKeyChanging { get; set; }

        public bool IsKeyColumnListChanging { get; set; }

        public bool IsIncludedColumnListChanging { get; set; }

        public bool IsFilterChanging { get; set; }

        public bool IsClusteredChanging { get; set; }

        public bool IsPartitioningChanging { get; set; }

        public bool IsPadIndexChanging { get; set; }

        public bool IsFillfactorChanging { get; set; }

        public bool IsIgnoreDupKeyChanging { get; set; }

        public bool IsStatisticsNoRecomputeChanging { get; set; }

        public bool IsStatisticsIncrementalChanging { get; set; }

        public bool IsAllowRowLocksChanging { get; set; }

        public bool IsAllowPageLocksChanging { get; set; }

        public bool IsDataCompressionChanging { get; set; }

        public bool IsCompressionDelayChanging { get; set; }

        public string IndexUpdateType { get; set; }

        public bool IsOnlineOperation { get; set; }

        public string ListOfChanges { get; set; }

        public string DropStatement { get; set; }

        public string CreateStatement { get; set; }

        public string AlterSetStatement { get; set; }

        public string AlterRebuildStatement { get; set; }

        public string AlterReorganizeStatement { get; set; }

        public string RenameIndexSQL { get; set; }

        public string RevertRenameIndexSQL { get; set; }

        public double IndexFragmentation { get; set; }

        public int TotalPages { get; set; }
    }
}
