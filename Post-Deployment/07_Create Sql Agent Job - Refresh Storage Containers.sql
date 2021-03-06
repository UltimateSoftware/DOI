--4. needs to be run on new month or new year...ADD SQLAgent Job.
IF EXISTS(SELECT 'True' FROM msdb.dbo.sysjobs WHERE name = 'DOI-Refresh Storage Containers To Current Date')
BEGIN
	EXEC msdb.dbo.sp_delete_job
		@job_name = 'DOI-Refresh Storage Containers To Current Date'

	PRINT 'Dropped Job DOI-Refresh Storage Containers To Current Date.'
END


IF NOT EXISTS(SELECT 'True' FROM msdb.dbo.sysjobs WHERE name = 'DOI-Refresh Storage Containers To Current Date')
BEGIN
	DECLARE @SQL VARCHAR(MAX) = '',
			@Debug BIT = 0,
			@RunDate VARCHAR(30) = CONVERT(VARCHAR(30), DATEADD(DAY, 1, SYSDATETIME()), 112)

		SET @SQL = '
		USE [msdb]

		/****** Object:  Job [DOI-Refresh Storage Containers To Current Date]    Script Date: 7/25/2014 4:08:45 PM ******/
		BEGIN TRY
			BEGIN TRANSACTION
				DECLARE @ReturnCode INT
				SELECT @ReturnCode = 0

				/****** Object:  JobCategory [DB Maintenance]    Script Date: 7/25/2014 4:08:45 PM ******/
				IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''DB Maintenance'' AND category_class=1)
				BEGIN
					EXEC @ReturnCode = msdb.dbo.sp_add_category 
						@class=N''JOB'', 
						@type=N''LOCAL'', 
						@name=N''DB Maintenance''
				END

				DECLARE @jobId BINARY(16)

				EXEC @ReturnCode =  msdb.dbo.sp_add_job 
					@job_name=N''DOI-Refresh Storage Containers To Current Date'', 
					@enabled=1, 
					@notify_level_eventlog=0, 
					@notify_level_email=0, 
					@notify_level_netsend=0, 
					@notify_level_page=0, 
					@delete_level=0, 
					@description=N''No description available.'', 
					@category_name=N''DB Maintenance'', 
					@owner_login_name=N''sa'', 
					@job_id = @jobId OUTPUT
				PRINT ''Created job DOI-Refresh Storage Containers To Current Date''

				/****** Object:  Step [Add New Partitions On Calendar Switch]    Script Date: 7/25/2014 4:08:45 PM ******/
				EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
					@job_id=@jobId, 
					@step_name=N''Refresh Storage Containers'', 
					@step_id=1, 
					@cmdexec_success_code=0, 
					@on_success_action=1, 
					@on_success_step_id=0, 
					@on_fail_action=2, 
					@on_fail_step_id=0, 
					@retry_attempts=0, 
					@retry_interval=0, 
					@os_run_priority=0, 
					@subsystem=N''TSQL'', 
					@command=N''EXEC DOI.spRefreshStorageContainers_All''

				EXEC @ReturnCode = msdb.dbo.sp_update_job 
					@job_id = @jobId, 
					@start_step_id = 1

				EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
					@job_id=@jobId, 
					@name=N''Weekly'', 
					@enabled=1, 
					@freq_type=8, 
					@freq_interval=1, 
					@freq_subday_type=1, 
					@freq_subday_interval=0, 
					@freq_relative_interval=0, 
					@freq_recurrence_factor=1, 
					@active_start_date=' +  @RunDate + ', 
					@active_end_date=99991231, 
					@active_start_time=170000, 
					@active_end_time=235959, 
					@schedule_uid=N''6cf2af6e-bbc9-4650-8e4b-87278aa36ab2''

				EXEC @ReturnCode = msdb.dbo.sp_add_jobserver 
					@job_id = @jobId, 
					@server_name = N''(local)''

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
			THROW;
		END CATCH'

		IF @Debug = 1
		BEGIN
			EXEC dbo.spPrintOutLongSQL @SQLInput = @SQL,
				@VariableName = N'@SQL'	
		END
		ELSE
		BEGIN
			EXEC (@SQL)
		END
END
GO