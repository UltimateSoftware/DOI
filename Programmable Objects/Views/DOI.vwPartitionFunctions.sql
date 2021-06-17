
GO

IF OBJECT_ID('[DOI].[vwPartitionFunctions]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   VIEW [DOI].[vwPartitionFunctions]
AS

/*
	select * from DOI.vwPartitionFunctions where partitionfunctionname = 'PfMonthlyUnitTest'
*/

SELECT	DatabaseName,
		PartitionFunctionName,
        PartitionFunctionDataType,
        BoundaryInterval,
        NumOfFutureIntervals AS NumOfFutureIntervals_Desired,
        ISNULL(FI.NumFutureIntervals, 0) AS NumOfFutureIntervals_Actual,
        InitialDate,
        UsesSlidingWindow,
        SlidingWindowSize,
        IsDeprecated,
        NumOfCharsInSuffix,
        LastBoundaryDate,
        NumOfTotalPartitionFunctionIntervals, --we can also use pf.fanout for this.
        MinValueOfDataType,
		CASE WHEN pf.name IS NULL THEN 1 ELSE 0 END AS IsPartitionFunctionMissing,
N'IF NOT EXISTS(SELECT * FROM sys.partition_functions WHERE name = ''' + PFM.PartitionFunctionName + ''')
BEGIN
	CREATE PARTITION FUNCTION ' + PFM.PartitionFunctionName + ' (' + PFM.PartitionFunctionDataType + ') 
		AS RANGE RIGHT FOR VALUES (' + STUFF(PfBoundaryList.BoundaryList, LEN(PfBoundaryList.BoundaryList), 1, SPACE(0)) + ')
END'  AS CreatePartitionFunctionSQL,
'IF EXISTS(SELECT ''True'' FROM sys.partition_functions WHERE name = ''' + PFM.PartitionFunctionName + ''')
BEGIN
	DROP PARTITION FUNCTION ' + PFM.PartitionFunctionName + '
END' AS DropPartitionFunctionSQL
--SELECT *
FROM DOI.PartitionFunctions PFM
	INNER JOIN DOI.SysDatabases D ON D.name = PFM.DatabaseName
	CROSS APPLY (	SELECT (SELECT '''' + CAST(PFP.BoundaryValue AS VARCHAR(30)) + ''',' AS BoundaryValue
							FROM DOI.vwPartitionFunctionPartitions PFP
							WHERE PFM.DatabaseName = PFP.DatabaseName
								AND PFM.PartitionFunctionName = PFP.PartitionFunctionName
								AND PFP.IncludeInPartitionFunction = 1
							ORDER BY BoundaryValue
							FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)')) PfBoundaryList(BoundaryList)
	LEFT JOIN DOI.SysPartitionFunctions pf ON pf.database_id = D.database_id
		AND pf.name = PFM.PartitionFunctionName
    LEFT JOIN DOI.SysPartitionSchemes ps ON ps.database_id = D.database_id
		AND ps.name = PFM.PartitionSchemeName
    OUTER APPLY (   SELECT prv.function_id, COUNT(prv.boundary_id) AS NumFutureIntervals
                    FROM DOI.SysDestinationDataSpaces AS DDS 
						INNER JOIN DOI.SysFilegroups AS FG ON FG.database_id = D.database_id
							AND FG.data_space_id = DDS.data_space_ID 
						LEFT JOIN DOI.SysPartitionRangeValues AS PRV ON PRV.database_id = D.database_id
							AND PRV.Boundary_ID = DDS.destination_id 
							AND prv.function_id = ps.function_id 
					WHERE DDS.database_id = D.database_id
						AND DDS.partition_scheme_id = ps.data_space_id
                        AND prv.value > GETDATE()
                    GROUP BY PRV.function_id)FI




GO
