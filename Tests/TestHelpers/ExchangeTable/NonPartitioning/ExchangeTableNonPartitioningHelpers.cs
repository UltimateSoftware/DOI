using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using DOI.Tests.IntegrationTests;
using DOI.Tests.TestHelpers.Metadata;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using Microsoft.Practices.Unity.Utility;
using Newtonsoft.Json.Linq;
using NUnit.Framework;

namespace DOI.Tests.TestHelpers.ExchangeTable
{
    public class ExchangeTableNonPartitioningHelpers : ExchangeTableHelpers
    {

        public void SetUpNonPartitioningTable()
        {
            sqlHelper.Execute("UPDATE DOI.Tables SET ReadyToQueue = 0");

            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.setUpTablesSql, 30, true, DatabaseName);
            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.DataInsert, 30, true, DatabaseName);
            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.setUpConstraintsSql, 30, true, DatabaseName);
            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.setUpIndexesSql, 30, true, DatabaseName);
            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.setUpStatisticsSql, 30, true, DatabaseName);
            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.CreateTrigger, 30, true, DatabaseName);

            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.setUpTablesMetadata);

            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysTriggersSql);

            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.setUpIndexesMetadataSql);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysIndexesSql);

            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.setUpStatisticsMetadataSql);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysStatsSql);

            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.setUpConstraintsMetadataSql);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysCheckConstraintsSql);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysDefaultConstraintsSql);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysTablesSql);

            //sqlHelper.Execute(SetupSqlStatements_NonPartitioned.UpdateJobStepForTest);  not sure what this is for?
        }

        public void ValidateThatTheNewTableHasAllTheData()
        {
            Assert.IsEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.DataMismatchValidation)), "Error: There is a data mismatch between the new and the old table.");
        }

        public void ValidateThatTheLiveTableExists()
        {
            Assert.IsNotEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.CheckLiveTable)), $" The new nonpartitioned table [dbo].[{NonPartitionedTableName}] does not exist.");
        }

        public void ValidateThatTheOldTableExists()
        {
            Assert.IsNotEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.CheckOldTable)), $" The old table [dbo].[{NonPartitionedTableName}_Old] does not exist.");
        }

        public void ValidateThatTheOfflineTableExists()
        {
            Assert.IsNotEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.CheckOfflineNonPartitionedTable)), $" The old table [dbo].[{NonPartitionedTableName}_NewTable] does not exist.");
        }

        public void ValidateThatAllRowsAreInNonPartitionedTable()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.DataInNonPartitionedTable));
            Assert.AreEqual(list.Count, 96, $"Expecting 96 rows in the nonpartitioned table but found {list.Count}.");
        }

        public void ValidateIndexesAreThereOnNewTableAfterTableExchangeNonPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.IndexesAfterTableExchangeNonPartitioningNewTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{NonPartitionedTableName}"), $"Index CDX_{NonPartitionedTableName} is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{NonPartitionedTableName}_Comments"), $"Index NCCI_{NonPartitionedTableName}_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{NonPartitionedTableName}_Comments"), $"Index IDX_{NonPartitionedTableName}_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{NonPartitionedTableName}"), $"Index PK_{NonPartitionedTableName} is missing.");
        }

        public void ValidateIndexesAreThereOnOldTableAfterTableExchangeNonPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.IndexesAfterTableExchangeNonPartitioningOldTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{NonPartitionedTableName}_OLD"), $"Index CDX_{NonPartitionedTableName}_OLD is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{NonPartitionedTableName}_OLD_Comments"), $"Index NCCI_{NonPartitionedTableName}_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{NonPartitionedTableName}_OLD_Comments"), $"Index IDX_{NonPartitionedTableName}_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{NonPartitionedTableName}_OLD"), $"Index PK_{NonPartitionedTableName}_OLD is missing.");
        }

        public void ValidateIndexesAreThereOnOfflinePartitionedTableAfterRevert()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.IndexesAfterRevertTableExchangeNonPartitioningTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{NonPartitionedTableName}_NewTable"), $"Index CDX_{NonPartitionedTableName}_NewTable is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{NonPartitionedTableName}_NewTable_Comments"), $"Index NCCI_{NonPartitionedTableName}_NewTable_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{NonPartitionedTableName}_NewTable_Comments"), $"Index IDX_{NonPartitionedTableName}_NewTable_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{NonPartitionedTableName}_NewTable"), $"Index PK_{NonPartitionedTableName}_NewTable is missing.");
        }

        public void ValidateConstraintsAreThereOnNewTableAfterTableExchangeNonPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.ConstraintsAfterTableExchangeNonPartitioningNewTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Chk_{NonPartitionedTableName}_TransactionUtcDt"), $"Constraint Chk_{NonPartitionedTableName}_TransactionUtcDt is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Def_{NonPartitionedTableName}_TransactionUtcDt"), $"Constraint Def_{NonPartitionedTableName}_TransactionUtcDt is missing.");
        }

        public void ValidateConstraintsAreThereOnOldTableAfterTableExchangeNonPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.ConstraintsAfterTableExchangeNonPartitioningOldTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Chk_{NonPartitionedTableName}_OLD_TransactionUtcDt"), $"Constraint Chk_{NonPartitionedTableName}_OLD_TransactionUtcDt is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Def_{NonPartitionedTableName}_OLD_TransactionUtcDt"), $"Constraint Def_{NonPartitionedTableName}_OLD_TransactionUtcDt is missing.");
        }

        public void ValidateConstraintsAreThereOnOfflinePartitionedTableAfterRevert()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.ConstraintsAfterRevertTableExchangeNonPartitioningTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Chk_{NonPartitionedTableName}_NewTable_TransactionUtcDt"), $"Constraint Chk_{NonPartitionedTableName}_NewTable_TransactionUtcDt is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Def_{NonPartitionedTableName}_NewTable_TransactionUtcDt"), $"Constraint Def_{NonPartitionedTableName}_NewTable_TransactionUtcDt is missing.");
        }

        public void ValidateStatisticsAreThereOnNewTableAfterTableExchangeNonPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.StatisticsAfterTableExchangeNonPartitioningNewTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{NonPartitionedTableName}"), $"Statistics for index CDX_{NonPartitionedTableName} is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{NonPartitionedTableName}_Comments"), $"Statistics for index NCCI_{NonPartitionedTableName}_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{NonPartitionedTableName}_Comments"), $"Statistics for index IDX_{NonPartitionedTableName}_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{NonPartitionedTableName}"), $"Statistics for index PK_{NonPartitionedTableName} is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_IncludedColumn"), $"Statistics ST_{NonPartitionedTableName}_IncludedColumn is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_TempAId"), $"Statistics ST_{NonPartitionedTableName}_TempAId is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_TextCol"), $"Statistics ST_{NonPartitionedTableName}_TextCol is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_TransactionUtcDt"), $"Statistics ST_{NonPartitionedTableName}_TransactionUtcDt is missing.");
        }

        public void ValidateStatisticsAreThereOnOldTableAfterTableExchangeNonPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.StatisticsAfterTableExchangeNonPartitioningOldTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{NonPartitionedTableName}_OLD"), $"Statistics for index CDX_{NonPartitionedTableName}_OLD is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{NonPartitionedTableName}_OLD_Comments"), $"Statistics for index NCCI_{NonPartitionedTableName}_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{NonPartitionedTableName}_OLD_Comments"), $"Statistics for index IDX_{NonPartitionedTableName}_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{NonPartitionedTableName}_OLD"), $"Statistics for index PK_{NonPartitionedTableName}_OLD is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_OLD_IncludedColumn"), $"Statistics ST_{NonPartitionedTableName}_OLD_IncludedColumn is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_OLD_TempAId"), $"Statistics ST_{NonPartitionedTableName}_OLD_TempAId is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_OLD_TextCol"), $"Statistics ST_{NonPartitionedTableName}_OLD_TextCol is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_OLD_TransactionUtcDt"), $"Statistics ST_{NonPartitionedTableName}_OLD_TransactionUtcDt is missing.");
        }

        public void ValidateStatisticsAreThereOnOfflinePartitionedTableAfterRevert()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.StatisticsAfterRevertTableExchangeNonPartitioningTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{NonPartitionedTableName}_NewTable"), $"Statistics for index CDX_{NonPartitionedTableName}_NewTable is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{NonPartitionedTableName}_NewTable_Comments"), $"Statistics for index NCCI_{NonPartitionedTableName}_NewTable_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{NonPartitionedTableName}_NewTable_Comments"), $"Statistics for index IDX_{NonPartitionedTableName}_NewTable_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{NonPartitionedTableName}_NewTable"), $"Statistics for index PK_{NonPartitionedTableName}_NewTable is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_NewTable_IncludedColumn"), $"Statistics ST_{NonPartitionedTableName}_NewTable_IncludedColumn is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_NewTable_TempAId"), $"Statistics ST_{NonPartitionedTableName}_NewTable_TempAId is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_NewTable_TextCol"), $"Statistics ST_{NonPartitionedTableName}_NewTable_TextCol is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{NonPartitionedTableName}_NewTable_TransactionUtcDt"), $"Statistics ST_{NonPartitionedTableName}_NewTable_TransactionUtcDt is missing.");
        }

        public void ValidateTriggersAreNotThereOnOldTable()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.TriggersDoNotExistOnOldTable));
            Assert.IsEmpty(list.Where(x => (string)(x[0].Second) == $"tr{NonPartitionedTableName}_OLD_ins"), $"Trigger tr{NonPartitionedTableName}_OLD_ins exists, but should not be there.");
        }

        public void ValidateTriggersAreThereOnLiveTable()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.TriggersExistOnLiveTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"tr{NonPartitionedTableName}_ins"), $"Trigger tr{NonPartitionedTableName}_ins is missing.");
        }

        public void ValidateThatTriggersAreNotThereOnOfflineTable()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_NonPartitioned.TriggersDoNotExistOnOfflineTable));
            Assert.IsEmpty(list.Where(x => (string)(x[0].Second) == $"tr{NonPartitionedTableName}_NewTable_ins"), $"Constraint tr{NonPartitionedTableName}_NewTable_ins exists, but should not be there.");
        }

        public void ValidateStateAfterExchangeTableNonPartitioned()
        {
            ValidateThatTheJobFinishedSuccessfully();

            //tables
            ValidateThatTheOldTableExists();
            ValidateThatTheLiveTableExists();

            //data
            ValidateThatTheNewTableHasAllTheData();
            ValidateThatAllRowsAreInNonPartitionedTable();

            //indexes
            ValidateIndexesAreThereOnNewTableAfterTableExchangeNonPartitioning();
            ValidateIndexesAreThereOnOldTableAfterTableExchangeNonPartitioning();

            //constraints
            ValidateConstraintsAreThereOnNewTableAfterTableExchangeNonPartitioning();
            ValidateConstraintsAreThereOnOldTableAfterTableExchangeNonPartitioning();

            //statistics
            ValidateStatisticsAreThereOnNewTableAfterTableExchangeNonPartitioning();
            ValidateStatisticsAreThereOnOldTableAfterTableExchangeNonPartitioning();

            //triggers
            ValidateTriggersAreThereOnLiveTable();
            ValidateTriggersAreNotThereOnOldTable();

            //queue
            ValidateThatTheQueueIsEmpty();

            //log has no errors.
            ValidateThatLogTableHasNoErrors();
        }

        public void RevertTableExchangeUnpartitionedToPriorTable()
        {
            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.RevertTableExchangeUnpartitionedToPriorTable);
        }

        public void ValidateStateAfterRevertTableExchangeUnpartitionedToPriorTable()
        {
            //tables
            ValidateThatTheLiveTableExists();
            ValidateThatTheOfflineTableExists();

            //indexes
            ValidateIndexesAreThereOnNewTableAfterTableExchangeNonPartitioning();
            ValidateIndexesAreThereOnOfflinePartitionedTableAfterRevert();

            //constraints
            ValidateConstraintsAreThereOnNewTableAfterTableExchangeNonPartitioning();
            ValidateConstraintsAreThereOnOfflinePartitionedTableAfterRevert();

            //statistics
            ValidateStatisticsAreThereOnNewTableAfterTableExchangeNonPartitioning();
            ValidateStatisticsAreThereOnOfflinePartitionedTableAfterRevert();

            //triggers
            ValidateTriggersAreThereOnLiveTable();
            ValidateThatTriggersAreNotThereOnOfflineTable();

            //there should be no rows in the queue after revert
            ValidateThatTheQueueIsEmpty();

            //there should be no errors in the log after revert
            ValidateThatLogTableHasNoErrors();
        }

        public void ReRevertTableExchangeUnpartitionedToNewTable()
        {
            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.ReRevertTableExchangeUnpartitionedToNewTable);
        }

        public void ValidateStateAfterReRevertTableExchangeUnpartitionedToNewTable()
        {
            //tables
            ValidateThatTheOldTableExists();
            ValidateThatTheLiveTableExists();

            //indexes
            ValidateIndexesAreThereOnNewTableAfterTableExchangeNonPartitioning();
            ValidateIndexesAreThereOnOldTableAfterTableExchangeNonPartitioning();

            //constraints
            ValidateConstraintsAreThereOnNewTableAfterTableExchangeNonPartitioning();
            ValidateConstraintsAreThereOnOldTableAfterTableExchangeNonPartitioning();

            //statistics
            ValidateStatisticsAreThereOnNewTableAfterTableExchangeNonPartitioning();
            ValidateStatisticsAreThereOnOldTableAfterTableExchangeNonPartitioning();

            //triggers
            ValidateTriggersAreThereOnLiveTable();

            //reverted offline table should not have ANY triggers.
            ValidateThatTriggersAreNotThereOnOfflineTable();
            ValidateTriggersAreNotThereOnOldTable();

            //there should be no rows in the queue after revert
            ValidateThatTheQueueIsEmpty();

            //there should be no errors in the log after revert
            ValidateThatLogTableHasNoErrors();
        }
    }
}