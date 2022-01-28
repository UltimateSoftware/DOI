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
    public class ExchangeTablePartitioningHelpers : ExchangeTableHelpers
    {
        public void SetUpPartitioningTable()
        {
            sqlHelper.Execute("UPDATE DOI.Tables SET ReadyToQueue = 0");
            sqlHelper.Execute(SetupSqlStatements_Partitioned.PartitionFunction_Setup_Metadata);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_PartitionFunctionsSql);
            IndexesHelper.CreatePartitioningContainerObjects("pfMonthlyTest"); //move this to param and have 2 test cases, one monthly and one yearly.

            sqlHelper.Execute(SetupSqlStatements_Partitioned.TableCreation, 30, true, DatabaseName);
            sqlHelper.Execute(SetupSqlStatements_Partitioned.DataInsert, 30, true, DatabaseName);
            sqlHelper.Execute(SetupSqlStatements_Partitioned.TableToMetadata);

            sqlHelper.Execute(SetupSqlStatements_Partitioned.CreateTrigger, 30, true, DatabaseName);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysTriggersSql);

            sqlHelper.Execute(SetupSqlStatements_Partitioned.RowStoreIndexes);
            sqlHelper.Execute(SetupSqlStatements_Partitioned.ColumnStoreIndexes);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysIndexesSql);

            sqlHelper.Execute(SetupSqlStatements_Partitioned.StatisticsToMetadata);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysStatsSql);

            sqlHelper.Execute(SetupSqlStatements_Partitioned.ConstraintsToMetadata);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysCheckConstraintsSql);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysDefaultConstraintsSql);
            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_SysTablesSql);

            sqlHelper.Execute(SetupSqlStatements.UpdateJobStepForTest);


            /*This sql statement was extracted from [Utility].[spDataDrivenIndexes_RefreshPartitionState]
            we should change calling the SQL code and call instead the Sp itself for this we need to wait for
            to Sam's makes the Sp take a parameter with the table name. Now the table names are hardcoded inside the Sp
            Ideally the Sp can get called for the specified table when building the queue so we dont need to even worry about it.
            Sam hasn't gotten to it yet, but sometime soon,20190122.*/
            sqlHelper.Execute(new SqlCommand(SetupSqlStatements_Partitioned.PartitionStateMetadata));
        }

        public void ValidateThatTheNewTableIsPartitioned()
        {
            DateTime now = DateTime.Now.ToUniversalTime();
            /*Sam explained that the number of partitions is equal to the number of month since January 2018
             and one year from now, plus 2 more partitions()*/
            //get this from the PartitionFunctions table.
            short minimumNumberOfExpectedPartitions = sqlHelper.ExecuteScalar<short>(@"   SELECT NumOfTotalPartitionFunctionIntervals 
                                                                                             FROM DOI.PartitionFunctions 
                                                                                             WHERE PartitionFunctionName = 'pfMonthlyTest'");
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.RowsInFileGroupsProcedureCall));
            Assert.IsTrue(list.Count >= minimumNumberOfExpectedPartitions, $"Expecting at least {minimumNumberOfExpectedPartitions} partition but found {list.Count}");
        }

        public void ValidateThatTheLiveTableIsNotPartitioned()
        {
            int actualNumPartitions = sqlHelper.ExecuteScalar<int>($@"USE {DatabaseName}
                                                                            SELECT COUNT(*) 
                                                                             FROM sys.partitions p
                                                                                INNER JOIN sys.tables t ON t.object_id = p.object_id
                                                                             WHERE t.name = 'PartitioningTestAutomationTable'
                                                                                AND index_id IN (0,1)");
            Assert.AreEqual(1, actualNumPartitions); //if it only has 1 partition then the table is 'unpartitioned'
        }

        public void ValidateThatTheNewTableHasAllTheData()
        {
            Assert.IsEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.DataMismatchValidation)), "Error: There is a data mismatch between the new and the old table.");
        }

        public void ValidateThatTheLiveTableExists()
        {
            Assert.IsNotEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.CheckLiveTable)), $" The new nonpartitioned table [dbo].[{PartitionedTableName}] does not exist.");
        }

        public void ValidateThatTheOldTableExists()
        {
            Assert.IsNotEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.CheckOldTable)), $" The old table [dbo].[{PartitionedTableName}_Old] does not exist.");
        }

        public void ValidateThatTheOfflineTableExists()
        {
            Assert.IsNotEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.CheckOfflinePartitionedTable)), $" The old table [dbo].[{PartitionedTableName}_NewPartitionedTableFromPrep] does not exist.");
        }

        public void ValidateThatAllRowsAreInPartitionedTable()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.DataInPartitionedTable));
            Assert.AreEqual(list.Count, 96, $"Expecting 96 rows in the nonpartitioned table but found {list.Count}.");
        }

        public void ValidateIndexesAreThereOnNewTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.IndexesAfterPartitioningNewTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{PartitionedTableName}"), $"Index CDX_{PartitionedTableName} is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{PartitionedTableName}_Comments"), $"Index NCCI_{PartitionedTableName}_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{PartitionedTableName}_Comments"), $"Index IDX_{PartitionedTableName}_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{PartitionedTableName}"), $"Index PK_{PartitionedTableName} is missing.");
        }

        public void ValidateIndexesAreThereOnOldTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.IndexesAfterPartitioningOldTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{PartitionedTableName}_OLD"), $"Index CDX_{PartitionedTableName}_OLD is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{PartitionedTableName}_OLD_Comments"), $"Index NCCI_{PartitionedTableName}_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{PartitionedTableName}_OLD_Comments"), $"Index IDX_{PartitionedTableName}_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{PartitionedTableName}_OLD"), $"Index PK_{PartitionedTableName}_OLD is missing.");
        }

        public void ValidateIndexesAreThereOnOfflinePartitionedTableAfterRevert()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.IndexesAfterRevertPartitionedTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{PartitionedTableName}_NewPartitionedTableFromPrep"), $"Index CDX_{PartitionedTableName}_NewPartitionedTableFromPrep is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{PartitionedTableName}_NewPartitionedTableFromPrep_Comments"), $"Index NCCI_{PartitionedTableName}_NewPartitionedTableFromPrep_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{PartitionedTableName}_NewPartitionedTableFromPrep_Comments"), $"Index IDX_{PartitionedTableName}_NewPartitionedTableFromPrep_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{PartitionedTableName}_NewPartitionedTableFromPrep"), $"Index PK_{PartitionedTableName}_NewPartitionedTableFromPrep is missing.");
        }

        public void ValidateConstraintsAreThereOnNewTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.ConstraintsAfterPartitioningNewTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Chk_{PartitionedTableName}_updatedUtcDt"), $"Constraint Chk_{PartitionedTableName}_updatedUtcDt is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Def_{PartitionedTableName}_updatedUtcDt"), $"Constraint Def_{PartitionedTableName}_updatedUtcDt is missing.");
        }

        public void ValidateConstraintsAreThereOnOldTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.ConstraintsAfterPartitioningOldTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Chk_{PartitionedTableName}_OLD_updatedUtcDt"), $"Constraint Chk_{PartitionedTableName}_OLD_updatedUtcDt is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Def_{PartitionedTableName}_OLD_updatedUtcDt"), $"Constraint Def_{PartitionedTableName}_OLD_updatedUtcDt is missing.");
        }

        public void ValidateConstraintsAreThereOnOfflinePartitionedTableAfterRevert()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.ConstraintsAfterRevertPartitionedTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Chk_{PartitionedTableName}_NewPartitionedTableFromPrep_updatedUtcDt"), $"Constraint Chk_{PartitionedTableName}_NewPartitionedTableFromPrep_updatedUtcDt is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"Def_{PartitionedTableName}_NewPartitionedTableFromPrep_updatedUtcDt"), $"Constraint Def_{PartitionedTableName}_NewPartitionedTableFromPrep_updatedUtcDt is missing.");
        }

        public void ValidateStatisticsAreThereOnNewTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.StatisticsAfterPartitioningNewTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{PartitionedTableName}"), $"Statistics for index CDX_{PartitionedTableName} is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{PartitionedTableName}_Comments"), $"Statistics for index NCCI_{PartitionedTableName}_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{PartitionedTableName}_Comments"), $"Statistics for index IDX_{PartitionedTableName}_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{PartitionedTableName}"), $"Statistics for index PK_{PartitionedTableName} is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_id"), $"Statistics ST_{PartitionedTableName}_id is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_myDateTime"), $"Statistics ST_{PartitionedTableName}_myDateTime is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_Comments"), $"Statistics ST_{PartitionedTableName}_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_updatedUtcDt"), $"Statistics ST_{PartitionedTableName}_updatedUtcDt is missing.");
        }

        public void ValidateStatisticsAreThereOnOldTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.StatisticsAfterPartitioningOldTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{PartitionedTableName}_OLD"), $"Statistics for index CDX_{PartitionedTableName}_OLD is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{PartitionedTableName}_OLD_Comments"), $"Statistics for index NCCI_{PartitionedTableName}_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{PartitionedTableName}_OLD_Comments"), $"Statistics for index IDX_{PartitionedTableName}_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{PartitionedTableName}_OLD"), $"Statistics for index PK_{PartitionedTableName}_OLD is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_OLD_id"), $"Statistics ST_{PartitionedTableName}_OLD_id is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_OLD_myDateTime"), $"Statistics ST_{PartitionedTableName}_OLD_myDateTime is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_OLD_Comments"), $"Statistics ST_{PartitionedTableName}_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_OLD_updatedUtcDt"), $"Statistics ST_{PartitionedTableName}_OLD_updatedUtcDt is missing.");
        }

        public void ValidateStatisticsAreThereOnOfflinePartitionedTableAfterRevert()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.StatisticsAfterRevertPartitionedTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"CDX_{PartitionedTableName}_NewPartitionedTableFromPrep"), $"Statistics for index CDX_{PartitionedTableName}_NewPartitionedTableFromPrep is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"NCCI_{PartitionedTableName}_NewPartitionedTableFromPrep_Comments"), $"Statistics for index NCCI_{PartitionedTableName}_NewPartitionedTableFromPrep_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"IDX_{PartitionedTableName}_NewPartitionedTableFromPrep_Comments"), $"Statistics for index IDX_{PartitionedTableName}_NewPartitionedTableFromPrep_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"PK_{PartitionedTableName}_NewPartitionedTableFromPrep"), $"Statistics for index PK_{PartitionedTableName}_NewPartitionedTableFromPrep is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_NewPartitionedTableFromPrep_id"), $"Statistics ST_{PartitionedTableName}_NewPartitionedTableFromPrep_id is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_NewPartitionedTableFromPrep_myDateTime"), $"Statistics ST_{PartitionedTableName}_NewPartitionedTableFromPrep_myDateTime is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_NewPartitionedTableFromPrep_Comments"), $"Statistics ST_{PartitionedTableName}_NewPartitionedTableFromPrep_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"ST_{PartitionedTableName}_NewPartitionedTableFromPrep_updatedUtcDt"), $"Statistics ST_{PartitionedTableName}_NewPartitionedTableFromPrep_updatedUtcDt is missing.");
        }

        public void ValidateTriggersAreNotThereOnOldTable()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.TriggersDoNotExistOnOldTable));
            Assert.IsEmpty(list.Where(x => (string)(x[0].Second) == $"tr{PartitionedTableName}_OLD_ins"), $"Trigger tr{PartitionedTableName}_OLD_ins exists, but should not be there.");
        }

        public void ValidateTriggersAreThereOnLiveTable()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.TriggersExistOnLiveTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == $"tr{PartitionedTableName}_ins"), $"Trigger tr{PartitionedTableName}_ins is missing.");
        }

        public void ValidateThatTriggersAreNotThereOnOfflineTable()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.TriggersDoNotExistOnOfflineTable));
            Assert.IsEmpty(list.Where(x => (string)(x[0].Second) == $"tr{PartitionedTableName}_NewPartitionedTableFromPrep_ins"), $"Trigger tr{PartitionedTableName}_NewPartitionedTableFromPrep_ins exists, but should not be there.");
        }

        public void ValidateThatTheOfflinePartitionedTableIsPartitioned()
        {
            int actualNumPartitions = sqlHelper.ExecuteScalar<int>($@"USE {DatabaseName}
                                                                            SELECT COUNT(*) 
                                                                             FROM sys.partitions p
                                                                                INNER JOIN sys.tables t ON t.object_id = p.object_id
                                                                             WHERE t.name = 'PartitioningTestAutomationTable_NewPartitionedTableFromPrep'
                                                                                AND index_id IN (0,1)");
            Assert.Less(1, actualNumPartitions); //if has more than 1 partition then the table is 'partitioned'
        }

        public void ValidateThatThereIsDataInPartitions()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.TotalRowsInFileGroups));
            Assert.AreEqual(list[0][0].Second, 96, $"Expecting 96 rows but found {list[0][0].Second} according to [Utility].[spSeeRowsInFileGroups]");
        }

        public void ValidateThatAllPartitionsHaveData()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.AllPartitionsHaveData));
            Assert.IsEmpty(list, $"Expecting all partitions to have data but some partition has 0 rows:{list}");
        }

        public void ValidateThatPartitionStateMetadataTableIsEmptyAfterPartitioning()
        {
            Assert.IsEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.CheckForEmptyPartitionStateMetadata("dbo", "PartitioningTestAutomationTable"))), "Expecting the PartitionState Metadata table [DOI.Run_PartitionState] to be empty but found records.");
        }

        public void ValidateThatTheOfflinePartitionedTableExists()
        {
            Assert.IsNotEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements_Partitioned.CheckOfflinePartitionedTable)), " The old table [dbo].[PartitioningTestAutomationTable_NewPartitionedTableFromPrep] does not exist.");
        }

        public void ValidateStateAfterPartitioning()
        {
            ValidateThatTheJobFinishedSuccessfully();

            //tables
            ValidateThatTheOldTableExists();
            ValidateThatTheLiveTableExists();
            ValidateThatTheNewTableIsPartitioned();

            //data
            ValidateThatTheNewTableHasAllTheData();
            ValidateThatThereIsDataInPartitions();
            ValidateThatAllPartitionsHaveData();
            ValidateThatAllRowsAreInPartitionedTable();

            //indexes
            ValidateIndexesAreThereOnNewTableAfterPartitioning();
            ValidateIndexesAreThereOnOldTableAfterPartitioning();

            //constraints
            ValidateConstraintsAreThereOnNewTableAfterPartitioning();
            ValidateConstraintsAreThereOnOldTableAfterPartitioning();

            //statistics
            ValidateStatisticsAreThereOnNewTableAfterPartitioning();
            ValidateStatisticsAreThereOnOldTableAfterPartitioning();

            //triggers
            ValidateTriggersAreThereOnLiveTable();
            ValidateTriggersAreNotThereOnOldTable();

            //queue
            ValidateThatTheQueueIsEmpty();
            //metadata
            ValidateThatPartitionStateMetadataTableIsEmptyAfterPartitioning();
            //log has no errors.
            ValidateThatLogTableHasNoErrors();
        }

        public void RevertPartitioningToUnpartitionedTable()
        {
            sqlHelper.Execute(SetupSqlStatements_Partitioned.RevertPartitioningToUnpartitionedTable);
        }

        public void ValidateStateAfterRevertToUnpartitionedTable()
        {
            //tables
            ValidateThatTheLiveTableExists();
            ValidateThatTheOfflinePartitionedTableExists();
            ValidateThatTheLiveTableIsNotPartitioned();
            ValidateThatTheOfflinePartitionedTableIsPartitioned();

            //indexes
            ValidateIndexesAreThereOnNewTableAfterPartitioning();
            ValidateIndexesAreThereOnOfflinePartitionedTableAfterRevert();

            //constraints
            ValidateConstraintsAreThereOnNewTableAfterPartitioning();
            ValidateConstraintsAreThereOnOfflinePartitionedTableAfterRevert();

            //statistics
            ValidateStatisticsAreThereOnNewTableAfterPartitioning();
            ValidateStatisticsAreThereOnOfflinePartitionedTableAfterRevert();

            //triggers
            ValidateTriggersAreThereOnLiveTable();
            ValidateThatTriggersAreNotThereOnOfflineTable();

            //there should be no rows in the queue after revert
            ValidateThatTheQueueIsEmpty();

            //there should be no errors in the log after revert
            ValidateThatLogTableHasNoErrors();
        }

        public void ReRevertPartitioningToPartitionedTable()
        {
            sqlHelper.Execute(SetupSqlStatements_Partitioned.ReRevertPartitioningToPartitionedTable);
        }

        public void ValidateStateAfterReRevertToPartitionedTable()
        {
            //tables
            ValidateThatTheOldTableExists();
            ValidateThatTheLiveTableExists();
            ValidateThatTheNewTableIsPartitioned();

            //indexes
            ValidateIndexesAreThereOnNewTableAfterPartitioning();
            ValidateIndexesAreThereOnOldTableAfterPartitioning();

            //constraints
            ValidateConstraintsAreThereOnNewTableAfterPartitioning();
            ValidateConstraintsAreThereOnOldTableAfterPartitioning();

            //statistics
            ValidateStatisticsAreThereOnNewTableAfterPartitioning();
            ValidateStatisticsAreThereOnOldTableAfterPartitioning();

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