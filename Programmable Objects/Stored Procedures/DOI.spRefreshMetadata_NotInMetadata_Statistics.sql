
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_NotInMetadata_Statistics]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_NotInMetadata_Statistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_NotInMetadata_Statistics]
        @DatabaseName SYSNAME = NULL,
        @SchemaName SYSNAME = NULL,
        @TableName SYSNAME = NULL
AS

/*
    EXEC DOI.spRefreshMetadata_NotInMetadata_Statistics
        @DatabaseName = 'PaymentReporting',
        @SchemaName = 'dbo',
        @TableName = 'Bai2BankTransactions'
*/

INSERT INTO DOI.[Statistics] ( DatabaseName, SchemaName ,TableName ,StatisticsName ,StatisticsColumnList_Desired ,SampleSizePct_Desired ,IsFiltered_Desired ,FilterPredicate_Desired ,IsIncremental_Desired ,NoRecompute_Desired ,LowerSampleSizeToDesired ,ReadyToQueue )
SELECT  d.name,
        s.name, 
        t.name, 
        CASE 
            WHEN st.name LIKE '|_WA%' ESCAPE '|' 
            THEN 'ST_' + T.NAME + '_' + REPLACE(STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL), ',', '_') 
            ELSE ST.NAME 
        END,
        STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL),
        20,
        has_filter,
        filter_definition,
        CAST(is_incremental AS VARCHAR(1)),
        CAST(no_recompute AS VARCHAR(1)),
        0,
        1
FROM DOI.SysStats AS ST 	    
    INNER JOIN DOI.SysDatabases d ON d.database_id = ST.database_id
	CROSS APPLY (	SELECT c.name + ',' 
					FROM DOI.SysStatsColumns stc 
						INNER JOIN DOI.SysColumns c ON stc.database_id = c.database_id
                            AND stc.object_id = c.object_id
							AND stc.column_id = c.column_id
					WHERE stc.database_id = st.database_id
                        AND stc.object_id = st.object_id 
						AND stc.stats_id = st.stats_id
                    ORDER BY stc.stats_column_id ASC
					FOR XML PATH('')) StatsColumns(StatsColumnList)
	INNER JOIN DOI.SysDmDbStatsProperties sp ON sp.database_id = ST.database_id
        AND sp.object_id = st.object_id
        AND sp.stats_id = st.stats_id
    INNER JOIN DOI.SysTables t ON st.database_id = t.database_id
        AND st.object_id = t.object_id
    INNER JOIN DOI.SysSchemas s ON s.database_id = t.database_id
        AND s.schema_id = t.schema_id
    INNER JOIN DOI.Tables TM ON TM.DatabaseName = d.name
        AND TM.SchemaName = S.name  
        AND TM.TableName = t.name
WHERE d.name = CASE WHEN @DatabaseName IS NULL THEN S.NAME ELSE @DatabaseName END
    AND S.NAME = CASE WHEN @SchemaName IS NULL THEN S.NAME ELSE @SchemaName END
    AND T.NAME = CASE WHEN @TableName IS NULL THEN T.NAME ELSE @TableName END
    AND st.name NOT LIKE 'NCCI|_%' ESCAPE '|'
    AND st.name NOT LIKE 'CCI|_%' ESCAPE '|'
    AND NOT EXISTS( SELECT 'True' 
                    FROM DOI.[Statistics] STM
                    WHERE d.name = STM.DatabaseName
                        AND s.name = STM.SchemaName
                        AND t.name = STM.TableName
                        AND stm.StatisticsName =    CASE 
                                                        WHEN st.name LIKE '|_WA%' ESCAPE '|' 
                                                        THEN 'ST_' + T.NAME + '_' + REPLACE(STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL), ',', '_') 
                                                        ELSE ST.NAME 
                                                    END)
ORDER BY d.name, s.name, t.name, st.name

GO
