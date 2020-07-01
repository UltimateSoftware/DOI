IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexesColumnStore_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexesColumnStore_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexesColumnStore_CreateTables]

AS
--EXEC DOI.spForeignKeysDrop 
--    @ForMetadataTablesOnly = 1,
--    @ReferencedSchemaName = 'DOI',
--	@ReferencedTableName	= 'IndexesColumnStore'
--GO

    DECLARE @DropSQL VARCHAR(MAX) = '',
            @RecreateSQL VARCHAR(MAX) = ''

    EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
        @SchemaName = 'DOI',
        @TableName = 'IndexesColumnStore',
        @DropSQL = @DropSQL OUTPUT,
        @RecreateSQL = @RecreateSQL OUTPUT

    EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

    IF OBJECT_ID('DOI.FK_IndexColumns_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DOI.IndexColumnStorePartitions DROP CONSTRAINT FK_IndexColumnStorePartitions_IndexesColumnStore
    END

    DROP TABLE IF EXISTS DOI.IndexesColumnStore


	CREATE TABLE DOI.IndexesColumnStore (
        DatabaseName			                                                NVARCHAR(128)   NOT NULL,
		SchemaName				                                                NVARCHAR(128)   NOT NULL,
		TableName				                                                NVARCHAR(128)   NOT NULL,
		IndexName				                                                NVARCHAR(128)   NOT NULL,
        IsIndexMissingFromSQLServer                                             BIT NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IsIndexMissingFromSQLServer
				DEFAULT(0),
		IsClustered_Desired				                                        BIT             NOT NULL,
		IsClustered_Actual				                                        BIT             NULL,
        ColumnList_Desired                                                      NVARCHAR(MAX)   NULL,
        ColumnList_Actual                                                       NVARCHAR(MAX)   NULL,
		IsFiltered_Desired				                                        BIT             NOT NULL,
		IsFiltered_Actual				                                        BIT             NULL,
		FilterPredicate_Desired			                                        VARCHAR(MAX)    NULL,
		FilterPredicate_Actual			                                        VARCHAR(MAX)    NULL,
		OptionDataCompression_Desired	                                        VARCHAR(30)     NOT NULL --solves collation conflict with sys.partitions column.
			CONSTRAINT Chk_IndexesColumnStore_OptionDataCompression
				CHECK (OptionDataCompression_Desired IN ('COLUMNSTORE', 'COLUMNSTORE_ARCHIVE'))
			CONSTRAINT Def_IndexesColumnStore_OptionDataCompression
				DEFAULT ('COLUMNSTORE'),
		OptionDataCompression_Actual	                                        VARCHAR(30)     NULL, --solves collation conflict with sys.partitions column.
		OptionDataCompressionDelay_Desired	                                    INT             NOT NULL,
		OptionDataCompressionDelay_Actual	                                    INT             NULL,
		Storage_Desired				                                            NVARCHAR(128)   NOT NULL,
		Storage_Actual				                                            NVARCHAR(128)   NULL,
        StorageType_Desired                                                     NVARCHAR(120)   NULL
			CONSTRAINT Def_IndexesColumnStore_StorageType_Desired
				CHECK(StorageType_Desired IN ('ROWS_FILEGROUP', 'PARTITION_SCHEME')),
        StorageType_Actual                                                      NVARCHAR(120)   NULL
			CONSTRAINT Def_IndexesColumnStore_StorageType_Actual
				CHECK(StorageType_Actual IN ('ROWS_FILEGROUP', 'PARTITION_SCHEME')),
        PartitionFunction_Desired                                               NVARCHAR(128)   NULL,
        PartitionFunction_Actual                                                NVARCHAR(128)   NULL,
		PartitionColumn_Desired				                                    NVARCHAR(128)   NULL,
		PartitionColumn_Actual				                                    NVARCHAR(128)   NULL,
        AllColsInTableSize_Estimated                                            INT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_AllColsInTableSize_Estimated
                DEFAULT (0),
        NumFixedCols_Estimated                                                  SMALLINT        NOT NULL
            CONSTRAINT Def_IndexesColumnStore_NumFixedCols_Estimated
                DEFAULT (0),
        NumVarCols_Estimated                                                    SMALLINT        NOT NULL
            CONSTRAINT Def_IndexesColumnStore_NumVarCols_Estimated
                DEFAULT (0),
        NumCols_Estimated                                                       SMALLINT        NOT NULL
            CONSTRAINT Def_IndexesColumnStore_NumCols_Estimated
                DEFAULT (0),
        FixedColsSize_Estimated                                                 INT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_FixedColsSize_Estimated
                DEFAULT (0),
        VarColsSize_Estimated                                                   INT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_VarColsSize_Estimated
                DEFAULT (0),
        ColsSize_Estimated                                                      INT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_ColsSize_Estimated
                DEFAULT (0),
        NumRows_Actual                                                          BIGINT          NOT NULL
            CONSTRAINT Def_IndexesColumnStore_NumRows_Actual
                DEFAULT (0),
        IndexSizeMB_Actual                                                      DECIMAL(10,2)   NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IndexSizeMB_Actual
                DEFAULT (0),
        DriveLetter                                                             CHAR(1)         NULL,
        IsIndexLarge                                                            BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IsIndexLarge
                DEFAULT (0),
        IndexMeetsMinimumSize                                                   BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IndexMeetsMinimumSize
                DEFAULT (0),
        Fragmentation                                                           FLOAT           NOT NULL
            CONSTRAINT Def_IndexesColumnStore_Fragmentation
                DEFAULT (0),
        FragmentationType                                                       VARCHAR(5)      NOT NULL
            CONSTRAINT Chk_IndexesColumnStore_FragmentationType
                CHECK (FragmentationType IN ('None', 'Light', 'Heavy'))
            CONSTRAINT Def_IndexesColumnStore_FragmentationType
                DEFAULT ('None'),
        AreDropRecreateOptionsChanging                                          BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_AreDropRecreateOptionsChanging
                DEFAULT (0),
        AreRebuildOptionsChanging                                               BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_AreRebuildOptionsChanging
                DEFAULT (0),
        AreRebuildOnlyOptionsChanging                                           BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_AreRebuildOnlyOptionsChanging
                DEFAULT (0),
        AreReorgOptionsChanging                                                 BIT             NOT NULL
            CONSTRAINT Chk_IndexesColumnStore_AreReorgOptionsChanging
                CHECK (AreReorgOptionsChanging = 0)
            CONSTRAINT Def_IndexesColumnStore_AreReorgOptionsChanging
                DEFAULT (0),
        AreSetOptionsChanging                                                   BIT             NOT NULL
            CONSTRAINT Chk_IndexesColumnStore_AreSetOptionsChanging
                CHECK (AreSetOptionsChanging = 0)
            CONSTRAINT Def_IndexesColumnStore_AreSetOptionsChanging
                DEFAULT (0),
        IsColumnListChanging                                                    BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IsColumnListChanging
                DEFAULT (0),
        IsFilterChanging                                                        BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IsFilterChanging
                DEFAULT (0),
        IsClusteredChanging                                                     BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IsClusteredChanging
                DEFAULT (0),
        IsPartitioningChanging                                                  BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IsPartitioningChanging
                DEFAULT (0),
        IsDataCompressionChanging                                               BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IsDataCompressionChanging
                DEFAULT (0),
        IsDataCompressionDelayChanging                                          BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IsDataCompressionDelayChanging
                DEFAULT (0),
        IsStorageChanging                                                       BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_IsStorageChanging
                DEFAULT (0),
        NumPages_Actual                                                         INT             NULL
            CONSTRAINT Def_IndexesColumnStore_NumPages_Actual
                DEFAULT (0),
        TotalPartitionsInIndex                                                  INT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_TotalPartitionsInIndex
                DEFAULT (0),
        NeedsPartitionLevelOperations                                           BIT             NOT NULL
            CONSTRAINT Def_IndexesColumnStore_NeedsPartitionLevelOperations
                DEFAULT (0),
                
		CONSTRAINT PK_IndexesColumnStore
			PRIMARY KEY NONCLUSTERED (DatabaseName, SchemaName, TableName, IndexName),
		CONSTRAINT Chk_IndexesColumnStore_Filter
			CHECK ((IsFiltered_Desired = 1 AND FilterPredicate_Desired IS NOT NULL AND IsClustered_Desired = 0)
						OR (IsFiltered_Desired = 0 AND FilterPredicate_Desired IS NULL)),
        CONSTRAINT FK_IndexesColumnStore_Tables
            FOREIGN KEY (DatabaseName, SchemaName, TableName)
                REFERENCES DOI.Tables(DatabaseName, SchemaName, TableName))

    WITH (MEMORY_OPTIMIZED = ON)

    IF OBJECT_ID('DOI.IndexColumnStorePartitions', 'U') IS NOT NULL
        AND OBJECT_ID('DOI.FK_IndexColumnStorePartitions_IndexesColumnStore', 'F') IS NULL
    BEGIN
        ALTER TABLE [DOI].[IndexColumnStorePartitions] ADD 
            CONSTRAINT FK_IndexColumnStorePartitions_IndexesColumnStore
                FOREIGN KEY(DatabaseName, SchemaName, TableName, IndexName)
                    REFERENCES DOI.IndexesColumnStore(DatabaseName, SchemaName, TableName, IndexName)    
    END;    

    EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL
GO
