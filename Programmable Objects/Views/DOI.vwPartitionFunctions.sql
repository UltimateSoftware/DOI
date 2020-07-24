
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

SELECT	PartitionFunctionName,
        PartitionFunctionDataType,
        BoundaryInterval,
        NumOfFutureIntervals AS NumOfFutureIntervals_Desired,
        ISNULL(FI.NumFutureIntervals, 0) AS NumOfFutureIntervals_Actual,
        InitialDate,
        UsesSlidingWindow,
        SlidingWindowSize,
        IsDeprecated,
        PartitionSchemeName,
        NumOfCharsInSuffix,
        LastBoundaryDate,
        NumOfTotalPartitionFunctionIntervals, --we can also use pf.fanout for this.
        NumOfTotalPartitionSchemeIntervals,
        MinValueOfDataType,
		CASE WHEN pf.name IS NULL THEN 1 ELSE 0 END AS IsPartitionFunctionMissing,
		CASE WHEN ps.name IS NULL THEN 1 ELSE 0 END AS IsPartitionSchemeMissing,
        NUF.NextUsedFileGroupName,
N'IF NOT EXISTS(SELECT * FROM sys.partition_functions WHERE name = ''' + PFM.PartitionFunctionName + ''')
BEGIN
	CREATE PARTITION FUNCTION ' + PFM.PartitionFunctionName + ' (' + PFM.PartitionFunctionDataType + ') 
		AS RANGE RIGHT FOR VALUES (' + STUFF(PfBoundaryList.BoundaryList, LEN(PfBoundaryList.BoundaryList), 1, SPACE(0)) + ')
END'  AS CreatePartitionFunctionSQL,
'
IF NOT EXISTS(SELECT * FROM sys.partition_schemes WHERE name = ''' + PFM.PartitionSchemeName + ''')
BEGIN
	CREATE PARTITION SCHEME	' + PFM.PartitionSchemeName + ' 
	AS PARTITION ' + PFM.PartitionFunctionName + '
	TO (' + STUFF(PfFileGroupList.FileGroupList, LEN(PfFileGroupList.FileGroupList), 1, SPACE(0)) + ')
END'  AS CreatePartitionSchemeSQL
--SELECT *
FROM DOI.PartitionFunctions PFM
	CROSS APPLY (	SELECT (SELECT '''' + CAST(PFP.BoundaryValue AS VARCHAR(30)) + ''',' AS BoundaryValue
							FROM DOI.vwPartitionFunctionPartitions PFP
							WHERE PFM.PartitionFunctionName = PFP.PartitionFunctionName
								AND PFP.IncludeInPartitionFunction = 1
							ORDER BY BoundaryValue
							FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)')) PfBoundaryList(BoundaryList)
	CROSS APPLY (	SELECT CAST(PFP.FileGroupName AS VARCHAR(30)) + ','
					FROM DOI.vwPartitionFunctionPartitions PFP 
					WHERE PFP.PartitionFunctionName = PFM.PartitionFunctionName
						AND PFP.IncludeInPartitionScheme = 1
					FOR XML PATH('')) PfFileGroupList(FileGroupList)
	LEFT JOIN DOI.SysPartitionFunctions pf ON pf.name = PFM.PartitionFunctionName
    LEFT JOIN DOI.SysPartitionSchemes ps ON ps.name = PFM.PartitionSchemeName
	OUTER APPLY (	SELECT *
					FROM (	SELECT	FG.Name AS NextUsedFileGroupName,
									prv.value, 
									ps.Name,
									ps.function_id,
									RANK() OVER (PARTITION BY ps.name ORDER BY dds.destination_Id) AS dest_rank
							FROM DOI.SysDestinationDataSpaces AS DDS 
								INNER JOIN DOI.SysFilegroups AS FG ON FG.data_space_id = DDS.data_space_ID 
								LEFT JOIN DOI.SysPartitionRangeValues AS PRV ON PRV.Boundary_ID = DDS.destination_id 
									AND prv.function_id = ps.function_id 
							WHERE DDS.partition_scheme_id = ps.data_space_id
								AND prv.Value IS NULL) x
					WHERE x.dest_rank = 2) AS NUF
    OUTER APPLY (   SELECT prv.function_id, COUNT(prv.boundary_id) AS NumFutureIntervals
                    FROM DOI.SysDestinationDataSpaces AS DDS 
						INNER JOIN DOI.SysFilegroups AS FG ON FG.data_space_id = DDS.data_space_ID 
						LEFT JOIN DOI.SysPartitionRangeValues AS PRV ON PRV.Boundary_ID = DDS.destination_id 
							AND prv.function_id = ps.function_id 
					WHERE DDS.partition_scheme_id = ps.data_space_id
                        AND prv.value > GETDATE()
                    GROUP BY PRV.function_id)FI




GO
