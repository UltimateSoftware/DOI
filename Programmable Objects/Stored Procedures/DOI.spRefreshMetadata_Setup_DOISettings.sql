
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
        ,( @DatabaseName    , 'FreeSpaceCheckerPercentBuffer'                  , '10') 

GO