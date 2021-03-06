
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexesColumnStore_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexesColumnStore_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexesColumnStore_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

--WITH NATIVE_COMPILATION, SCHEMABINDING --update...from is not supported in NC modules.
AS

--BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)

/************************************************   SQL SERVER METADATA (START) *******************************************/

--ROW COUNTS
    DECLARE @FilteredRowCounts DOI.FilteredRowCountsTT

    DECLARE @SQL VARCHAR(MAX) = ''

    SELECT @SQL += CASE @SQL WHEN '' THEN '' ELSE CHAR(13) + CHAR(10) + 'UNION ALL' + CHAR(13) + CHAR(10) END + 'SELECT ''' + DatabaseName + ''' AS DatabaseName, ''' + SchemaName + ''' AS SchemaName, ''' + TableName + ''' AS TableName, ''' + IndexName + ''' AS IndexName, COUNT(*) as NumRows FROM ' + DatabaseName + '.' + SchemaName + '.' + TableName + ' WHERE ' + FilterPredicate_Desired
    FROM (  SELECT ICS.DatabaseName, ICS.SchemaName, ICS.TableName, ICS.IndexName, ICS.FilterPredicate_Desired
            FROM DOI.IndexesColumnStore ICS
            WHERE IsFiltered_Desired = 1
                AND ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END )x

    INSERT @FilteredRowCounts        
    EXEC(@SQL)

    UPDATE ICS
    SET IsIndexMissingFromSQLServer = CASE WHEN I.NAME IS NULL THEN 1 ELSE 0 END
    FROM DOI.IndexesColumnStore ICS
        INNER JOIN DOI.SysDatabases d ON d.name = ICS.DatabaseName
        INNER JOIN DOI.SysSchemas s ON s.name = ICS.SchemaName
            AND s.database_id = d.database_id            
		INNER JOIN DOI.SysTables t ON t.name = ICS.TableName
            AND t.database_id = s.database_id
            AND s.schema_id = t.schema_id
		LEFT JOIN DOI.SysIndexes i ON i.name = ICS.IndexName
            AND i.database_id = t.database_id
            AND i.object_id = t.object_id
        AND ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END 

    UPDATE ICS
    SET NumRows_Actual = T.NumRows
    FROM DOI.IndexesColumnStore ICS
        INNER JOIN @FilteredRowCounts T ON ICS.DatabaseName = T.DatabaseName
            AND ICS.SchemaName = T.SchemaName
            AND ICS.TableName = T.TableName
            AND ICS.IndexName = T.IndexName
    WHERE IsFiltered_Desired = 1
        AND ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END 

    UPDATE ICS
    SET NumRows_Actual = p.NumRows --integrate this with index size update below?
    --SELECT p.*
    FROM DOI.IndexesColumnStore ICS
        CROSS APPLY (   SELECT d.name, s.name AS SchemaName, t.name AS TableName, SUM(p.rows) AS NumRows
                        FROM DOI.SysSchemas s 
                            INNER JOIN DOI.SysDatabases d ON s.database_id = d.database_id
                            INNER JOIN DOI.SysTables t ON s.database_id = t.database_id
                                AND s.schema_id = t.schema_id
                            INNER JOIN DOI.SysPartitions p ON p.database_id = t.database_id
                                AND p.object_id = t.object_id
                        WHERE p.index_id IN (0,1)
                            AND d.name = ICS.DatabaseName COLLATE DATABASE_DEFAULT
                            AND s.name = ICS.SchemaName COLLATE DATABASE_DEFAULT
                            AND t.name = ICS.TableName COLLATE DATABASE_DEFAULT
                        GROUP BY d.name, s.name , t.name)p
    WHERE IsFiltered_Desired = 0
        AND ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END 

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
    FROM DOI.IndexesColumnStore ICS
        OUTER APPLY (   SELECT * 
                        FROM DOI.fnActualIndexSizing() AIS 
                        WHERE AIS.DatabaseName = ICS.DatabaseName 
                            AND AIS.SchemaName = ICS.SchemaName 
                            AND AIS.TableName = ICS.TableName 
                            AND AIS.IndexName = ICS.IndexName) TS --try this both with params inside the function or a correlated subquery...wonder which one is faster?
    /*
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
		                FROM DOI.systables t 
                            INNER JOIN DOI.SysDatabases d ON t.database_id = d.database_id
                            INNER JOIN DOI.SysSchemas s ON t.database_id = s.database_id
                                AND t.SCHEMA_ID = s.SCHEMA_ID
                            INNER JOIN DOI.SysIndexes i ON s.database_id = i.database_id
                                AND i.OBJECT_ID = t.object_id
                            INNER JOIN DOI.SysPartitions p ON p.database_id = i.database_id
                                AND p.OBJECT_ID = i.OBJECT_ID
                                AND p.index_id = I.index_id
							INNER JOIN DOI.SysColumnStoreRowGroups CSRG ON p.database_id = csrg.database_id
								AND p.object_id = csrg.object_id
								AND p.index_id = csrg.index_id
								AND p.partition_number = csrg.partition_number
							INNER JOIN DOI.SysAllocationUnits a ON a.database_id = d.database_id
								AND ((a.type IN (1,3)
										AND  container_id = csrg.delta_store_hobt_id)
									OR (a.type = 2
										AND container_id = p.partition_id))
                            INNER JOIN DOI.SysDatabaseFiles df ON a.database_id = df.database_id
                                AND df.data_space_id = a.data_space_id
			                INNER JOIN (SELECT DatabaseName, CAST(SettingValue AS INT) AS SizeCutoffValue
						                FROM DOI.DOISettings 
						                WHERE SettingName = 'LargeTableCutoffValue')SS1
                                ON SS1.DatabaseName = d.name
                            INNER JOIN (SELECT DatabaseName, CAST(SettingValue AS INT) AS MinNumPages
                                        FROM DOI.DOISettings 
                                        WHERE SettingName = 'MinNumPagesForIndexDefrag')SS2
                                ON SS2.DatabaseName = d.name
			                INNER JOIN DOI.SysDmOsVolumeStats vs ON vs.database_id = df.database_id
                                AND vs.FILE_ID = df.FILE_ID
		                WHERE d.name = ICS.DatabaseName
                            AND s.NAME = ICS.SchemaName
                            AND t.NAME = ICS.TableName
                            AND i.NAME = ICS.IndexName
		                GROUP BY d.name, s.name, t.name, i.name) TS
    WHERE ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END */
    OPTION (FORCE ORDER)
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
    FROM DOI.IndexesColumnStore ICS
        INNER JOIN (SELECT DatabaseName, CAST(SettingValue AS INT) AS MinNumPages
                    FROM DOI.DOISettings 
                    WHERE SettingName = 'MinNumPagesForIndexDefrag')SS
            ON SS.DatabaseName = ICS.DatabaseName
        CROSS APPLY (   SELECT  Fragmentation
                        FROM DOI.fnActualIndex_Frag() FN
                        WHERE FN.DatabaseName = ICS.DatabaseName
                            AND FN.SchemaName = ICS.SchemaName
                            AND FN.TableName = ICS.TableName
                            AND FN.IndexName = ICS.IndexName) F
    WHERE ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END 

    --partition functions & storage for partitioned tables
    UPDATE ICS
    SET Storage_Desired = PF.PartitionSchemeName
    FROM DOI.IndexesColumnStore ICS
        INNER JOIN DOI.PartitionFunctions PF ON ICS.PartitionFunction_Desired = PF.PartitionFunctionName
    WHERE ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END 

    UPDATE ICS
    SET PartitionFunction_Actual = ExistingPf.name,
        Storage_Actual = NewPs.name
    FROM DOI.IndexesColumnStore ICS 
        INNER JOIN DOI.SysDatabases d on d.name = ICS.DatabaseName
	    INNER JOIN DOI.SysPartitionSchemes ExistingPs ON d.database_id = ExistingPs.database_id
            AND ICS.Storage_Actual = ExistingPs.name
	    INNER JOIN DOI.SysPartitionFunctions ExistingPf ON d.database_id = ExistingPf.database_id
            AND ExistingPs.function_id = ExistingPf.function_id
	    INNER JOIN DOI.SysPartitionSchemes NewPs ON NewPs.database_id = D.database_id
            AND NewPs.name = ICS.Storage_Desired
	    INNER JOIN DOI.SysPartitionFunctions NewPf ON NewPf.database_id = NewPs.database_id
            AND NewPf.function_id = NewPs.function_id
    WHERE ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END 

    --SysIndexes, and friends...
    UPDATE ICS
    SET IsClustered_Actual      = CASE WHEN i.type_desc = 'CLUSTERED COLUMNSTORE' THEN 1 ELSE 0 END,
        ColumnList_Actual       = CASE WHEN i.type_desc = 'CLUSTERED COLUMNSTORE' THEN NULL ELSE i.included_column_list END,
        IsFiltered_Actual       = i.has_filter,
        FilterPredicate_Actual  = i.filter_definition,
        Storage_Actual          = ActualDS.name,
        Storage_Desired         = DesiredDS.name, --THIS IS A PROBLEM BECAUSE THIS COLUMN IS BEING UPDATED HERE AND ALSO USED IN A JOIN...CIRCULAR REFERENCE.
        StorageType_Actual      = ActualDS.type_desc,
        StorageType_Desired     = DesiredDS.type_desc,
        IsStorageChanging       = CASE WHEN ActualDS.name <> DesiredDS.name THEN 1 ELSE 0 END
    --SELECT i.*
    FROM DOI.Tables TTP
        INNER JOIN DOI.SysDatabases d on d.name = TTP.DatabaseName
	    INNER JOIN DOI.SysSchemas s ON D.database_id = s.database_id
            AND TTP.SchemaName = s.name
	    INNER JOIN DOI.SysTables t ON s.database_id = t.database_id
            AND TTP.TableName = t.name
		    AND s.schema_id = t.schema_id
	    INNER JOIN DOI.SysIndexes i ON t.database_id = i.database_id
            AND i.object_id = t.object_id
	    INNER JOIN DOI.IndexesColumnStore ICS ON TTP.DatabaseName = ICS.DatabaseName
            AND TTP.SchemaName = ICS.SchemaName
		    AND TTP.TableName = ICS.TableName
		    AND ICS.IndexName = i.name	
	    INNER JOIN DOI.SysDataSpaces ActualDS ON ActualDS.database_id = i.database_id
            AND ActualDS.data_space_id = I.data_space_id
	    INNER JOIN DOI.SysDataSpaces DesiredDS ON DesiredDS.database_id = d.database_id
            AND DesiredDS.name = ICS.Storage_Desired
    WHERE ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END 

    --CHANGE BITS
    UPDATE ICS
    SET IsColumnListChanging	        = CASE WHEN ICS.ColumnList_Desired <> ICS.ColumnList_Actual THEN 1 ELSE 0 END, 
	    IsFilterChanging                = CASE WHEN ISNULL(ICS.FilterPredicate_Desired, '') <> ISNULL(ICS.FilterPredicate_Actual, '') THEN 1 ELSE 0 END, 
	    IsClusteredChanging             = CASE WHEN ICS.IsClustered_Desired <> CASE ISNULL(ICS.IsClustered_Actual, '') WHEN 1 THEN 1 ELSE 0 END  THEN 1 ELSE 0 END, 
	    IsPartitioningChanging          = CASE WHEN ICS.IsStorageChanging = 1 AND T.IntendToPartition = 1 THEN 1 ELSE 0 END, 
	    IsDataCompressionChanging       = CASE WHEN ICS.OptionDataCompression_Desired <> ISNULL(ICS.OptionDataCompression_Actual, '') THEN 1 ELSE 0 END,
	    IsDataCompressionDelayChanging  = CASE WHEN ICS.OptionDataCompressionDelay_Desired <> ISNULL(ICS.OptionDataCompressionDelay_Actual, '') THEN 1 ELSE 0 END
    FROM DOI.IndexesColumnStore ICS
        INNER JOIN DOI.Tables T ON ICS.DatabaseName = T.DatabaseName
            AND ICS.SchemaName = T.SchemaName
            AND ICS.TableName = T.TableName
    WHERE ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END 

    /*			
			    ,ISNULL(i.has_LOB_columns, 0) AS IndexHasLOBColumns
    */

    UPDATE DOI.IndexesColumnStore
    SET AreDropRecreateOptionsChanging  =   CASE
                                                WHEN (IsColumnListChanging = 1
                                                        OR IsFilterChanging = 1
                                                        OR IsClusteredChanging = 1
                                                        OR IsStorageChanging = 1
                                                        OR IsPartitioningChanging = 1)
                                                THEN 1
                                                ELSE 0
                                            END,
        AreRebuildOptionsChanging       =   CASE    
                                                WHEN (IsDataCompressionChanging = 1)
                                                THEN 1
                                                ELSE 0
                                            END,
        AreRebuildOnlyOptionsChanging   =   CASE    
                                                WHEN (IsDataCompressionChanging = 1)
                                                THEN 1
                                                ELSE 0
                                            END,
        AreSetOptionsChanging           =   CASE    
                                                WHEN (IsDataCompressionDelayChanging = 1)
                                                THEN 1
                                                ELSE 0
                                            END
    WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 

    /*******************************        FOR ESTIMATING INDEX SIZE (START) *******************************************/
    /*******************************        FOR ESTIMATING INDEX SIZE (END) *******************************************/
--END

GO
