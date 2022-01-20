
IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysSqlModules]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysSqlModules];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysSqlModules]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysSqlModules]
        @DatabaseName = 'ULTIPRO_CALENDAR'
*/

DELETE T
FROM DOI.SysSqlModules T
    INNER JOIN DOI.SysDatabases D ON T.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL NVARCHAR(MAX) = ''
DECLARE @ColumnList VARCHAR(MAX) = 'database_id,object_id,definition,uses_ansi_nulls,uses_quoted_identifier,is_schema_bound,uses_database_collation,is_recompiled,null_on_null_input,execute_as_principal_id,uses_native_compilation'

IF   SERVERPROPERTY('ProductMajorVersion') > 13
BEGIN
    SET @ColumnList += ', [inline_type], [is_inlineable]'
END

SET @SQL += '

SELECT DB_ID(''model'') AS ' + @ColumnList + '
INTO #SysSqlModules
FROM model.sys.sql_modules
WHERE 1 = 0'

SELECT @SQL += '

INSERT INTO #SysSqlModules
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.sql_modules'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SET @SQL += '

INSERT INTO DOI.SysSqlModules(' + @ColumnList + ')
SELECT ' + @ColumnList + '
FROM #SysSqlModules

DROP TABLE IF EXISTS #SysSqlModules
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