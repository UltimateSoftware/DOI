
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStatsColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].spRefreshMetadata_System_SysStatsColumns;

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].spRefreshMetadata_System_SysStatsColumns
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysStatsColumns]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE SC
FROM DOI.SysStatsColumns SC
    INNER JOIN DOI.SysDatabases D ON SC.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT @SQL += '
SELECT TOP 1 DB_ID(''model'') AS database_id, *, SPACE(0) AS ColumnList
INTO #SysStatsColumns
FROM model.sys.stats_columns
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysStatsColumns
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *, NULL
FROM ' + DatabaseName + '.sys.stats_columns'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysStatsColumns
SELECT *
FROM #SysStatsColumns

DROP TABLE IF EXISTS #SysStatsColumns' + CHAR(13) + CHAR(10)

IF @Debug = 1
BEGIN
    EXEC DOI.spPrintOutLongSQL
        @SQLInput = @SQL,
        @VariableName = '@SQL'
END
ELSE
BEGIN
    EXEC(@SQL)
END

GO