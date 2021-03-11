
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

AS

UPDATE ICSP
SET Fragmentation = IPS.avg_fragmentation_in_percent,
    NumRows = p.rows,
    TotalPages = au.total_pages,
    DataFileName = df.physical_name,
    DriveLetter = LEFT(df.physical_name, 1),
    TotalIndexPartitionSizeInMB = (au.total_pages * 8) / 1024.00
FROM DOI.SysIndexPhysicalStats IPS
    INNER JOIN DOI.SysDatabases d ON d.database_id = IPS.database_id
    INNER JOIN DOI.SysTables t ON t.database_id = d.database_id
        AND IPS.object_id = t.object_id
    INNER JOIN DOI.SysSchemas s ON t.database_id = s.database_id
        AND t.schema_id = s.schema_id
    INNER JOIN DOI.SysIndexes i ON i.database_id = d.database_id
        AND i.object_id = t.object_id
        AND IPS.index_id = i.index_id
    INNER JOIN DOI.IndexPartitionsColumnStore ICSP ON ICSP.DatabaseName = D.name
        AND ICSP.SchemaName = s.name
        AND ICSP.TableName = t.name
        AND ICSP.IndexName = i.name
        AND ICSP.PartitionNumber = IPS.partition_number
	INNER JOIN DOI.SysPartitionSchemes ps ON i.database_id = ps.database_id
        AND i.data_space_id = ps.data_space_id
	INNER JOIN DOI.SysDestinationDataSpaces dds ON ps.database_id = dds.database_id
        AND ps.data_space_id = dds.partition_scheme_id
	INNER JOIN DOI.SysDataSpaces ds ON ds.database_id = dds.database_id
        AND ds.data_space_id = dds.data_space_id
	INNER JOIN DOI.SysAllocationUnits au ON au.database_id = dds.database_id
        AND au.data_space_id = dds.data_space_id
	INNER JOIN DOI.SysDatabaseFiles df ON df.database_id = dds.database_id
        AND df.data_space_id = dds.data_space_id
    INNER JOIN DOI.SysPartitions p ON p.database_id = d.database_id
        AND p.object_id = t.object_id
		AND p.index_id = i.index_id
		AND p.partition_number = ICSP.PartitionNumber
        AND p.hobt_id = au.container_id
WHERE ICSP.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICSP.DatabaseName ELSE @DatabaseName END 


UPDATE ICSP
SET PartitionUpdateType =   CASE
			                    WHEN Fragmentation > 30
				                    OR OptionDataCompression <> OptionDataCompression --certain options or frag over 30%.
			                    THEN 'AlterRebuild-PartitionLevel' --can be done on a partition level
			                    WHEN (OptionDataCompression = OptionDataCompression)--NO OPTIONS CHANGES, 5-30% frag, needs LOB compaction
				                    AND Fragmentation BETWEEN 5 AND 30
			                    THEN 'AlterReorganize-PartitionLevel' --this always happens online, can be done on a partition level
			                    ELSE 'None'
                    		END
FROM DOI.IndexPartitionsColumnStore ICSP
WHERE ICSP.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICSP.DatabaseName ELSE @DatabaseName END 

UPDATE ICSP
SET IsMissingFromSQLServer = PFP.IsPartitionMissing
FROM DOI.IndexPartitionsColumnStore ICSP
    INNER JOIN DOI.IndexesColumnStore ICS ON ICSP.DatabaseName = ICS.DatabaseName
        AND ICSP.SchemaName = ICS.SchemaName
        AND ICSP.TableName = ICS.TableName
        AND ICSP.IndexName = ICS.IndexName
    INNER JOIN DOI.vwPartitionFunctionPartitions PFP ON PFP.DatabaseName = ICS.DatabaseName
        AND PFP.PartitionFunctionName = ICS.PartitionFunction_Actual
        AND PFP.PartitionNumber = ICSP.PartitionNumber
WHERE ICSP.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICSP.DatabaseName ELSE @DatabaseName END 

UPDATE ICS
SET TotalPartitionsInIndex = ICSP.TotalPartitionsInIndex,
    NeedsPartitionLevelOperations = ICSP.NeedsPartitionLevelOperations
FROM DOI.IndexesColumnStore ICS
    INNER JOIN (SELECT	DatabaseName,
                        SchemaName,
		                TableName,
		                IndexName, 
                        MAX(PartitionNumber) AS TotalPartitionsInIndex, 
			            CASE 
				            WHEN MIN(PartitionUpdateType) <> MAX(PartitionUpdateType)
				            THEN 1 
				            ELSE 0
			            END NeedsPartitionLevelOperations
                --select count(*)
                FROM DOI.IndexPartitionsColumnStore
                GROUP BY DatabaseName, SchemaName, TableName, IndexName) ICSP
        ON ICSP.DatabaseName = ICS.DatabaseName
            AND ICSP.SchemaName = ICS.SchemaName
            AND ICSP.TableName = ICS.TableName
            AND ICSP.IndexName = ICS.IndexName
WHERE ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END 

GO
