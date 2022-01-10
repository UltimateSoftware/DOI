using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class vwPartitioning_Tables_PrepTables
    {
        public string DatabaseName { get; set; }
        public string SchemaName { get; set; }
        public string TableName { get; set; }
        public int DateDiffs { get; set; }
        public string PrepTableName { get; set; }
        public string PrepTableNameSuffix { get; set; }
        public string NewPartitionedPrepTableName { get; set; }
        public string PartitionFunctionName { get; set; }
        public DateTime BoundaryValue { get; set; }
        public DateTime NextBoundaryValue { get; set; }
        public string PartitionColumn { get; set; }
        public int IsNewPartitionedTable { get; set; }
        public string PKColumnList { get; set; }
        public string PKColumnListJoinClause { get; set; }
        public string UpdateColumnList { get; set; }
        public string Storage_Desired { get; set; }
        public string StorageType_Desired { get; set; }
        public string PrepTableFilegroup { get; set; }
        public string CreatePrepTableSQL { get; set; }
        public string CreateViewForBCPSQL { get; set; }
        public string BCPSQL { get; set; }
        public string CheckConstraintSQL { get; set; }
        public string FinalRepartitioningValidation_CreateActualIndexesForTableFunctionSQL { get; set; }
        public string FinalRepartitioningValidation_CreateActualConstraintsForTableFunctionSQL { get; set; }
        public string FinalRepartitioningValidation_CreateCompareTableStructuresDetailsFunctionSQL { get; set; }
        public string FinalRepartitioningValidation_CreateCompareTableStructuresFunctionSQL { get; set; }
        public string FinalRepartitioningValidationSQL { get; set; }
        public string RenameNewPartitionedPrepTableSQL { get; set; }
        public string RenameExistingTableSQL { get; set; }
        public string TurnOnDataSynchSQL { get; set; }
        public string PrepTableTriggerSQLFragment { get; set; }
        public string SynchInsertsPrepTableSQL { get; set; }
        public string SynchUpdatesPrepTableSQL { get; set; }
        public string SynchDeletesPrepTableSQL { get; set; }
        public string RevertRenameNewPartitionedPrepTableSQL { get; set; }
        public string RevertRenameExistingTableSQL { get; set; }
        public string DataSynchProgressSQL { get; set; }
        public string PostDataValidationMissingEventsSQL { get; set; }
        public string PostDataValidationCompareByPartitionSQL { get; set; }
    }
}
