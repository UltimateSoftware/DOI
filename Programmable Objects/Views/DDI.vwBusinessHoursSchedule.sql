IF OBJECT_ID('[DDI].[vwBusinessHoursSchedule]') IS NOT NULL
	DROP VIEW [DDI].[vwBusinessHoursSchedule];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [DDI].[vwBusinessHoursSchedule]
AS

/*
    SELECT * FROM DDI.vwBusinessHoursSchedule
*/

SELECT BHS1.*, ISNULL(BHS2.StartUtcMilitaryTime, '23:59:59') AS EndUtcMilitaryTime
FROM (  SELECT *, ROW_NUMBER() OVER(PARTITION BY DayOfWeekId ORDER BY StartUtcMilitaryTime) AS RowNum
        FROM DDI.BusinessHoursSchedule ) BHS1
    LEFT JOIN ( SELECT *, ROW_NUMBER() OVER(PARTITION BY DayOfWeekId ORDER BY StartUtcMilitaryTime) AS RowNum
                FROM DDI.BusinessHoursSchedule) BHS2
        ON BHS2.DayOfWeekId = BHS1.DayOfWeekId
            AND BHS2.RowNum = BHS1.RowNum + 1

GO
