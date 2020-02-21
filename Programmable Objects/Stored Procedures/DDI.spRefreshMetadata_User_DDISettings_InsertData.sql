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
         ( DatabaseName         , SettingName                                      , SettingValue )
VALUES   ( 'PaymentReporting'   , 'LargeTableCutoffValue'                          , '1000')
        ,( 'PaymentReporting'   , 'ReindexingMilitaryTimeToStopJob'                , '10:00:00.0000000') --this is in UTC
        ,( 'PaymentReporting'   , 'DBFileInitialSizeMB'                            , '100') 
        ,( 'PaymentReporting'   , 'DBFileGrowthMB'                                 , '10') 
        ,( 'PaymentReporting'   , 'UTEBCP Filepath'                                , 'c:\tmp\user-management\utebcp\')
        ,( 'PaymentReporting'   , 'DefaultStatsSampleSizePct'                      , '20') 
        ,( 'PaymentReporting'   , 'FreeSpaceCheckerTestMultiplierForDataFiles'     , '1') 
        ,( 'PaymentReporting'   , 'FreeSpaceCheckerTestMultiplierForLogFiles'      , '1') 
        ,( 'PaymentReporting'   , 'FreeSpaceCheckerTestMultiplierForTempDBFiles'   , '1') 
        ,( 'PaymentReporting'   , 'MinNumPagesForIndexDefrag'                      , '500') 
        ,( 'PaymentReporting'   , 'FreeSpaceCheckerPercentBuffer'                  , '10') 

GO
