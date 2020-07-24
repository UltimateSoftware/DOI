-- <Migration ID="e414f66a-f152-4976-8486-d7d611d85811" TransactionHandling="Custom" />
IF OBJECT_ID(N'[DOI].[BusinessHoursSchedule]', 'U') IS NULL
CREATE TABLE [DOI].[BusinessHoursSchedule]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[DayOfWeekId] [tinyint] NOT NULL,
[DayOfWeekName] AS (case [DayOfWeekId] when (1) then 'Sunday' when (2) then 'Monday' when (3) then 'Tuesday' when (4) then 'Wednesday' when (5) then 'Thursday' when (6) then 'Friday' when (7) then 'Saturday' end),
[StartUtcMilitaryTime] [time] NOT NULL,
[IsBusinessHours] [bit] NOT NULL,
[IsEnabled] [bit] NOT NULL
)
GO
PRINT N'Creating primary key [PK_BusinessHoursSchedule] on [DOI].[BusinessHoursSchedule]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[DOI].[PK_BusinessHoursSchedule]', 'PK') AND parent_object_id = OBJECT_ID(N'[DOI].[BusinessHoursSchedule]', 'U'))
ALTER TABLE [DOI].[BusinessHoursSchedule] ADD CONSTRAINT [PK_BusinessHoursSchedule] PRIMARY KEY CLUSTERED  ([DatabaseName], [DayOfWeekId], [StartUtcMilitaryTime])
GO