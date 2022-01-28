using System;
using System.Text;

namespace DOI.Tests.TestHelpers.ExchangeTable
{
    public static class SetupSqlStatements
    {
        private const string DatabaseName = "DOIUnitTests";
        private const string TableName = "PartitioningTestAutomationTable";

        public static string StartJob = @"  exec msdb.dbo.sp_start_job @job_name =  'DOI-Refresh Indexes' ";

        public static string JobActivity = @"exec msdb.dbo.sp_help_jobactivity @job_name =  'DOI-Refresh Indexes'";

        public static string UpdateJobStepForTest = @"
                                                    EXEC msdb.dbo.sp_update_jobstep  
                                                     @job_name =  'DOI-Refresh Indexes' 
                                                    ,@step_id = 1
                                                    ,@command = N'    DECLARE @BatchId UNIQUEIDENTIFIER

	EXEC DOI.spQueue 
        @BatchIdOUT = @BatchId

	EXEC DOI.spRun 
		@BatchId = @BatchId
    
	EXEC DOI.spForeignKeysAdd
		@CallingProcess = ''Job'''
                                                    ";

        public static string RestoreJobStep = @"
                                                    EXEC msdb.dbo.sp_update_jobstep  
                                                     @job_name =  'DOI-Refresh Indexes' 
                                                    ,@step_id = 1
                                                    ,@command = N'    DECLARE @BatchId UNIQUEIDENTIFIER

	EXEC DOI.spQueue 
        @BatchIdOUT = @BatchId

	EXEC DOI.spRun 
		@BatchId = @BatchId
    
	EXEC DOI.spForeignKeysAdd
		@CallingProcess = ''Job'''
                                                    ";




        public static string RecordsInTheQueue = @"Select * FROM  DOI.Queue";

        public static string LogHasNoErrors = @"SELECT * FROM DOI.Log WHERE SchemaName = 'dbo' and TableName = '{TableName}' and ErrorText IS NOT NULL";


        public static string DetailsOfLastJobRun = @"
                                                    DECLARE @LatestRunDate varchar(10)
                                                    DECLARE @LatestRunTime varchar(10)
                                                        
                                                    select @LatestRunDate = max(jh.run_date) 
                                                        , @LatestRunTime =  max(jh.run_time ) 
                                                    from msdb.dbo.sysjobs j
                                                    JOIN msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
                                                    where  j.name = N'DOI-Refresh Indexes'
                                                        AND jh.step_id = 1

                                                    select jh. step_id,  step_name , message , sql_severity, run_date , run_time, run_status
                                                    from msdb.dbo.sysjobs j
                                                    JOIN msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
                                                    where  j.name = N'Refresh Index Structures'
                                                    and jh.run_date >= @LatestRunDate 
                                                    AND jh.run_time >= @LatestRunTime";
    }
}