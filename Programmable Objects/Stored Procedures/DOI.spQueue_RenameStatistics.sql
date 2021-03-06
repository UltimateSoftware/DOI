
GO

IF OBJECT_ID('[DOI].[spQueue_RenameStatistics]') IS NOT NULL
	DROP PROCEDURE [DOI].[spQueue_RenameStatistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spQueue_RenameStatistics]
    @DatabaseName NVARCHAR(128) = NULL,
    @SchemaName NVARCHAR(128) = NULL,
    @TableName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC DOI.spQueue_RenameStatistics
        --@DatabaseName = 'PaymentReporting',
        --@SchemaName = 'dbo',
        --@TableName = 'PartitioningTestAutomationTable',
        @Debug = 1
*/

DECLARE @RenameStatisticsSQL NVARCHAR(MAX) = ''

SELECT @RenameStatisticsSQL += '
EXEC ' + @DatabaseName + '.sys.sp_rename 
    @objname = N''' + s.name + '.' + t.name + '.' + ST.NAME + ''', 
    @newname = N''ST_' + LEFT(T.NAME + '_' + REPLACE(STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL), ',', '_'), 125) + ''',
    @objtype = N''STATISTICS'';' + CHAR(13) + CHAR(10)
FROM DOI.SysStats st
    INNER JOIN DOI.SysDatabases d ON d.database_id = st.database_id
    INNER JOIN DOI.SysTables t ON st.database_id = t.database_id
        AND st.object_id = t.object_id
    INNER JOIN DOI.SysSchemas s ON s.database_id = t.database_id
        AND t.schema_id = s.schema_id
    CROSS APPLY (	SELECT c.name + ',' 
					FROM DOI.SysStatsColumns stc 
						INNER JOIN DOI.SysColumns c ON c.database_id = stc.database_id
                            AND stc.object_id = c.object_id
							AND stc.column_id = c.column_id
					WHERE stc.database_id = st.database_id
                        AND stc.object_id = st.object_id 
						AND stc.stats_id = st.stats_id
                    ORDER BY stc.stats_column_id ASC
					FOR XML PATH('')) StatsColumns(StatsColumnList)
    INNER JOIN DOI.Tables T2 ON T2.DatabaseName = d.name
        AND S.NAME = T2.SchemaName
        AND T.NAME = T2.TableName
WHERE NOT EXISTS (SELECT 'True' 
                    FROM DOI.SysIndexes i 
                    WHERE i.database_id = st.database_id
                        AND i.object_id = st.object_id 
                        AND i.name = st.name) --exclude statistics from indexes
    AND NOT EXISTS (SELECT 'True' 
                    FROM DOI.SysStats st2
                    WHERE st2.database_id = T.database_id
                        AND st2.name = 'ST_' + LEFT(T.NAME + '_' + REPLACE(STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL), ',', '_'), 125))
    AND st.name <> 'ST_' + LEFT(T.NAME + '_' + REPLACE(STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL), ',', '_'), 125)
    AND T2.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T2.DatabaseName ELSE @DatabaseName END
    AND T2.SchemaName = CASE WHEN @SchemaName IS NULL THEN T2.SchemaName ELSE @SchemaName END
    AND T2.TableName = CASE WHEN @TableName IS NULL THEN T2.TableName ELSE @TableName END
ORDER BY d.name, s.name, t.name, st.name



IF @Debug = 1
BEGIN
    EXEC DOI.spPrintOutLongSQL 
        @SQLInput = @RenameStatisticsSQL,
        @VariableName = N'@RenameStatisticsSQL'
END
ELSE
BEGIN
    EXEC (@RenameStatisticsSQL)
END 

DECLARE @DeleteBadlyNamedDuplicateStatisticsSQL NVARCHAR(MAX) = ''

SELECT @DeleteBadlyNamedDuplicateStatisticsSQL += '
DROP STATISTICS ' + s.name + '.' + t.name + '.' + ST.NAME + CHAR(13) + CHAR(10)
FROM DOI.SysStats st
    INNER JOIN DOI.SysDatabases d ON d.database_id = st.database_id
    INNER JOIN DOI.SysTables t ON st.database_id = t.database_id
        AND st.object_id = t.object_id
    INNER JOIN DOI.SysSchemas s ON s.database_id = t.database_id
        AND t.schema_id = s.schema_id
    CROSS APPLY (	SELECT c.name + ',' 
					FROM DOI.SysStatsColumns stc 
						INNER JOIN DOI.SysColumns c ON c.database_id = stc.database_id
                            AND stc.object_id = c.object_id
							AND stc.column_id = c.column_id
					WHERE stc.database_id = st.database_id
						AND stc.stats_id = st.stats_id
                    ORDER BY stc.stats_column_id ASC
					FOR XML PATH('')) StatsColumns(StatsColumnList)
    INNER JOIN DOI.Tables T2 ON T2.DatabaseName = d.name
        AND S.NAME = T2.SchemaName COLLATE DATABASE_DEFAULT
        AND T.NAME = T2.TableName COLLATE DATABASE_DEFAULT
WHERE NOT EXISTS (  SELECT 'True' 
                    FROM DOI.SysIndexes i 
                    WHERE i.database_id = st.database_id
                        AND i.object_id = st.object_id 
                        AND i.name = st.name) --exclude statistics from indexes
    AND EXISTS (SELECT 'True' 
                FROM DOI.SysStats st2
                WHERE st2.database_id = T.database_id
                    AND st2.name = 'ST_' + LEFT(T.NAME + '_' + REPLACE(STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL), ',', '_'), 125))
    AND st.name <> 'ST_' + LEFT(T.NAME + '_' + REPLACE(STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL), ',', '_'), 125)
    AND T2.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T2.DatabaseName ELSE @DatabaseName END
    AND T2.SchemaName = CASE WHEN @SchemaName IS NULL THEN T2.SchemaName ELSE @SchemaName END
    AND T2.TableName = CASE WHEN @TableName IS NULL THEN T2.TableName ELSE @TableName END
ORDER BY d.name, s.name, t.name, st.name

IF @Debug = 1
BEGIN
    EXEC DOI.spPrintOutLongSQL 
        @SQLInput = @DeleteBadlyNamedDuplicateStatisticsSQL,
        @VariableName = N'@DeleteBadlyNamedDuplicateStatisticsSQL'
END
ELSE
BEGIN
    EXEC (@DeleteBadlyNamedDuplicateStatisticsSQL)
END 

GO
