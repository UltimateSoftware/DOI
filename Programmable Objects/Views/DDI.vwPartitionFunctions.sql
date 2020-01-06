IF OBJECT_ID('[DDI].[vwPartitionFunctions]') IS NOT NULL
	DROP VIEW [DDI].[vwPartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   VIEW [DDI].[vwPartitionFunctions]
AS

/*
	select * from DDI.vwPartitionFunctions
*/

SELECT	PartitionFunctionName,
        PartitionFunctionDataType,
        BoundaryInterval,
        NumOfFutureIntervals AS NumOfFutureIntervalsDesired,
        ISNULL(FI.NumFutureIntervals, 0) AS NumOfFutureIntervalsActual,
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
N'USE ' + DatabaseName + ';
IF NOT EXISTS(SELECT * FROM sys.partition_functions WHERE name = ''' + PFM.PartitionFunctionName + ''')
BEGIN
	CREATE PARTITION FUNCTION ' + PFM.PartitionFunctionName + ' (' + PFM.PartitionFunctionDataType + ') 
		AS RANGE RIGHT FOR VALUES (' + STUFF(PfBoundaryList.BoundaryList, LEN(PfBoundaryList.BoundaryList), 1, SPACE(0)) + ')
END'  AS CreatePartitionFunctionSQL,
'
USE ' + DatabaseName + ';
IF NOT EXISTS(SELECT * FROM sys.partition_schemes WHERE name = ''' + PFM.PartitionSchemeName + ''')
BEGIN
	CREATE PARTITION SCHEME	' + PFM.PartitionSchemeName + ' 
	AS PARTITION ' + PFM.PartitionFunctionName + '
	TO (' + STUFF(PfFileGroupList.FileGroupList, LEN(PfFileGroupList.FileGroupList), 1, SPACE(0)) + ')
END'  AS CreatePartitionSchemeSQL
--SELECT *
FROM DDI.PartitionFunctions PFM
	CROSS APPLY (	SELECT (SELECT '''' + CAST(PFP.BoundaryValue AS VARCHAR(30)) + ''',' AS BoundaryValue
							FROM DDI.vwPartitionFunctionPartitions PFP
							WHERE PFM.PartitionFunctionName = PFP.PartitionFunctionName
								AND PFP.IncludeInPartitionFunction = 1
							ORDER BY BoundaryValue
							FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)')) PfBoundaryList(BoundaryList)
	CROSS APPLY (	SELECT CAST(PFP.FileGroupName AS VARCHAR(30)) + ','
					FROM DDI.vwPartitionFunctionPartitions PFP 
					WHERE PFP.PartitionFunctionName = PFM.PartitionFunctionName
						AND PFP.IncludeInPartitionScheme = 1
					FOR XML PATH('')) PfFileGroupList(FileGroupList)
	LEFT JOIN DDI.SysPartitionFunctions pf ON pf.name = PFM.PartitionFunctionName
    LEFT JOIN DDI.SysPartitionSchemes ps ON ps.name = PFM.PartitionSchemeName
	OUTER APPLY (	SELECT *
					FROM (	SELECT	FG.Name AS NextUsedFileGroupName,
									prv.value, 
									ps.Name,
									ps.function_id,
									RANK() OVER (PARTITION BY ps.name ORDER BY dds.destination_Id) AS dest_rank
							FROM DDI.SysDestinationDataSpaces AS DDS 
								INNER JOIN DDI.SysFilegroups AS FG ON FG.data_space_id = DDS.data_space_ID 
								LEFT JOIN DDI.SysPartitionRangeValues AS PRV ON PRV.Boundary_ID = DDS.destination_id 
									AND prv.function_id = ps.function_id 
							WHERE DDS.partition_scheme_id = ps.data_space_id
								AND prv.Value IS NULL) x
					WHERE x.dest_rank = 2) AS NUF
    OUTER APPLY (   SELECT prv.function_id, COUNT(prv.boundary_id) AS NumFutureIntervals
                    FROM DDI.SysDestinationDataSpaces AS DDS 
						INNER JOIN DDI.SysFilegroups AS FG ON FG.data_space_id = DDS.data_space_ID 
						LEFT JOIN DDI.SysPartitionRangeValues AS PRV ON PRV.Boundary_ID = DDS.destination_id 
							AND prv.function_id = ps.function_id 
					WHERE DDS.partition_scheme_id = ps.data_space_id
                        AND prv.value > GETDATE()
                    GROUP BY PRV.function_id)FI


GO
