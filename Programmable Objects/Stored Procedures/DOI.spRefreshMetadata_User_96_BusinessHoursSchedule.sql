
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_96_BusinessHoursSchedule]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_96_BusinessHoursSchedule];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_96_BusinessHoursSchedule]
AS

DELETE DOI.BusinessHoursSchedule

INSERT INTO DOI.BusinessHoursSchedule ( DatabaseName, DayOfWeekId, StartUtcMilitaryTime, IsBusinessHours, IsEnabled )
VALUES   ('PaymentReporting', 1, '00:00:00',0,1)
        ,('PaymentReporting', 1, '17:00:00',1,1)
        ,('PaymentReporting', 2, '00:00:00',1,1)
        ,('PaymentReporting', 3, '00:00:00',1,1)
        ,('PaymentReporting', 4, '00:00:00',1,1)
        ,('PaymentReporting', 5, '00:00:00',1,1)
        ,('PaymentReporting', 6, '00:00:00',1,1)
        ,('PaymentReporting', 7, '00:00:00',0,1)
GO
