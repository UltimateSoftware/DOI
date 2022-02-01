-- <Migration ID="4f47b7a8-284e-47bc-9a89-ebb395c372aa" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

GO

IF OBJECT_ID('[DOI].[spRun_DisableResourceGovernor]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRun_DisableResourceGovernor];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRun_DisableResourceGovernor]

AS

/*
	exec DOI.spRun_DisableResourceGovernor
*/

ALTER RESOURCE POOL IndexMaintenancePool  
WITH(   
		MAX_IOPS_PER_VOLUME = 0, --what is the right number?  run test rebuilds and watch max value SQL Server:Resource Pool Stats:Disk Write IO/Sec perfmon counter to get # IOPS consumed.
		MIN_IOPS_PER_VOLUME = 0, 
		MAX_MEMORY_PERCENT = 100, 
		CAP_CPU_PERCENT = 0, --hard cap on MAXIMUM cpu bandwidth
		MAX_CPU_PERCENT = 0 --max AVERAGE CPU bandwidth WHEN THERE IS CPU CONTENTION.
);  
  

ALTER RESOURCE GOVERNOR RECONFIGURE

GO