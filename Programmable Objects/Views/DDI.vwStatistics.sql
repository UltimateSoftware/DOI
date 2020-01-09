IF OBJECT_ID('[DDI].[vwStatistics]') IS NOT NULL
	DROP VIEW [DDI].[vwStatistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   VIEW [DDI].[vwStatistics]
AS 

/*
    select * from DDI.vwStatistics
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
IF NOT EXISTS(SELECT ''True'' FROM sys.stats WHERE NAME = ''' + S.StatisticsName + ''')
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
EXEC sys.sp_rename 
    @objname = N''' + S.SchemaName + '.' + S.TableName + '.' + S.StatisticsName + ''', 
    @newname = N''ST_' + LEFT(S.TableName + '_' + REPLACE(STUFF(StatisticsColumnList_Desired, LEN(StatisticsColumnList_Desired), 1,NULL), ',', '_'), 125) + ''',
    @objtype = N''STATISTICS'';' + CHAR(13) + CHAR(10) AS RenameStatisticsSQL
FROM DDI.[Statistics] S



GO
