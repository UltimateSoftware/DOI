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
using DOI.Tests.TestHelpers.ExchangeTable;
using Microsoft.Practices.Unity.Utility;
using Newtonsoft.Json.Linq;
using NUnit.Framework;

namespace DOI.Tests.TestHelpers
{
    public class ExchangeTableHelpers : DOIBaseTest
    {
        private const long TimeoutMilliseconds = 5 * 60 * 1000;
        private string standardBcpFileFullPath = @"c:\tmp\user-management\utebcp\utebcp.exe";
        protected const string NonPartitionedTableName = "TempA";
        protected const string PartitionedTableName = "PartitioningTestAutomationTable";

        private bool IsTheJobRunning()
        {
            return GetJobRunStatus() == null;
        }

        private short? GetJobRunStatus()
        {
            List<List<Pair<string, object>>> result = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements.JobActivity));
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

        private void WaitForJobToFinish()
        {
            WaitFor(() => !IsTheJobRunning());
        }

        private bool IsTestRunningInLocalEnvironment()
        {
            string reportingGatewayUri = TestConfigurationHelper.GetReportingGatewayUri();
            return (reportingGatewayUri == null || reportingGatewayUri.ToLower().Contains("localhost"));
        }

        public void StartSqlServerAgentIfIsNotRunning()
        {
            if (IsTestRunningInLocalEnvironment())
            {
                WindowsServiceHelper.StartSqlServerAgent();
            }
        }

        public void RunPartitionJobAndWaitForItToFinish()
        {
            sqlHelper.Execute(SetupSqlStatements_Partitioned.StartJob);
            WaitForJobToFinish();
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

        private List<JobRunInfo> GetDetailsOfLastJobRun()
        {
            List<List<Pair<string, object>>> rows = sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements.DetailsOfLastJobRun));
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

        public void EnsureThatBcpUtilityIsInPlace()
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
                            $"Cannot find our copy of the utebcp.exe file in {ourCopyOfBcp.FullName}. This test depends on this BCP DOI.");
                    }
                }
            }
        }

        public void ValidateThatTheJobFinishedSuccessfully()
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

        public void ValidateThatTheQueueIsEmpty()
        {
            Assert.IsEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements.RecordsInTheQueue)), "Expecting the Queue table [DOI.Queue] to be empty but found records.");
        }

        public void ValidateThatLogTableHasNoErrors()
        {
            Assert.IsEmpty(sqlHelper.ExecuteQuery(new SqlCommand(SetupSqlStatements.LogHasNoErrors)), "Log table [DOI.Log] has errors!!");
        }
    }
}