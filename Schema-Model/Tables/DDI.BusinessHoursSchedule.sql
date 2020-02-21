CREATE TABLE [DDI].[BusinessHoursSchedule]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[DayOfWeekId] [tinyint] NOT NULL,
[DayOfWeekName] AS (case [DayOfWeekId] when (1) then 'Sunday' when (2) then 'Monday' when (3) then 'Tuesday' when (4) then 'Wednesday' when (5) then 'Thursday' when (6) then 'Friday' when (7) then 'Saturday' end),
[StartUtcMilitaryTime] [time] NOT NULL,
[IsBusinessHours] [bit] NOT NULL,
[IsEnabled] [bit] NOT NULL
)
GO
ALTER TABLE [DDI].[BusinessHoursSchedule] ADD CONSTRAINT [PK_BusinessHoursSchedule] PRIMARY KEY CLUSTERED  ([DatabaseName], [DayOfWeekId], [StartUtcMilitaryTime])
GO
