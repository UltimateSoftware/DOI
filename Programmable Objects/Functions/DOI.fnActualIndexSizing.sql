

IF OBJECT_ID('[DOI].[fnActualIndexSizing]') IS NOT NULL
	DROP FUNCTION [DOI].[fnActualIndexSizing];
GO

CREATE FUNCTION [DOI].[fnActualIndexSizing]()

RETURNS TABLE 

AS
RETURN 
(
	SELECT	AllIdx.DatabaseName,
			AllIdx.SchemaName,
			AllIdx.TableName,
			AllIdx.IndexName,
			SUM(NumPages) AS NumPages,
			MAX(FilePath) AS FilePath,
			MAX(DriveLetter) AS DriveLetter,
			SUM(TotalSpaceMB) AS TotalSpaceMB,
			SUM(TotalSpaceMBDec) AS TotalSpaceMBDec,
			SUM(UsedSpaceMB) AS UsedSpaceMB,
			SUM(UsedSpaceMBDec) AS UsedSpaceMBDec,
			SUM(UnusedSpaceMB) AS UnusedSpaceMB,
			MAX(SizeCutoffValue) AS SizeCutoffValue,
			SUM(NumRows) AS NumRows,
			MAX(AllIdx.data_compression_desc) AS data_compression_desc,
			CASE WHEN SUM(NumPages) > MAX(MinNumPages) THEN 1 ELSE 0 END AS IndexMeetsMinimumSize
	FROM (
			--ROWSTORE INDEXES, REGULAR DATA
			SELECT  d.NAME AS DatabaseName,
					s.NAME AS SchemaName,
					t.NAME AS TableName,
					i.NAME AS IndexName,
					SUM(a.total_pages) AS NumPages,
					MAX(df.physical_name) AS FilePath, 
					MAX(LEFT(vs.volume_mount_point, 1)) AS DriveLetter,
					CAST(CEILING(((SUM(a.total_pages) * 8) / 1024.00)) AS INT) AS TotalSpaceMB,
					CAST(((SUM(a.total_pages) * 8) / 1024.00) AS DECIMAL(10,2)) AS TotalSpaceMBDec,
					CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS INT) AS UsedSpaceMB, 
					CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS INT) AS UsedSpaceMBDec, 
					CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB,
					MAX(SS.SizeCutoffValue ) AS SizeCutoffValue,
					SUM(p.rows) AS NumRows,
					MAX(p.data_compression_desc) COLLATE DATABASE_DEFAULT AS data_compression_desc,
					MAX(SS2.MinNumPages) AS MinNumPages
			FROM DOI.SysDatabases d
				INNER JOIN DOI.SysSchemas s ON s.database_id = d.database_id
				INNER JOIN DOI.SysTables t ON t.database_id = s.database_id
					AND t.SCHEMA_ID = s.SCHEMA_ID
				INNER JOIN DOI.SysIndexes i ON i.database_id = t.database_id
					AND i.OBJECT_ID = t.object_id
				INNER JOIN DOI.SysPartitions p ON p.database_id = i.database_id
					AND p.OBJECT_ID = i.OBJECT_ID
					AND p.index_id = i.index_id
				INNER JOIN DOI.SysAllocationUnits a ON a.database_id = p.database_id
					AND a.container_id = p.hobt_id					
				INNER JOIN DOI.SysDatabaseFiles df ON df.database_id = a.database_id
					AND df.data_space_id = a.data_space_id
				INNER JOIN DOI.SysDmOsVolumeStats vs ON vs.database_id = df.database_id
					AND vs.FILE_ID = df.FILE_ID
				INNER JOIN (SELECT DatabaseName, CAST(SettingValue AS INT) AS SizeCutoffValue
							FROM DOI.DOISettings 
							WHERE SettingName = 'LargeTableCutoffValue')SS
					ON SS.DatabaseName = d.name
                INNER JOIN (SELECT DatabaseName, CAST(SettingValue AS INT) AS MinNumPages
                            FROM DOI.DOISettings 
                            WHERE SettingName = 'MinNumPagesForIndexDefrag')SS2
					ON SS2.DatabaseName = d.name
			WHERE i.type_desc IN ('CLUSTERED', 'NONCLUSTERED', 'HEAP') 
				AND a.type IN (1,3)
			GROUP BY d.name, s.NAME, t.NAME, i.name
			UNION ALL
			--COLUMNSTORE INDEXES, REGULAR DATA
			SELECT  d.NAME,
					s.NAME,
					t.NAME,
					i.NAME,
					SUM(a.total_pages) AS NumPages,
					MAX(df.physical_name) AS FilePath, 
					MAX(LEFT(vs.volume_mount_point, 1)) AS DriveLetter,
					CAST(CEILING(((SUM(a.total_pages) * 8) / 1024.00)) AS INT) AS TotalSpaceMB,
					CAST(((SUM(a.total_pages) * 8) / 1024.00) AS DECIMAL(10,2)) AS TotalSpaceMBDec,
					CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS INT) AS UsedSpaceMB, 
					CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS INT) AS UsedSpaceMBDec, 
					CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB,
					MAX(SS.SizeCutoffValue ) AS SizeCutoffValue,
					SUM(p.rows) AS NumRows,
					MAX(p.data_compression_desc) COLLATE DATABASE_DEFAULT AS data_compression_desc,
					MAX(SS2.MinNumPages) AS MinNumPages
			FROM DOI.SysDatabases d
				INNER JOIN DOI.SysSchemas s ON d.database_id = s.database_id
				INNER JOIN DOI.SysTables t ON t.database_id = d.database_id
					AND t.SCHEMA_ID = s.SCHEMA_ID
				INNER JOIN DOI.SysIndexes i ON i.database_id = t.database_id
					AND i.object_id = t.object_id
				INNER JOIN DOI.SysPartitions p ON p.database_id = i.database_id
					AND p.object_id = i.object_id
					AND p.index_id = I.index_id
				INNER JOIN DOI.SysColumnStoreRowGroups csrg ON p.database_id = csrg.database_id
					AND p.object_id = csrg.object_id
					AND p.index_id = csrg.index_id
					AND p.partition_number = csrg.partition_number
				INNER JOIN DOI.SysAllocationUnits a ON a.database_id = csrg.database_id
					AND a.container_id = csrg.delta_store_hobt_id
				INNER JOIN DOI.SysDatabaseFiles df ON df.database_id = a.database_id
					AND df.data_space_id = a.data_space_id
				INNER JOIN DOI.SysDmOsVolumeStats vs ON vs.database_id = d.database_id
					AND vs.FILE_ID = df.FILE_ID
				INNER JOIN (SELECT DatabaseName, CAST(SettingValue AS INT) AS SizeCutoffValue
							FROM DOI.DOISettings 
							WHERE SettingName = 'LargeTableCutoffValue')SS
					ON SS.DatabaseName = d.name
                INNER JOIN (SELECT DatabaseName, CAST(SettingValue AS INT) AS MinNumPages
                            FROM DOI.DOISettings 
                            WHERE SettingName = 'MinNumPagesForIndexDefrag')SS2
					ON SS2.DatabaseName = d.name
			WHERE i.type_desc IN ('CLUSTERED COLUMNSTORE', 'NONCLUSTERED COLUMNSTORE') 
				AND a.type IN (1,3)
			GROUP BY d.name, s.NAME, t.NAME, i.name
			UNION ALL
			--ALL INDEXES, LOB DATA
			SELECT  d.NAME,
					s.NAME,
					t.NAME,
					i.NAME,
					SUM(a.total_pages) AS NumPages,
					MAX(df.physical_name) AS FilePath, 
					MAX(LEFT(vs.volume_mount_point, 1)) AS DriveLetter,
					CAST(CEILING(((SUM(a.total_pages) * 8) / 1024.00)) AS INT) AS TotalSpaceMB,
					CAST(((SUM(a.total_pages) * 8) / 1024.00) AS DECIMAL(10,2)) AS TotalSpaceMBDec,
					CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS INT) AS UsedSpaceMB, 
					CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS INT) AS UsedSpaceMBDec, 
					CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB,
					MAX(SS.SizeCutoffValue ) AS SizeCutoffValue,
					SUM(p.rows) AS NumRows,
					MAX(p.data_compression_desc) COLLATE DATABASE_DEFAULT AS data_compression_desc,
					MAX(SS2.MinNumPages) AS MinNumPages
			FROM DOI.SysDatabases d
				INNER JOIN DOI.SysSchemas s ON s.database_id = d.database_id
				INNER JOIN DOI.SysTables t ON t.database_id = s.database_id
					AND t.SCHEMA_ID = s.SCHEMA_ID
				INNER JOIN DOI.SysIndexes i ON i.database_id = t.database_id
					AND i.OBJECT_ID = t.object_id
				INNER JOIN DOI.SysPartitions p ON p.database_id = i.database_id
					AND p.OBJECT_ID = i.OBJECT_ID
					AND p.index_id = i.index_id
				INNER JOIN DOI.SysAllocationUnits a ON a.database_id = p.database_id
					AND a.container_id = p.partition_id
				INNER JOIN DOI.SysDatabaseFiles df ON df.database_id = a.database_id
					AND df.data_space_id = a.data_space_id
				INNER JOIN DOI.SysDmOsVolumeStats vs ON vs.database_id = df.database_id
					AND vs.FILE_ID = df.FILE_ID
				INNER JOIN (SELECT DatabaseName, CAST(SettingValue AS INT) AS SizeCutoffValue
							FROM DOI.DOISettings 
							WHERE SettingName = 'LargeTableCutoffValue')SS
					ON SS.DatabaseName = d.name
                INNER JOIN (SELECT DatabaseName, CAST(SettingValue AS INT) AS MinNumPages
                            FROM DOI.DOISettings 
                            WHERE SettingName = 'MinNumPagesForIndexDefrag')SS2
					ON SS2.DatabaseName = d.name
			WHERE a.type = 2
			GROUP BY d.name, s.NAME, t.NAME, i.name)AllIdx
GROUP BY AllIdx.DatabaseName,
			AllIdx.SchemaName,
			AllIdx.TableName,
			AllIdx.IndexName
)
GO


