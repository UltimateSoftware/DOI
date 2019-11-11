USE msdb
GO

IF EXISTS(	SELECT 'True' 
				FROM dbo.sysschedules 
				WHERE name = 'One Time Weekend')
BEGIN
	EXEC dbo.sp_delete_schedule
		@schedule_name = 'One Time Weekend'
	
END

GO

IF NOT EXISTS(SELECT 'True' FROM dbo.sysjobs WHERE name = 'Refresh Index Structures')
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @ReturnCode INT
			SELECT @ReturnCode = 0

			/****** Object:  JobCategory [DB Maintenance]    Script Date: 7/25/2014 4:08:45 PM ******/
			IF NOT EXISTS (SELECT name FROM dbo.syscategories WHERE name=N'DB Maintenance' AND category_class=1)
			BEGIN
				EXEC @ReturnCode = dbo.sp_add_category 
					@class=N'JOB', 
					@type=N'LOCAL', 
					@name=N'DB Maintenance'
			END

			DECLARE @jobId BINARY(16)

			EXEC @ReturnCode =  dbo.sp_add_job 
				@job_name=N'Refresh Index Structures', 
				@enabled=1, 
				@notify_level_eventlog=0, 
				@notify_level_email=0, 
				@notify_level_netsend=0, 
				@notify_level_page=0, 
				@delete_level=0, 
				@description=N'No description available.', 
				@category_name=N'DB Maintenance', 
				@owner_login_name=N'sa', 
				@job_id = @jobId OUTPUT
			PRINT 'Created job Refresh Index Structures'


			/****** Object:  Step [Refresh Index Structures]    Script Date: 7/25/2014 4:08:45 PM ******/
			EXEC @ReturnCode = dbo.sp_add_jobstep 
				@job_id=@jobId, 
				@step_name=N'Populate Index Structures Queue', 
				@step_id=1, 
				@cmdexec_success_code=0, 
				@on_success_action=3, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, 
				@subsystem=N'TSQL', 
				@command=N'
TRUNCATE TABLE Utility.RefreshIndexStructuresQueue

DECLARE @BatchId UNIQUEIDENTIFIER

EXEC Utility.spRefreshIndexStructures_Queue 
	@SchemaName = ''dbo'',
	@TableName = ''Pays'',
	@BatchIdOUT = @BatchId
	', 
				@database_name=N'PaymentReporting', 
				@flags=0


			EXEC @ReturnCode = dbo.sp_add_jobstep 
				@job_id=@jobId, 
				@step_name=N'Refresh Index Structures', 
				@step_id=2, 
				@cmdexec_success_code=0, 
				@on_success_action=1, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, 
				@subsystem=N'TSQL', 
				@command=N'EXEC Utility.spRefreshIndexStructures_Run
								@SchemaName = NULL,
								@TableName = NULL,
								@CallingProcess = ''SQLAgentJob''', 
				@database_name=N'PaymentReporting', 
				@flags=0


			EXEC @ReturnCode = dbo.sp_update_job 
				@job_id = @jobId, 
				@start_step_id = 1

			EXEC @ReturnCode = dbo.sp_add_jobserver 
				@job_id = @jobId, 
				@server_name = N'(local)'

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END
GO

declare @jobid UNIQUEIDENTIFIER

select @jobid = job_id 
from dbo.sysjobs j 
where j.name = 'Refresh Index Structures'

IF EXISTS(SELECT 'True' FROM master.dbo.JobsToGovern WHERE JobName = 'Refresh Index Structures')
BEGIN
	DELETE master.dbo.JobsToGovern WHERE JobName = 'Refresh Index Structures'
END

IF NOT EXISTS(SELECT 'True' FROM master.dbo.JobsToGovern WHERE JobName = 'Refresh Index Structures')
BEGIN
	INSERT INTO master.dbo.JobsToGovern ( JobID ,JobName ,MatchString )
	VALUES ( @jobid , N'Refresh Index Structures' , N'SQLAgent - TSQL JobStep (Job ' + CONVERT(VARCHAR(36), CONVERT(BINARY(16), @jobid), 1) + '%')
END
GO


--For Rebuild By Partition branch
declare @StepID int

select @StepID = step_id 
from dbo.sysjobs j 
	inner join dbo.sysjobsteps js on j.job_id = js.job_id
where j.name = 'Refresh Index Structures'
	and js.step_name = 'Populate Index Structures Queue'

EXEC dbo.sp_update_jobstep
	@job_name = 'Refresh Index Structures',
	@step_name = 'Populate Index Structures Queue',
	@step_id = @StepID,
	@command = '
TRUNCATE TABLE Utility.RefreshIndexStructuresQueue

DECLARE @BatchId UNIQUEIDENTIFIER

EXEC Utility.spRefreshIndexStructures_Queue 
	@OnlineOperations = 1,
	@IsBeingRunDuringADeployment = 0,
	@BatchIdOUT = @BatchId'
GO

declare @StepID int

select @StepID = step_id 
from dbo.sysjobs j 
	inner join dbo.sysjobsteps js on j.job_id = js.job_id
where j.name = 'Refresh Index Structures'
	and js.step_name = 'Refresh Index Structures'

EXEC dbo.sp_update_jobstep
	@job_name = 'Refresh Index Structures',
	@step_name = 'Refresh Index Structures',
	@step_id = @StepID,
	@command = '
EXEC Utility.spRefreshIndexStructures_Run
	@OnlineOperations = 1'
GO

IF EXISTS(	SELECT 'True' 
			FROM dbo.sysjobschedules js 
				INNER JOIN dbo.sysjobs j ON j.job_id = js.job_id 
				INNER JOIN dbo.sysschedules s ON s.schedule_id = js.schedule_id
			WHERE j.name = 'Refresh Index Structures'
				AND s.name = 'One Time Weekend')
BEGIN
	EXEC dbo.sp_detach_schedule  
		@job_name = 'Refresh Index Structures',
		@schedule_name = 'One Time Weekend' ;  
END 
GO  

IF NOT EXISTS(	SELECT 'True' 
				FROM dbo.sysschedules 
				WHERE name = 'Nightly')
BEGIN
	EXEC dbo.sp_add_schedule 
		@schedule_name = 'Nightly' ,   
	    @enabled = 1 ,                 
	    @freq_type = 1 ,               
	    @freq_interval = 1 ,           
	    @freq_subday_type = 0 ,        
	    @freq_subday_interval = 0 ,    
	    @freq_relative_interval = 0 ,  
	    @freq_recurrence_factor = 0 ,  
	    @active_start_date = 20190101 ,
	    @active_end_date = 99991231 ,  
	    @active_start_time = 050000 ,  
	    @active_end_time = 235959 ,    
	    @owner_login_name = 'sa' 
END

GO

IF NOT EXISTS(	SELECT 'True' 
				FROM dbo.sysjobschedules js
					INNER JOIN dbo.sysschedules s ON s.schedule_id = js.schedule_id
					INNER JOIN dbo.sysjobs j ON j.job_id = js.job_id
				WHERE s.name = 'Nightly'
					AND j.name = 'Refresh Index Structures')
BEGIN
	EXEC dbo.sp_attach_schedule
		@job_name = 'Refresh Index Structures' ,
		@schedule_name = 'Nightly'
END
GO