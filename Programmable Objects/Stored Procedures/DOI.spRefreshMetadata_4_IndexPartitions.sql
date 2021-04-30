

IF OBJECT_ID('[DOI].[spRefreshMetadata_4_IndexPartitions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_4_IndexPartitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_4_IndexPartitions]
    @DatabaseName NVARCHAR(128) = NULL
AS


	EXEC DOI.spRefreshMetadata_3_Indexes
		@DatabaseName = @DatabaseName

	--for indexpartitions insert SPs:  IndexesRowStore, IndexesColumnStore, SysDatabaseFiles, SysPartitionSchemes, SysDestinationDataSpaces, SysDatabases:  
	--for IndexPartition update SPs:  SysDatabases, SysDatabaseFiles, SysPartitionSchemes, SysDestinationDataSpaces, SysDataSpaces, SysIndexes, SysPartitions, SysAllocationUnits, SysSchemas, SysTables, SysIndexPhysicalStats.

	EXEC [spRefreshMetadata_User_IndexPartitions_RowStore_InsertData]
		@DatabaseName = @DatabaseName
	EXEC [spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData]
		@DatabaseName = @DatabaseName
	EXEC [spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData]
		@DatabaseName = @DatabaseName
	EXEC [spRefreshMetadata_User_IndexPartitions_ColumnStore_UpdateData]
		@DatabaseName = @DatabaseName

GO