USE master
GO

/*************************************	MASTER DB OBJECTS *********************************************/

IF OBJECT_ID('dbo.JobsToGovern') IS NULL
BEGIN
	CREATE TABLE dbo.JobsToGovern(
		JobID UNIQUEIDENTIFIER NOT NULL,
		JobName SYSNAME,
		MatchString NVARCHAR(256) PRIMARY KEY CLUSTERED,
		DateInserted DATETIME2 NOT NULL DEFAULT SYSDATETIME())

	PRINT 'Created table dbo.JobsToGovern.'
END


IF '$(IsShadowDeployment)' = 0
BEGIN
	IF EXISTS(SELECT 'True' FROM sys.resource_governor_configuration rgc WHERE rgc.is_enabled = 0)
	BEGIN
		ALTER RESOURCE GOVERNOR RECONFIGURE;   --enables resource governor

		PRINT 'Enabled Resource Governor.'
	END

	IF NOT EXISTS(SELECT 'True' FROM sys.resource_governor_configuration rgc WHERE rgc.is_enabled = 1)
	BEGIN
		RAISERROR('Resource Governor was not enabled.', 16, 1)
	END
END
GO  

IF '$(IsShadowDeployment)' = 0
BEGIN
	IF EXISTS (SELECT 'True' FROM sys.resource_governor_workload_groups WHERE name = 'IndexMaintenanceGroup')
	BEGIN
		DROP WORKLOAD GROUP IndexMaintenanceGroup

		PRINT 'Dropped IndexMaintenanceGroup.'
	END
END
GO

IF '$(IsShadowDeployment)' = 0
BEGIN
	IF EXISTS(SELECT 'True' FROM sys.resource_governor_resource_pools WHERE name = 'IndexMaintenancePool')
	BEGIN
		DROP RESOURCE POOL IndexMaintenancePool

		PRINT 'Dropped IndexMaintenancePool.'
	END
END
GO

IF '$(IsShadowDeployment)' = 0
BEGIN
	IF NOT EXISTS(SELECT 'True' FROM sys.resource_governor_resource_pools WHERE name = 'IndexMaintenancePool')
	BEGIN
		CREATE RESOURCE POOL IndexMaintenancePool WITH
		(
			MAX_IOPS_PER_VOLUME = 500, --what is the right number?  run test rebuilds and watch max value SQL Server:Resource Pool Stats:Disk Write IO/Sec perfmon counter to get # IOPS consumed.
			MIN_IOPS_PER_VOLUME = 1, 
			MAX_MEMORY_PERCENT = 20, 
			CAP_CPU_PERCENT = 20, --hard cap on MAXIMUM cpu bandwidth
			MAX_CPU_PERCENT = 20 --max AVERAGE CPU bandwidth WHEN THERE IS CPU CONTENTION.
			--AFFINITY {SCHEDULER =  
		 --                 AUTO 
		 --               | ( <scheduler_range_spec> )   
		 --               | NUMANODE = ( <NUMA_node_range_spec> )
		 --               } ]   
		)

		PRINT 'Created IndexMaintenancePool Resource Governor Resource Pool.'
	END
END
GO
 
IF '$(IsShadowDeployment)' = 0
BEGIN
	-- Create a new Workload Group for the Index Maintenance process
	IF NOT EXISTS (SELECT 'True' FROM sys.resource_governor_workload_groups WHERE name = 'IndexMaintenanceGroup')
	BEGIN
		CREATE WORKLOAD GROUP IndexMaintenanceGroup
		--WITH (MAX_DOP = 1, IMPORTANCE = LOW)
		USING IndexMaintenancePool

		PRINT 'Created IndexMaintenanceGroup Resource Governor Workload Group.'
	END
END
GO

IF '$(IsShadowDeployment)' = 0
BEGIN
	IF EXISTS(	SELECT 'True'
				FROM sys.resource_governor_configuration rgc 
					INNER JOIN sys.objects o ON rgc.classifier_function_id = o.object_id
				WHERE o.name = 'fnClassifier')
	BEGIN
		ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = null)

		PRINT 'Changed Resource Gov Classifier Function to NULL.'

		IF EXISTS(SELECT 'True' FROM sys.dm_resource_governor_configuration WHERE is_reconfiguration_pending = 1)
		BEGIN
			ALTER RESOURCE GOVERNOR RECONFIGURE

			PRINT 'Ran Resource Gov Reconfigure.'
		END
		ELSE
		BEGIN
			RAISERROR('Resource Governor change to ClassifierFunction = NULL did not take.', 16, 1)
		END
	END
END
GO

IF '$(IsShadowDeployment)' = 0
BEGIN
	--DROP OLD CLASSIFIER FUNCTION.
	IF OBJECT_ID('dbo.fnLoginClassifier') IS NOT NULL
	BEGIN
		IF EXISTS(	SELECT 'True'
					FROM sys.resource_governor_configuration rgc 
						INNER JOIN sys.objects o ON rgc.classifier_function_id = o.object_id
					WHERE o.name = 'fnLoginClassifier')
		BEGIN
			ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = null)

			PRINT 'Changed Resource Gov Classifier Function to NULL.'

			IF EXISTS(SELECT 'True' FROM sys.dm_resource_governor_configuration WHERE is_reconfiguration_pending = 1)
			BEGIN
				ALTER RESOURCE GOVERNOR RECONFIGURE

				PRINT 'Ran Resource Gov Reconfigure.'
			END
			ELSE
			BEGIN
				RAISERROR('Resource Governor change to ClassifierFunction = NULL did not take.', 16, 1)
			END
		END

		DROP FUNCTION dbo.fnLoginClassifier

		PRINT 'Dropped dbo.fnLoginClassifier.'
	END
END
GO


IF '$(IsShadowDeployment)' = 0
BEGIN
	EXEC('
	CREATE OR ALTER FUNCTION dbo.fnClassifier()
	RETURNS SYSNAME WITH SCHEMABINDING
	AS
	BEGIN
		DECLARE @app		NVARCHAR(256) = APP_NAME(),
				@GroupName	SYSNAME = N''default'';
	
		IF @app LIKE N''SQLAgent - TSQL JobStep%''
		BEGIN
			IF EXISTS (	SELECT 1 FROM dbo.JobsToGovern WHERE @app LIKE MatchString)
			BEGIN
				SET @GroupName = ''IndexMaintenanceGroup''
			END
		END
	
		RETURN @GroupName;
	END')
END
GO

IF '$(IsShadowDeployment)' = 0
BEGIN
	-- Register the Classifier Function within Resource Governor
	IF EXISTS(	SELECT 'True'
				FROM sys.resource_governor_configuration rgc 
				WHERE rgc.classifier_function_id = 0)
	BEGIN
		ALTER RESOURCE GOVERNOR WITH(CLASSIFIER_FUNCTION = dbo.fnClassifier)

		PRINT 'Changed Resource Gov Classifier Function to dbo.fnClassifier.'

		IF EXISTS(SELECT 'True' FROM sys.dm_resource_governor_configuration WHERE is_reconfiguration_pending = 1)
		BEGIN
			ALTER RESOURCE GOVERNOR RECONFIGURE

			PRINT 'Ran Resource Gov Reconfigure.'
		END
		ELSE
		BEGIN
			RAISERROR('Resource Governor change to ClassifierFunction = fnClassifier did not take.', 16, 1)
		END
	END
END
GO 