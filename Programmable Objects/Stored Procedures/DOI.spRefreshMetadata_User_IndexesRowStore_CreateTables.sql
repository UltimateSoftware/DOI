
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexesRowStore_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexesRowStore_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexesRowStore_CreateTables]

AS
    DECLARE @DropSQL VARCHAR(MAX) = '',
            @RecreateSQL VARCHAR(MAX) = ''

    EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
        @SchemaName = 'DOI',
        @TableName = 'IndexesRowStore',
        @DropSQL = @DropSQL OUTPUT,
        @RecreateSQL = @RecreateSQL OUTPUT

    EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

    ALTER TABLE DOI.IndexRowStorePartitions DROP CONSTRAINT FK_IndexRowStorePartitions_IndexesRowStore

    DROP TABLE IF EXISTS DOI.IndexesRowStore


	CREATE TABLE DOI.IndexesRowStore (
        DatabaseName				                                                NVARCHAR(128) NOT NULL,
		SchemaName					                                                NVARCHAR(128) NOT NULL,
		TableName					                                                NVARCHAR(128) NOT NULL,
		IndexName					                                                NVARCHAR(128) NOT NULL,
        IsIndexMissingFromSQLServer                                                 BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsIndexMissingFromSQLServer
				DEFAULT(0),
		IsUnique_Desired			                                                BIT NOT NULL,
		IsUnique_Actual				                                                BIT NULL,
		IsPrimaryKey_Desired		                                                BIT NOT NULL,
		IsPrimaryKey_Actual		                                                    BIT NULL,
		IsUniqueConstraint_Desired	                                                BIT NOT NULL
			CONSTRAINT Chk_IndexesRowStore_IsUniqueConstraint_Desired
				CHECK (IsUniqueConstraint_Desired = 0)
			CONSTRAINT Def_IndexesRowStore_IsUniqueConstraint_Desired
				DEFAULT(0),
		IsUniqueConstraint_Actual	                                                BIT NULL,
		IsClustered_Desired			                                                BIT NOT NULL,
		IsClustered_Actual			                                                BIT NULL,
		KeyColumnList_Desired		                                                NVARCHAR(MAX) NOT NULL,
		KeyColumnList_Actual		                                                NVARCHAR(MAX) NULL,
		IncludedColumnList_Desired	                                                NVARCHAR(MAX) NULL,
		IncludedColumnList_Actual	                                                NVARCHAR(MAX) NULL,
		IsFiltered_Desired			                                                BIT NOT NULL,
		IsFiltered_Actual			                                                BIT NULL,
		FilterPredicate_Desired		                                                VARCHAR(MAX) NULL,
/*			CONSTRAINT Chk_IndexesRowStore_FilterPredicate
				CHECK ((FilterPredicate IS NOT NULL AND FilterPredicate LIKE '|(%|[%|]%|)' ESCAPE '|')--must use parentheses around expression and square brackets around columnnames.
						OR (FilterPredicate IS NULL))*/ 
		FilterPredicate_Actual		                                                VARCHAR(MAX) NULL,
		Fillfactor_Desired				                                            TINYINT NOT NULL
			CONSTRAINT Chk_Indexes_FillFactor_Desired	
				CHECK (Fillfactor_Desired BETWEEN 0 AND 100)
			CONSTRAINT Def_Indexes_FillFactor_Desired	
				DEFAULT (90),
		Fillfactor_Actual				                                            TINYINT NULL,


		OptionPadIndex_Desired				                                        BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionPadIndex_Desired
				DEFAULT(1),
		OptionPadIndex_Actual				                                        BIT NULL,
		OptionStatisticsNoRecompute_Desired                                         BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionStatisticsNoRecompute_Desired
				DEFAULT(0),
		OptionStatisticsNoRecompute_Actual                                          BIT NULL,
		OptionStatisticsIncremental_Desired                                         BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionStatisticsIncremental_Desired
				DEFAULT(0),
		OptionStatisticsIncremental_Actual                                          BIT NULL,
		OptionIgnoreDupKey_Desired			                                        BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionIgnoreDupKey_Desired
				DEFAULT(0),
		OptionIgnoreDupKey_Actual			                                        BIT NULL,
		OptionResumable_Desired			                                            BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionResumable_Desired
				DEFAULT(0),
		OptionResumable_Actual			                                            BIT NULL,
		OptionMaxDuration_Desired			                                        SMALLINT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionMaxDuration_Desired
				DEFAULT(0),
		OptionMaxDuration_Actual			                                        SMALLINT NULL,
		OptionAllowRowLocks_Desired			                                        BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionAllowRowLocks_Desired
				DEFAULT(1),
		OptionAllowRowLocks_Actual			                                        BIT NULL,
		OptionAllowPageLocks_Desired		                                        BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionAllowPageLocks_Desired
				DEFAULT(1),
		OptionAllowPageLocks_Actual		                                            BIT NULL,
		OptionDataCompression_Desired		                                        NVARCHAR(60) NOT NULL
			CONSTRAINT Chk_IndexesRowStore_OptionDataCompression_Desired
				CHECK (OptionDataCompression_Desired IN ('NONE', 'ROW', 'PAGE'))
			CONSTRAINT Def_IndexesRowStore_OptionDataCompression_Desired
				DEFAULT('PAGE'),
		OptionDataCompression_Actual		                                        NVARCHAR(60) NULL,
		OptionDataCompressionDelay_Desired                                          BIT NOT NULL
			CONSTRAINT Chk_IndexesRowStore_OptionDataCompressionDelay_Desired
				CHECK (OptionDataCompressionDelay_Desired = 0)
			CONSTRAINT Def_IndexesRowStore_OptionDataCompressionDelay_Desired
				DEFAULT(0),
		OptionDataCompressionDelay_Actual		                                    BIT NOT NULL
			CONSTRAINT Chk_IndexesRowStore_OptionDataCompressionDelay_Actual
				CHECK (OptionDataCompressionDelay_Actual = 0)
			CONSTRAINT Def_IndexesRowStore_OptionDataCompressionDelay_Actual
				DEFAULT(0),
		Storage_Desired					                                            NVARCHAR(128) NOT NULL,
		Storage_Actual					                                            NVARCHAR(128) NULL,
        StorageType_Desired                                                         NVARCHAR(120) NULL
			CONSTRAINT Def_IndexesRowStore_StorageType_Desired
				CHECK(StorageType_Desired IN ('ROWS_FILEGROUP', 'PARTITION_SCHEME')),
        StorageType_Actual                                                          NVARCHAR(120) NULL
			CONSTRAINT Def_IndexesRowStore_StorageType_Actual
				CHECK(StorageType_Actual IN ('ROWS_FILEGROUP', 'PARTITION_SCHEME')),
        PartitionFunction_Desired                                                   NVARCHAR(128) NULL,
        PartitionFunction_Actual                                                    NVARCHAR(128) NULL,
		PartitionColumn_Desired				                                        NVARCHAR(128) NULL,
		PartitionColumn_Actual				                                        NVARCHAR(128) NULL,

        NumRows_Actual                                                              BIGINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumRows_Actual
                DEFAULT (0),
        AllColsInTableSize_Estimated                                                INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_AllColsInTableSize_Estimated
                DEFAULT (0),
        NumFixedKeyCols_Estimated                                                   SMALLINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumFixedKeyCols_Estimated
                DEFAULT (0),
        NumVarKeyCols_Estimated                                                     SMALLINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumVarKeyCols_Estimated
                DEFAULT (0),
        NumKeyCols_Estimated                                                        SMALLINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumKeyCols_Estimated
                DEFAULT (0),
        NumFixedInclCols_Estimated                                                  SMALLINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumFixedInclCols_Estimated
                DEFAULT (0),
        NumVarInclCols_Estimated                                                    SMALLINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumVarInclCols_Estimated
                DEFAULT (0),
        NumInclCols_Estimated                                                       SMALLINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumInclCols_Estimated
                DEFAULT (0),
        NumFixedCols_Estimated                                                      SMALLINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumFixedCols_Estimated
                DEFAULT (0),
        NumVarCols_Estimated                                                        SMALLINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumVarCols_Estimated
                DEFAULT (0),
        NumCols_Estimated                                                           SMALLINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumCols_Estimated
                DEFAULT (0),
        FixedKeyColsSize_Estimated                                                  INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_FixedKeyColsSize_Estimated
                DEFAULT (0),
        VarKeyColsSize_Estimated                                                    INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_VarKeyColsSize_Estimated
                DEFAULT (0),
        KeyColsSize_Estimated                                                       INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_KeyColsSize_Estimated
                DEFAULT (0),
        FixedInclColsSize_Estimated                                                 INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_FixedInclColsSize_Estimated
                DEFAULT (0),
        VarInclColsSize_Estimated                                                   INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_VarInclColsSize_Estimated
                DEFAULT (0),
        InclColsSize_Estimated                                                      INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_InclColsSize_Estimated
                DEFAULT (0),
        FixedColsSize_Estimated                                                     INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_FixedColsSize_Estimated
                DEFAULT (0),
        VarColsSize_Estimated                                                       INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_VarColsSize_Estimated
                DEFAULT (0),
        ColsSize_Estimated                                                          INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_ColsSize_Estimated
                DEFAULT (0),
        PKColsSize_Estimated                                                        INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_PKColsSize_Estimated
                DEFAULT (0),
        NullBitmap_Estimated                                                        INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NullBitmap_Estimated
                DEFAULT (0),
        Uniqueifier_Estimated                                                       TINYINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_Uniqueifier_Estimated
                DEFAULT (0),
        TotalRowSize_Estimated                                                      INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_TotalRowSize_Estimated
                DEFAULT (0),
        NonClusteredIndexRowLocator_Estimated                                       INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NonClusteredIndexRowLocator_Estimated
                DEFAULT (0),
        NumRowsPerPage_Estimated                                                    INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumRowsPerPage_Estimated
                DEFAULT (0),
        NumFreeRowsPerPage_Estimated                                                INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumFreeRowsPerPage_Estimated
                DEFAULT (0),
        NumLeafPages_Estimated                                                      INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumLeafPages_Estimated
                DEFAULT (0),
        LeafSpaceUsed_Estimated                                                     DECIMAL(18,2) NOT NULL
            CONSTRAINT Def_IndexesRowStore_LeafSpaceUsed_Estimated
                DEFAULT (0),
        LeafSpaceUsedMB_Estimated                                                   DECIMAL(10,2) NOT NULL
            CONSTRAINT Def_IndexesRowStore_LeafSpaceUsedMB_Estimated
                DEFAULT (0),
        NumNonLeafLevelsInIndex_Estimated                                           TINYINT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumNonLeafLevelsInIndex_Estimated
                DEFAULT (0),
        NumIndexPages_Estimated                                                     INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumIndexPages_Estimated
                DEFAULT (0),
        IndexSizeMB_Actual_Estimated                                                       DECIMAL(10,2) NOT NULL
            CONSTRAINT Def_IndexesRowStore_IndexSizeMB_Actual_Estimated
                DEFAULT (0),
        IndexSizeMB_Actual                                                          DECIMAL(10,2) NOT NULL
            CONSTRAINT Def_IndexesRowStore_IndexSizeMB_Actual
                DEFAULT (0),
        DriveLetter                                                                 CHAR(1) NULL,
        IsIndexLarge                                                                BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsIndexLarge
                DEFAULT (0),
        IndexMeetsMinimumSize                                                       BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IndexMeetsMinimumSize
                DEFAULT (0),
        Fragmentation                                                               FLOAT NOT NULL
            CONSTRAINT Def_IndexesRowStore_Fragmentation
                DEFAULT (0),
        FragmentationType                                                           VARCHAR(5) NOT NULL
            CONSTRAINT Chk_IndexesRowStore_FragmentationType
                CHECK (FragmentationType IN ('None', 'Light', 'Heavy'))
            CONSTRAINT Def_IndexesRowStore_FragmentationType
                DEFAULT ('None'),
        AreDropRecreateOptionsChanging                                              BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_AreDropRecreateOptionsChanging
                DEFAULT (0),
        AreRebuildOptionsChanging                                                   BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_AreRebuildOptionsChanging
                DEFAULT (0),
        AreRebuildOnlyOptionsChanging                                               BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_AreRebuildOnlyOptionsChanging            
                DEFAULT (0),
        AreReorgOptionsChanging                                                     BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_AreReorgOptionsChanging
                DEFAULT (0),
        AreSetOptionsChanging                                                       BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_AreSetOptionsChanging
                DEFAULT (0),
        IsUniquenessChanging                                                        BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsUniquenessChanging
                DEFAULT (0),
        IsPrimaryKeyChanging                                                        BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsPrimaryKeyChanging
                DEFAULT (0),
        IsKeyColumnListChanging                                                     BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsKeyColumnListChanging
                DEFAULT (0),
        IsIncludedColumnListChanging                                                BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsIncludedColumnListChanging
                DEFAULT (0),
        IsFilterChanging                                                            BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsFilterChanging
                DEFAULT (0),
        IsClusteredChanging                                                         BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsClusteredChanging
                DEFAULT (0),
        IsPartitioningChanging                                                      BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsPartitioningChanging
                DEFAULT (0),
        IsPadIndexChanging                                                          BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsPadIndexChanging
                DEFAULT (0),
        IsFillfactorChanging                                                        BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsFillfactorChanging
                DEFAULT (0),
        IsIgnoreDupKeyChanging                                                      BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsIgnoreDupKeyChanging
                DEFAULT (0),
        IsStatisticsNoRecomputeChanging                                             BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsStatisticsNoRecomputeChanging
                DEFAULT (0),
        IsStatisticsIncrementalChanging                                             BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsStatisticsIncrementalChanging
                DEFAULT (0),
        IsAllowRowLocksChanging                                                     BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsAllowRowLocksChanging
                DEFAULT (0),
        IsAllowPageLocksChanging                                                    BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsAllowPageLocksChanging
                DEFAULT (0),
        IsDataCompressionChanging                                                   BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsDataCompressionChanging
                DEFAULT (0),
        IsDataCompressionDelayChanging                                              BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsDataCompressionDelayChanging
                DEFAULT (0),
        IsStorageChanging                                                           BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IsStorageChanging
                DEFAULT (0),
        IndexHasLOBColumns                                                          BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_IndexHasLOBColumns
                DEFAULT (0),
        NumPages_Actual                                                             INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NumPages_Actual
                DEFAULT (0),
        TotalPartitionsInIndex                                                      INT NOT NULL
            CONSTRAINT Def_IndexesRowStore_TotalPartitionsInIndex
                DEFAULT (0),
        NeedsPartitionLevelOperations                                               BIT NOT NULL
            CONSTRAINT Def_IndexesRowStore_NeedsPartitionLevelOperations
                DEFAULT (0),

		CONSTRAINT PK_IndexesRowStore
			PRIMARY KEY NONCLUSTERED (DatabaseName, SchemaName, TableName, IndexName),
		CONSTRAINT Chk_IndexesRowStore_Filter
			CHECK ((IsFiltered_Desired = 1 AND FilterPredicate_Desired IS NOT NULL AND IsPrimaryKey_Desired = 0 AND IsUniqueConstraint_Desired = 0 AND IsClustered_Desired = 0 AND OptionStatisticsIncremental_Desired = 0)
						OR (IsFiltered_Desired = 0 AND FilterPredicate_Desired IS NULL)),
		CONSTRAINT Chk_IndexesRowStore_PrimaryKeyIsUnique
			CHECK ((IsPrimaryKey_Desired = 1 AND IsUnique_Desired = 1)
						OR (IsPrimaryKey_Desired = 0)),
		CONSTRAINT Chk_IndexesRowStore_UniqueConstraintIsUnique
			CHECK ((IsUniqueConstraint_Desired = 1 AND IsUnique_Desired = 1)
						OR (IsUniqueConstraint_Desired = 0)),
		CONSTRAINT Chk_IndexesRowStore_PKvsUQ
			CHECK ((IsPrimaryKey_Desired = 1 AND IsUniqueConstraint_Desired = 0)
						OR (IsPrimaryKey_Desired = 0 AND IsUniqueConstraint_Desired = 1)
						OR (IsPrimaryKey_Desired = 0 AND IsUniqueConstraint_Desired = 0)),
		CONSTRAINT Chk_IndexesRowStore_IncludedColumnsNotAllowed
			CHECK ((IncludedColumnList_Desired IS NOT NULL AND (IsClustered_Desired = 0 AND IsPrimaryKey_Desired = 0 AND IsUniqueConstraint_Desired = 0))
						OR (IncludedColumnList_Desired IS NULL)),
        CONSTRAINT FK_IndexesRowStore_Tables
            FOREIGN KEY (DatabaseName, SchemaName, TableName)
                REFERENCES DOI.Tables(DatabaseName, SchemaName, TableName)

)

    WITH (MEMORY_OPTIMIZED = ON)


    ALTER TABLE [DOI].[IndexesRowStore] ADD INDEX IDX_IndexesRowStore_IndexName NONCLUSTERED ([IndexName])

    ALTER TABLE [DOI].[IndexRowStorePartitions] ADD 
        CONSTRAINT FK_IndexRowStorePartitions_IndexesRowStore
            FOREIGN KEY(DatabaseName, SchemaName, TableName, IndexName)
                REFERENCES DOI.IndexesRowStore(DatabaseName, SchemaName, TableName, IndexName)

    EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL

GO
