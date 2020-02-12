using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using Microsoft.Practices.Unity.Utility;
using Newtonsoft.Json.Linq;
using NUnit.Framework;
using Reporting.TestHelpers;
using TaxHub.TestHelpers;
using SqlHelper = Reporting.TestHelpers.SqlHelper;

namespace Reporting.Ingestion.Integration.Tests.Database.TablePartitioning
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    [Parallelizable(ParallelScope.Fixtures)]
    public class TablePartitioningTest
    {
        private SqlHelper sqlHelper = new SqlHelper();
        private const long TimeoutMilliseconds = 5 * 60 * 1000;
        private string standardBcpFileFullPath = @"c:\tmp\user-management\utebcp\utebcp.exe";

        [SetUp]
        public void SetUp()
        {
            StartSqlServerAgentIfIsNotRunning();
            EnsureThatBcpUtilityIsInPlace();
            TearDown();
        }

        private void EnsureThatBcpUtilityIsInPlace()
        {
            if (IsTestRunningInLocalEnvironment())
            {
                var desiredBcpFileLocation = new FileInfo(standardBcpFileFullPath);
                if (!desiredBcpFileLocation.Exists)
                {
                    var ourCopyOfBcp = new FileInfo(TestContext.CurrentContext.TestDirectory + @"\Database\TablePartitioning\utebcp.exe");
                    if (ourCopyOfBcp.Exists)
                    {
                        desiredBcpFileLocation.Directory.Create();
                        ourCopyOfBcp.CopyTo(standardBcpFileFullPath);
                    }
                    else
                    {
                        throw new FileNotFoundException(
                            $"Cannot find our copy of the utebcp.exe file in {ourCopyOfBcp.FullName}. This test depends on this BCP utility.");
                    }
                }
            }
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TablePartitioningSqlStatements.DropTableAndDeleteMetadata);
            sqlHelper.Execute(TablePartitioningSqlStatements.RestoreJobStep);
         }

        [Test]
        public void HappyPath_PartitionTable()
        {
            //Setup
            SetUpTableUnderTest();

            //Action
            RunPartitionJobAndWaitForItToFinish();

            //Validation
            ValidateThatTheJobFinishedSuccessfully();

            //tables
            ValidateThatTheOldTableExists();
            ValidateThatTheNewTableExists();
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

            //queue
            ValidateThatTheQueueIsEmptyAfterPartitioning();
            //metadata
            ValidateThatPartitionStateMetadataTableIsEmptyAfterPartitioning();
            //log has no errors.
            ValidateThatLogTableHasNoErrors();
        }

        private void StartSqlServerAgentIfIsNotRunning()
        {
            if (IsTestRunningInLocalEnvironment())
            {
                WindowsServiceHelper.StartSqlServerAgent();
            }
        }

        private void SetUpTableUnderTest()
        {
            sqlHelper.Execute("UPDATE Utility.Tables SET ReadyToQueue = 0");
            sqlHelper.Execute(TablePartitioningSqlStatements.PartitionFunctionCreation);
            sqlHelper.Execute(TablePartitioningSqlStatements.TableCreation);
            sqlHelper.Execute(TablePartitioningSqlStatements.DataInsert);
            sqlHelper.Execute(TablePartitioningSqlStatements.TableToMetadata);
            sqlHelper.Execute(TablePartitioningSqlStatements.RowStoreIndexes);
            sqlHelper.Execute(TablePartitioningSqlStatements.ColumnStoreIndexes);
            sqlHelper.Execute(TablePartitioningSqlStatements.StatisticsToMetadata);
            sqlHelper.Execute(TablePartitioningSqlStatements.ConstraintsToMetadata);
            sqlHelper.Execute(TablePartitioningSqlStatements.UpdateJobStepForTest);


            /*This sql statement was extracted from [Utility].[spDataDrivenIndexes_RefreshPartitionState]
            we should change calling the SQL code and call instead the Sp itself for this we need to wait for
            to Sam's makes the Sp take a parameter with the table name. Now the table names are hardcoded inside the Sp
            Ideally the Sp can get called for the specified table when building the queue so we dont need to even worry about it.
            Sam hasn't gotten to it yet, but sometime soon,20190122.*/
            sqlHelper.Execute(new SqlCommand(TablePartitioningSqlStatements.PartitionStateMetadata));
        }

        private void RunPartitionJobAndWaitForItToFinish()
        {
            sqlHelper.Execute(TablePartitioningSqlStatements.StartJob);
            WaitForJobToFinish();
        }

        private bool IsTheJobRunning()
        {
            return GetJobRunStatus() == null;
        }

        private short? GetJobRunStatus()
        {
            List<List<Pair<string, object>>> result = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.JobActivity));
            if (result.Count > 0)
            {
                var val = result[0].Single(x => x.First == "run_status").Second;
                if (val == DBNull.Value)
                {
                    return null;
                }
                else
                {
                    return Convert.ToInt16(val);
                }
            }
            return -1;
        }

        private void WaitForJobToFinish()
        {
            WaitFor(() => !IsTheJobRunning());
        }

        private void WaitFor(Func<bool> function)
        {
            var clock = new Stopwatch();
            clock.Start();
            do
            {
                if (function())
                {
                    return;
                }
                Thread.Sleep(1000);
            } while (clock.ElapsedMilliseconds < TimeoutMilliseconds);
            clock.Stop();
        }

        private void ValidateThatTheJobFinishedSuccessfully()
        {
            short? status = GetJobRunStatus();
            if (status != 1)
            {
                foreach (JobRunInfo jobRunInfo in GetDetailsOfLastJobRun())
                {
                    Console.WriteLine(jobRunInfo);
                }
            }

            Assert.IsNotNull(status, $"The status was null, it probably exceeded the timeout of {TimeoutMilliseconds / 1000} seconds.");
            Assert.True(status == 1, $@"The job did not succeed. Expecting run_status = 1 but found {status}.
                                        0 = Error failed
                                        1 = Succeeded
                                        3 = Canceled
                                        5 = Status unknown");
        }

        private void ValidateThatTheOldTableExists()
        {
            Assert.IsNotEmpty(sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.CheckOldTable)), " The old table [dbo].[PartitioningTestAutomationTable_Old] does not exist.");
        }

        private void ValidateThatTheNewTableExists()
        {
            Assert.IsNotEmpty(sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.CheckNewTable)), " The new partitioned table [dbo].[PartitioningTestAutomationTable] does not exist.");
        }

        private void ValidateThatTheNewTableIsPartitioned()
        {
            DateTime now = DateTime.Now.ToUniversalTime();
            /*Sam explained that the number of partitions is equal to the number of month since January 2018
             and one year from now, plus 2 more partitions()*/
             //get this from the PartitionFunctions table.
            int minimumNumberOfExpectedPartitions = sqlHelper.ExecuteScalar<int>(@"SELECT NumOfTotalPartitionFunctionIntervals 
                                                                                 FROM Utility.PartitionFunctions 
                                                                                 WHERE PartitionFunctionName = 'pfMonthlyTest'");
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.RowsInFileGroupsProcedureCall));
            Assert.IsTrue(list.Count >= minimumNumberOfExpectedPartitions, $"Expecting at least {minimumNumberOfExpectedPartitions} partition but found {list.Count}");
        }

        private void ValidateThatTheNewTableHasAllTheData()
        {
            Assert.IsEmpty(sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.DataMismatchValidation)), "Error: There is a data mismatch between the new and the old table.");
        }

        private void ValidateThatThereIsDataInPartitions()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.TotalRowsInFileGroups));
            Assert.AreEqual(list[0][0].Second, 96, $"Expecting 96 rows but found {list[0][0].Second} according to [Utility].[spSeeRowsInFileGroups]");
        }

        private void ValidateThatAllPartitionsHaveData()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.AllPartitionsHaveData));
            Assert.IsEmpty(list, $"Expecting all partitions to have data but some partition has 0 rows:{list}");
        }

        private void ValidateThatAllRowsAreInPartitionedTable()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.DataInPartitionedTable));
            Assert.AreEqual(list.Count, 96, $"Expecting 96 rows in the partitioned table but found {list.Count}.");
        }

        private void ValidateIndexesAreThereOnNewTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.IndexesAfterPartitioningNewTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "CDX_PartitioningTestAutomationTable"), "Index CDX_PartitioningTestAutomationTable is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "NCCI_PartitioningTestAutomationTable_Comments"), "Index NCCI_PartitioningTestAutomationTable_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "IDX_PartitioningTestAutomationTable_Comments"), "Index IDX_PartitioningTestAutomationTable_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "PK_PartitioningTestAutomationTable"), "Index PK_PartitioningTestAutomationTable is missing.");
        }

        private void ValidateIndexesAreThereOnOldTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.IndexesAfterPartitioningOldTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "CDX_PartitioningTestAutomationTable_OLD"), "Index CDX_PartitioningTestAutomationTable_OLD is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "NCCI_PartitioningTestAutomationTable_OLD_Comments"), "Index NCCI_PartitioningTestAutomationTable_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "IDX_PartitioningTestAutomationTable_OLD_Comments"), "Index IDX_PartitioningTestAutomationTable_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "PK_PartitioningTestAutomationTable_OLD"), "Index PK_PartitioningTestAutomationTable_OLD is missing.");
        }

        private void ValidateConstraintsAreThereOnNewTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.ConstraintsAfterPartitioningNewTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "Chk_PartitioningTestAutomationTable_updatedUtcDt"), "Constraint Chk_PartitioningTestAutomationTable_updatedUtcDt is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "Def_PartitioningTestAutomationTable_updatedUtcDt"), "Constraint Def_PartitioningTestAutomationTable_updatedUtcDt is missing.");
        }

        private void ValidateConstraintsAreThereOnOldTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.ConstraintsAfterPartitioningOldTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "Chk_PartitioningTestAutomationTable_OLD_updatedUtcDt"), "Constraint Chk_PartitioningTestAutomationTable_OLD_updatedUtcDt is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "Def_PartitioningTestAutomationTable_OLD_updatedUtcDt"), "Constraint Def_PartitioningTestAutomationTable_OLD_updatedUtcDt is missing.");
        }

        private void ValidateStatisticsAreThereOnNewTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.StatisticsAfterPartitioningNewTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "CDX_PartitioningTestAutomationTable"), "Statistics for index CDX_PartitioningTestAutomationTable is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "NCCI_PartitioningTestAutomationTable_Comments"), "Statistics for index NCCI_PartitioningTestAutomationTable_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "IDX_PartitioningTestAutomationTable_Comments"), "Statistics for index IDX_PartitioningTestAutomationTable_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "PK_PartitioningTestAutomationTable"), "Statistics for index PK_PartitioningTestAutomationTable is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "ST_PartitioningTestAutomationTable_id"), "Statistics ST_PartitioningTestAutomationTable_id is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "ST_PartitioningTestAutomationTable_myDateTime"), "Statistics ST_PartitioningTestAutomationTable_myDateTime is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "ST_PartitioningTestAutomationTable_Comments"), "Statistics ST_PartitioningTestAutomationTable_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "ST_PartitioningTestAutomationTable_updatedUtcDt"), "Statistics ST_PartitioningTestAutomationTable_updatedUtcDt is missing.");
        }

        private void ValidateStatisticsAreThereOnOldTableAfterPartitioning()
        {
            List<List<Pair<string, object>>> list = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.StatisticsAfterPartitioningOldTable));
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "CDX_PartitioningTestAutomationTable_OLD"), "Statistics for index CDX_PartitioningTestAutomationTable_OLD is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "NCCI_PartitioningTestAutomationTable_OLD_Comments"), "Statistics for index NCCI_PartitioningTestAutomationTable_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "IDX_PartitioningTestAutomationTable_OLD_Comments"), "Statistics for index IDX_PartitioningTestAutomationTable_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "PK_PartitioningTestAutomationTable_OLD"), "Statistics for index PK_PartitioningTestAutomationTable_OLD is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "ST_PartitioningTestAutomationTable_OLD_id"), "Statistics ST_PartitioningTestAutomationTable_OLD_id is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "ST_PartitioningTestAutomationTable_OLD_myDateTime"), "Statistics ST_PartitioningTestAutomationTable_OLD_myDateTime is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "ST_PartitioningTestAutomationTable_OLD_Comments"), "Statistics ST_PartitioningTestAutomationTable_OLD_Comments is missing.");
            Assert.IsNotEmpty(list.Where(x => (string)(x[0].Second) == "ST_PartitioningTestAutomationTable_OLD_updatedUtcDt"), "Statistics ST_PartitioningTestAutomationTable_OLD_updatedUtcDt is missing.");
        }

        private void ValidateThatTheQueueIsEmptyAfterPartitioning()
        {
            Assert.IsEmpty(sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.RecordsInTheQueue)), "Expecting the Queue table [utility.RefreshIndexStructuresQueue] to be empty but found records.");
        }

        private void ValidateThatLogTableHasNoErrors()
        {
            Assert.IsEmpty(sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.LogHasNoErrors)), "Log table [Utility].[RefreshIndexStructuresLog] has errors!!");
        }

        private void ValidateThatPartitionStateMetadataTableIsEmptyAfterPartitioning()
        {
            Assert.IsEmpty(sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.CheckForEmptyPartitionStateMetadata("dbo", "PartitioningTestAutomationTable"))), "Expecting the PartitionState Metadata table [utility.RefreshIndexStructures_PartitionState] to be empty but found records.");
        }

        private bool IsTestRunningInLocalEnvironment()
        {
            string reportingGatewayUri = TestConfigurationHelper.GetReportingGatewayUri();
            return (reportingGatewayUri == null || reportingGatewayUri.ToLower().Contains("localhost"));
        }

        private List<JobRunInfo> GetDetailsOfLastJobRun()
        {
            List<List<Pair<string, object>>> rows = sqlHelper.ExecuteQuery(new SqlCommand(TablePartitioningSqlStatements.DetailsOfLastJobRun));
            List<JobRunInfo> list = new List<JobRunInfo>();
            foreach (List<Pair<string, object>> row in rows)
            {
                JobRunInfo info = new JobRunInfo();
                info.StepId = row.Find(x => x.First == "step_id").Second.ToString();
                info.StepName = row.Find(x => x.First == "step_name").Second.ToString();
                info.Message = row.Find(x => x.First == "message").Second.ToString();
                info.SqlSeverity = row.Find(x => x.First == "sql_severity").Second.ToString();
                info.RunDate = row.Find(x => x.First == "run_date").Second.ToString();
                info.RunTime = row.Find(x => x.First == "run_time").Second.ToString();
                info.RunStatus = row.Find(x => x.First == "run_status").Second.ToString();
                list.Add(info);
            }
            return list;
        }

        private class JobRunInfo
        {
            public string StepId { get; set; }
            public string StepName { get; set; }
            public string Message { get; set; }
            public string SqlSeverity { get; set; }
            public string RunDate { get; set; }
            public string RunTime { get; set; }
            public string RunStatus { get; set; }

            public override string ToString()
            {
                return JObject.FromObject(this).ToString();
            }
        }
    }
}
