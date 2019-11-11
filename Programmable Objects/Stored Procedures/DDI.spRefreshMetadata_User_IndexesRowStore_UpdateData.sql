IF OBJECT_ID('[DDI].[spRefreshMetadata_User_IndexesRowStore_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_IndexesRowStore_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_IndexesRowStore_UpdateData]
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
FROM (  SELECT IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, IRS.FilterPredicate_Desired
        FROM DDI.IndexesRowStore IRS
        WHERE IsFiltered_Desired = 1)x

INSERT #FilteredRowCounts        
EXEC(@SQL)


UPDATE IRS
SET IsIndexMissingFromSQLServer = 1
FROM DDI.IndexesRowStore IRS
WHERE NOT EXISTS(	SELECT 'True' 
					FROM DDI.SysSchemas s 
                        INNER JOIN DDI.SysDatabases d ON s.database_id = d.database_id
						INNER JOIN DDI.SysTables t ON d.database_id = t.database_id
                            AND t.schema_id = s.schema_id 
						INNER JOIN DDI.SysIndexes i ON i.database_id = d.database_id
                            AND i.object_id = t.object_id
					WHERE d.name = IRS.DatabaseName
                        AND s.name = IRS.SchemaName
						AND t.name = IRS.TableName
						AND i.name = IRS.IndexName)

UPDATE IRS
SET NumRows_Actual = T.NumRows
FROM DDI.IndexesRowStore IRS
    INNER JOIN #FilteredRowCounts T ON IRS.DatabaseName = T.DatabaseName
        AND IRS.SchemaName = T.SchemaName
        AND IRS.TableName = T.TableName
        AND IRS.IndexName = T.IndexName
WHERE IsFiltered_Desired = 1

UPDATE IRS
SET NumRows_Actual = p.NumRows
--SELECT p.*
FROM DDI.IndexesRowStore IRS
    CROSS APPLY (SELECT s.name AS SchemaName, t.name AS TableName, SUM(p.rows) AS NumRows
                FROM DDI.SysSchemas s 
                    INNER JOIN DDI.SysTables t ON s.schema_id = t.schema_id
                    INNER JOIN DDI.SysPartitions p ON p.object_id = t.object_id
                WHERE p.index_id IN (0,1)
                    AND s.name = IRS.SchemaName COLLATE DATABASE_DEFAULT
                    AND t.name = IRS.TableName COLLATE DATABASE_DEFAULT
                GROUP BY s.name , t.name)p
WHERE IsFiltered_Desired = 0

DROP TABLE IF EXISTS #FilteredRowCounts 


--INDEX SIZING
UPDATE IRS
SET IndexSizeMB_Actual = ISNULL(TS.TotalSpaceMBDec,0),
    DriveLetter = TS.DriveLetter,
    IsIndexLarge =  CASE 
                        WHEN TS.TotalSpaceMBDec > TS.SizeCutoffValue
                        THEN 1
                        ELSE 0
                    END,
    NumPages_Actual = ISNULL(TS.NumPages,0),
    IndexMeetsMinimumSize = ISNULL(TS.IndexMeetsMinimumSize,0),
    OptionDataCompression_Actual = TS.data_compression_desc
FROM DDI.IndexesRowStore IRS
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
                        CROSS JOIN (SELECT database_id FROM DDI.SysDatabases WHERE name = IRS.DatabaseName) DB
			            INNER JOIN DDI.SysDmOsVolumeStats vs ON vs.database_id = DB.database_id
                            AND vs.FILE_ID = df.FILE_ID
		            WHERE s.NAME = IRS.SchemaName
                        AND t.NAME = IRS.TableName
                        AND i.NAME = IRS.IndexName
		            GROUP BY s.name, t.name, i.name) TS

--FRAG
UPDATE IRS
SET Fragmentation = F.Fragmentation,
    FragmentationType = CASE
                            WHEN IRS.NumPages_Actual > SS.MinNumPages AND F.Fragmentation > 30 
				            THEN 'Heavy' 
				            WHEN IRS.NumPages_Actual > SS.MinNumPages AND F.Fragmentation BETWEEN 5 AND 30 
                            THEN 'Light' 
				            ELSE 'None' 
                        END 
FROM DDI.IndexesRowStore IRS
    CROSS JOIN (SELECT CAST(SettingValue AS INT) AS MinNumPages
                FROM DDI.DDISettings 
                WHERE SettingName = 'MinNumPagesForIndexDefrag')SS
    CROSS APPLY (   SELECT  Fragmentation
                    FROM DDI.fnActualIndex_Frag() FN
                    WHERE FN.DatabaseName = IRS.DatabaseName
                        AND FN.SchemaName = IRS.SchemaName
                        AND FN.TableName = IRS.TableName
                        AND FN.IndexName = IRS.IndexName) F

--SysIndexes, and friends...
UPDATE IRS
SET IsUnique_Actual = i.is_unique,
    IsPrimaryKey_Actual = i.is_primary_key,
    IsUniqueConstraint_Actual = i.is_unique_constraint,
    IsClustered_Actual = CASE WHEN i.type_desc = 'CLUSTERED' THEN 1 ELSE 0 END,
    KeyColumnList_Actual = i.key_column_list,
    IncludedColumnList_Actual = i.included_column_list,
    IsFiltered_Actual = i.has_filter,
    FilterPredicate_Actual = i.filter_definition,
    FillFactor_Actual = i.fill_factor,
    OptionPadIndex_Actual = i.is_padded,
    OptionIgnoreDupKey_Actual = i.ignore_dup_key,
    OptionAllowRowLocks_Actual = i.allow_row_locks,
    OptionAllowPageLocks_Actual = i.allow_page_locks,
    Storage_Actual = ActualDS.name,
    StorageType_Actual = ActualDS.type_desc,
    StorageType_Desired = DesiredDS.type_desc,
    IsStorageChanging = CASE WHEN ActualDS.name <> DesiredDS.name THEN 1 ELSE 0 END,
    IndexHasLOBColumns = i.has_LOB_columns,
    OptionStatisticsIncremental_Actual = s2.is_incremental,
    OptionStatisticsNoRecompute_Actual = s2.no_recompute
FROM DDI.Tables TTP
    INNER JOIN DDI.SysDatabases d on d.name = TTP.DatabaseName
	INNER JOIN DDI.SysSchemas s ON D.database_id = s.database_id
        AND TTP.SchemaName = s.name
	INNER JOIN DDI.SysTables t ON s.database_id = t.database_id
        AND TTP.TableName = t.name
		AND s.schema_id = t.schema_id
	INNER JOIN DDI.SysIndexes i ON t.database_id = i.database_id
        AND i.object_id = t.object_id
    INNER JOIN DDI.SysStats s2 ON s2.database_id = i.database_id
        AND s2.object_id = I.object_id
		AND s2.stats_id = i.index_id
	INNER JOIN DDI.IndexesRowStore IRS ON TTP.DatabaseName = IRS.DatabaseName
        AND TTP.SchemaName = IRS.SchemaName
		AND TTP.TableName = IRS.TableName
		AND IRS.IndexName = i.name	
	INNER JOIN DDI.SysDataSpaces ActualDS ON ActualDS.database_id = i.database_id
        AND ActualDS.data_space_id = I.data_space_id
	INNER JOIN DDI.SysDataSpaces DesiredDS ON DesiredDS.database_id = d.database_id
        AND DesiredDS.name = IRS.Storage_Desired

UPDATE IRS
SET     PartitionFunction_Desired = NewPf.name,
        PartitionFunction_Actual = ExistingPf.name
FROM DDI.IndexesRowStore IRS 
    INNER JOIN DDI.SysDatabases d on d.name = IRS.DatabaseName
	LEFT JOIN DDI.SysPartitionSchemes ExistingPs ON d.database_id = ExistingPs.database_id
        AND IRS.Storage_Actual = ExistingPs.name
	LEFT JOIN DDI.SysPartitionFunctions ExistingPf ON d.database_id = ExistingPf.database_id
        AND ExistingPs.function_id = ExistingPf.function_id
	LEFT JOIN DDI.SysPartitionSchemes NewPs ON NewPs.database_id = D.database_id
        AND NewPs.name = IRS.Storage_Desired
	LEFT JOIN DDI.SysPartitionFunctions NewPf ON NewPf.database_id = NewPs.database_id
        AND NewPf.function_id = NewPs.function_id

--CHANGE BITS

UPDATE IRS
SET IsUniquenessChanging = CASE WHEN IRS.IsUnique_Desired <> IRS.IsUnique_Actual THEN 1 ELSE 0 END, 
	IsPrimaryKeyChanging =	CASE WHEN IRS.IsPrimaryKey_Desired <> IRS.IsPrimaryKey_Actual THEN 1 ELSE 0 END,
	IsKeyColumnListChanging	= CASE WHEN IRS.KeyColumnList_Desired <>IRS.KeyColumnList_Actual THEN 1 ELSE 0 END, 
	IsIncludedColumnListChanging = CASE WHEN ISNULL(IRS.IncludedColumnList_Desired, '') <> ISNULL(IRS.IncludedColumnList_Actual, '') THEN 1 ELSE 0 END, 
	IsFilterChanging = CASE WHEN ISNULL(IRS.FilterPredicate_Desired, '') <> ISNULL(IRS.FilterPredicate_Actual, '') THEN 1 ELSE 0 END, 
	IsClusteredChanging = CASE WHEN IRS.IsClustered_Desired <> CASE IRS.IsClustered_Actual WHEN 1 THEN 1 ELSE 0 END  THEN 1 ELSE 0 END, 
	IsPartitioningChanging =    CASE 
				                    WHEN IRS.IsStorageChanging = 1 AND T.IntendToPartition = 1 
				                    THEN 1 
				                    ELSE 0 
			                    END, 
	IsPadIndexChanging = CASE WHEN IRS.OptionPadIndex_Desired <> IRS.OptionPadIndex_Actual THEN 1 ELSE 0 END, 
    IsFillfactorChanging = CASE WHEN IRS.Fillfactor_Desired <> IRS.Fillfactor_Actual THEN 1 ELSE 0 END, 
	IsIgnoreDupKeyChanging = CASE WHEN IRS.OptionIgnoreDupKey_Desired <> IRS.OptionIgnoreDupKey_Actual THEN 1 ELSE 0 END, 
	IsStatisticsNoRecomputeChanging = CASE WHEN IRS.OptionStatisticsNoRecompute_Desired <> IRS.OptionStatisticsNoRecompute_Actual THEN 1 ELSE 0 END, 
	IsStatisticsIncrementalChanging = CASE WHEN IRS.OptionStatisticsIncremental_Desired <> IRS.OptionStatisticsIncremental_Actual THEN 1 ELSE 0 END,  --if the table is partitioned, ignore this check.
	IsAllowRowLocksChanging	= CASE WHEN IRS.OptionAllowRowLocks_Desired <> IRS.OptionAllowRowLocks_Actual THEN 1 ELSE 0 END, 
	IsAllowPageLocksChanging = CASE WHEN IRS.OptionAllowPageLocks_Desired <> IRS.OptionAllowPageLocks_Actual THEN 1 ELSE 0 END, 
	IsDataCompressionChanging = CASE WHEN IRS.OptionDataCompression_Desired <> IRS.OptionDataCompression_Actual THEN 1 ELSE 0 END
FROM DDI.IndexesRowStore IRS
    INNER JOIN DDI.Tables T ON IRS.DatabaseName = T.DatabaseName
        AND IRS.SchemaName = T.SchemaName
        AND IRS.TableName = T.TableName

/*			
			,ISNULL(i.has_LOB_columns, 0) AS IndexHasLOBColumns
*/

UPDATE IRS
SET AreDropRecreateOptionsChanging =    CASE
                                            WHEN (IsUniquenessChanging = 1
                                                    OR IsKeyColumnListChanging = 1
                                                    OR IsIncludedColumnListChanging = 1
                                                    OR IsFilterChanging = 1
                                                    OR IsClusteredChanging = 1
                                                    OR IsPartitioningChanging = 1)
                                            THEN 1
                                            ELSE 0
                                        END,
    AreRebuildOptionsChanging =         CASE    
                                            WHEN (IsPadIndexChanging = 1
                                                    OR IsFillfactorChanging = 1
                                                    OR IsIgnoreDupKeyChanging = 1
                                                    OR IsStatisticsNoRecomputeChanging = 1
                                                    OR IsStatisticsIncrementalChanging = 1
                                                    OR IsAllowRowLocksChanging = 1
                                                    OR IsAllowPageLocksChanging = 1
                                                    OR IsDataCompressionChanging = 1)
                                            THEN 1
                                            ELSE 0
                                        END,
    AreRebuildOnlyOptionsChanging =     CASE    
                                            WHEN (IsPadIndexChanging = 1
                                                    OR IsFillfactorChanging = 1
                                                    OR IsStatisticsIncrementalChanging = 1
                                                    OR IsDataCompressionChanging = 1)
                                            THEN 1
                                            ELSE 0
                                        END,
    AreSetOptionsChanging =             CASE
                                            WHEN (IsIgnoreDupKeyChanging = 1
                                                    OR IsStatisticsNoRecomputeChanging = 1
                                                    OR IsAllowRowLocksChanging = 1
                                                    OR IsAllowPageLocksChanging = 1)
                                            THEN 1
                                            ELSE 0
                                        END              
FROM DDI.IndexesRowStore IRS


/*******************************        FOR ESTIMATING INDEX SIZE (START) *******************************************/
UPDATE DDI.IndexesRowStore
SET AllColsInTableSize_Estimated = ISNULL(DDI.fnEstimateIndexSize_AllColSize(DatabaseName, schemaname, tablename), 0)
--NEED TO HANDLE THIS NULL VALUE INSIDE OF FUNCTION!!!

UPDATE IRS
SET IRS.NumFixedKeyCols_Estimated = FN.NumFixedCols,
    IRS.FixedKeyColsSize_Estimated = FN.FixedColSize
FROM DDI.IndexesRowStore IRS
    CROSS APPLY (   SELECT * 
                    FROM DDI.fnEstimateIndexSize_KeyFixedColSize() FN
                    WHERE IRS.DatabaseName = FN.DatabaseName
                        AND IRS.SchemaName = FN.SchemaName
                        AND IRS.TableName = FN.TableName
                        AND IRS.IndexName = FN.IndexName) FN

UPDATE IRS
SET IRS.NumVarKeyCols_Estimated = FN.NumVarCols,
    IRS.VarKeyColsSize_Estimated = FN.VarColSize
FROM DDI.IndexesRowStore IRS
    CROSS APPLY (   SELECT * 
                    FROM DDI.fnEstimateIndexSize_KeyVarColSize() FN
                    WHERE IRS.DatabaseName = FN.DatabaseName
                        AND IRS.SchemaName = FN.SchemaName
                        AND IRS.TableName = FN.TableName
                        AND IRS.IndexName = FN.IndexName) FN

UPDATE IRS
SET IRS.NumFixedInclCols_Estimated = FN.NumInclFixedCols,
    IRS.FixedInclColsSize_Estimated = FN.FixedInclColSize
FROM DDI.IndexesRowStore IRS
    CROSS APPLY (   SELECT * 
                    FROM DDI.fnEstimateIndexSize_InclFixedColSize() FN
                    WHERE IRS.DatabaseName = FN.DatabaseName
                        AND IRS.SchemaName = FN.SchemaName
                        AND IRS.TableName = FN.TableName
                        AND IRS.IndexName = FN.IndexName) FN

UPDATE IRS
SET IRS.NumVarInclCols_Estimated = FN.NumInclVarCols,
    IRS.VarInclColsSize_Estimated = FN.VarInclColSize
FROM DDI.IndexesRowStore IRS
    CROSS APPLY (   SELECT * 
                    FROM DDI.fnEstimateIndexSize_InclVarColSize() FN
                    WHERE IRS.DatabaseName = FN.DatabaseName
                        AND IRS.SchemaName = FN.SchemaName
                        AND IRS.TableName = FN.TableName
                        AND IRS.IndexName = FN.IndexName) FN


UPDATE IRS
SET KeyColsSize_Estimated   = FixedKeyColsSize_Estimated  + VarKeyColsSize_Estimated,
    InclColsSize_Estimated  = FixedInclColsSize_Estimated + VarInclColsSize_Estimated,
    FixedColsSize_Estimated = FixedKeyColsSize_Estimated  + FixedInclColsSize_Estimated,
    VarColsSize_Estimated   = VarKeyColsSize_Estimated    + VarInclColsSize_Estimated,
    NumKeyCols_Estimated    = NumFixedKeyCols_Estimated   + NumVarKeyCols_Estimated,
    NumInclCols_Estimated   = NumFixedInclCols_Estimated  + NumVarInclCols_Estimated,
    NumFixedCols_Estimated  = NumFixedKeyCols_Estimated   + NumFixedInclCols_Estimated,
    NumVarCols_Estimated    = NumVarKeyCols_Estimated     + NumVarInclCols_Estimated
FROM DDI.IndexesRowStore IRS

UPDATE IRS
SET ColsSize_Estimated = KeyColsSize_Estimated + InclColsSize_Estimated,
    NumCols_Estimated = NumKeyCols_Estimated + NumInclCols_Estimated,
    NullBitmap_Estimated = CAST((((ISNULL(NumKeyCols_Estimated,0) + ISNULL(NumInclCols_Estimated, 0)) + 7)/8) + 2 AS INT),
    Uniqueifier_Estimated =   CASE 
                        WHEN IsClustered_Desired = 1 
                            AND IsUnique_Desired = 0 
                        THEN 4 
                        ELSE 0 
                    END
FROM DDI.IndexesRowStore IRS
                             
UPDATE IRS
SET TotalRowSize_Estimated =  CASE
                        WHEN IRS.IsClustered_Desired = 1
                        THEN FixedKeyColsSize_Estimated + VarKeyColsSize_Estimated + NullBitmap_Estimated + 1 + 6
                        WHEN IRS.IsClustered_Desired = 0
                        THEN FixedColsSize_Estimated + VarColsSize_Estimated
                    END + NullBitmap_Estimated + 4,
    NonClusteredIndexRowLocator_Estimated =   CASE
                                        WHEN IsClustered_Desired = 0 AND IsUnique_Desired = 0
                                        THEN 0 --when NC index is over a CDX, it's the clustering key.  If it's over a heap, it's the heap RID.
                                        ELSE 0 
                                    END
FROM DDI.IndexesRowStore IRS

UPDATE IRS 
SET NumFreeRowsPerPage_Estimated = FLOOR(8096 * ((100 - [Fillfactor_Desired]) / 100.00)) / (TotalRowSize_Estimated),
    NumRowsPerPage_Estimated = FLOOR(8096 / (TotalRowSize_Estimated + 2)) * 1.00
FROM DDI.IndexesRowStore IRS

UPDATE IRS 
SET NumLeafPages_Estimated = CEILING(NumRows_Actual / (NumRowsPerPage_Estimated - NumFreeRowsPerPage_Estimated))
FROM DDI.IndexesRowStore IRS

UPDATE IRS
SET LeafSpaceUsed_Estimated = (NumLeafPages_Estimated) * 8192.00,
    LeafSpaceUsedMB_Estimated = CAST((((NumLeafPages_Estimated * 8192.00)/ 1024.00)/ 1024.00) AS DECIMAL(10,2)),
    NumNonLeafLevelsInIndex_Estimated = CASE
                                            WHEN CEILING((NumRows_Actual / (NumRowsPerPage_Estimated * 1.00)) - NumFreeRowsPerPage_Estimated) > 1
                                            THEN CEILING(1 + CAST(LOG((NumLeafPages_Estimated/(NumRowsPerPage_Estimated * 1.00)), NumRowsPerPage_Estimated) AS DECIMAL(10,2)))
                                            ELSE 1
                                        END
FROM DDI.IndexesRowStore IRS

UPDATE IRS
SET PKColsSize_Estimated = PKColsSize.PKColsSize
FROM DDI.IndexesRowStore IRS
    CROSS APPLY (   SELECT ISNULL(SUM(c.max_length + c.precision + scale), 0) AS PKColsSize
                    FROM DDI.SysIndexes i
                        INNER JOIN DDI.SysIndexColumns ic ON ic.object_id = i.object_id
                            AND ic.index_id = i.index_id
                        INNER JOIN DDI.SysColumns c ON c.object_id = ic.object_id
                            AND c.column_id = ic.column_id
                        INNER JOIN DDI.SysTables t ON i.object_id = t.object_id
                        INNER JOIN DDI.SysSchemas s ON t.schema_id = s.schema_id
                    WHERE s.name = IRS.SchemaName
                        AND t.name = IRS.TableName
                        AND i.is_primary_key = 1) PKColsSize


UPDATE IRS
SET  NumIndexPages_Estimated =  CASE NumNonLeafLevelsInIndex_Estimated
                                    WHEN 1 --for tables up to 133 rows
                                    THEN CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)
                                    WHEN 2 --for tables up to 17.6K rows
                                    THEN CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated) --leaf level
                                            + CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated) --first non-leaf
                                            + CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated) --second non-leaf
                                    WHEN 3 --for tables up to 2.3M rows
                                    THEN CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated) --leaf level
                                            + CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated) --first non-leaf
                                            + CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated) --second non-leaf
                                            + CEILING(CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)
                                    WHEN 4 --for tables up to 312M rows
                                    THEN CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated) --leaf level
                                            + CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated) --first non-leaf
                                            + CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated) --second non-leaf
                                            + CEILING(CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)
                                            + CEILING(CEILING(CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)
                                    WHEN 5 --for tables up to 41.6B rows
                                    THEN CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated) --leaf level
                                            + CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated) --first non-leaf
                                            + CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated) --second non-leaf
                                            + CEILING(CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)
                                            + CEILING(CEILING(CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)
                                            + CEILING(CEILING(CEILING(CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)
                                    WHEN 6 --for tables up to 5.5T rows
                                    THEN CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated) --leaf level
                                            + CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated) --first non-leaf
                                            + CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated) --second non-leaf
                                            + CEILING(CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)
                                            + CEILING(CEILING(CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)
                                            + CEILING(CEILING(CEILING(CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)
                                            + CEILING(CEILING(CEILING(CEILING(CEILING(CEILING(CEILING(NumLeafPages_Estimated/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)/NumRowsPerPage_Estimated)
                                    ELSE 0
                                END + 1  --we add 1 for the root page.
FROM DDI.IndexesRowStore IRS

UPDATE IRS
SET IndexSizeMB_Estimated = CAST(CASE
                                    WHEN IsClustered_Desired = 1
                                    THEN (((LeafSpaceUsed_Estimated + (NumIndexPages_Estimated * 8192.00))/1024.00)/1024.00)
                                    ELSE ((((ColsSize_Estimated
                                            +   CASE 
                                                    WHEN IsPrimaryKey_Desired = 0 
                                                    THEN PKColsSize_Estimated 
                                                    ELSE 0 
                                                END) * NumRows_Actual)/ 1024.00)/ 1024.00) 
                                END AS DECIMAL(10,2))
FROM DDI.IndexesRowStore IRS

/*******************************        FOR ESTIMATING INDEX SIZE (END) *******************************************/

GO
