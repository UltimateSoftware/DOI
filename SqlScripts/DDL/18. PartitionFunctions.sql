USE DDI
GO

DROP TABLE IF EXISTS DDI.PartitionFunctions
GO

CREATE TABLE DDI.PartitionFunctions(
    DatabaseName SYSNAME,
	PartitionFunctionName SYSNAME,
	PartitionFunctionDataType SYSNAME,
	BoundaryInterval VARCHAR(10) NOT NULL
		CONSTRAINT Chk_PartitionFunctions_BoundaryInterval
			CHECK (BoundaryInterval IN ('Yearly', 'Monthly')),
	NumOfFutureIntervals TINYINT NOT NULL,
	InitialDate DATE NOT NULL,
	UsesSlidingWindow BIT NOT NULL,
	SlidingWindowSize SMALLINT NULL,
	IsDeprecated BIT NOT NULL,
	PartitionSchemeName NVARCHAR(128) NULL,--AS ,
	NumOfCharsInSuffix TINYINT NULL,/*AS	,*/
	LastBoundaryDate DATE NULL, /*AS ,*/
	NumOfTotalPartitionFunctionIntervals SMALLINT NULL, /*AS */
	NumOfTotalPartitionSchemeIntervals SMALLINT NULL,
	MinValueOfDataType VARCHAR(20) NULL
	CONSTRAINT PK_PartitionFunctions
		PRIMARY KEY NONCLUSTERED (DatabaseName, PartitionFunctionName),
	CONSTRAINT Chk_PartitionFunctions_SlidingWindow
		CHECK ((UsesSlidingWindow = 1 AND SlidingWindowSize IS NOT NULL)
				OR (UsesSlidingWindow = 0 AND SlidingWindowSize IS NULL)))
    WITH (MEMORY_OPTIMIZED = ON)
GO


CREATE OR ALTER PROCEDURE DDI.spRefreshMetadata_PartitionFunctions

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


UPDATE DDI.PartitionFunctions
SET PartitionSchemeName = REPLACE(PartitionFunctionName, 'pf', 'ps'),
    NumOfCharsInSuffix =    CASE BoundaryInterval 
								WHEN 'Monthly' 
								THEN 6
								WHEN 'Yearly' 
								THEN 4
							END,
    LastBoundaryDate = CASE 
							WHEN UsesSlidingWindow = 0
							THEN	CASE BoundaryInterval 
										WHEN 'Monthly' 
										THEN DATEFROMPARTS(DATEPART(YEAR, DATEADD(MONTH, NumOfFutureIntervals, SYSDATETIME())), DATEPART(MONTH, DATEADD(MONTH, NumOfFutureIntervals, SYSDATETIME())), 1)
										WHEN 'Yearly' 
										THEN DATEFROMPARTS(DATEPART(YEAR, DATEADD(YEAR, NumOfFutureIntervals, SYSDATETIME())), 1, 1)
									END
							ELSE	CASE
										/*IF IT'S THE 101st DAY OF THE YEAR, LEAVE THE LAST DATE AS 12/31 SO IT WON'T BREAK 
										PARTITION FUNCTION WITH DUPLICATE DATE BOUNDARIES.*/
										WHEN MONTH(CAST(DATEADD(DAY, -1*SlidingWindowSize,SYSDATETIME()) AS DATE)) = 1
												AND DAY(CAST(DATEADD(DAY, -1*SlidingWindowSize,SYSDATETIME()) AS DATE)) = 1
										THEN DATEADD(DAY, -1, CAST(DATEADD(DAY, -1*SlidingWindowSize,SYSDATETIME()) AS DATE))
										ELSE CAST(DATEADD(DAY, -1*SlidingWindowSize,SYSDATETIME()) AS DATE)
									END 
						END,
     NumOfTotalPartitionFunctionIntervals = CASE --DIFF BETWEEN INITIAL DATE AND LAST BOUNDARY DATE.
												WHEN BoundaryInterval = 'Monthly'
												THEN DATEDIFF(MONTH, InitialDate,	CASE 
																						WHEN UsesSlidingWindow = 0
																						THEN DATEFROMPARTS(DATEPART(YEAR, DATEADD(MONTH, NumOfFutureIntervals, SYSDATETIME())), DATEPART(MONTH, DATEADD(MONTH, NumOfFutureIntervals, SYSDATETIME())), 1)
																						ELSE CAST(DATEADD(DAY, -1*SlidingWindowSize,SYSDATETIME()) AS DATE)
																					END) + 1 --datediff clips 1 month off the end, so we add it back.
												WHEN BoundaryInterval = 'Yearly'
												THEN DATEDIFF(YEAR, InitialDate,	CASE 
																						WHEN UsesSlidingWindow = 0
																						THEN DATEFROMPARTS(DATEPART(YEAR, DATEADD(YEAR, NumOfFutureIntervals, SYSDATETIME())), 1, 1)
																						ELSE CAST(DATEADD(DAY, -1*SlidingWindowSize,SYSDATETIME()) AS DATE)
																					END) + 1 --datediff clips 1 month off the end, so we add it back.
											END + CASE WHEN UsesSlidingWindow = 1 THEN 1 ELSE 0 END, --one interval for the sliding window
                                            
    NumOfTotalPartitionSchemeIntervals =    CASE
											    WHEN BoundaryInterval = 'Monthly'
											    THEN DATEDIFF(MONTH, InitialDate,	CASE 
																					    WHEN UsesSlidingWindow = 0
																					    THEN DATEFROMPARTS(DATEPART(YEAR, DATEADD(MONTH, NumOfFutureIntervals, SYSDATETIME())), DATEPART(MONTH, DATEADD(MONTH, NumOfFutureIntervals, SYSDATETIME())), 1)
																					    ELSE CAST(DATEADD(DAY, -1*SlidingWindowSize,SYSDATETIME()) AS DATE)
																				    END) + 1 --datediff clips 1 month off the end, so we add it back.
											    WHEN BoundaryInterval = 'Yearly'
											    THEN DATEDIFF(YEAR, InitialDate,	CASE 
																					    WHEN UsesSlidingWindow = 0
																					    THEN DATEFROMPARTS(DATEPART(YEAR, DATEADD(YEAR, NumOfFutureIntervals, SYSDATETIME())), 1, 1)
																					    ELSE CAST(DATEADD(DAY, -1*SlidingWindowSize,SYSDATETIME()) AS DATE)
																				    END) + 1 --datediff clips 1 month off the end, so we add it back.
										    END + CASE WHEN UsesSlidingWindow = 1 THEN 2 ELSE 1 END, --one interval for historical and one for the sliding window
    MinValueOfDataType = CASE WHEN PartitionFunctionDataType = 'DATETIME2' THEN '0001-01-01' ELSE 'Error' END


GO

EXEC DDI.spRefreshMetadata_PartitionFunctions
GO


CREATE OR ALTER TRIGGER DDI.trUpdPartitionFunctions
	ON DDI.PartitionFunctions 
        WITH NATIVE_COMPILATION, SCHEMABINDING
        	AFTER INSERT, UPDATE

AS
BEGIN ATOMIC  
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')

BEGIN TRY 
    DECLARE @IsUpdate bit = 0

    SELECT TOP 1 @IsUpdate = 1
    FROM inserted i 
        INNER JOIN deleted d ON i.PartitionFunctionName = d.PartitionFunctionName

    IF @IsUpdate = 1
    BEGIN
        THROW 50000, 'Updating the PartitionFunctions table is not allowed.', 1
    END

    DECLARE @PartitionFunctionsToMerge VARCHAR(MAX) = ''

    SELECT @PartitionFunctionsToMerge += PFA.name + ','
    --SELECT pfa.name, MAX(PFM.NumOfTotalPartitionFunctionIntervals), MAX(prv.boundary_id)
    FROM DDI.SysPartitionRangeValues prv 
	    INNER JOIN DDI.SysPartitionFunctions PFA ON PFA.function_id = prv.function_id
	    INNER JOIN DDI.PartitionFunctions PFM ON PFA.name = PFM.PartitionFunctionName
    WHERE PFM.IsDeprecated = 0
    GROUP BY PFA.name
    HAVING MAX(PFM.NumOfTotalPartitionFunctionIntervals) < MAX(prv.boundary_id)

    IF LTRIM(RTRIM(@PartitionFunctionsToMerge)) <> ''
    BEGIN
	    DECLARE @ErrorMsg VARCHAR(MAX) = 'The following partition functions are defined with less partitions than what exist in production:  ' + @PartitionFunctionsToMerge + '.  Partition MERGEs are not supported yet in DDI.';
	    THROW 50000, @ErrorMsg, 1
    END
END TRY
BEGIN CATCH
    THROW;
END CATCH 
    --THIS VALIDATION HAS A CIRCULAR REFERENCE...IT NEEDS TO RUN POST-DEPLOY OR SOMETHING....
    --SET @PartitionFunctionsToMerge = ''

    --SELECT @PartitionFunctionsToMerge += CONVERT(VARCHAR(30), value, 112) + ',' 
    --FROM SYS.partition_range_values prv 
    --	INNER JOIN sys.partition_functions PFA ON PFA.function_id = prv.function_id
    --WHERE pfa.name NOT IN (SELECT PartitionFunctionName FROM Utility.vwPartitionFunctions WHERE pfa.name = PartitionFunctionName AND IsDeprecated = 1)
    --	AND NOT EXISTS(	SELECT 't' 
    --					FROM Utility.vwPartitionFunctionIntervals i 
    --					WHERE i.PartitionFunctionName = pfa.name 
    --						AND CAST(prv.value AS DATE) = i.BoundaryValue
    --						AND i.IsDeprecated = 0)

    --IF LTRIM(RTRIM(@PartitionFunctionsToMerge)) <> ''
    --BEGIN
    --	DECLARE @ErrorMsg2 VARCHAR(MAX) = 'The NumOfFutureIntervals value will cause the following partitions to not exist:  ' + @PartitionFunctionsToMerge + '.  Partition MERGEs are not supported yet in DDI.'
    --	RAISERROR(@ErrorMsg2, 16, 1)
    --END
END

GO
