
GO

IF OBJECT_ID('[DOI].[vwPartitioning_Tables_PrepTables_Statistics]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitioning_Tables_PrepTables_Statistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   VIEW [DOI].[vwPartitioning_Tables_PrepTables_Statistics]
AS

/*
	SELECT	*
	FROM  DOI.vwPartitioning_Tables_PrepTables_Statistics FNS
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
			REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) AS StatisticsName,
            STM.StatisticsName AS ParentStatisticsName,
			ROW_NUMBER() OVER(PARTITION BY T.SchemaName, T.TableName ORDER BY T.SchemaName, T.TableName, STM.StatisticsName) AS RowNum,
'
IF NOT EXISTS(SELECT ''True'' FROM sys.stats WHERE NAME = ''' + REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) + ''')
BEGIN
    CREATE STATISTICS ' + REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) + '
    ON ' + T.SchemaName + '.' + T.PrepTableName + '(' + STM.StatisticsColumnList_Desired + ')' + 
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
                WHEN T.IsNewPartitionedPrepTable = 0
                THEN ''
                ELSE    CASE 
                            WHEN STM.IsStatisticsMissing = 1
                            THEN ''
                            ELSE STM.RenameStatisticsSQL
                        END 
            END AS RenameExistingTableStatisticsSQL,
            CASE 
                WHEN T.IsNewPartitionedPrepTable = 0
                THEN ''
                ELSE STM.RevertRenameStatisticsSQL
            END AS RevertRenameExistingTableStatisticsSQL,
            CASE
                WHEN T.IsNewPartitionedPrepTable = 0
                THEN ''
                ELSE '
IF EXISTS ( SELECT ''True''
            FROM SYS.stats st 
                INNER JOIN SYS.TABLES t ON t.object_id = st.object_id 
                INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = ''' + T.SchemaName + '''
                AND t.name = ''' + T.PrepTableName + '''
                AND st.name = ''' + REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) + ''')
BEGIN
    SET DEADLOCK_PRIORITY 10
    EXEC sys.sp_rename 
        @objname = ''' + T.SchemaName + '.' + T.PrepTableName + '.' + REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) + ''',
        @newname = ''' + STM.StatisticsName + ''',
        @objtype = ''STATISTICS''
END'
            END AS RenameNewPartitionedPrepTableStatisticsSQL,
            CASE
                WHEN T.IsNewPartitionedPrepTable = 0
                THEN ''
                ELSE '
IF EXISTS ( SELECT ''True''
            FROM SYS.stats st 
                INNER JOIN SYS.TABLES t ON t.object_id = st.object_id 
                INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = ''' + T.SchemaName + '''
                AND t.name = ''' + T.PrepTableName + '''
                AND st.name = ''' + STM.StatisticsName + ''')
BEGIN
    SET DEADLOCK_PRIORITY 10
    EXEC sys.sp_rename 
        @objname = ''' + T.SchemaName + '.' + T.PrepTableName + '.' + STM.StatisticsName + ''',
        @newname = ''' + REPLACE(STM.StatisticsName, T.TableName, T.PrepTableName) + ''',
        @objtype = ''STATISTICS''
END' 
            END AS RevertRenameNewPartitionedPrepTableStatisticsSQL
	FROM  DOI.vwPartitioning_Tables_PrepTables T
        INNER JOIN DOI.[vwStatistics] STM ON STM.SchemaName = T.SchemaName 
            AND STM.TableName = T.TableName
    WHERE T.IsNewPartitionedPrepTable = 1

GO
