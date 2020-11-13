
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData]
	@DatabaseName SYSNAME = NULL

AS

DELETE DOI.IndexPartitionsColumnStore
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END

INSERT INTO DOI.IndexPartitionsColumnStore 
(		DatabaseName,	SchemaName	,TableName			,IndexName									,PartitionNumber	,OptionDataCompression )
SELECT ICS.DatabaseName, ICS.SchemaName, ICS.TableName, ICS.IndexName, P.PartitionNumber, 'COLUMNSTORE'
FROM DOI.IndexesColumnStore ICS
    INNER JOIN DOI.vwPartitionFunctionPartitions P ON ICS.Storage_Desired = P.PartitionSchemeName
WHERE ICS.StorageType_Desired = 'PARTITION_SCHEME'
	AND ICS.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN ICS.DatabaseName ELSE @DatabaseName END

GO
