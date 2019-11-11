IF OBJECT_ID('[DDI].[spRefreshMetadata_User_PartitionFunctions_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_PartitionFunctions_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_PartitionFunctions_InsertData]

AS

DELETE DDI.PartitionFunctions

INSERT INTO DDI.PartitionFunctions ( 
				DatabaseName                    , PartitionFunctionName			    ,PartitionFunctionDataType	,BoundaryInterval	,NumOfFutureIntervals	, InitialDate	, UsesSlidingWindow	, SlidingWindowSize	, IsDeprecated)
VALUES		(	'PaymentReporting'              ,'pfMonthly'						, 'DATETIME2'				, 'Monthly'			, 13					, '2018-01-01'	, 0					, NULL				, 0           )
		,	(	'PaymentReporting'              ,'pfYearlyNoSlidingWindow'		    , 'DATETIME2'				, 'Yearly'			, 1						, '2016-01-01'	, 0					, NULL				, 0           )
		,	(	'PaymentReporting'              ,'pf100DaysToYearlySlidingWindow'   , 'DATETIME2'				, 'Yearly'			, 1						, '2016-01-01'	, 1					, 100				, 1           )
		,	(	'PaymentReporting'              ,'pfYearlyPlusSlidingWindow'		, 'DATETIME2'				, 'Yearly'			, 1						, '2016-01-01'	, 1					, 100				, 1           )
		,	(	'PaymentReporting'              ,'pfYearly'						    , 'DATETIME2'				, 'Yearly'			, 1						, '2016-01-01'	, 1					, 100				, 1           )
		,	(	'PaymentReporting'              ,'pfTest'						    , 'DATETIME2'				, 'Yearly'			, 1						, '2016-01-01'	, 1					, 100				, 1           )


GO
