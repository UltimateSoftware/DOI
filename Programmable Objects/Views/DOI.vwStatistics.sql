
GO

IF OBJECT_ID('[DOI].[vwStatistics]') IS NOT NULL
	DROP VIEW [DOI].[vwStatistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   VIEW [DOI].[vwStatistics]
AS 

/*
    select * from DOI.vwStatistics
*/
SELECT  *,         
        '
UPDATE STATISTICS ' + S.DatabaseName + '.' + S.SchemaName + '.' + S.TableName + '(' + S.StatisticsName + ') 
WITH SAMPLE ' + CAST(S.SampleSizePct_Desired AS VARCHAR(3)) + ' PERCENT
    /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.
    , MAXDOP = 0*/
' + CASE WHEN S.NoRecompute_Desired = 1 THEN ', NORECOMPUTE' ELSE '' END +
', INCREMENTAL = ' + CASE WHEN S.IsIncremental_Desired = 1 THEN 'ON' ELSE 'OFF' END 
AS UpdateStatisticsSQL,
                '
IF NOT EXISTS(SELECT ''True'' FROM ' + S.DatabaseName + '.sys.stats WHERE NAME = ''' + S.StatisticsName + ''')
BEGIN
    CREATE STATISTICS ' + S.StatisticsName + '
    ON ' + S.DatabaseName + '.' + S.SchemaName + '.' + S.TableName + '(' + S.StatisticsColumnList_Desired + ')' + 
        CASE 
            WHEN S.IsFiltered_Desired = 1 
            THEN '
    WHERE ' + S.FilterPredicate_Desired
            ELSE '' 
        END + '
    WITH SAMPLE ' + CAST(S.SampleSizePct_Desired AS VARCHAR(3)) + ' PERCENT
        /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.
        , MAXDOP = 0*/
    ' + CASE WHEN S.NoRecompute_Desired = 1 THEN ', NORECOMPUTE' ELSE '' END +
    ', INCREMENTAL = ' + CASE WHEN S.IsIncremental_Desired = 1 THEN 'ON' ELSE 'OFF' END + '
END' 
AS CreateStatisticsSQL,
        '
DROP STATISTICS ' + S.TableName + '.' + S.StatisticsName AS DropStatisticsSQL,
        '  
IF EXISTS ( SELECT ''True''
    FROM SYS.stats st 
        INNER JOIN SYS.TABLES t ON t.object_id = st.object_id 
        INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = ''' + S.SchemaName + '''
        AND t.name = ''' + S.TableName + '''
        AND st.name = ''' + S.StatisticsName  + ''')
BEGIN
    EXEC sys.sp_rename 
        @objname = N''' + S.SchemaName + '.' + S.TableName + '.' + S.StatisticsName + ''', 
        @newname = N''' + REPLACE(S.StatisticsName, S.TableName, S.TableName + '_OLD') + ''', 
        @objtype = N''STATISTICS''
END' AS RenameStatisticsSQL,
        '
IF EXISTS ( SELECT ''True''
            FROM ' + S.DatabaseName + '.SYS.stats st 
                INNER JOIN ' + S.DatabaseName + '.SYS.TABLES t ON t.object_id = st.object_id 
                INNER JOIN ' + S.DatabaseName + '.sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = ''' + S.SchemaName + '''
                AND t.name = ''' + S.TableName + '''
                AND st.name = ''ST_' + S.TableName + '_' + S.StatisticsColumnList_Actual + ''')
BEGIN
    SET DEADLOCK_PRIORITY 10
    EXEC ' + S.DatabaseName + '.sys.sp_rename 
        @objname = ''' + S.SchemaName + '.' + S.TableName + '_OLD.ST_' + S.TableName + '_OLD_' + S.StatisticsColumnList_Actual + '''
        ,@newname = ''' + S.StatisticsName + '''
        ,@objtype = ''STATISTICS''
END' AS RevertRenameStatisticsSQL

FROM DOI.[Statistics] S





GO
