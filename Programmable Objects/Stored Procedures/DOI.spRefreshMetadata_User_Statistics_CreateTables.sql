USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Statistics_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_Statistics_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_Statistics_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'Statistics',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DOI.[Statistics]


CREATE TABLE DOI.[Statistics] (
    DatabaseName                                                NVARCHAR(128) NOT NULL,
    SchemaName                                                  NVARCHAR(128) NOT NULL,
    TableName                                                   NVARCHAR(128) NOT NULL,
    StatisticsName                                              SYSNAME,
    IsStatisticsMissingFromSQLServer                            BIT NOT NULL
        CONSTRAINT Def_Statistics_IsStatisticsMissingFromSQLServer
            DEFAULT (0),
    StatisticsColumnList_Desired                                VARCHAR(MAX) NOT NULL,
    StatisticsColumnList_Actual                                 VARCHAR(MAX) NULL,
    SampleSizePct_Desired                                       TINYINT NOT NULL
        CONSTRAINT Chk_Statistics_SampleSize_Desired
            CHECK(SampleSizePct_Desired BETWEEN 0 AND 100),
    SampleSizePct_Actual                                        TINYINT NOT NULL
        CONSTRAINT Chk_Statistics_SampleSize_Actual
            CHECK(SampleSizePct_Actual BETWEEN 0 AND 100)
        CONSTRAINT Def_Statistics_SampleSize_Actual
            DEFAULT (0),
    IsFiltered_Desired                                          BIT NOT NULL,
    IsFiltered_Actual                                           BIT NOT NULL
        CONSTRAINT Def_Statistics_IsFiltered_Actual
            DEFAULT (0),
    FilterPredicate_Desired                                     VARCHAR(MAX) NULL,
    FilterPredicate_Actual                                      NVARCHAR(MAX) NULL,
    IsIncremental_Desired                                       BIT NOT NULL, --validate that the table is partitioned or not?
    IsIncremental_Actual                                        BIT NOT NULL 
        CONSTRAINT Def_Statistics_IsIncremental_Actual
            DEFAULT (0),
    NoRecompute_Desired                                         BIT NOT NULL,
    NoRecompute_Actual                                          BIT NOT NULL 
        CONSTRAINT Def_Statistics_NoRecompute_Actual
            DEFAULT (0),
	LowerSampleSizeToDesired                                    BIT NOT NULL,
    ReadyToQueue                                                BIT NOT NULL
        CONSTRAINT Def_Statistics_ReadyToQueue
            DEFAULT (0),
    DoesSampleSizeNeedUpdate                                    BIT NOT NULL
        CONSTRAINT Def_Statistics_DoesSampleSizeNeedUpdate
            DEFAULT (0),
    IsStatisticsMissing                                         BIT NOT NULL
        CONSTRAINT Def_Statistics_IsStatisticsMissing
            DEFAULT (0),     
    HasFilterChanged                                            BIT NOT NULL
        CONSTRAINT Def_Statistics_HasFilterChanged
            DEFAULT (0),        
    HasIncrementalChanged                                       BIT NOT NULL
        CONSTRAINT Def_Statistics_HasIncrementalChanged
            DEFAULT (0),   
    HasNoRecomputeChanged                                       BIT NOT NULL
        CONSTRAINT Def_Statistics_HasNoRecomputeChanged
            DEFAULT (0),   
    NumRowsInTableUnfiltered                                    BIGINT NULL, 
    NumRowsInTableFiltered                                      BIGINT NULL, 
    NumRowsSampled                                              BIGINT NULL, 
    StatisticsLastUpdated                                       DATETIME2 NULL, 
    HistogramSteps                                              INT NULL, 
    StatisticsModCounter                                        BIGINT NULL,
    PersistedSamplePct                                          FLOAT NULL,
    StatisticsUpdateType                                        VARCHAR(30) NOT NULL
        CONSTRAINT Def_Statistics_StatisticsUpdateType
            DEFAULT ('None'),
    ListOfChanges                                               VARCHAR(500) NULL,
    IsOnlineOperation                                           BIT NOT NULL
        CONSTRAINT Def_Statistics_IsOnlineOperation
            DEFAULT (0),
    CONSTRAINT PK_Statistics
        PRIMARY KEY NONCLUSTERED (DatabaseName, SchemaName, TableName, StatisticsName),
    CONSTRAINT Chk_Statistics_Filter
			CHECK ((IsFiltered_Desired = 1 AND FilterPredicate_Desired IS NOT NULL)
						OR (IsFiltered_Desired = 0 AND FilterPredicate_Desired IS NULL)),
    CONSTRAINT FK_Statistics_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName) 
            REFERENCES DOI.Tables(DatabaseName, SchemaName, TableName))

    WITH (MEMORY_OPTIMIZED = ON)


EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL
GO
