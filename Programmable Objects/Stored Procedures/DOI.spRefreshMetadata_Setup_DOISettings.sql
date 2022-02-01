
IF OBJECT_ID('[DOI].[spRefreshMetadata_Setup_DOISettings]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_Setup_DOISettings];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_Setup_DOISettings]
    @DatabaseName SYSNAME
AS

DELETE DOI.DOISettings
WHERE DatabaseName = @DatabaseName

INSERT INTO DOI.DOISettings 
         ( DatabaseName     , SettingName                                      , SettingValue )
VALUES   ( @DatabaseName    , 'LargeTableCutoffValue'                          , '1000')
        ,( @DatabaseName    , 'ReindexingMilitaryTimeToStopJob'                , '10:00:00.0000000') --this is in UTC
        ,( @DatabaseName    , 'DBFileInitialSizeMB'                            , '100') 
        ,( @DatabaseName    , 'DBFileGrowthMB'                                 , '10') 
        ,( @DatabaseName    , 'UTEBCP Filepath'                                , 'c:\tmp\user-management\utebcp\')
        ,( @DatabaseName    , 'DefaultStatsSampleSizePct'                      , '20') 
        ,( @DatabaseName    , 'FreeSpaceCheckerTestMultiplierForDataFiles'     , '1') 
        ,( @DatabaseName    , 'FreeSpaceCheckerTestMultiplierForLogFiles'      , '1') 
        ,( @DatabaseName    , 'FreeSpaceCheckerTestMultiplierForTempDBFiles'   , '1') 
        ,( @DatabaseName    , 'MinNumPagesForIndexDefrag'                      , '500') 

IF NOT EXISTS (SELECT 'True' FROM DOI.DOI.DOISettings WHERE DatabaseName = @DatabaseName AND SettingName = 'OKToRunOfflineOperations')
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

GO