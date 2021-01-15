USE [DOI]
GO

/****** Object:  View [DOI].[vwPartitioning_PrepTables]    Script Date: 1/13/2021 2:57:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [DOI].[vwPartitioning_PrepTables]
AS

/*
	select addfilesql from DOI.vwPartitioning_PrepTables where partitionfunctionname = 'PfMonthlyUnitTest'
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
                PFI.BoundaryValue,
                CAST(LEAD(BoundaryValue, 1, '9999-12-31') OVER (PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS DATE) AS NextBoundaryValue,
                DATEDIFF(DAY, PFI.BoundaryValue, CAST(LEAD(BoundaryValue, 1, '9999-12-31') OVER (PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS DATE)) AS DateDiffs,
                ROW_NUMBER() OVER(PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS PartitionNumber,
				PFI.IncludeInPartitionFunction,
                PFI.IncludeInPartitionScheme
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
                ORDER BY PartitionFunctionName, BoundaryValue)PFI)X

GO


