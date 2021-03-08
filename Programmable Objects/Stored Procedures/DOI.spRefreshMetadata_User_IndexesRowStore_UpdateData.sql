
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexesRowStore_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexesRowStore_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [DOI].[spRefreshMetadata_User_IndexesRowStore_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

--WITH NATIVE_COMPILATION, SCHEMABINDING --UPDATE..FROM NOT SUPPORTED IN NC MODULES.
AS

--BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    /************************************************   SQL SERVER METADATA (START) *******************************************/

    --ROW COUNTS
    DECLARE @FilteredRowCounts FilteredRowCountsTT


    DECLARE @SQL VARCHAR(MAX) = ''

    SELECT @SQL += CASE @SQL WHEN '' THEN '' ELSE CHAR(13) + CHAR(10) + 'UNION ALL' + CHAR(13) + CHAR(10) END + 'SELECT ''' + DatabaseName + ''' AS DatabaseName, ''' + SchemaName + ''' AS SchemaName, ''' + TableName + ''' AS TableName, ''' + IndexName + ''' AS IndexName, COUNT(*) as NumRows FROM ' + DatabaseName + '.' + SchemaName + '.' + TableName + ' WHERE ' + FilterPredicate_Desired
    FROM (  SELECT IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, IRS.FilterPredicate_Desired
            FROM DOI.IndexesRowStore IRS
            WHERE IsFiltered_Desired = 1
                AND IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END )x

    INSERT @FilteredRowCounts        
    EXEC(@SQL)


    UPDATE IRS
    SET IsIndexMissingFromSQLServer = CASE WHEN I.NAME IS NULL THEN 1 ELSE 0 END
    FROM DOI.IndexesRowStore IRS
        INNER JOIN DOI.SysDatabases d ON d.name = IRS.DatabaseName
        INNER JOIN DOI.SysSchemas s ON s.name = IRS.SchemaName
            AND s.database_id = d.database_id            
		INNER JOIN DOI.SysTables t ON t.name = IRS.TableName
            AND t.database_id = s.database_id
            AND s.schema_id = t.schema_id
		LEFT JOIN DOI.SysIndexes i ON i.name = IRS.IndexName
            AND i.database_id = t.database_id
            AND i.object_id = t.object_id
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

    UPDATE IRS
    SET NumRows_Actual = T.NumRows
    FROM DOI.IndexesRowStore IRS
        INNER JOIN @FilteredRowCounts T ON IRS.DatabaseName = T.DatabaseName
            AND IRS.SchemaName = T.SchemaName
            AND IRS.TableName = T.TableName
            AND IRS.IndexName = T.IndexName
    WHERE IsFiltered_Desired = 1
        AND IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

    UPDATE IRS
    SET NumRows_Actual = p.NumRows
    --SELECT p.*
    FROM DOI.IndexesRowStore IRS
        CROSS APPLY (SELECT s.name AS SchemaName, t.name AS TableName, SUM(p.rows) AS NumRows
                    FROM DOI.SysSchemas s 
                        INNER JOIN DOI.SysTables t ON s.database_id = t.database_id
                            AND s.schema_id = t.schema_id
                        INNER JOIN DOI.SysPartitions p ON p.database_id = t.database_id
                            AND p.object_id = t.object_id
                        INNER JOIN DOI.SysDatabases d ON s.database_id = d.database_id
                    WHERE p.index_id IN (0,1)
                        AND d.name = IRS.DatabaseName COLLATE DATABASE_DEFAULT
                        AND s.name = IRS.SchemaName COLLATE DATABASE_DEFAULT
                        AND t.name = IRS.TableName COLLATE DATABASE_DEFAULT
                    GROUP BY s.name , t.name)p
    WHERE IsFiltered_Desired = 0
        AND IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

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
    FROM DOI.IndexesRowStore IRS
        OUTER APPLY (   SELECT  db.name AS DatabaseName,
                                s.NAME AS SchemaName,
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
		                FROM DOI.systables t 
                            INNER JOIN DOI.SysSchemas s ON t.database_id = s.database_id
                                AND t.SCHEMA_ID = s.SCHEMA_ID
                            INNER JOIN DOI.SysIndexes i ON i.database_id = t.database_id
                                AND i.OBJECT_ID = t.object_id
                            INNER JOIN DOI.SysPartitions p ON p.database_id = t.database_id
                                AND p.OBJECT_ID = t.OBJECT_ID
                                AND p.index_id = I.index_id
                            INNER JOIN DOI.SysAllocationUnits a ON p.database_id = a.database_id
                                AND p.hobt_id = a.container_id
                            INNER JOIN DOI.SysDatabaseFiles df ON df.database_id = a.database_id
                                AND df.data_space_id = a.data_space_id
			                CROSS JOIN (SELECT CAST(SettingValue AS INT) AS SizeCutoffValue
						                FROM DOI.DOISettings 
						                WHERE SettingName = 'LargeTableCutoffValue'
                                            AND DatabaseName = IRS.DatabaseName)SS1
                            CROSS JOIN (SELECT CAST(SettingValue AS INT) AS MinNumPages
                                        FROM DOI.DOISettings 
                                        WHERE SettingName = 'MinNumPagesForIndexDefrag'
                                            AND DatabaseName = IRS.DatabaseName)SS2
                            CROSS JOIN (SELECT database_id, name FROM DOI.SysDatabases WHERE name = IRS.DatabaseName) DB
			                INNER JOIN DOI.SysDmOsVolumeStats vs ON vs.database_id = DB.database_id
                                AND vs.FILE_ID = df.FILE_ID
		                WHERE db.name = IRS.DatabaseName
                            AND s.NAME = IRS.SchemaName
                            AND t.NAME = IRS.TableName
                            AND i.NAME = IRS.IndexName
		                GROUP BY db.name, s.name, t.name, i.name) TS
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

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
    FROM DOI.IndexesRowStore IRS
        CROSS JOIN (SELECT CAST(SettingValue AS INT) AS MinNumPages
                    FROM DOI.DOISettings 
                    WHERE SettingName = 'MinNumPagesForIndexDefrag')SS
        CROSS APPLY (   SELECT  Fragmentation
                        FROM DOI.fnActualIndex_Frag() FN
                        WHERE FN.DatabaseName = IRS.DatabaseName
                            AND FN.SchemaName = IRS.SchemaName
                            AND FN.TableName = IRS.TableName
                            AND FN.IndexName = IRS.IndexName) F
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

    --partition functions & storage for partitioned tables
    UPDATE IRS
    SET Storage_Desired = PF.PartitionSchemeName
    FROM DOI.IndexesRowStore IRS
        INNER JOIN DOI.PartitionFunctions PF ON IRS.PartitionFunction_Desired = PF.PartitionFunctionName
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

    UPDATE IRS
    SET PartitionFunction_Actual = ExistingPf.name,
        Storage_Actual = NewPs.name
    FROM DOI.IndexesRowStore IRS 
        INNER JOIN DOI.SysDatabases d on d.name = IRS.DatabaseName
	    INNER JOIN DOI.SysPartitionSchemes ExistingPs ON d.database_id = ExistingPs.database_id
            AND IRS.Storage_Actual = ExistingPs.name
	    INNER JOIN DOI.SysPartitionFunctions ExistingPf ON d.database_id = ExistingPf.database_id
            AND ExistingPs.function_id = ExistingPf.function_id
	    INNER JOIN DOI.SysPartitionSchemes NewPs ON NewPs.database_id = D.database_id
            AND NewPs.name = IRS.Storage_Desired
	    INNER JOIN DOI.SysPartitionFunctions NewPf ON NewPf.database_id = NewPs.database_id
            AND NewPf.function_id = NewPs.function_id
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 


    --SysIndexes, and friends...including storage for non-partitioned tables.
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
        Storage_Desired = DesiredDS.name,
        StorageType_Actual = ActualDS.type_desc,
        StorageType_Desired = DesiredDS.type_desc,
        IsStorageChanging = CASE WHEN ActualDS.name <> DesiredDS.name THEN 1 ELSE 0 END,
        IndexHasLOBColumns = i.has_LOB_columns,
        OptionStatisticsIncremental_Actual = s2.is_incremental,
        OptionStatisticsNoRecompute_Actual = s2.no_recompute
    FROM DOI.Tables TTP
        INNER JOIN DOI.SysDatabases d on d.name = TTP.DatabaseName
	    INNER JOIN DOI.SysSchemas s ON D.database_id = s.database_id
            AND TTP.SchemaName = s.name
	    INNER JOIN DOI.SysTables t ON s.database_id = t.database_id
            AND TTP.TableName = t.name
		    AND s.schema_id = t.schema_id
	    INNER JOIN DOI.SysIndexes i ON t.database_id = i.database_id
            AND i.object_id = t.object_id
        INNER JOIN DOI.SysStats s2 ON s2.database_id = i.database_id
            AND s2.object_id = I.object_id
		    AND s2.stats_id = i.index_id
	    INNER JOIN DOI.IndexesRowStore IRS ON TTP.DatabaseName = IRS.DatabaseName
            AND TTP.SchemaName = IRS.SchemaName
		    AND TTP.TableName = IRS.TableName
		    AND IRS.IndexName = i.name	
	    INNER JOIN DOI.SysDataSpaces ActualDS ON ActualDS.database_id = i.database_id
            AND ActualDS.data_space_id = I.data_space_id
	    INNER JOIN DOI.SysDataSpaces DesiredDS ON DesiredDS.database_id = d.database_id
            AND DesiredDS.name = IRS.Storage_Desired
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END

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
    FROM DOI.IndexesRowStore IRS
        INNER JOIN DOI.Tables T ON IRS.DatabaseName = T.DatabaseName
            AND IRS.SchemaName = T.SchemaName
            AND IRS.TableName = T.TableName
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

    /*			
			    ,ISNULL(i.has_LOB_columns, 0) AS IndexHasLOBColumns
    */

    UPDATE IRS
    SET AreDropRecreateOptionsChanging =    CASE
                                                WHEN (IsPrimaryKeyChanging = 1
                                                        OR IsUniquenessChanging = 1
                                                        OR IsKeyColumnListChanging = 1
                                                        OR IsIncludedColumnListChanging = 1
                                                        OR IsFilterChanging = 1
                                                        OR IsClusteredChanging = 1
                                                        OR IsStorageChanging = 1
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
    FROM DOI.IndexesRowStore IRS
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 


    /*******************************        FOR ESTIMATING INDEX SIZE (START) *******************************************/
    UPDATE IRS
    SET AllColsInTableSize_Estimated = ISNULL(DOI.fnEstimateIndexSize_AllColSize(DatabaseName, schemaname, tablename), 0)
    FROM DOI.IndexesRowStore IRS
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 
    --NEED TO HANDLE THIS NULL VALUE INSIDE OF FUNCTION!!!

    UPDATE IRS
    SET IRS.NumFixedKeyCols_Estimated = FN.NumFixedCols,
        IRS.FixedKeyColsSize_Estimated = FN.FixedColSize
    FROM DOI.IndexesRowStore IRS
        CROSS APPLY (   SELECT * 
                        FROM DOI.fnEstimateIndexSize_KeyFixedColSize() FN
                        WHERE IRS.DatabaseName = FN.DatabaseName
                            AND IRS.SchemaName = FN.SchemaName
                            AND IRS.TableName = FN.TableName
                            AND IRS.IndexName = FN.IndexName) FN
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

    UPDATE IRS
    SET IRS.NumVarKeyCols_Estimated = FN.NumVarCols,
        IRS.VarKeyColsSize_Estimated = FN.VarColSize
    FROM DOI.IndexesRowStore IRS
        CROSS APPLY (   SELECT * 
                        FROM DOI.fnEstimateIndexSize_KeyVarColSize() FN
                        WHERE IRS.DatabaseName = FN.DatabaseName
                            AND IRS.SchemaName = FN.SchemaName
                            AND IRS.TableName = FN.TableName
                            AND IRS.IndexName = FN.IndexName) FN
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

    UPDATE IRS
    SET IRS.NumFixedInclCols_Estimated = FN.NumInclFixedCols,
        IRS.FixedInclColsSize_Estimated = FN.FixedInclColSize
    FROM DOI.IndexesRowStore IRS
        CROSS APPLY (   SELECT * 
                        FROM DOI.fnEstimateIndexSize_InclFixedColSize() FN
                        WHERE IRS.DatabaseName = FN.DatabaseName
                            AND IRS.SchemaName = FN.SchemaName
                            AND IRS.TableName = FN.TableName
                            AND IRS.IndexName = FN.IndexName) FN
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

    UPDATE IRS
    SET IRS.NumVarInclCols_Estimated = FN.NumInclVarCols,
        IRS.VarInclColsSize_Estimated = FN.VarInclColSize
    FROM DOI.IndexesRowStore IRS
        CROSS APPLY (   SELECT * 
                        FROM DOI.fnEstimateIndexSize_InclVarColSize() FN
                        WHERE IRS.DatabaseName = FN.DatabaseName
                            AND IRS.SchemaName = FN.SchemaName
                            AND IRS.TableName = FN.TableName
                            AND IRS.IndexName = FN.IndexName) FN
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 


    UPDATE DOI.IndexesRowStore
    SET KeyColsSize_Estimated   = FixedKeyColsSize_Estimated  + VarKeyColsSize_Estimated,
        InclColsSize_Estimated  = FixedInclColsSize_Estimated + VarInclColsSize_Estimated,
        FixedColsSize_Estimated = FixedKeyColsSize_Estimated  + FixedInclColsSize_Estimated,
        VarColsSize_Estimated   = VarKeyColsSize_Estimated    + VarInclColsSize_Estimated,
        NumKeyCols_Estimated    = NumFixedKeyCols_Estimated   + NumVarKeyCols_Estimated,
        NumInclCols_Estimated   = NumFixedInclCols_Estimated  + NumVarInclCols_Estimated,
        NumFixedCols_Estimated  = NumFixedKeyCols_Estimated   + NumFixedInclCols_Estimated,
        NumVarCols_Estimated    = NumVarKeyCols_Estimated     + NumVarInclCols_Estimated
    WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 

    UPDATE DOI.IndexesRowStore
    SET ColsSize_Estimated = KeyColsSize_Estimated + InclColsSize_Estimated,
        NumCols_Estimated = NumKeyCols_Estimated + NumInclCols_Estimated,
        NullBitmap_Estimated = CAST((((ISNULL(NumKeyCols_Estimated,0) + ISNULL(NumInclCols_Estimated, 0)) + 7)/8) + 2 AS INT),
        Uniqueifier_Estimated =   CASE 
                            WHEN IsClustered_Desired = 1 
                                AND IsUnique_Desired = 0 
                            THEN 4 
                            ELSE 0 
                        END
    WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 
                             
    UPDATE DOI.IndexesRowStore
    SET TotalRowSize_Estimated =  CASE
                            WHEN IsClustered_Desired = 1
                            THEN FixedKeyColsSize_Estimated + VarKeyColsSize_Estimated + NullBitmap_Estimated + 1 + 6
                            WHEN IsClustered_Desired = 0
                            THEN FixedColsSize_Estimated + VarColsSize_Estimated
                        END + NullBitmap_Estimated + 4,
        NonClusteredIndexRowLocator_Estimated = CASE
                                                    WHEN IsClustered_Desired = 0 AND IsUnique_Desired = 0
                                                    THEN 0 --when NC index is over a CDX, it's the clustering key.  If it's over a heap, it's the heap RID.
                                                    ELSE 0 
                                                END
    WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 

    UPDATE DOI.IndexesRowStore 
    SET NumFreeRowsPerPage_Estimated = FLOOR(8096 * ((100 - [Fillfactor_Desired]) / 100.00)) / (TotalRowSize_Estimated),
        NumRowsPerPage_Estimated = FLOOR(8096 / (TotalRowSize_Estimated + 2)) * 1.00
    WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 

    UPDATE DOI.IndexesRowStore 
    SET NumLeafPages_Estimated = CEILING(NumRows_Actual / (NumRowsPerPage_Estimated - NumFreeRowsPerPage_Estimated))
    WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 

    UPDATE DOI.IndexesRowStore
    SET LeafSpaceUsed_Estimated = (NumLeafPages_Estimated) * 8192.00,
        LeafSpaceUsedMB_Estimated = CAST((((NumLeafPages_Estimated * 8192.00)/ 1024.00)/ 1024.00) AS DECIMAL(10,2)),
        NumNonLeafLevelsInIndex_Estimated = CASE
                                                WHEN CEILING((NumRows_Actual / (NumRowsPerPage_Estimated * 1.00)) - NumFreeRowsPerPage_Estimated) > 1
                                                THEN CEILING(1 + CAST(LOG((NumLeafPages_Estimated/(NumRowsPerPage_Estimated * 1.00)), NumRowsPerPage_Estimated) AS DECIMAL(10,2)))
                                                ELSE 1
                                            END
    WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 

    UPDATE IRS
    SET PKColsSize_Estimated = PKColsSize.PKColsSize
    FROM DOI.IndexesRowStore IRS
            CROSS APPLY (   SELECT ISNULL(SUM(c.max_length + c.precision + scale), 0) AS PKColsSize
                            FROM DOI.SysIndexes i
                                INNER JOIN DOI.SysIndexColumns ic ON ic.database_id = i.database_id
                                    AND ic.object_id = i.object_id
                                    AND ic.index_id = i.index_id
                                INNER JOIN DOI.SysColumns c ON c.database_id = ic.database_id
                                    AND c.object_id = ic.object_id
                                    AND c.column_id = ic.column_id
                                INNER JOIN DOI.SysTables t ON i.database_id = t.database_id
                                    AND i.object_id = t.object_id
                                INNER JOIN DOI.SysSchemas s ON t.database_id = s.database_id
                                    AND t.schema_id = s.schema_id
                            WHERE s.name = IRS.SchemaName
                                AND t.name = IRS.TableName
                                AND i.is_primary_key = 1) PKColsSize
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 


    UPDATE DOI.IndexesRowStore
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
    WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 

    UPDATE IRS
    SET IndexSizeMB_Actual_Estimated = CAST(CASE
                                        WHEN IsClustered_Desired = 1
                                        THEN (((LeafSpaceUsed_Estimated + (NumIndexPages_Estimated * 8192.00))/1024.00)/1024.00)
                                        ELSE ((((ColsSize_Estimated
                                                +   CASE 
                                                        WHEN IsPrimaryKey_Desired = 0 
                                                        THEN PKColsSize_Estimated 
                                                        ELSE 0 
                                                    END) * NumRows_Actual)/ 1024.00)/ 1024.00) 
                                    END AS DECIMAL(10,2))
    FROM DOI.IndexesRowStore IRS
    WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

    /*******************************        FOR ESTIMATING INDEX SIZE (END) *******************************************/
--END

GO
