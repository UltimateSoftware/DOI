
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData]

AS

DELETE DOI.IndexPartitionsRowStore

INSERT INTO DOI.IndexPartitionsRowStore (DatabaseName, SchemaName,TableName,IndexName,PartitionNumber)

SELECT IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber
FROM DOI.IndexesRowStore IRS
    INNER JOIN DOI.vwPartitionFunctionPartitions P ON IRS.Storage_Desired = P.PartitionSchemeName
WHERE IRS.StorageType_Desired = 'PARTITION_SCHEME'
ORDER BY IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber


GO
