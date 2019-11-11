IF OBJECT_ID('[DDI].[spRefreshMetadata_User_IndexesColumnStore_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_IndexesColumnStore_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_IndexesColumnStore_UpdateData]
AS

/************************************************   SQL SERVER METADATA (START) *******************************************/

--ROW COUNTS
DROP TABLE IF EXISTS #FilteredRowCounts 

CREATE TABLE #FilteredRowCounts (
    DatabaseName SYSNAME,
    SchemaName SYSNAME,
    TableName SYSNAME,
    IndexName SYSNAME,
    NumRows BIGINT NOT NULL)

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL += CASE @SQL WHEN '' THEN '' ELSE CHAR(13) + CHAR(10) + 'UNION ALL' + CHAR(13) + CHAR(10) END + 'SELECT ''' + DatabaseName + ''' AS DatabaseName, ''' + SchemaName + ''' AS SchemaName, ''' + TableName + ''' AS TableName, ''' + IndexName + ''' AS IndexName, COUNT(*) as NumRows FROM ' + DatabaseName + '.' + SchemaName + '.' + TableName + ' WHERE ' + FilterPredicate_Desired
FROM (  SELECT ICS.DatabaseName, ICS.SchemaName, ICS.TableName, ICS.IndexName, ICS.FilterPredicate_Desired
        FROM DDI.IndexesColumnStore ICS
        WHERE IsFiltered_Desired = 1)x

INSERT #FilteredRowCounts        
EXEC(@SQL)

UPDATE ICS
SET IsIndexMissingFromSQLServer = 1
FROM DDI.IndexesColumnStore ICS
WHERE NOT EXISTS(	SELECT 'True' 
					FROM DDI.SysSchemas s 
                        INNER JOIN DDI.SysDatabases d ON s.database_id = d.database_id
						INNER JOIN DDI.SysTables t ON d.database_id = t.database_id
                            AND t.schema_id = s.schema_id 
						INNER JOIN DDI.SysIndexes i ON i.database_id = d.database_id
                            AND i.object_id = t.object_id
					WHERE d.name = ICS.DatabaseName
                        AND s.name = ICS.SchemaName
						AND t.name = ICS.TableName
						AND i.name = ICS.IndexName)

UPDATE ICS
SET NumRows_Actual = T.NumRows
FROM DDI.IndexesColumnStore ICS
    INNER JOIN #FilteredRowCounts T ON ICS.DatabaseName = T.DatabaseName
        AND ICS.SchemaName = T.SchemaName
        AND ICS.TableName = T.TableName
        AND ICS.IndexName = T.IndexName
WHERE IsFiltered_Desired = 1

UPDATE ICS
SET NumRows_Actual = p.NumRows
--SELECT p.*
FROM DDI.IndexesColumnStore ICS
    CROSS APPLY (SELECT s.name AS SchemaName, t.name AS TableName, SUM(p.rows) AS NumRows
                FROM DDI.SysSchemas s 
                    INNER JOIN DDI.SysTables t ON s.schema_id = t.schema_id
                    INNER JOIN DDI.SysPartitions p ON p.object_id = t.object_id
                WHERE p.index_id IN (0,1)
                    AND s.name = ICS.SchemaName COLLATE DATABASE_DEFAULT
                    AND t.name = ICS.TableName COLLATE DATABASE_DEFAULT
                GROUP BY s.name , t.name)p
WHERE IsFiltered_Desired = 0

DROP TABLE IF EXISTS #FilteredRowCounts 

--INDEX SIZING
UPDATE ICS
SET IndexSizeMB_Actual = ISNULL(TS.TotalSpaceMBDec,0),
    DriveLetter = TS.DriveLetter,
    IsIndexLarge =  CASE 
                        WHEN TS.TotalSpaceMBDec > TS.SizeCutoffValue
                        THEN 1
                        ELSE 0
                    END,
    NumPages_Actual = TS.NumPages,
    IndexMeetsMinimumSize = ISNULL(TS.IndexMeetsMinimumSize,0),
    OptionDataCompression_Actual = TS.data_compression_desc
FROM DDI.IndexesColumnStore ICS
    OUTER APPLY (   SELECT  s.NAME AS SchemaName,
                            t.NAME AS TableName,
                            i.NAME AS IndexName,
                            MAX(df.physical_name) AS FilePath, 
		                    MAX(LEFT(vs.volume_mount_point, 1)) AS DriveLetter,
                            SUM(a.total_pages) AS NumPages,
                            CAST(((SUM(a.total_pages) * 8) / 1024.00) AS DECIMAL(10,2)) AS TotalSpaceMBDec,
			                CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS INT) AS UsedSpaceMB, 
			                CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS INT) AS UsedSpaceMBDec, 
			                CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB,
			                MAX(SS1.SizeCutoffValue ) AS SizeCutoffValue,
                            --SUM(p.rows) AS NumRows,  this is done above....
                            MAX(p.data_compression_desc) COLLATE DATABASE_DEFAULT AS data_compression_desc,
                            CASE WHEN SUM(a.total_pages) > MAX(SS2.MinNumPages) THEN 1 ELSE 0 END AS IndexMeetsMinimumSize
		            FROM DDI.systables t 
                        INNER JOIN DDI.SysSchemas s ON t.SCHEMA_ID = s.SCHEMA_ID
                        INNER JOIN DDI.SysIndexes i ON i.OBJECT_ID = t.object_id
                        INNER JOIN DDI.SysPartitions p ON p.OBJECT_ID = t.OBJECT_ID
                            AND p.index_id = I.index_id
                        INNER JOIN DDI.SysAllocationUnits a ON p.hobt_id = a.container_id
                        INNER JOIN DDI.SysDatabaseFiles df ON df.data_space_id = a.data_space_id
			            CROSS JOIN (SELECT CAST(SettingValue AS INT) AS SizeCutoffValue
						            FROM DDI.DDISettings 
						            WHERE SettingName = 'LargeTableCutoffValue')SS1
                        CROSS JOIN (SELECT CAST(SettingValue AS INT) AS MinNumPages
                                    FROM DDI.DDISettings 
                                    WHERE SettingName = 'MinNumPagesForIndexDefrag')SS2
                        CROSS JOIN (SELECT database_id FROM DDI.SysDatabases WHERE name = ICS.DatabaseName) DB
			            INNER JOIN DDI.SysDmOsVolumeStats vs ON vs.database_id = DB.database_id
                            AND vs.FILE_ID = df.FILE_ID
		            WHERE s.NAME = ICS.SchemaName
                        AND t.NAME = ICS.TableName
                        AND i.NAME = ICS.IndexName
		            GROUP BY s.name, t.name, i.name) TS
--FRAG
UPDATE ICS
SET Fragmentation = F.Fragmentation,
    FragmentationType = CASE
                            WHEN ICS.NumPages_Actual > SS.MinNumPages AND F.Fragmentation > 30 
				            THEN 'Heavy' 
				            WHEN ICS.NumPages_Actual > SS.MinNumPages AND F.Fragmentation BETWEEN 5 AND 30 
                            THEN 'Light' 
				            ELSE 'None' 
                        END 
FROM DDI.IndexesColumnStore ICS
    CROSS JOIN (SELECT CAST(SettingValue AS INT) AS MinNumPages
                FROM DDI.DDISettings 
                WHERE SettingName = 'MinNumPagesForIndexDefrag')SS
    CROSS APPLY (   SELECT  Fragmentation
                    FROM DDI.fnActualIndex_Frag() FN
                    WHERE FN.DatabaseName = ICS.DatabaseName
                        AND FN.SchemaName = ICS.SchemaName
                        AND FN.TableName = ICS.TableName
                        AND FN.IndexName = ICS.IndexName) F

--SysIndexes, and friends...
UPDATE ICS
SET IsClustered_Actual = CASE WHEN i.type_desc = 'CLUSTERED' THEN 1 ELSE 0 END,
    --ColumnList_Actual = i.key_column_list,
    IsFiltered_Actual = i.has_filter,
    FilterPredicate_Actual = i.filter_definition,
    Storage_Actual = ActualDS.name,
    StorageType_Actual = ActualDS.type_desc,
    StorageType_Desired = DesiredDS.type_desc,
    IsStorageChanging = CASE WHEN ActualDS.name <> DesiredDS.name THEN 1 ELSE 0 END
FROM DDI.Tables TTP
    INNER JOIN DDI.SysDatabases d on d.name = TTP.DatabaseName
	INNER JOIN DDI.SysSchemas s ON D.database_id = s.database_id
        AND TTP.SchemaName = s.name
	INNER JOIN DDI.SysTables t ON s.database_id = t.database_id
        AND TTP.TableName = t.name
		AND s.schema_id = t.schema_id
	INNER JOIN DDI.SysIndexes i ON t.database_id = i.database_id
        AND i.object_id = t.object_id
	INNER JOIN DDI.IndexesColumnStore ICS ON TTP.DatabaseName = ICS.DatabaseName
        AND TTP.SchemaName = ICS.SchemaName
		AND TTP.TableName = ICS.TableName
		AND ICS.IndexName = i.name	
	INNER JOIN DDI.SysDataSpaces ActualDS ON ActualDS.database_id = i.database_id
        AND ActualDS.data_space_id = I.data_space_id
	INNER JOIN DDI.SysDataSpaces DesiredDS ON DesiredDS.database_id = d.database_id
        AND DesiredDS.name = ICS.Storage_Desired


UPDATE ICS
SET     PartitionFunction_Desired = NewPf.name,
        PartitionFunction_Actual = ExistingPf.name
FROM DDI.IndexesColumnStore ICS 
    INNER JOIN DDI.SysDatabases d on d.name = ICS.DatabaseName
	LEFT JOIN DDI.SysPartitionSchemes ExistingPs ON d.database_id = ExistingPs.database_id
        AND ICS.Storage_Actual = ExistingPs.name
	LEFT JOIN DDI.SysPartitionFunctions ExistingPf ON d.database_id = ExistingPf.database_id
        AND ExistingPs.function_id = ExistingPf.function_id
	LEFT JOIN DDI.SysPartitionSchemes NewPs ON NewPs.database_id = D.database_id
        AND NewPs.name = ICS.Storage_Desired
	LEFT JOIN DDI.SysPartitionFunctions NewPf ON NewPf.database_id = NewPs.database_id
        AND NewPf.function_id = NewPs.function_id

--CHANGE BITS

UPDATE ICS
SET IsColumnListChanging	= CASE WHEN ICS.ColumnList_Desired <> ICS.ColumnList_Actual THEN 1 ELSE 0 END, 
	IsFilterChanging = CASE WHEN ISNULL(ICS.FilterPredicate_Desired, '') <> ISNULL(ICS.FilterPredicate_Actual, '') THEN 1 ELSE 0 END, 
	IsClusteredChanging = CASE WHEN ICS.IsClustered_Desired <> CASE ICS.IsClustered_Actual WHEN 1 THEN 1 ELSE 0 END  THEN 1 ELSE 0 END, 
	IsPartitioningChanging =    CASE 
				                    WHEN ICS.IsStorageChanging = 1 AND T.IntendToPartition = 1 
				                    THEN 1 
				                    ELSE 0 
			                    END, 
	IsDataCompressionChanging = CASE WHEN ICS.OptionDataCompression_Desired <> ICS.OptionDataCompression_Actual THEN 1 ELSE 0 END,
	IsDataCompressionDelayChanging = CASE WHEN ICS.OptionDataCompressionDelay_Desired <> ICS.OptionDataCompressionDelay_Actual THEN 1 ELSE 0 END
FROM DDI.IndexesColumnStore ICS
    INNER JOIN DDI.Tables T ON ICS.DatabaseName = T.DatabaseName
        AND ICS.SchemaName = T.SchemaName
        AND ICS.TableName = T.TableName

/*			
			,ISNULL(i.has_LOB_columns, 0) AS IndexHasLOBColumns
*/

UPDATE ICS
SET AreDropRecreateOptionsChanging =    CASE
                                            WHEN (IsColumnListChanging = 1
                                                    OR IsFilterChanging = 1
                                                    OR IsClusteredChanging = 1
                                                    OR IsPartitioningChanging = 1)
                                            THEN 1
                                            ELSE 0
                                        END,
    AreRebuildOptionsChanging =         CASE    
                                            WHEN (IsDataCompressionChanging = 1)
                                            THEN 1
                                            ELSE 0
                                        END,
    AreRebuildOnlyOptionsChanging =     CASE    
                                            WHEN (IsDataCompressionChanging = 1)
                                            THEN 1
                                            ELSE 0
                                        END
FROM DDI.IndexesColumnStore ICS

/*******************************        FOR ESTIMATING INDEX SIZE (START) *******************************************/
/*******************************        FOR ESTIMATING INDEX SIZE (END) *******************************************/

GO
