
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  OR ALTER VIEW [DOI].vwPartitioning_Filegroups
AS

/*
	select * from DOI.vwPartitioning_Filegroups 
    where partitionfunctionname = 'PfMonthlyUnitTest'
*/

SELECT	DatabaseName, 
		PartitionFunctionName, 
		PartitionSchemeName, 
		BoundaryValue, 
		NextBoundaryValue, 
		FileGroupName, 
		AddFileGroupSQL, 
		DropFileGroupSQL,
		CASE WHEN FG.data_space_id IS NULL THEN 1 ELSE 0 END AS IsFileGroupMissing
FROM (  SELECT	PFI.DatabaseName,
                DBFilePath.database_id,
				PFI.PartitionFunctionName,
                PFI.PartitionSchemeName,
                PFI.BoundaryInterval,
                NUF.NextUsedFileGroupName,
                PFI.BoundaryValue,
                CAST(LEAD(BoundaryValue, 1, '9999-12-31') OVER (PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS DATE) AS NextBoundaryValue,
		        DBFilePath.DatabaseName + '_' + PFI.Suffix AS FileGroupName,
'IF NOT EXISTS(SELECT ''True'' FROM ' + DBFilePath.DatabaseName + '.sys.filegroups WHERE NAME = ''' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ''')
BEGIN
	ALTER DATABASE ' + DBFilePath.DatabaseName + ' ADD FILEGROUP [' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ']
END' AS AddFileGroupSQL,
'IF NOT EXISTS(SELECT ''True'' FROM ' + DBFilePath.DatabaseName + '.sys.filegroups WHERE NAME = ''' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ''')
BEGIN
	ALTER DATABASE ' + DBFilePath.DatabaseName + ' REMOVE FILEGROUP [' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ']
END' AS DropFileGroupSQL,
'USE ' + DBFilePath.DatabaseName + '
		ALTER PARTITION SCHEME ' + PFI.PartitionSchemeName + ' NEXT USED [' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ']' 
AS SetFilegroupToNextUsedSQL
--SELECT count(*)
FROM (  SELECT	TOP (1234567890987) *
        FROM (SELECT DISTINCT
		        PFM.*,
		        CASE  
			        WHEN BoundaryInterval = 'Monthly' AND (DATEADD(MONTH, RowNum-1, InitialDate) > PFM.LastBoundaryDate) 
			        THEN PFM.LastBoundaryDate
			        WHEN BoundaryInterval = 'Monthly' AND (DATEADD(MONTH, RowNum-1, InitialDate) <= PFM.LastBoundaryDate) 
			        THEN DATEADD(MONTH, RowNum-1, InitialDate)
			        WHEN BoundaryInterval = 'Yearly' AND (DATEADD(YEAR, RowNum-1, InitialDate) > PFM.LastBoundaryDate)
			        THEN PFM.LastBoundaryDate
			        WHEN BoundaryInterval = 'Yearly' AND (DATEADD(YEAR, RowNum-1, InitialDate) <= PFM.LastBoundaryDate)
			        THEN DATEADD(YEAR, RowNum-1, InitialDate)
		        END AS BoundaryValue,
		        CASE 
			        WHEN BoundaryInterval = 'Monthly' AND (DATEADD(MONTH, RowNum-1, InitialDate) > PFM.LastBoundaryDate) 
			        THEN 'Active'
			        WHEN BoundaryInterval = 'Monthly' AND (DATEADD(MONTH, RowNum-1, InitialDate) <= PFM.LastBoundaryDate) 
			        THEN LEFT(CONVERT(VARCHAR(20), DATEADD(MONTH, RowNum-1, InitialDate), 112), NumOfCharsInSuffix) 
			        WHEN BoundaryInterval = 'Yearly'  AND (DATEADD(YEAR, RowNum-1, InitialDate) > PFM.LastBoundaryDate)
			        THEN 'Active'
			        WHEN BoundaryInterval = 'Yearly'  AND (DATEADD(YEAR, RowNum-1, InitialDate) <= PFM.LastBoundaryDate)
			        THEN LEFT(CONVERT(VARCHAR(20), DATEADD(YEAR, RowNum-1, InitialDate), 112), NumOfCharsInSuffix) 
		        END AS Suffix,
		        CASE 
			        WHEN (PFM.BoundaryInterval = 'Yearly' AND PFM.UsesSlidingWindow = 1 AND (DATEADD(YEAR, RowNum-1, InitialDate) > PFM.LastBoundaryDate))
					        OR (PFM.BoundaryInterval = 'Monthly' AND PFM.UsesSlidingWindow = 1 AND (DATEADD(MONTH, RowNum-1, InitialDate) > PFM.LastBoundaryDate))
			        THEN 1
			        ELSE 0
		        END AS IsSlidingWindowActivePartition,
		        1 AS IncludeInPartitionFunction,
		        1 AS IncludeInPartitionScheme
        --select count(*)
        FROM DOI.PartitionFunctions PFM
	        CROSS APPLY DOI.fnNumberTable(ISNULL(NumOfTotalPartitionFunctionIntervals, 0)) PSN
        UNION ALL
        SELECT	PFM.*,
		        MinInterval.MinValueOfDataType AS BoundaryValue,
		        'Historical' AS Suffix,
		        0 AS IsSlidingWindowActivePartition,
		        0 AS IncludeInPartitionFunction,
		        1 AS IncludeInPartitionScheme
        FROM DOI.PartitionFunctions PFM
	        CROSS APPLY (   SELECT PFM2.MinValueOfDataType 
                            FROM DOI.PartitionFunctions PFM2 
                            WHERE PFM2.PartitionFunctionName = PFM.PartitionFunctionName) MinInterval)V
        ORDER BY PartitionFunctionName, BoundaryValue)PFI
	CROSS APPLY (	SELECT	d.database_id, 
                            d.name AS DatabaseName, 
                            (df.size*8)/1024 AS InitialSizeMB, 
                            CASE 
                                WHEN df.is_percent_growth = 1
                                THEN CAST(df.growth AS VARCHAR(50)) + ' PERCENT'
                                ELSE CAST((df.growth*8)/1024 AS VARCHAR(50)) + ' MB'
                            END AS FileGrowth,
                            SUBSTRING(physical_name, 1, CHARINDEX(d.name + N'.mdf', LOWER(physical_name)) - 1) AS DBFilePath
					FROM DOI.SysDatabaseFiles df
                        INNER JOIN DOI.SysDatabases d ON d.database_id = df.database_id
					WHERE df.physical_name LIKE '%.mdf'
                        AND d.name = PFI.DatabaseName) DBFilePath
	OUTER APPLY (	SELECT 1 AS DoesPartitionExist, pf.function_id, ps.data_space_id, ps.name, PRV.boundary_id
					FROM DOI.SysPartitionFunctions pf
						INNER JOIN DOI.SysPartitionRangeValues prv ON prv.function_id = pf.function_id
                        INNER JOIN DOI.SysPartitionSchemes ps ON ps.function_id = pf.function_id
					WHERE pf.name = PFI.PartitionFunctionName
						AND CAST(prv.value AS DATE) = PFI.BoundaryValue) ExistingPartitions
	OUTER APPLY (	SELECT *
					FROM (	SELECT	FG.Name AS NextUsedFileGroupName,
									prv.value, 
									ExistingPartitions.Name,
									ExistingPartitions.function_id,
									RANK() OVER (PARTITION BY ExistingPartitions.name ORDER BY dds.destination_Id) AS dest_rank
							FROM DOI.SysDestinationDataSpaces AS DDS 
								INNER JOIN DOI.SysFilegroups AS FG ON FG.data_space_id = DDS.data_space_ID 
								LEFT JOIN DOI.SysPartitionRangeValues AS PRV ON PRV.Boundary_ID = DDS.destination_id 
									AND prv.function_id=ExistingPartitions.function_id 
							WHERE DDS.partition_scheme_id = ExistingPartitions.data_space_id
								AND prv.Value IS NULL) x
					WHERE x.dest_rank = 2) AS NUF)X
    LEFT JOIN DOI.SysFilegroups FG ON FG.database_id = X.database_id
        AND FG.name = X.FileGroupName


GO