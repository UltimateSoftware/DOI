
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexColumns]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysIndexColumns]
        @DatabaseName = 'DOIUnitTests'
*/


DELETE IC
FROM DOI.SysIndexColumns IC
    INNER JOIN DOI.SysDatabases D ON IC.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


DECLARE @SQL NVARCHAR(MAX) = ''

SELECT TOP 1 @SQL += '

SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
INTO #SysIndexColumns
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '
WHERE 1 = 2'
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysIndexColumns'
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO #SysIndexColumns
SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ''
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysIndexColumns'
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO DOI.SysIndexColumns([database_id], [object_id], [index_id], [index_column_id], [column_id], [key_ordinal], [partition_ordinal], [is_descending_key], [is_included_column])
SELECT [database_id], [object_id], [index_id], [index_column_id], [column_id], [key_ordinal], [partition_ordinal], [is_descending_key], [is_included_column]
FROM #SysIndexColumns

DROP TABLE IF EXISTS #SysIndexColumns
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