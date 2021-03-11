
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

AS

UPDATE IRSP
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
    INNER JOIN DOI.IndexPartitionsRowStore IRSP ON IRSP.DatabaseName = D.name
        AND IRSP.SchemaName = s.name
        AND IRSP.TableName = t.name
        AND IRSP.IndexName = i.name
        AND IRSP.PartitionNumber = IPS.partition_number
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
		AND p.partition_number = IRSP.PartitionNumber
        AND p.hobt_id = au.container_id
WHERE IRSP.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRSP.DatabaseName ELSE @DatabaseName END 


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
FROM DOI.IndexPartitionsRowStore IRSP
WHERE IRSP.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRSP.DatabaseName ELSE @DatabaseName END 

UPDATE IRSP
SET IsMissingFromSQLServer = PFP.IsPartitionMissing
FROM DOI.IndexPartitionsRowStore IRSP
    INNER JOIN DOI.IndexesRowStore IRS ON IRSP.DatabaseName = IRS.DatabaseName
        AND IRSP.SchemaName = IRS.SchemaName
        AND IRSP.TableName = IRS.TableName
        AND IRSP.IndexName = IRS.IndexName
    INNER JOIN DOI.vwPartitionFunctionPartitions PFP ON PFP.DatabaseName = IRS.DatabaseName
        AND PFP.PartitionFunctionName = IRS.PartitionFunction_Actual
        AND PFP.PartitionNumber = IRSP.PartitionNumber
WHERE IRSP.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRSP.DatabaseName ELSE @DatabaseName END 

UPDATE IRS
SET TotalPartitionsInIndex = IRSP.TotalPartitionsInIndex,
    NeedsPartitionLevelOperations = IRSP.NeedsPartitionLevelOperations
FROM DOI.IndexesRowStore IRS
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
                FROM DOI.IndexPartitionsRowStore
                GROUP BY DatabaseName, SchemaName, TableName, IndexName) IRSP
        ON IRSP.DatabaseName = IRS.DatabaseName
            AND IRSP.SchemaName = IRS.SchemaName
            AND IRSP.TableName = IRS.TableName
            AND IRSP.IndexName = IRS.IndexName
WHERE IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END 

GO