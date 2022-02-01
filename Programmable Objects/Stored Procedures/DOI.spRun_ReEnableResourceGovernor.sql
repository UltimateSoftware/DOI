-- <Migration ID="4f47b7a8-284e-47bc-9a89-ebb395c372aa" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

GO

IF OBJECT_ID('[DOI].[spRun_ReEnableResourceGovernor]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRun_ReEnableResourceGovernor];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRun_ReEnableResourceGovernor]
	@Debug BIT = 0

AS

/*
	EXEC DOI.spRun_ReEnableResourceGovernor
		@Debug = 1
*/
--check if the maintenance pool is off first?

DECLARE @ResourceGovernorMinIopsPerVolume VARCHAR(50) = (SELECT SettingValue FROM DOI.DOISettings WHERE SettingName = 'ResourceGovernorMinIopsPerVolume'),
		@ResourceGovernorMaxIopsPerVolume VARCHAR(50) = (SELECT SettingValue FROM DOI.DOISettings WHERE SettingName = 'ResourceGovernorMaxIopsPerVolume'),
		@ResourceGovernorMaxMemoryPercent VARCHAR(50) = (SELECT SettingValue FROM DOI.DOISettings WHERE SettingName = 'ResourceGovernorMaxMemoryPercent'),
		@ResourceGovernorMaxCpuPercent    VARCHAR(50) = (SELECT SettingValue FROM DOI.DOISettings WHERE SettingName = 'ResourceGovernorMaxCpuPercent'),
		@ResourceGovernorCapCpuPercent    VARCHAR(50) = (SELECT SettingValue FROM DOI.DOISettings WHERE SettingName = 'ResourceGovernorCapCpuPercent'),
		@SQL							  NVARCHAR(MAX) = N''


SET @SQL += '
IF EXISTS (	SELECT ''True''
			FROM SYS.resource_governor_resource_pools
			WHERE name = ''IndexMaintenancePool''
				AND (max_cpu_percent <> ' + @ResourceGovernorMaxCpuPercent + '
						OR cap_cpu_percent <> ' + @ResourceGovernorCapCpuPercent + '
						OR max_memory_percent <> ' + @ResourceGovernorMaxMemoryPercent + '
						OR min_iops_per_volume <> ' + @ResourceGovernorMinIopsPerVolume + '
						OR max_iops_per_volume <> ' + @ResourceGovernorMaxIopsPerVolume + '))
BEGIN
	ALTER RESOURCE POOL IndexMaintenancePool WITH
		(
			MAX_IOPS_PER_VOLUME = ' + @ResourceGovernorMaxIopsPerVolume + ',
			MIN_IOPS_PER_VOLUME = ' + @ResourceGovernorMinIopsPerVolume + ',
			MAX_MEMORY_PERCENT = ' + @ResourceGovernorMaxMemoryPercent + ',
			CAP_CPU_PERCENT = ' + @ResourceGovernorCapCpuPercent + ',
			MAX_CPU_PERCENT = ' + @ResourceGovernorMaxCpuPercent + '
		)

	PRINT ''Re-enabled IndexMaintenancePool Resource Governor Resource Pool.''

	ALTER RESOURCE GOVERNOR RECONFIGURE
END

'

IF @Debug = 1
BEGIN
	EXEC dbo.spPrintOutLongSQL
		@SQLInput = @SQL,
	    @VariableName = N'@SQL'
END
ELSE
BEGIN
	EXEC sp_executesql @SQL
END

GO