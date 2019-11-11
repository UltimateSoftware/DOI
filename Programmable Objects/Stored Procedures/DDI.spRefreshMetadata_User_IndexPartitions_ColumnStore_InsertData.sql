IF OBJECT_ID('[DDI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData]

AS

DELETE DDI.IndexColumnStorePartitions

INSERT INTO DDI.IndexColumnStorePartitions 
(		DatabaseName,	SchemaName	,TableName			,IndexName									,PartitionNumber	,OptionDataCompression )
SELECT IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber, 'COLUMNSTORE'
FROM DDI.IndexesColumnStore IRS
    INNER JOIN DDI.vwPartitionFunctionPartitions P ON IRS.Storage_Desired = P.PartitionSchemeName
WHERE IRS.StorageType_Desired = 'PARTITION_SCHEME'

GO
