-- <Migration ID="80b9d690-808a-5c9a-b27c-cc2c0ea09e87" TransactionHandling="Custom" />

GO

IF OBJECT_ID('DOI.trIndexesRowStore_IndexValidations') IS NOT NULL
DROP TRIGGER DOI.trIndexesRowStore_IndexValidations
GO

IF OBJECT_ID('[DOI].[spIndexValidations]') IS NOT NULL
	DROP PROCEDURE [DOI].[spIndexValidations];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spIndexValidations]

WITH NATIVE_COMPILATION, SCHEMABINDING

AS

/*
	EXEC DOI.spIndexValidations
*/
BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)

    DECLARE @ObjectList												VARCHAR(MAX) = '',
		    @TablesWithMoreThan1PKList								VARCHAR(MAX) = '',
		    @TablesWithMoreThan1ClusteredIndexList					VARCHAR(MAX) = '',
		    @InvalidTableNamesList									VARCHAR(MAX) = '',
		    @InvalidKeyColumnNamesList								VARCHAR(MAX) = '',
		    @InvalidIncludedColumnNamesList							VARCHAR(MAX) = '',
		    @ErrorMessage											VARCHAR(MAX) = '',
		    @AlignedIndexesWithoutIncrementalStatistics				VARCHAR(MAX) = '',
		    @FilteredIndexesWithIncrementalStatistics				VARCHAR(MAX) = '',
		    @IntendToPartitionWithPartitionColumnNotInKeyColumnList VARCHAR(MAX) = '',
		    @IndexesSetToRunAutomaticallyButTableHasNot				VARCHAR(MAX) = '',
		    @OnlineOnWithLOBKeyColumns								VARCHAR(MAX) = '',
		    @OnlineOnWithLOBIncludedColumns							VARCHAR(MAX) = '',
		    @PartitionEnabledWithBadSettings						VARCHAR(MAX) = '',
		    @NoUpdatedUtcDtColumnInTable							VARCHAR(MAX) = '',
		    @TableAndIndexStorageMismatch							VARCHAR(MAX) = '',
		    @IndexAndPartitionCompressionMismatch					VARCHAR(MAX) = '',
		    @ColumnListsWithSpacesAfterCommas						VARCHAR(MAX) = '',
		    @InvalidPartitionColumnNamesList		 				VARCHAR(MAX) = '',
            @StatisticsIncrementalNotAlignedWithTable				VARCHAR(MAX) = '',
            @StatisticsIncrementalNotAlignedWithIndex				VARCHAR(MAX) = '',
            @NonPartitionedIndexesWithIncrementalStatistics         VARCHAR(MAX) = ''

    SET @ErrorMessage = 'The following indexes have the partitioning column also listed as an INCLUDED column. Remove the INCLUDED column:  ' 

    SELECT @ObjectList += IRS.IndexName + '.' + IC.ColumnName
    FROM DOI.IndexesRowStore IRS
        INNER JOIN DOI.IndexColumns IC ON IC.DatabaseName = IRS.DatabaseName
            AND IC.SchemaName = IRS.SchemaName
            AND IC.TableName = IRS.TableName
            AND IC.IndexName = IRS.IndexName
    WHERE IC.IsIncludedColumn = 1
        AND IC.ColumnName = IRS.PartitionColumn_Desired

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000, @ErrorMessage, 1;
    END

    SET @ObjectList = ''
    SET @ErrorMessage = 'The following indexes have an included column also listed as an key column. Remove the INCLUDED column:  ' 


    SELECT @ObjectList += IRS.IndexName + ','
    FROM DOI.IndexesRowStore IRS
        INNER JOIN DOI.IndexColumns IC ON IC.DatabaseName = IRS.DatabaseName
                AND IC.SchemaName = IRS.SchemaName
                AND IC.TableName = IRS.TableName
                AND IC.IndexName = IRS.IndexName
    WHERE IC.IsIncludedColumn = 1
        AND IC.IsKeyColumn = 1

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000, @ErrorMessage, 1;
    END

    --aligned indexes on partitioned tables must have statistics incremental = on
    SET @ObjectList = ''
    SET @ErrorMessage = 'The following Unique Index(es) are partition-aligned but do not have incremental statistics.  Set OptionStatisticsIncremental to 1 for these indexes:  '

    SELECT @ObjectList += IRS.IndexName + ','
    FROM DOI.IndexesRowStore IRS
        INNER JOIN DOI.SysDatabases d ON IRS.DatabaseName = d.name
	    INNER JOIN DOI.SysSchemas s ON d.database_id = s.database_id
            AND s.name = IRS.SchemaName
	    INNER JOIN DOI.SysTables t ON t.database_id = d.database_id
            AND IRS.TableName = t.name
		    AND s.schema_id = t.schema_id
	    INNER JOIN DOI.SysIndexes i ON i.database_id = d.database_id
            AND i.object_id = t.object_id
		    AND i.Name = IRS.IndexName 
	    INNER JOIN (SELECT name AS ExistingStorage, data_space_id, type_desc AS ExistingStorageType
				    FROM DOI.SysDataSpaces) ExistingDS 
		    ON ExistingDS.data_space_id = i.data_space_id
        INNER JOIN DOI.IndexColumns IC ON IC.DatabaseName = IRS.DatabaseName
            AND IC.SchemaName = IRS.SchemaName
            AND IC.TableName = IRS.TableName
            AND IC.IndexName = IRS.IndexName
    WHERE IRS.IsUnique_Desired = 1
	    AND ISNULL(ExistingDS.ExistingStorage,'NONE') <> 'NONE' --are the indexes partitioned?
	    AND IC.ColumnName = IRS.PartitionColumn_Desired --are the indexes aligned?
	    AND IRS.OptionStatisticsIncremental_Desired = 0

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END

    --non-aligned indexes on partitioned tables cannot have statistics incremental = on
    SET @ObjectList = ''
    SET @ErrorMessage = 'The following Unique Index(es) are NOT partition-aligned but do not have incremental statistics.  Set OptionStatisticsIncremental to 0 for these indexes:  '

    SELECT @AlignedIndexesWithoutIncrementalStatistics += IRS.IndexName + ','
    FROM DOI.IndexesRowStore IRS
        INNER JOIN DOI.SysDatabases d ON IRS.DatabaseName = d.name
	    INNER JOIN DOI.SysSchemas s ON d.database_id = s.database_id
            AND s.name = IRS.SchemaName
	    INNER JOIN DOI.SysTables t ON t.database_id = d.database_id
            AND IRS.TableName = t.name
		    AND s.schema_id = t.schema_id
	    INNER JOIN DOI.SysIndexes i ON i.database_id = d.database_id
            AND i.object_id = t.object_id
		    AND i.Name = IRS.IndexName 
	    INNER JOIN (SELECT name AS ExistingStorage, data_space_id, type_desc AS ExistingStorageType
				    FROM DOI.SysDataSpaces) ExistingDS 
		    ON ExistingDS.data_space_id = i.data_space_id
    WHERE IRS.IsUnique_Desired = 1
	    AND ISNULL(ExistingDS.ExistingStorage,'NONE') <> 'NONE' --are the indexes partitioned?
	    AND IRS.OptionStatisticsIncremental_Desired = 0
        AND NOT EXISTS (SELECT 'True'
                        FROM DOI.IndexColumns IC 
                        WHERE IC.DatabaseName = IRS.DatabaseName
                            AND IC.SchemaName = IRS.SchemaName
                            AND IC.TableName = IRS.TableName
                            AND IC.IndexName = IRS.IndexName
                            AND IC.ColumnName = IRS.PartitionColumn_Desired) --are the indexes NOT aligned?

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END

    --tables with more than 1 PK
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Table(s) have more than 1 Primary Key defined.  Delete or convert one of the Primary Keys to a Unique index:'

    SELECT @TablesWithMoreThan1PKList += SchemaName + '.' + TableName + ','
    FROM DOI.IndexesRowStore 
    WHERE IsPrimaryKey_Desired = 1 
    GROUP BY SchemaName, TableName 
    HAVING COUNT(*) > 1

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END

    --tables with more than 1 Clustered Index
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Table(s) have more than 1 Clustered Index defined.  Delete or convert one of the Clustered Indexes to IsClustered = 0:' 

    SELECT @TablesWithMoreThan1ClusteredIndexList += SchemaName + '.' + TableName + ','
    FROM (	SELECT SchemaName, TableName 
		    FROM DOI.IndexesRowStore 
		    WHERE IsClustered_Desired = 1 
		    UNION ALL
		    SELECT SchemaName, TableName
		    FROM DOI.IndexesColumnStore
		    WHERE IsClustered_Desired = 1 ) AllIdx
    GROUP BY SchemaName, TableName 
    HAVING COUNT(*) > 1

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END


    --@PartitionEnabledWithBadSettings
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Table(s) have a bad PartitionColumn/PartitionScheme combination:  ' 

    SELECT @PartitionEnabledWithBadSettings += AllIdx.SchemaName + '.' + AllIdx.TableName + '.' + AllIdx.IndexName + ','
    --SELECT AllIdx.IndexName, T.IntendToPartition, AllIdx.PartitionColumn, AllIdx.NewPartitionFunction
    FROM DOI.Tables T
	    INNER JOIN (SELECT	SchemaName , 
						    TableName, 
						    IndexName, 
						    PartitionColumn_Desired, 
						    Storage_Desired
				    FROM DOI.IndexesRowStore
				    UNION ALL
				    SELECT	SchemaName , 
						    TableName , 
						    IndexName, 
						    PartitionColumn_Desired, 
						    Storage_Desired
				    FROM DOI.IndexesColumnStore) AllIdx
		    ON AllIdx.SchemaName = T.SchemaName
			    AND AllIdx.TableName = T.TableName
	    LEFT JOIN DOI.SysPartitionSchemes ps ON AllIdx.Storage_Desired = ps.name
    WHERE T.ReadyToQueue = 1
        AND (T.IntendToPartition = 1
		    AND (AllIdx.PartitionColumn_Desired = 'NONE'
				    OR ps.name IS NULL))
	    OR (T.IntendToPartition = 0
		    AND (AllIdx.PartitionColumn_Desired <> 'NONE'
				    OR ps.name IS NOT NULL))

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END   


    --NEED TO VALIDATE THAT THE PARTITION SCHEME NAMES ACTUALLY EXIST IN DB.
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Indexe(s) are intended to be partitioned but do not have the Partition Column in their Key Column List:  '

    SELECT @ObjectList += AllIdx.SchemaName + '.' + AllIdx.TableName + '.' + AllIdx.IndexName + ','
    FROM DOI.Tables T
	    INNER JOIN (SELECT DatabaseName, SchemaName, TableName, IndexName, KeyColumnList_Desired, PartitionColumn_Desired
				    FROM DOI.IndexesRowStore IRS
				    UNION ALL
				    SELECT DatabaseName, SchemaName, TableName, IndexName, ColumnList_Desired, PartitionColumn_Desired
				    FROM DOI.IndexesColumnStore ICS) AllIdx
		    ON AllIdx.SchemaName = T.SchemaName
			    AND AllIdx.TableName = T.TableName
    WHERE T.IntendToPartition = 1
	    --AND I.IsUnique = 1
	    AND NOT EXISTS (SELECT 'True'
                        FROM DOI.IndexColumns IC 
                        WHERE IC.DatabaseName = AllIdx.DatabaseName
                            AND IC.SchemaName = AllIdx.SchemaName
                            AND IC.TableName = AllIdx.TableName
                            AND IC.IndexName = AllIdx.IndexName
                            AND IC.IsKeyColumn = 1
                            AND IC.ColumnName = AllIdx.PartitionColumn_Desired) --partitioning column is NOT in the indexkey column.

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END   

    --mismatch of storage setting between index and its parent table.
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Indexe(s) do not match the storage of their parent table:  ' 

    SELECT @ObjectList += AllIdx.SchemaName + '.' + AllIdx.TableName + '.' + AllIdx.IndexName + ','
    FROM DOI.Tables T
	    INNER JOIN (SELECT SchemaName, TableName, IndexName, Storage_Desired
				    FROM DOI.IndexesRowStore IRS
				    UNION ALL
				    SELECT SchemaName, TableName, IndexName, Storage_Desired
				    FROM DOI.IndexesColumnStore ICS) AllIdx
		    ON AllIdx.SchemaName = T.SchemaName
			    AND AllIdx.TableName = T.TableName
    WHERE AllIdx.Storage_Desired <> t.Storage_Desired

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END   

    --mismatch of compression setting between index and its partitions
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Index Partition(s) do not match the compression setting of their parent index:  ' 

    SELECT @ObjectList += AllIdx.SchemaName + '.' + AllIdx.TableName + '.' + AllIdx.IndexName + '__' + CAST(AllIP.PartitionNumber AS VARCHAR(5)) + ','
    FROM (	SELECT SchemaName, TableName, IndexName, OptionDataCompression_Desired
		    FROM DOI.IndexesRowStore IRS
		    UNION ALL
		    SELECT SchemaName, TableName, IndexName, OptionDataCompression_Desired
		    FROM DOI.IndexesColumnStore ICS) AllIdx
	    INNER JOIN (SELECT SchemaName, TableName, IndexName, PartitionNumber, OptionDataCompression
				    FROM DOI.IndexPartitionsRowStore IRS
				    UNION ALL
				    SELECT SchemaName, TableName, IndexName, PartitionNumber, OptionDataCompression
				    FROM DOI.IndexPartitionsColumnStore ICS) AllIP 
		    ON AllIdx.SchemaName = AllIP.SchemaName 
			    AND AllIdx.TableName = AllIP.TableName 
			    AND AllIdx.IndexName = AllIP.IndexName 
    WHERE AllIdx.OptionDataCompression_Desired <> AllIP.OptionDataCompression

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END  

    --mismatch of Incremental setting for Statistic and partition setting for its parent table.
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Statistic(s) have "Incremental" settings that do not match their parent table:  ' 

    SELECT @ObjectList += STM.StatisticsName + ','
    FROM DOI.[Statistics] STM
        INNER JOIN DOI.Tables T ON T.SchemaName = STM.SchemaName
            AND T.TableName = STM.TableName
    WHERE (STM.IsIncremental_Desired = 1 AND T.IntendToPartition = 0)
        OR (STM.IsIncremental_Desired = 0 AND T.IntendToPartition = 1)

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END  

    --incremental statistics with index not incremental
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Statistic(s) have "Incremental" settings that do not match their parent index:  ' 

    SELECT @StatisticsIncrementalNotAlignedWithIndex += STM.StatisticsName + ','
    FROM DOI.[Statistics] STM
        INNER JOIN DOI.IndexesRowStore IRS ON IRS.SchemaName = STM.SchemaName
            AND IRS.TableName = STM.TableName
            AND IRS.IndexName = STM.StatisticsName
    WHERE (STM.IsIncremental_Desired = 1 AND irs.OptionStatisticsIncremental_Desired = 0)
        OR (STM.IsIncremental_Desired = 0 AND irs.OptionStatisticsIncremental_Desired = 1)

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END  

    --Invalid Table Names   
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Table name(s) are invalid:  ' 

    SELECT @ObjectList += AllIdx.SchemaName + '.' + AllIdx.TableName + ','
    FROM  (	SELECT DatabaseName, SchemaName, TableName 
		    FROM DOI.IndexesRowStore 
		    UNION ALL
		    SELECT DatabaseName, SchemaName, TableName
		    FROM DOI.IndexesColumnStore) AllIdx
    WHERE NOT EXISTS(	SELECT 'True' 
					    FROM DOI.SysSchemas s 
						    INNER JOIN DOI.SysTables t ON s.database_id = t.database_id
                                AND t.schema_id = s.schema_id 
                            INNER JOIN DOI.SysDatabases d ON d.database_id = t.database_id
					    WHERE d.name = AllIdx.DatabaseName
                            AND s.name = AllIdx.SchemaName 
						    AND t.name = AllIdx.TableName)

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END   
	
    --Invalid Key Column Names
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Index Column name(s) are invalid:  ' 

    SELECT @ObjectList += AllIdx.SchemaName + '.' + AllIdx.TableName + '.' + IC.ColumnName + ','
    FROM  (	SELECT DatabaseName, SchemaName, TableName, KeyColumnList_Desired
		    FROM DOI.IndexesRowStore 
		    UNION ALL
		    SELECT DatabaseName, SchemaName, TableName, ColumnList_Desired
		    FROM DOI.IndexesColumnStore) AllIdx
        INNER JOIN DOI.IndexColumns IC ON IC.DatabaseName = AllIdx.DatabaseName
            AND IC.SchemaName = AllIdx.SchemaName
            AND IC.TableName = AllIdx.TableName
    WHERE NOT EXISTS(	SELECT 'True' 
					    FROM DOI.SysSchemas s 
						    INNER JOIN DOI.SysTables t ON s.database_id = t.database_id
                                AND t.schema_id = s.schema_id 
                            INNER JOIN DOI.SysDatabases d ON d.database_id = t.database_id
						    INNER JOIN DOI.SysColumns c ON c.database_id = t.database_id
                                AND c.object_id = t.object_id
					    WHERE d.name = AllIdx.DatabaseName
                            AND s.name = AllIdx.SchemaName
						    AND t.name = AllIdx.TableName
						    AND c.name = IC.ColumnName)

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END   

    --VALIDATE THAT PARTITION COLUMN NAMES ARE VALID.
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Partition Column name(s) are invalid:  ' 

    SELECT @ObjectList += AllIdx.SchemaName + '.' + AllIdx.TableName + '.' + AllIdx.PartitionColumn_Desired + ','
    FROM (	SELECT DatabaseName, SchemaName, TableName, KeyColumnList_Desired, PartitionColumn_Desired
		    FROM DOI.IndexesRowStore 
		    UNION ALL
		    SELECT DatabaseName, SchemaName, TableName, ColumnList_Desired, PartitionColumn_Desired
		    FROM DOI.IndexesColumnStore) AllIdx
    WHERE NOT EXISTS(	SELECT 'True' 
					    FROM DOI.SysSchemas s 
						    INNER JOIN DOI.SysTables t ON s.database_id = t.database_id
                                AND t.schema_id = s.schema_id 
                            INNER JOIN DOI.SysDatabases d ON d.database_id = t.database_id
						    INNER JOIN DOI.SysColumns c ON c.database_id = t.database_id
                                AND c.object_id = t.object_id
					    WHERE d.name = AllIdx.DatabaseName
                            AND s.name = AllIdx.SchemaName
						    AND t.name = AllIdx.TableName)

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END 

    --No UpdatedUtcDt column on a table about to be partitioned.
    SET @ObjectList = ''
    SET @ErrorMessage = 'The Following Table(s) do NOT have the UpdatedUtc column.  This column is REQUIRED for partitioning:  ' 

    SELECT @ObjectList += T.SchemaName + '.' + T.TableName + ','
    FROM DOI.Tables T
    WHERE T.IntendToPartition = 1
	    AND NOT EXISTS (SELECT 'True' 
					    FROM DOI.SysColumns c 
                            INNER JOIN DOI.SysTables TS ON TS.database_id = c.database_id
                                AND TS.object_id = c.object_id
                            INNER JOIN DOI.SysDatabases d ON d.database_id = TS.database_id
					    WHERE d.name = T.DatabaseName
                            AND TS.NAME = t.TableName
						    AND c.name = 'UpdatedUtcDt')

    IF @ObjectList <> ''
    BEGIN
        SET @ErrorMessage += @ObjectList
	    ;THROW 50000 , @ErrorMessage, 1;
    END
END    
GO