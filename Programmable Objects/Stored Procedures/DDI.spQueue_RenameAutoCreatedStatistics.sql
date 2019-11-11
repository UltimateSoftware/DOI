IF OBJECT_ID('[DDI].[spQueue_RenameAutoCreatedStatistics]') IS NOT NULL
	DROP PROCEDURE [DDI].[spQueue_RenameAutoCreatedStatistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spQueue_RenameAutoCreatedStatistics]
    @Debug BIT = 0

AS

/*
    EXEC DDI.spRenameAutoCreatedStatistics
        @Debug = 1
*/

DECLARE @RenameStatisticsSQL NVARCHAR(MAX) = ''

SELECT @RenameStatisticsSQL += RenameStatisticsSQL
FROM DDI.vwStatistics
WHERE StatisticsName LIKE '|_WA|_Sys|_%' ESCAPE '|'
    AND NOT EXISTS( SELECT 't' 
                    FROM DDI.SysStats ST
                        INNER JOIN DDI.SysDatabases D ON ST.database_id = D.database_id
                        INNER JOIN DDI.SysTables T ON T.database_id = D.database_id
                            AND ST.object_id = T.object_id
                    WHERE ST.name = 'ST_' + LEFT(T.NAME + '_' + REPLACE(STUFF(StatisticsColumnList_Desired, LEN(StatisticsColumnList_Desired), 1,NULL), ',', '_'), 125))


--SELECT @RenameStatisticsSQL += '
--EXEC sys.sp_rename 
--    @objname = N''' + s.name + '.' + t.name + '.' + ST.NAME + ''', 
--    @newname = N''ST_' + LEFT(T.NAME + '_' + REPLACE(STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL), ',', '_'), 125) + ''',
--    @objtype = N''STATISTICS'';' + CHAR(13) + CHAR(10)
--FROM sys.stats st
--    INNER JOIN sys.tables t ON st.object_id = t.object_id
--    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
--    CROSS APPLY (	SELECT c.name + ',' 
--					FROM sys.stats_columns stc 
--						INNER JOIN sys.columns c ON stc.object_id = c.object_id
--							AND stc.column_id = c.column_id
--					WHERE stc.object_id = st.object_id 
--						AND stc.stats_id = st.stats_id
--                    ORDER BY stc.stats_column_id ASC
--					FOR XML PATH('')) StatsColumns(StatsColumnList)
--    INNER JOIN DDI.Tables T2 ON S.NAME = T2.SchemaName
--        AND T.NAME = T2.TableName
--WHERE ST.NAME LIKE '|_WA|_Sys|_%' ESCAPE '|'
--    AND NOT EXISTS( SELECT 't' 
--                    FROM sys.stats 
--                    WHERE name = 'ST_' + LEFT(T.NAME + '_' + REPLACE(STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL), ',', '_'), 125))

IF @Debug = 1
BEGIN
    EXEC DDI.spPrintOutLongSQL 
        @SQLInput = @RenameStatisticsSQL,
        @VariableName = N'@RenameStatisticsSQL'
END
ELSE
BEGIN
    EXEC (@RenameStatisticsSQL)
END 

GO
