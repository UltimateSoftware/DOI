USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData]

AS

DELETE DOI.IndexColumnStorePartitions

INSERT INTO DOI.IndexColumnStorePartitions 
(		DatabaseName,	SchemaName	,TableName			,IndexName									,PartitionNumber	,OptionDataCompression )
SELECT IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber, 'COLUMNSTORE'
FROM DOI.IndexesColumnStore IRS
    INNER JOIN DOI.vwPartitionFunctionPartitions P ON IRS.Storage_Desired = P.PartitionSchemeName
WHERE IRS.StorageType_Desired = 'PARTITION_SCHEME'

GO
