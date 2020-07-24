
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_CreateTables]

AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'IndexRowStorePartitions',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL
DROP TABLE IF EXISTS DOI.IndexRowStorePartitions


CREATE TABLE DOI.IndexRowStorePartitions (
    DatabaseName                NVARCHAR(128) NOT NULL,
	SchemaName					NVARCHAR(128) NOT NULL,
	TableName					NVARCHAR(128) NOT NULL,
	IndexName					NVARCHAR(128) NOT NULL,
	PartitionNumber				SMALLINT NOT NULL,
	OptionResumable				BIT NOT NULL
		CONSTRAINT Def_IndexRowStorePartitions_OptionResumable
			DEFAULT(0),
	OptionMaxDuration			SMALLINT NOT NULL
		CONSTRAINT Def_IndexRowStorePartitions_OptionMaxDuration
			DEFAULT(0),
	OptionDataCompression		NVARCHAR(60) NOT NULL
		CONSTRAINT Chk_IndexRowStorePartitions_OptionDataCompression
			CHECK (OptionDataCompression IN ('NONE', 'ROW', 'PAGE'))
		CONSTRAINT Def_IndexRowStorePartitions_OptionDataCompression
			DEFAULT('PAGE'),
    NumRows                     BIGINT NOT NULL
		CONSTRAINT Def_IndexRowStorePartitions_NumRows
			DEFAULT(0),
    TotalPages                  BIGINT NOT NULL
		CONSTRAINT Def_IndexRowStorePartitions_TotalPages
			DEFAULT(0),
    PartitionType               VARCHAR(20) NOT NULL
        CONSTRAINT Chk_IndexRowStorePartitions_PartitionType
            CHECK (PartitionType = 'RowStore')
		CONSTRAINT Def_IndexRowStorePartitions_PartitionType
			DEFAULT('RowStore'),
    TotalIndexPartitionSizeInMB DECIMAL(10,2) NOT NULL
		CONSTRAINT Def_IndexRowStorePartitions_TotalIndexPartitionSizeInMB
			DEFAULT(0.00),
    Fragmentation               FLOAT NOT NULL
		CONSTRAINT Def_IndexRowStorePartitions_Fragmentation
			DEFAULT(0),
    DataFileName                NVARCHAR(260) NOT NULL
		CONSTRAINT Def_IndexRowStorePartitions_DataFileName
			DEFAULT(''),
    DriveLetter                 CHAR(1) NOT NULL
		CONSTRAINT Def_IndexRowStorePartitions_DriveLetter
			DEFAULT(''),
    PartitionUpdateType         VARCHAR(30) NOT NULL
		CONSTRAINT Def_IndexRowStorePartitions_PartitionUpdateType
			DEFAULT('None'),

	CONSTRAINT PK_IndexRowStorePartitions
		PRIMARY KEY NONCLUSTERED (DatabaseName, SchemaName, TableName, IndexName, PartitionNumber),
    CONSTRAINT FK_IndexRowStorePartitions_IndexesRowStore
        FOREIGN KEY(DatabaseName, SchemaName, TableName, IndexName)
            REFERENCES DOI.IndexesRowStore(DatabaseName, SchemaName, TableName, IndexName))

WITH (MEMORY_OPTIMIZED = ON)

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL

GO
