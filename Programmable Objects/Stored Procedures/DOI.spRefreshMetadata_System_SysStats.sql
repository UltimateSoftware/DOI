
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysStats]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysStats]
        @DatabaseName = 'DOIUnitTests'
*/
DELETE ST
FROM DOI.SysStats ST
    INNER JOIN DOI.SysDatabases D ON ST.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


DECLARE @SQL NVARCHAR(MAX) = ''

SELECT TOP 1 @SQL += '
SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *, SPACE(0) AS ColumnList
INTO #SysStats
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '
WHERE 1 = 2'
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysStats' 
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO #SysStats
SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *, NULL
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ''

--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysStats' 
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

    INSERT INTO DOI.SysStats([database_id], [object_id], [name], [stats_id], [auto_created], [user_created], [no_recompute], [has_filter], [filter_definition], [is_temporary], [is_incremental])
    SELECT [database_id], [object_id], [name], [stats_id], [auto_created], [user_created], [no_recompute], [has_filter], [filter_definition], [is_temporary], [is_incremental]
    FROM #SysStats
'

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