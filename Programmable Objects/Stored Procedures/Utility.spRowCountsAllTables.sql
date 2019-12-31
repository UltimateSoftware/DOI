IF OBJECT_ID('[Utility].[spRowCountsAllTables]') IS NOT NULL
	DROP PROCEDURE [Utility].[spRowCountsAllTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [Utility].[spRowCountsAllTables]

AS

/*
    exec Utility.spRowCountsAllTables
*/

DECLARE @sql VARCHAR(MAX) = ''

SELECT @sql += CASE WHEN @sql = '' THEN '' ELSE 'UNION ALL' + CHAR(13) + CHAR(10) END + 'SELECT ''' + t.name + ''', COUNT(*) from ' + s.name + '.[' + t.name + ']' +CHAR(13) + CHAR(10)
FROM sys.tables t
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
ORDER BY t.name
EXEC(@sql)

GO
