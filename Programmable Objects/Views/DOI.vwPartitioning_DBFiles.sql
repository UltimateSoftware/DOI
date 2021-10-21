
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE OR ALTER VIEW [DOI].vwPartitioning_DBFiles
AS

/*
	select * from DOI.vwPartitioning_DBFiles 
    where partitionfunctionname = 'PfMonthlyUnitTest'
*/

--take columns out of vwPartitionFunctionPartitions that have to do with storage containers and move them to these views?
SELECT DatabaseName, 
		PartitionFunctionName, 
		PartitionSchemeName, 
		BoundaryValue, 
		NextBoundaryValue, 
        FileGroupName,
		X.DBFileName, df.DBFileName AS ddd,
		AddFileSQL,
		DropFileSQL,
		CASE WHEN DF.DBFileName IS NULL THEN 1 ELSE 0 END AS IsDBFileMissing
FROM (  SELECT	PFI.DatabaseName,
				DBFilePath.database_id,
				PFI.PartitionFunctionName,
                PFI.PartitionSchemeName,
                PFI.BoundaryInterval,
                PFI.BoundaryValue,
                CAST(LEAD(BoundaryValue, 1, '9999-12-31') OVER (PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS DATE) AS NextBoundaryValue,
		        DBFilePath.DatabaseName + '_' + PFI.Suffix AS FileGroupName,
				DBFilePath.DatabaseName + '_' + PFI.Suffix + '.ndf' AS DBFileName,
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
'IF EXISTS(SELECT * FROM ' + DBFilePath.DatabaseName + '.sys.database_files WHERE name = ''' + DBFilePath.DatabaseName + '_' + PFI.Suffix + ''')
BEGIN
	ALTER DATABASE ' + DBFilePath.DatabaseName + ' REMOVE FILE ' + DBFilePath.DatabaseName + '_' + PFI.Suffix + '
END;' AS DropFileSQL
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
		                1 AS IncludeInPartitionFunction,
		                1 AS IncludeInPartitionScheme
                --select count(*)
                FROM DOI.PartitionFunctions PFM
	                CROSS APPLY DOI.fnNumberTable(ISNULL(NumOfTotalPartitionFunctionIntervals, 0)) PSN
                UNION ALL
                SELECT	PFM.*,
		                MinInterval.MinValueOfDataType AS BoundaryValue,
		                'Historical' AS Suffix,
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
                                    SUBSTRING(df.physical_name, 1, LEN(df.physical_name) + 1 - CHARINDEX('\', REVERSE(df.physical_name)))
					        FROM DOI.SysDatabaseFiles df
                                INNER JOIN DOI.SysDatabases d ON d.database_id = df.database_id
					        WHERE df.physical_name LIKE '%.mdf'
                                AND d.name = PFI.DatabaseName) DBFilePath)X
	LEFT JOIN ( SELECT	CASE 
							WHEN type_desc = 'ROWS' AND data_space_id = 1
							THEN name + '.mdf'
							WHEN type_desc = 'ROWS' AND data_space_id > 1
							THEN name + '.ndf'
							WHEN type_desc = 'LOG'
							THEN name + '.ldf'
						END AS DBFileName, *
				FROM DOI.SysDatabaseFiles) DF ON DF.database_id = X.database_id
		AND DF.DBFileName = X.DBFileName
GO