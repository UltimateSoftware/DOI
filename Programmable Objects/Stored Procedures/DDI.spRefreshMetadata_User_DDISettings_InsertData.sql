IF OBJECT_ID('[DDI].[spRefreshMetadata_User_DDISettings_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_DDISettings_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_DDISettings_InsertData]
AS

DELETE DDI.DDISettings

INSERT INTO DDI.DDISettings 
         ( SettingName                                      , SettingValue )
VALUES   ( 'LargeTableCutoffValue'                          , '1000')
        ,( 'ReindexingMilitaryTimeToStopJob'                , '10:00:00.0000000') --this is in UTC
        ,( 'DBFileInitialSizeMB'                            , '100') 
        ,( 'DBFileGrowthMB'                                 , '10') 
        ,( 'UTEBCP Filepath'                                , 'c:\tmp\user-management\utebcp\')
        ,( 'DefaultStatsSampleSizePct'                      , '20') 
        ,( 'FreeSpaceCheckerTestMultiplierForDataFiles'     , '1') 
        ,( 'FreeSpaceCheckerTestMultiplierForLogFiles'      , '1') 
        ,( 'FreeSpaceCheckerTestMultiplierForTempDBFiles'   , '1') 
        ,( 'MinNumPagesForIndexDefrag'                      , '500') 
        ,( 'FreeSpaceCheckerPercentBuffer'                  , '10') 

GO