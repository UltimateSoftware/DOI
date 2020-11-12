
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_PartitionFunctions_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_PartitionFunctions_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [DOI].[spRefreshMetadata_User_PartitionFunctions_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC DOI.[spRefreshMetadata_User_PartitionFunctions_UpdateData]
        @DatabaseName = 'DOIUnitTests'
*/

    UPDATE DOI.PartitionFunctions
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
	WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 
GO
