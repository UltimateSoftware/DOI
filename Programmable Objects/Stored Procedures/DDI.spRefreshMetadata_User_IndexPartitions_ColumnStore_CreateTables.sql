IF OBJECT_ID('[DDI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_CreateTables]

AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'IndexColumnStorePartitions',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DDI.IndexColumnStorePartitions

CREATE TABLE DDI.IndexColumnStorePartitions (
    DatabaseName                NVARCHAR(128) NOT NULL,
	SchemaName					NVARCHAR(128) NOT NULL,
	TableName					NVARCHAR(128) NOT NULL,
	IndexName					NVARCHAR(128) NOT NULL,
	PartitionNumber				SMALLINT NOT NULL,
	OptionDataCompression		NVARCHAR(60) NOT NULL --solves collation conflict with sys.partitions column.
		CONSTRAINT Chk_IndexColumnStorePartitions_OptionDataCompression
			CHECK (OptionDataCompression IN ('COLUMNSTORE', 'COLUMNSTORE_ARCHIVE'))
		CONSTRAINT Def_IndexColumnStorePartitions_OptionDataCompression
			DEFAULT('COLUMNSTORE'),

	CONSTRAINT PK_IndexColumnStorePartitions
		PRIMARY KEY NONCLUSTERED (SchemaName, TableName, IndexName, PartitionNumber),
    CONSTRAINT FK_IndexColumnStorePartitions_IndexesColumnStore
        FOREIGN KEY(DatabaseName, SchemaName, TableName, IndexName)
            REFERENCES DDI.IndexesColumnStore(DatabaseName, SchemaName, TableName, IndexName))

    WITH (MEMORY_OPTIMIZED = ON)

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL
GO
