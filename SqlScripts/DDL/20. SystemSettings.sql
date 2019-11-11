USE DDI
GO

IF OBJECT_ID('DDI.SystemSettings') IS NULL 
BEGIN
	CREATE TABLE DDI.SystemSettings(
		SettingName SYSNAME 
			CONSTRAINT PK_SystemSettings PRIMARY KEY NONCLUSTERED,
		SettingValue VARCHAR(50))
        WITH (MEMORY_OPTIMIZED = ON)

	PRINT 'Created SystemSettings table.'
END
GO

CREATE OR ALTER PROCEDURE DDI.spRefreshMetadata_SystemSettings
AS

IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'LargeTableCutoffValue')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName ,SettingValue )
	VALUES ( 'LargeTableCutoffValue' , '1000')
END

IF EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'LargeTableCutoffValue' AND SettingValue <> '1000')
BEGIN
	UPDATE DDI.SystemSettings 
    SET SettingValue = '1000'
    WHERE SettingName = 'LargeTableCutoffValue'
END

--DELETE DDI.SystemSettings WHERE SettingName = 'ReindexingMilitaryTimeToStopJob'
IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'ReindexingMilitaryTimeToStopJob')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName ,SettingValue )
	VALUES ( 'ReindexingMilitaryTimeToStopJob' , '10:00:00.0000000') --this is in UTC
END

IF EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'ReindexingMilitaryTimeToStopJob' AND SettingValue <> '10:00:00.0000000')
BEGIN
	UPDATE DDI.SystemSettings
    SET SettingValue = '10:00:00.0000000'
	WHERE SettingName = 'ReindexingMilitaryTimeToStopJob'
END

IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'DBFileInitialSizeMB')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName ,SettingValue )
	VALUES ( 'DBFileInitialSizeMB' , '100') 
END

IF EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'DBFileInitialSizeMB' AND SettingValue <> '100')
BEGIN
    UPDATE DDI.SystemSettings
    SET SettingValue = '100'
    WHERE SettingName = 'DBFileInitialSizeMB'
END


IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'DBFileGrowthMB')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName ,SettingValue )
	VALUES ( 'DBFileGrowthMB' , '10') 
END

IF EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'DBFileGrowthMB' AND SettingValue <> '10')
BEGIN
	UPDATE DDI.SystemSettings 
    SET SettingValue = '10'
	WHERE SettingName = 'DBFileGrowthMB'
END


IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'UTEBCP Filepath')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName , SettingValue )
	VALUES ( 'UTEBCP Filepath', 'c:\tmp\user-management\utebcp\')
END

IF EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'UTEBCP Filepath' AND SettingValue <> 'c:\tmp\user-management\utebcp\')
BEGIN
	UPDATE DDI.SystemSettings 
	SET SettingValue = 'c:\tmp\user-management\utebcp\'
    WHERE SettingName = 'UTEBCP Filepath'
END


IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'DefaultStatsSampleSizePct')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName ,SettingValue )
	VALUES ( 'DefaultStatsSampleSizePct' , '20') 
END

IF EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'DefaultStatsSampleSizePct' AND SettingValue <> '20')
BEGIN
	UPDATE DDI.SystemSettings 
	SET SettingValue = '20'
    WHERE SettingName = 'DefaultStatsSampleSizePct'
END


IF EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'FreeSpaceCheckerTestMultiplier')
BEGIN
    DELETE DDI.SystemSettings WHERE SettingName = 'FreeSpaceCheckerTestMultiplier'
END

IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForDataFiles')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName ,SettingValue )
	VALUES ( 'FreeSpaceCheckerTestMultiplierForDataFiles' , '1') 
END

IF EXISTS (SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForDataFiles' AND SettingValue <> '1')
BEGIN
	UPDATE DDI.SystemSettings 
	SET SettingValue = '1'
    WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForDataFiles'
END

IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForLogFiles')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName ,SettingValue )
	VALUES ( 'FreeSpaceCheckerTestMultiplierForLogFiles' , '1') 
END

IF EXISTS (SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForLogFiles' AND SettingValue <> '1')
BEGIN
	UPDATE DDI.SystemSettings 
	SET SettingValue = '1'
    WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForLogFiles'
END

IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForTempDBFiles')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName ,SettingValue )
	VALUES ( 'FreeSpaceCheckerTestMultiplierForTempDBFiles' , '1') 
END

IF EXISTS (SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForTempDBFiles' AND SettingValue <> '1')
BEGIN
	UPDATE DDI.SystemSettings 
	SET SettingValue = '1'
    WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForTempDBFiles'
END

IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'MinNumPagesForIndexDefrag')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName ,SettingValue )
	VALUES ( 'MinNumPagesForIndexDefrag' , '500') 
END

IF EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'MinNumPagesForIndexDefrag' AND SettingValue <> '500')
BEGIN
	UPDATE DDI.SystemSettings
	SET SettingValue = '500'
    WHERE SettingName = 'MinNumPagesForIndexDefrag'
END

IF NOT EXISTS(SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'FreeSpaceCheckerPercentBuffer')
BEGIN
	INSERT INTO DDI.SystemSettings ( SettingName ,SettingValue )
	VALUES ( 'FreeSpaceCheckerPercentBuffer' , '10') 
END

IF EXISTS (SELECT 'True' FROM DDI.SystemSettings WHERE SettingName = 'FreeSpaceCheckerPercentBuffer' AND SettingValue <> '10')
BEGIN
	UPDATE DDI.SystemSettings 
	SET SettingValue = '10'
    WHERE SettingName = 'FreeSpaceCheckerPercentBuffer'
END

GO


EXEC DDI.spRefreshMetadata_SystemSettings
GO
