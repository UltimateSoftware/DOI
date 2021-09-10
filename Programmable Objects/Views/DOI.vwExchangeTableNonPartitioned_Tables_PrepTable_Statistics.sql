
IF OBJECT_ID('[DOI].[vwExchangeTableNonPartitioned_Tables_PrepTable_Statistics]') IS NOT NULL
	DROP VIEW [DOI].[vwExchangeTableNonPartitioned_Tables_PrepTable_Statistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   VIEW [DOI].[vwExchangeTableNonPartitioned_Tables_PrepTable_Statistics]
AS

/*
	SELECT	*
	FROM  DOI.vwExchangeTableNonPartitioned_Tables_PrepTable_Statistics FNS
	WHERE FNS.SchemaName = 'dbo'
		AND FNS.ParentTableName = 'PartitioningTestAutomationTable'
    
    STATISTICS DON'T HAVE THE SAME REQUIREMENTS AS INDEXES AND CONSTRAINTS:
    1. WE DON'T NEED THEM IN ORDER TO DO PARTITION SWITCHING.  
        - SO WE DON'T CREATE STATISTICS ON THE PREP TABLES, ONLY ON THE NEWLY PARTITIONED TABLE.
    2. WHEN YOU RENAME AN INDEX, ITS ACCOMPANYING STATISTICS OBJECT AUTOMATICALLY GETS RENAMED.
        - SO WE REALLY ONLY NEED TO RENAME THE STATISTICS NOT ASSOCIATED WITH AN INDEX.
            - FOR THIS REASON, WE ADDED AN IF...EXISTS TO THE STATISTICS RENAMES.
*/ 
	SELECT	STM.DatabaseName,
            T.SchemaName,
			T.TableName AS ParentTableName, 
            T.PrepTableName,
			REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) AS PrepTableStatisticsName,
            STM.StatisticsName AS ParentStatisticsName,
			ROW_NUMBER() OVER(PARTITION BY T.SchemaName, T.TableName ORDER BY T.SchemaName, T.TableName, STM.StatisticsName) AS RowNum,
'
IF NOT EXISTS(SELECT ''True'' FROM ' + T.DatabaseName + '.sys.stats WHERE NAME = ''' + REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) + ''')
BEGIN
    CREATE STATISTICS ' + REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) + '
    ON ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.PrepTableName + '(' + STM.StatisticsColumnList_Desired + ')' + 
        CASE 
            WHEN STM.IsFiltered_Desired = 1 
            THEN '
    WHERE ' + STM.FilterPredicate_Desired 
            ELSE '' 
        END + '
    WITH SAMPLE ' + CAST(STM.SampleSizePct_Desired AS VARCHAR(3)) + ' PERCENT
        /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.
        , MAXDOP = 0*/
    ' + CASE WHEN STM.NoRecompute_Desired = 1 THEN ', NORECOMPUTE' ELSE '' END +
    ', INCREMENTAL = ' + CASE WHEN STM.IsIncremental_Desired = 1 THEN 'ON' ELSE 'OFF' END + '
END' AS CreateStatisticsStatement,
/*
WE NEED THE IF EXISTS HERE, because when Renaming an index with statistics it also automatically renames the statistics.  So
if an index is renamed before its statistic, then the statistic will no longer be there.
*/
            CASE 
                WHEN STM.IsStatisticsMissing = 1
                THEN ''
                ELSE STM.RenameStatisticsSQL
            END AS RenameExistingTableStatisticsSQL,
            STM.RevertRenameStatisticsSQL AS RevertRenameExistingTableStatisticsSQL,
'
IF EXISTS ( SELECT ''True''
            FROM ' + T.DatabaseName + '.SYS.stats st 
                INNER JOIN ' + T.DatabaseName + '.SYS.TABLES t ON t.object_id = st.object_id 
                INNER JOIN ' + T.DatabaseName + '.sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = ''' + T.SchemaName + '''
                AND t.name = ''' + T.PrepTableName + '''
                AND st.name = ''' + REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) + ''')
BEGIN
    SET DEADLOCK_PRIORITY 10
    EXEC ' + T.DatabaseName + '.sys.sp_rename 
        @objname = ''' + T.SchemaName + '.' + T.PrepTableName + '.' + REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) + ''',
        @newname = ''' + STM.StatisticsName + ''',
        @objtype = ''STATISTICS''
END'
            AS RenameNewNonPartitionedPrepTableStatisticsSQL,
'
IF EXISTS ( SELECT ''True''
            FROM ' + T.DatabaseName + '.SYS.stats st 
                INNER JOIN ' + T.DatabaseName + '.SYS.TABLES t ON t.object_id = st.object_id 
                INNER JOIN ' + T.DatabaseName + '.sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = ''' + T.SchemaName + '''
                AND t.name = ''' + T.PrepTableName + '''
                AND st.name = ''' + STM.StatisticsName + ''')
BEGIN
    SET DEADLOCK_PRIORITY 10
    EXEC ' + T.DatabaseName + '.sys.sp_rename 
        @objname = ''' + T.SchemaName + '.' + T.PrepTableName + '.' + STM.StatisticsName + ''',
        @newname = ''' + REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) + ''',
        @objtype = ''STATISTICS''
END' 
            AS RevertRenameNewNonPartitionedPrepTableStatisticsSQL
	FROM  DOI.vwExchangeTableNonPartitioned_Tables_PrepTable T
        INNER JOIN DOI.[vwStatistics] STM ON STM.DatabaseName = T.DatabaseName
            AND STM.SchemaName = T.SchemaName 
            AND STM.TableName = T.TableName
GO