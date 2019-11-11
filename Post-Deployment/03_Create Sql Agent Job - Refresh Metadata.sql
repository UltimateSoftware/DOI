USE msdb
GO

IF EXISTS(SELECT 'True' FROM dbo.sysjobs WHERE name = 'DDI - Refresh Metadata')
BEGIN
	EXEC sp_delete_job @job_name = N'DDI - Refresh Metadata' ;  

	PRINT 'Deleted Job DDI - Refresh Metadata.'
END
GO


--BEGIN TRY
--	BEGIN TRANSACTION
--		DECLARE @ReturnCode INT
--		SELECT @ReturnCode = 0

--		/****** Object:  JobCategory [DB Maintenance]    Script Date: 7/25/2014 4:08:45 PM ******/
--		IF NOT EXISTS (SELECT name FROM dbo.syscategories WHERE name=N'DB Maintenance' AND category_class=1)
--		BEGIN
--			EXEC @ReturnCode = dbo.sp_add_category 
--				@class=N'JOB', 
--				@type=N'LOCAL', 
--				@name=N'DB Maintenance'
--		END

--		DECLARE @jobId BINARY(16)

--		EXEC @ReturnCode =  dbo.sp_add_job 
--			@job_name=N'DDI - Refresh Metadata', 
--			@enabled=1, 
--			@notify_level_eventlog=0, 
--			@notify_level_email=0, 
--			@notify_level_netsend=0, 
--			@notify_level_page=0, 
--			@delete_level=0, 
--			@description=N'No description available.', 
--			@category_name=N'DB Maintenance', 
--			@owner_login_name=N'sa', 
--			@job_id = @jobId OUTPUT
--		PRINT 'Created job DDI - Refresh Metadata'


--		/****** Object:  Step [DDI - Refresh Metadata]    Script Date: 7/25/2014 4:08:45 PM ******/
--		EXEC @ReturnCode = dbo.sp_add_jobstep 
--			@job_id=@jobId, 
--			@step_name=N'Refresh Metadata', 
--			@step_id=1, 
--			@cmdexec_success_code=0, 
--			@on_success_action=1, 
--			@on_success_step_id=0, 
--			@on_fail_action=2, 
--			@on_fail_step_id=0, 
--			@retry_attempts=0, 
--			@retry_interval=0, 
--			@os_run_priority=0, 
--			@subsystem=N'TSQL', 
--			@command=N'EXEC DDI.spRefreshMetadata_Run_All', 
--			@database_name=N'DDI', 
--			@flags=0

--		EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
--			@job_id=@jobId, 
--			@name=N'DDI-Every 5 Minutes', 
--			@enabled=1, 
--			@freq_type=4, 
--			@freq_interval=1, 
--			@freq_subday_type=4, 
--			@freq_subday_interval=5, 
--			@freq_relative_interval=0, 
--			@freq_recurrence_factor=0, 
--			@active_start_date=20191217, 
--			@active_end_date=99991231, 
--			@active_start_time=0, 
--			@active_end_time=235959, 
--			@schedule_uid=N'39536401-ebf7-4876-8ad7-86ea459ded1c'


--		EXEC @ReturnCode = dbo.sp_update_job 
--			@job_id = @jobId, 
--			@start_step_id = 1

--		EXEC @ReturnCode = dbo.sp_add_jobserver 
--			@job_id = @jobId, 
--			@server_name = N'(local)'

--	COMMIT TRANSACTION
--END TRY

--BEGIN CATCH
--	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
--	THROW;
--END CATCH


--SELECT @jobid = job_id 
--FROM dbo.sysjobs j 
--WHERE j.name = 'DDI - Refresh Metadata'

--IF EXISTS(SELECT 'True' FROM master.dbo.JobsToGovern WHERE JobName = 'DDI - Refresh Metadata')
--BEGIN
--	DELETE master.dbo.JobsToGovern WHERE JobName = 'DDI - Refresh Metadata'
--END

--IF NOT EXISTS(SELECT 'True' FROM master.dbo.JobsToGovern WHERE JobName = 'DDI - Refresh Metadata')
--BEGIN
--	INSERT INTO master.dbo.JobsToGovern ( JobID ,JobName ,MatchString )
--	VALUES ( @jobid , N'DDI - Refresh Metadata' , N'SQLAgent - TSQL JobStep (Job ' + CONVERT(VARCHAR(36), CONVERT(BINARY(16), @jobid), 1) + '%')
--END
--GO