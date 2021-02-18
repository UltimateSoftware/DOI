using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class vwTables
    {
        public string DatabaseName { get; set; }
        public string SchemaName { get; set; }
        public string TableName { get; set; }
        public string PartitionColumn { get; set; }
        public string Storage_Desired { get; set; }
        public string Storage_Actual { get; set; }
        public string StorageType_Desired { get; set; }
        public string StorageType_Actual { get; set; }
        public bool IntendToPartition { get; set; }
        public bool ReadyToQueue { get; set; }
        public bool AreIndexesFragmented { get; set; }
        public bool AreIndexesBeingUpdated { get; set; }
        public bool AreIndexesMissing { get; set; }
        public bool IsClusteredIndexBeingDropped { get; set; }
        public string WhichUniqueConstraintIsBeingDropped { get; set; }
        public bool IsStorageChanging { get; set; }
        public bool NeedsTransaction { get; set; }
        public bool AreStatisticsChanging { get; set; }
        public string DSTriggerSQL { get; set; }
        public string PKColumnList { get; set; }
        public string PKColumnListJoinClause  { get; set; }
        public string ColumnListNoTypes { get; set; }
        public string ColumnListWithTypes { get; set; }
        public string UpdateColumnList { get; set; }
        public string NewPartitionedPrepTableName { get; set; }
        public string PartitionFunctionName { get; set; }
        public string CreateDataSynchTriggerSQL { get; set; }
        public string CreateFinalDataSynchTableSQL { get; set; }
        public string CreateFinalDataSynchTriggerSQL { get; set; }
        public string TurnOffDataSynchSQL { get; set; }
        public string DropDataSynchTriggerSQL { get; set; }
        public string DropDataSynchTableSQL { get; set; }
        public string DeletePartitionStateMetadataSQL { get; set; }
        public string FreeDataSpaceCheckSQL { get; set; }
        public string FreeLogSpaceCheckSQL { get; set; }
        public string FreeTempDBSpaceCheckSQL { get; set; }
    }
}
