IF OBJECT_ID('[DDI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData]

AS

DELETE DDI.IndexRowStorePartitions

INSERT INTO DDI.IndexRowStorePartitions (DatabaseName, SchemaName,TableName,IndexName,PartitionNumber)

SELECT IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber
FROM DDI.IndexesRowStore IRS
    INNER JOIN DDI.vwPartitionFunctionPartitions P ON IRS.Storage_Desired = P.PartitionSchemeName
WHERE IRS.StorageType_Desired = 'PARTITION_SCHEME'
ORDER BY IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber
--INSERT INTO DDI.IndexColumnStorePartitions 
--(			SchemaName	,TableName			,IndexName									,PartitionNumber	,OptionDataCompression )
--SELECT IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber, 'DEFAULT', 'DEFAULT', 'DEFAULT'
--FROM DDI.IndexesColumnStore IRS
--    INNER JOIN DDI.vwPartitionFunctionPartitions P ON IRS.Storage_Desired = P.PartitionSchemeName
--WHERE IRS.StorageType_Desired = 'PARTITION_SCHEME'

GO
