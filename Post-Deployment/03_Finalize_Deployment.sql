/*
Post-Deployment Script Template
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.
 Use SQLCMD syntax to include a file in the post-deployment script.
 Example:      :r .\myfile.sql
 Use SQLCMD syntax to reference a variable in the post-deployment script.
 Example:      :setvar TableName MyTable
               SELECT * FROM [$(TableName)]
--------------------------------------------------------------------------------------
*/
IF NOT EXISTS (SELECT 'True' FROM DOI.DOI.DOISettings WHERE DatabaseName = 'ALL' AND SettingName = 'OKToRunOfflineOperations')
BEGIN
	INSERT INTO DOI.DOISettings 
	VALUES   ( 'ALL'             , 'OKToRunOfflineOperations'                  , '0') 
END

IF NOT EXISTS (SELECT 'True' FROM DOI.DOI.DOISettings WHERE DatabaseName = 'ALL' AND SettingName = 'ResourceGovernorMinIopsPerVolume')
BEGIN
	INSERT INTO DOI.DOISettings 
	VALUES   ( 'ALL'             , 'ResourceGovernorMinIopsPerVolume'               , '1') 
END

IF NOT EXISTS (SELECT 'True' FROM DOI.DOI.DOISettings WHERE DatabaseName = 'ALL' AND SettingName = 'ResourceGovernorMaxIopsPerVolume')
BEGIN
	INSERT INTO DOI.DOISettings 
	VALUES   ( 'ALL'            , 'ResourceGovernorMaxIopsPerVolume'               , '500') 
END

IF NOT EXISTS (SELECT 'True' FROM DOI.DOI.DOISettings WHERE DatabaseName = 'ALL' AND SettingName = 'ResourceGovernorMaxMemoryPercent')
BEGIN
	INSERT INTO DOI.DOISettings 
	VALUES   ( 'ALL'            , 'ResourceGovernorMaxMemoryPercent'               , '20') 
END

IF NOT EXISTS (SELECT 'True' FROM DOI.DOI.DOISettings WHERE DatabaseName = 'ALL' AND SettingName = 'ResourceGovernorMaxCpuPercent')
BEGIN
	INSERT INTO DOI.DOISettings 
	VALUES   ( 'ALL'             , 'ResourceGovernorMaxCpuPercent'                  , '20') 
END

IF NOT EXISTS (SELECT 'True' FROM DOI.DOI.DOISettings WHERE DatabaseName = 'ALL' AND SettingName = 'ResourceGovernorCapCpuPercent')
BEGIN
	INSERT INTO DOI.DOISettings 
	VALUES   ( 'ALL'             , 'ResourceGovernorCapCpuPercent'                  , '20') 
END

DELETE DOI.BusinessHoursSchedule
WHERE DatabaseName = 'ALL'

INSERT INTO DOI.BusinessHoursSchedule ( DatabaseName, DayOfWeekId, StartUtcMilitaryTime, IsBusinessHours, IsEnabled )
VALUES   ('ALL', 1, '00:00:00',0,1)
        ,('ALL', 1, '17:00:00',1,1)
        ,('ALL', 2, '00:00:00',1,1)
        ,('ALL', 3, '00:00:00',1,1)
        ,('ALL', 4, '00:00:00',1,1)
        ,('ALL', 5, '00:00:00',1,1)
        ,('ALL', 6, '00:00:00',1,1)
        ,('ALL', 7, '00:00:00',0,1)

GO