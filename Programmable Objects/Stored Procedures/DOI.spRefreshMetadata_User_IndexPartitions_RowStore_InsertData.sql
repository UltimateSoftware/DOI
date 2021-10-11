
IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData]
	@DatabaseName SYSNAME = NULL

AS

--DELETE DOI.IndexPartitionsRowStore
--WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END --this wipes out user updates....need a better solution.

INSERT INTO DOI.IndexPartitionsRowStore (DatabaseName, SchemaName,TableName,IndexName,PartitionNumber)
SELECT IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber
FROM DOI.IndexesRowStore IRS
    INNER JOIN DOI.vwPartitionFunctionPartitions P ON IRS.Storage_Desired = P.PartitionSchemeName
WHERE IRS.StorageType_Desired = 'PARTITION_SCHEME'
	AND IRS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IRS.DatabaseName ELSE @DatabaseName END
	AND NOT EXISTS (SELECT 'True'
					FROM DOI.IndexPartitionsRowStore IPRS
					WHERE IPRS.DatabaseName = IRS.DatabaseName
						AND IPRS.SchemaName = IRS.SchemaName
						AND IPRS.TableName = IRS.TableName
						AND IPRS.IndexName = IRS.IndexName
						AND IPRS.PartitionNumber = P.PartitionNumber)
ORDER BY IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber


GO