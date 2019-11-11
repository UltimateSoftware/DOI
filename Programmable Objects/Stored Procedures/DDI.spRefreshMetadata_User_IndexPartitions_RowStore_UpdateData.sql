IF OBJECT_ID('[DDI].[spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData]

AS

UPDATE IRSP
SET Fragmentation = IPS.avg_fragmentation_in_percent,
    NumRows = p.rows,
    TotalPages = au.total_pages,
    DataFileName = df.physical_name,
    DriveLetter = LEFT(df.physical_name, 1),
    TotalIndexPartitionSizeInMB = (au.total_pages * 8) / 1024.00
FROM DDI.SysIndexPhysicalStats IPS
    INNER JOIN DDI.SysDatabases d ON d.database_id = IPS.database_id
    INNER JOIN DDI.SysTables t ON t.database_id = d.database_id
        AND IPS.object_id = t.object_id
    INNER JOIN DDI.SysSchemas s ON t.schema_id = s.schema_id
    INNER JOIN DDI.SysIndexes i ON i.database_id = d.database_id
        AND i.object_id = t.object_id
        AND IPS.index_id = i.index_id
    INNER JOIN DDI.IndexRowStorePartitions IRSP ON IRSP.DatabaseName = D.name
        AND IRSP.SchemaName = s.name
        AND IRSP.TableName = t.name
        AND IRSP.IndexName = i.name
        AND IRSP.PartitionNumber = IPS.partition_number
	INNER JOIN DDI.SysPartitionSchemes ps ON i.data_space_id = ps.data_space_id
	INNER JOIN DDI.SysDestinationDataSpaces dds ON ps.data_space_id = dds.partition_scheme_id
	INNER JOIN DDI.SysDataSpaces ds ON ds.data_space_id = dds.data_space_id
	INNER JOIN DDI.SysAllocationUnits au ON au.data_space_id = dds.data_space_id
	INNER JOIN DDI.SysDatabaseFiles df ON df.data_space_id = dds.data_space_id
    INNER JOIN DDI.SysPartitions p ON p.database_id = d.database_id
        AND p.object_id = t.object_id
		AND p.index_id = i.index_id
		AND p.partition_number = IRSP.PartitionNumber
        AND p.hobt_id = au.container_id


UPDATE IRSP
SET PartitionUpdateType =   CASE
			                    WHEN Fragmentation > 30
				                    OR OptionDataCompression <> OptionDataCompression --certain options or frag over 30%.
			                    THEN 'AlterRebuild-PartitionLevel' --can be done on a partition level
			                    WHEN (OptionDataCompression = OptionDataCompression)--NO OPTIONS CHANGES, 5-30% frag, needs LOB compaction
				                    AND Fragmentation BETWEEN 5 AND 30
			                    THEN 'AlterReorganize-PartitionLevel' --this always happens online, can be done on a partition level
			                    ELSE 'None'
                    		END
FROM DDI.IndexRowStorePartitions IRSP


UPDATE IRS
SET TotalPartitionsInIndex = IRSP.TotalPartitionsInIndex,
    NeedsPartitionLevelOperations = IRSP.NeedsPartitionLevelOperations
FROM DDI.IndexesRowStore IRS
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
                FROM DDI.IndexRowStorePartitions
                GROUP BY DatabaseName, SchemaName, TableName, IndexName) IRSP
        ON IRSP.DatabaseName = IRS.DatabaseName
            AND IRSP.SchemaName = IRS.SchemaName
            AND IRSP.TableName = IRS.TableName
            AND IRSP.IndexName = IRS.IndexName

GO
