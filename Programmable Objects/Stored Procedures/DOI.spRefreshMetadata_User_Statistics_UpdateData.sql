IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Statistics_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_Statistics_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_Statistics_UpdateData]
AS

UPDATE St
SET StatisticsColumnList_Actual         = St2.column_list,
    SampleSizePct_Actual                = ISNULL(CAST((((SP.rows_sampled * 1.00)/rows) * 100) AS DECIMAL(5,2)),0),
    IsFiltered_Actual                   = ISNULL(St2.has_filter,0),
    FilterPredicate_Actual              = St2.filter_definition,
    IsIncremental_Actual                = ISNULL(St2.is_incremental,0),
    NoRecompute_Actual                  = ISNULL(St2.no_recompute,0),
    NumRowsInTableUnfiltered            = SP.unfiltered_rows,
    NumRowsInTableFiltered              = SP.rows,
    NumRowsSampled                      = SP.rows_sampled,
    StatisticsLastUpdated               = SP.last_updated,
    HistogramSteps                      = SP.steps,
    StatisticsModCounter                = SP.modification_counter,
    IsStatisticsMissingFromSQLServer    = CASE WHEN St2.name IS NULL THEN 1 ELSE 0 END
--select COUNT(*)
FROM DOI.[Statistics] St
    INNER JOIN DOI.SysDatabases d ON d.name = St.DatabaseName
    INNER JOIN DOI.SysSchemas Sc ON St.SchemaName = Sc.name
    INNER JOIN DOI.SysTables t ON t.name = St.TableName
        AND Sc.schema_id = t.schema_id
    LEFT JOIN DOI.SysStats St2 ON St2.database_id = d.database_id
        AND St2.object_id = t.object_id
        AND St2.name = St.StatisticsName
    LEFT JOIN DOI.SysDmDbStatsProperties SP ON St2.database_id = SP.database_id
        AND St2.object_id = SP.object_id
        AND St2.stats_id = SP.stats_id

UPDATE St
SET DoesSampleSizeNeedUpdate =  CASE 
                                    WHEN NumRowsInTableFiltered IS NULL
                                    THEN 0
                                    WHEN ((((NumRowsSampled * 1.00)/NumRowsInTableFiltered) * 100) < (St.SampleSizePct_Desired - 5))
			                            OR (LowerSampleSizeToDesired = 1 AND ((((NumRowsSampled * 1.00)/NumRowsInTableFiltered) * 100) > (SampleSizePct_Desired + 5)))
                                    /*We take away 5 from the percentage because SQL Server doesn't always give us the sample size we want.*/
                                    THEN 1
                                    ELSE 0
                                END,
    HasFilterChanged = CASE WHEN ISNULL(St.FilterPredicate_Desired, '') <> ISNULL(St.FilterPredicate_Actual, '') THEN 1 ELSE 0 END,
    HasIncrementalChanged = CASE WHEN St.IsIncremental_Desired <> St.IsIncremental_Actual THEN 1 ELSE 0 END,
    HasNoRecomputeChanged = CASE WHEN St.NoRecompute_Desired <> St.NoRecompute_Actual THEN 1 ELSE 0 END
FROM DOI.[Statistics] St


UPDATE St
SET StatisticsUpdateType = 
        CASE 
            WHEN IsStatisticsMissing = 1
            THEN 'Create Statistics'
            WHEN (IsStatisticsMissing = 0 AND HasFilterChanged = 1)
            THEN 'DropRecreate Statistics'
            WHEN (IsStatisticsMissing = 0
                    AND HasFilterChanged = 0
                    AND (DoesSampleSizeNeedUpdate = 1 
                            OR HasIncrementalChanged = 1
                            OR HasNoRecomputeChanged = 1))
            THEN 'Update Statistics'
            ELSE 'None'
        END,
	ListOfChanges = STUFF(CASE WHEN HasFilterChanged			= 1 THEN ', Filter'			ELSE '' END
				+ CASE WHEN HasIncrementalChanged	= 1 THEN ', Incremental'	ELSE '' END
				+ CASE WHEN HasNoRecomputeChanged	= 1 THEN ', NoRecompute'	ELSE '' END
				+ CASE WHEN DoesSampleSizeNeedUpdate	= 1 THEN ', SampleSize'		ELSE '' END, 1, 2, SPACE(0)),
    IsOnlineOperation = CASE 
                            WHEN (IsStatisticsMissing = 0 AND HasFilterChanged = 1)
                            THEN 0
                            ELSE 1
                        END
FROM DOI.[Statistics] St

GO
