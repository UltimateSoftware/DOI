-- <Migration ID="ea410dfe-2053-50dc-ac7d-aa067dfd4f0d" TransactionHandling="Custom" />
IF OBJECT_ID('[DOI].[spRefreshMetadata_User_PartitionFunctions_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_PartitionFunctions_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    PROCEDURE [DOI].[spRefreshMetadata_User_PartitionFunctions_InsertData]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.[spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs]
        @TableName = 'SysTables', @Debug = 1
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    DELETE DOI.PartitionFunctions

    INSERT INTO DOI.PartitionFunctions ( DatabaseName, PartitionFunctionName,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals , InitialDate , UsesSlidingWindow , SlidingWindowSize , IsDeprecated)    VALUES	(	'PaymentReporting'              ,'pfMonthly'						, 'DATETIME2'				, 'Monthly'			, 13					, '2018-01-01'	, 0					, NULL				, 0           )
    INSERT INTO DOI.PartitionFunctions ( DatabaseName, PartitionFunctionName,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals , InitialDate , UsesSlidingWindow , SlidingWindowSize , IsDeprecated)    VALUES  (	'PaymentReporting'              ,'pfYearlyNoSlidingWindow'		    , 'DATETIME2'				, 'Yearly'			, 1						, '2016-01-01'	, 0					, NULL				, 0           )
    INSERT INTO DOI.PartitionFunctions ( DatabaseName, PartitionFunctionName,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals , InitialDate , UsesSlidingWindow , SlidingWindowSize , IsDeprecated)    VALUES  (	'PaymentReporting'              ,'pf100DaysToYearlySlidingWindow'   , 'DATETIME2'				, 'Yearly'			, 1						, '2016-01-01'	, 1					, 100				, 1           )
    INSERT INTO DOI.PartitionFunctions ( DatabaseName, PartitionFunctionName,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals , InitialDate , UsesSlidingWindow , SlidingWindowSize , IsDeprecated)    VALUES  (	'PaymentReporting'              ,'pfYearlyPlusSlidingWindow'		, 'DATETIME2'				, 'Yearly'			, 1						, '2016-01-01'	, 1					, 100				, 1           )
    INSERT INTO DOI.PartitionFunctions ( DatabaseName, PartitionFunctionName,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals , InitialDate , UsesSlidingWindow , SlidingWindowSize , IsDeprecated)    VALUES  (	'PaymentReporting'              ,'pfYearly'						    , 'DATETIME2'				, 'Yearly'			, 1						, '2016-01-01'	, 1					, 100				, 1           )
    INSERT INTO DOI.PartitionFunctions ( DatabaseName, PartitionFunctionName,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals , InitialDate , UsesSlidingWindow , SlidingWindowSize , IsDeprecated)    VALUES  (	'PaymentReporting'              ,'pfTest'						    , 'DATETIME2'				, 'Yearly'			, 1						, '2016-01-01'	, 1					, 100				, 1           )
END
GO
