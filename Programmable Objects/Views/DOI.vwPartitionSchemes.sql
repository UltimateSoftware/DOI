
GO

IF OBJECT_ID('[DOI].[vwPartitionSchemes]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitionSchemes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   VIEW [DOI].[vwPartitionSchemes]
AS

/*
	select * from DOI.vwPartitionSchemes where partitionfunctionname = 'PfMonthlyUnitTest'
*/

SELECT	DatabaseName,
		PartitionSchemeName,
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
        NumOfTotalPartitionSchemeIntervals,
        MinValueOfDataType,
		CASE WHEN ps.name IS NULL THEN 1 ELSE 0 END AS IsPartitionSchemeMissing,
        NUF.NextUsedFileGroupName,
'
IF NOT EXISTS(SELECT * FROM sys.partition_schemes WHERE name = ''' + PFM.PartitionSchemeName + ''')
BEGIN
	CREATE PARTITION SCHEME	' + PFM.PartitionSchemeName + ' 
	AS PARTITION ' + PFM.PartitionFunctionName + '
	TO (' + STUFF(PfFileGroupList.FileGroupList, LEN(PfFileGroupList.FileGroupList), 1, SPACE(0)) + ')
END'  AS CreatePartitionSchemeSQL,
'IF EXISTS(SELECT ''True'' FROM sys.partition_schemes WHERE name = ''' + PFM.PartitionSchemeName + ''')
BEGIN
	DROP PARTITION SCHEME ' + PFM.PartitionSchemeName + '
END' AS DropPartitionSchemeSQL
--SELECT *
FROM DOI.PartitionFunctions PFM
	CROSS APPLY (	SELECT CAST(PFP.FileGroupName AS VARCHAR(30)) + ','
					FROM DOI.vwPartitionFunctionPartitions PFP 
					WHERE PFP.PartitionFunctionName = PFM.PartitionFunctionName
						AND PFP.IncludeInPartitionScheme = 1
					FOR XML PATH('')) PfFileGroupList(FileGroupList)
    LEFT JOIN DOI.SysPartitionSchemes ps ON ps.name = PFM.PartitionSchemeName
	OUTER APPLY (	SELECT x.NextUsedFileGroupName
					FROM DOI.SysPartitionFunctions pf
						OUTER APPLY (	SELECT	FG.Name AS NextUsedFileGroupName,
												prv.value, 
												ps.Name AS PartitionSchemeName,
												ps.function_id,
												RANK() OVER (PARTITION BY ps.name ORDER BY dds.destination_Id) AS dest_rank
										FROM DOI.SysPartitionSchemes ps
											INNER JOIN DOI.SysDestinationDataSpaces AS DDS ON DDS.database_id = ps.database_id
												AND DDS.partition_scheme_id = ps.data_space_id
											INNER JOIN DOI.SysFilegroups AS FG ON FG.data_space_id = DDS.data_space_ID 
												AND FG.database_id = DDS.database_id
											LEFT JOIN DOI.SysPartitionRangeValues AS PRV ON PRV.database_id = DDS.database_id
												AND PRV.Boundary_ID = DDS.destination_id 
												AND prv.function_id = ps.function_id 
										WHERE pf.database_id = ps.database_id
											AND ps.function_id = pf.function_id
											AND prv.Value IS NULL) x
                    WHERE x.PartitionSchemeName = PFM.PartitionSchemeName) AS NUF
    OUTER APPLY (   SELECT prv.function_id, COUNT(prv.boundary_id) AS NumFutureIntervals
                    FROM DOI.SysDestinationDataSpaces AS DDS 
						INNER JOIN DOI.SysFilegroups AS FG ON FG.data_space_id = DDS.data_space_ID 
						LEFT JOIN DOI.SysPartitionRangeValues AS PRV ON PRV.Boundary_ID = DDS.destination_id 
							AND prv.function_id = ps.function_id 
					WHERE DDS.partition_scheme_id = ps.data_space_id
                        AND prv.value > GETDATE()
                    GROUP BY PRV.function_id)FI




GO
