
GO

IF OBJECT_ID('[DOI].[vwPartitionFunctionPartitions]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitionFunctionPartitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   VIEW [DOI].[vwPartitionFunctionPartitions]
AS

/*
	select addfilesql from DOI.vwPartitionFunctionPartitions where partitionfunctionname = 'PfMonthlyUnitTest'
*/

SELECT  *,         
        CASE 
			WHEN DateDiffs IN (365, 366) 
			THEN CAST(YEAR(CONVERT(DATE, BoundaryValue, 112)) AS VARCHAR(4))-- 'Yearly' 
			WHEN DateDiffs IN (28, 29, 30, 31) 
			THEN CAST(YEAR(CONVERT(DATE, BoundaryValue, 112)) AS VARCHAR(4))
					+ CASE WHEN LEN(CAST(MONTH(CONVERT(DATE, BoundaryValue, 112)) AS VARCHAR(2))) < 2 THEN '0' ELSE '' END 
					+ CAST(MONTH(CONVERT(DATE, BoundaryValue, 112)) AS VARCHAR(4)) --'Monthly' 
			WHEN DateDiffs = 1
			THEN 'Daily'
			WHEN BoundaryValue = '0001-01-01'
			THEN 'Historical' 
			WHEN NextBoundaryValue = '9999-12-31'
			THEN 'LastPartition'
			ELSE ''
		END + '_PartitionPrep' AS PrepTableNameSuffix
FROM (  SELECT	PFI.DatabaseName,
				PFI.PartitionFunctionName,
                PFI.PartitionSchemeName,
                PFI.BoundaryInterval,
                PFI.UsesSlidingWindow,
                PFI.SlidingWindowSize,
                PFI.IsDeprecated,
                NUF.NextUsedFileGroupName,
                PFI.BoundaryValue,
                CAST(LEAD(BoundaryValue, 1, '9999-12-31') OVER (PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS DATE) AS NextBoundaryValue,
                DATEDIFF(DAY, PFI.BoundaryValue, CAST(LEAD(BoundaryValue, 1, '9999-12-31') OVER (PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS DATE)) AS DateDiffs,
                ROW_NUMBER() OVER(PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS PartitionNumber,
		        PFI.DatabaseName + '_' + PFI.Suffix AS FileGroupName,
				PFI.DatabaseName + '_' + PFI.Suffix + '.ndf' AS DBFileName,
				PFI.IsSlidingWindowActivePartition,
                PFI.IncludeInPartitionFunction,
                PFI.IncludeInPartitionScheme,
		        CASE  PFI.IncludeInPartitionFunction
			        WHEN 0
			        THEN 0
			        ELSE CASE WHEN ISNULL(ExistingPartitions.DoesPartitionExist, 0) = 0 THEN 1 ELSE 0 END
		        END AS IsPartitionMissing,
'IF NOT EXISTS(SELECT ''True'' FROM ' + DBFilePath.DatabaseName + '.sys.filegroups WHERE NAME = ''' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ''')
BEGIN
	ALTER DATABASE ' + DBFilePath.DatabaseName + ' ADD FILEGROUP [' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ']
END' AS AddFileGroupSQL,
'IF NOT EXISTS(SELECT * FROM ' + DBFilePath.DatabaseName + '.sys.database_files WHERE name = ''' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ''')
BEGIN
	ALTER DATABASE ' + DBFilePath.DatabaseName + '
		ADD FILE 
		(
    		NAME = ' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ', 
    		FILENAME = ''' + DBFilePath.DBFilePath + '' + DBFilePath.DatabaseName + '_' +  PFI.Suffix + '.ndf'', 
			SIZE = ' + CAST(DBFilePath.InitialSizeMB AS NVARCHAR(20)) + ' MB, 
			MAXSIZE = UNLIMITED, 
			FILEGROWTH = ' + CAST(DBFilePath.FileGrowth AS NVARCHAR(20)) + '
		) 
			TO FILEGROUP ' + DBFilePath.DatabaseName + '_' + PFI.Suffix + '
END' AS AddFileSQL,
'USE ' + DBFilePath.DatabaseName + '
BEGIN TRY
	BEGIN TRAN
		ALTER PARTITION SCHEME ' + PFI.PartitionSchemeName + ' NEXT USED [' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ']

		ALTER PARTITION FUNCTION ' + PFI.PartitionFunctionName + ' () SPLIT RANGE (N''' + CAST(PFI.BoundaryValue AS NVARCHAR(20)) + ''')
	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRAN;
	THROW;
END CATCH' AS PartitionFunctionSplitSQL,
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
	        OUTER APPLY (	SELECT	d.database_id, 
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
                                INNER JOIN DOI.SysDatabases d ON d.database_id = pf.database_id
						        INNER JOIN DOI.SysPartitionRangeValues prv ON prv.database_id = pf.database_id
                                    AND prv.function_id = pf.function_id
                                INNER JOIN DOI.SysPartitionSchemes ps ON ps.database_id = pf.database_id
                                    AND ps.function_id = pf.function_id
					        WHERE d.name = pfi.DatabaseName
                                AND pf.name = PFI.PartitionFunctionName
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
					        WHERE x.dest_rank = 2) AS NUF
    )X





GO
