

--rename job to 'online' now that we also have an 'offline' job
IF EXISTS(SELECT 'True' FROM msdb.dbo.sysjobs WHERE name IN ('DOI-Refresh Indexes - Online'))
BEGIN
	EXEC msdb.dbo.sp_delete_job 
		@job_name = 'DOI-Refresh Indexes - Online'

	PRINT 'Deleted DOI-Refresh Indexes - Online Job.'
END

IF NOT EXISTS(SELECT 'True' FROM msdb.dbo.sysjobs WHERE name IN ('DOI-Refresh Indexes - Online'))
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @ReturnCode INT
			SELECT @ReturnCode = 0

			/****** Object:  JobCategory [DB Maintenance]    Script Date: 7/25/2014 4:08:45 PM ******/
			IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DB Maintenance' AND category_class=1)
			BEGIN
				EXEC @ReturnCode = msdb.dbo.sp_add_category 
					@class=N'JOB', 
					@type=N'LOCAL', 
					@name=N'DB Maintenance'
			END

			DECLARE @jobId BINARY(16)

			EXEC @ReturnCode =  msdb.dbo.sp_add_job 
				@job_name=N'DOI-Refresh Indexes - Online', 
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
			PRINT 'Created job DOI-Refresh Indexes - Online'


			/****** Object:  Step [Refresh Indexes]    Script Date: 7/25/2014 4:08:45 PM ******/
			EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
				@job_id=@jobId, 
				@step_name=N'Populate Queue - Online', 
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
EXEC DOI.spQueue
	@OnlineOperations = 1,
	@IsBeingRunDuringADeployment = 0
	', 
				@database_name=N'DOI', 
				@flags=0


			EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
				@job_id=@jobId, 
				@step_name=N'DOI-Refresh Indexes - Online', 
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
				@command=N'
EXEC DOI.spRun @OnlineOperations = 1
    
EXEC DOI.spForeignKeysAdd
    @CallingProcess = ''Job''', 
				@database_name=N'DOI', 
				@flags=0


			EXEC @ReturnCode = msdb.dbo.sp_update_job 
				@job_id = @jobId, 
				@start_step_id = 1

			EXEC @ReturnCode = msdb.dbo.sp_add_jobserver 
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
from msdb.dbo.sysjobs j 
where j.name = 'DOI-Refresh Indexes - Online'

IF EXISTS(SELECT 'True' FROM master.dbo.JobsToGovern WHERE JobName = 'DOI-Refresh Indexes - Online')
BEGIN
	DELETE master.dbo.JobsToGovern WHERE JobName = 'DOI-Refresh Indexes - Online'
END

IF NOT EXISTS(SELECT 'True' FROM master.dbo.JobsToGovern WHERE JobName = 'DOI-Refresh Indexes - Online')
BEGIN
	INSERT INTO master.dbo.JobsToGovern ( JobID ,JobName ,MatchString )
	VALUES ( @jobid , N'DOI-Refresh Indexes - Online' , N'SQLAgent - TSQL JobStep (Job ' + CONVERT(VARCHAR(36), CONVERT(BINARY(16), @jobid), 1) + '%')
END
GO