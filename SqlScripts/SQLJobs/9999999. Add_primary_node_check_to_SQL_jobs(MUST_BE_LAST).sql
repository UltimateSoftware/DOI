DECLARE @v_AddJobStep VARCHAR(MAX) = '
EXEC msdb..sp_add_jobstep @job_id = ''{JobId}''
                        , @step_id = 1
                        , @step_name = ''Check is primary server''
                        , @command = ''IF COALESCE((SELECT CASE WHEN primary_replica = @@SERVERNAME THEN 1 ELSE 0 END FROM sys.availability_groups AG JOIN sys.dm_hadr_availability_group_states AGS ON AG.group_id = AGS.group_id), 1) = 0 RAISERROR(''''Not the primary node, nothing to do'''', 16, 1)''
                        , @on_success_action = 3 -- Go to next step
                        , @on_fail_action = 1 -- Quit with success
                        , @database_name = ''master'' 
'

DECLARE @v_SQL VARCHAR(MAX) = ''
SELECT @v_SQL = @v_SQL + REPLACE(@v_AddJobStep, '{JobId}', CONVERT(VARCHAR(50), Job_Id)) + CHAR(13) + CHAR(10)
  FROM msdb..sysjobs j
  WHERE [name] NOT IN ('syspolicy_purge_history'/*this is a microsoft job*/) 
    AND NOT EXISTS (SELECT * FROM msdb.dbo.syscategories c WHERE j.category_id = c.category_id AND c.name in ('Database Maintenance', 'PS Operations'))
    AND NOT EXISTS (SELECT * 
	                  FROM msdb..sysjobsteps js
					  WHERE j.job_id = js.job_id
					    AND js.step_name = 'Check is primary server')

--PRINT @v_SQL
EXEC(@v_SQL)