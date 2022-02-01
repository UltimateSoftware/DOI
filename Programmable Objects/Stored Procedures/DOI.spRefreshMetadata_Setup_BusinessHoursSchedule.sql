IF OBJECT_ID('[DOI].[spRefreshMetadata_Setup_BusinessHoursSchedule]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_Setup_BusinessHoursSchedule];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_Setup_BusinessHoursSchedule]
    @DatabaseName SYSNAME
AS

DELETE DOI.BusinessHoursSchedule

INSERT INTO DOI.BusinessHoursSchedule ( DatabaseName, DayOfWeekId, StartUtcMilitaryTime, IsBusinessHours, IsEnabled )
VALUES   (@DatabaseName, 1, '00:00:00',0,1)
        ,(@DatabaseName, 1, '17:00:00',1,1)
        ,(@DatabaseName, 2, '00:00:00',1,1)
        ,(@DatabaseName, 3, '00:00:00',1,1)
        ,(@DatabaseName, 4, '00:00:00',1,1)
        ,(@DatabaseName, 5, '00:00:00',1,1)
        ,(@DatabaseName, 6, '00:00:00',1,1)
        ,(@DatabaseName, 7, '00:00:00',0,1)
GO