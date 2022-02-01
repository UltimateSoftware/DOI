

--rename job to 'online' now that we also have an 'offline' job
IF EXISTS(SELECT 'True' FROM msdb.dbo.sysjobs WHERE name IN ('DOI-Refresh Indexes-Offline'))
BEGIN
	EXEC msdb.dbo.sp_delete_job 
		@job_name = 'DOI-Refresh Indexes-Offline'

	PRINT 'Deleted DOI-Refresh Indexes-Offline Job.'
END

IF NOT EXISTS(SELECT 'True' FROM msdb.dbo.sysjobs WHERE name IN ('DOI-Refresh Indexes-Offline'))
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
				@job_name=N'DOI-Refresh Indexes-Offline', 
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
			PRINT 'Created job DOI-Refresh Indexes-Offline'


			EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
				@job_id=@jobId, 
				@step_name=N'Check if we can run Offline Operations', 
				@step_id=1, 
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
				--business hours check OR, has DOISettings flag been set?
				IF EXISTS (	SELECT ''True''
							FROM DOI.vwBusinessHoursSchedule
							WHERE DATEPART(WEEKDAY, SYSDATETIME()) = DayOfWeekId
							    AND DATEPART(HOUR, SYSDATETIME()) BETWEEN DATEPART(HOUR, StartUtcMilitaryTime) AND DATEPART(HOUR, EndUtcMilitaryTime)
							    AND IsBusinessHours = 0)
					OR (SELECT ''True'' FROM DOI.DOISettings WHERE SettingName = ''OKToRunOfflineOperations'' AND DatabaseName = ''ALL'' AND SettingValue = 1)
				BEGIN
					RAISERROR(''Offline DOI Refresh Indexes Job is OK to run.'', 10, 1)
				END
				ELSE
				BEGIN
					RAISERROR(''Cannot run Offline DOI Refresh Indexes Job during business hours when manual override flag has not been set.'', 16, 1)
				END
				', 
				@database_name=N'DOI', 
				@flags=0
			/****** Object:  Step [Refresh Indexes]    Script Date: 7/25/2014 4:08:45 PM ******/
			EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
				@job_id=@jobId, 
				@step_name=N'Refresh Indexes', 
				@step_id=1, 
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
    DECLARE @BatchId UNIQUEIDENTIFIER

	EXEC DOI.spQueue 
        @BatchIdOUT = @BatchId,
		@Online = 0

	EXEC DOI.spRun 
		@BatchId = @BatchId,
		@Online = 0
    
	EXEC DOI.spForeignKeysAdd
		@CallingProcess = ''Job''
	', 
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