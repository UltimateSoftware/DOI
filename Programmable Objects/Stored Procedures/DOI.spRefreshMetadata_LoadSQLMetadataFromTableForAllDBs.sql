
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs]
    @DatabaseId INT = NULL,
    @TableName SYSNAME,
    @Debug BIT = 0
AS

/*
    EXEC DOI.[spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs]
--        @DatabaseId = 19,
        @TableName = 'SysStats', 
        @Debug = 1
*/

DECLARE @SQL VARCHAR(MAX) = ''

IF @TableName IN ('SysDmDbStatsProperties')
BEGIN
    SELECT TOP 1 @SQL += '
    SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' FN.*
    INTO #' + @TableName + '
    FROM DOI.' + M.FunctionParentDMV + ' p
        CROSS APPLY ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ' FN  
    WHERE 1 = 2' + CHAR(13) + CHAR(10)
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END

    SELECT @SQL += '

    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' FN.*
    FROM DOI.' + M.FunctionParentDMV + ' p
        CROSS APPLY ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ' FN  
    WHERE p.database_id = ' + CASE WHEN @DatabaseId IS NULL THEN 'p.database_id' ELSE CAST(@DatabaseId AS VARCHAR(20)) END  
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END
END
ELSE
IF @TableName IN ('SysDatabaseFiles')
BEGIN
    SELECT TOP 1 @SQL += '
    SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + D.DatabaseName + ''') AS database_id,' END + ' FN.*
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE d.DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', d.DatabaseName) + ')' ELSE '' END + ' FN 
    WHERE 1 = 2'
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END

    SELECT @SQL += '

    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + D.DatabaseName + ''') AS database_id,' END + ' FN.*
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE d.DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', d.DatabaseName) + ')' ELSE '' END + ' FN '
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END

    SELECT @SQL += '

    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''TempDB'') AS database_id,' END + ' FN.*
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'TempDB' + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', 'TempDB') + ')' ELSE '' END + ' FN '
    FROM DOI.MappingSqlServerDMVToDOITables M 
    WHERE M.DOITableName = @TableName
END
ELSE
IF @TableName IN ('SysDmOsVolumeStats')
BEGIN
    SELECT TOP 1 @SQL += '
    SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + d.DatabaseName + ''') AS database_id,' END + ' FN.*
    INTO #' + @TableName + '
    FROM DOI.' + M.FunctionParentDMV + ' p
        CROSS APPLY ' + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', d.DatabaseName) + ')' ELSE '' END + ' FN 
    WHERE 1 = 2'
--select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END

    SELECT @SQL += '

    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + d.DatabaseName + ''') AS database_id,' END + ' FN.*
    FROM DOI.' + M.FunctionParentDMV + ' p
        CROSS APPLY ' + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', d.DatabaseName) + ')' ELSE '' END + ' FN '
--select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END

    SELECT @SQL += '

    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''TempDB'') AS database_id,' END + ' FN.*
    FROM DOI.' + M.FunctionParentDMV + ' p
        CROSS APPLY ' + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', 'TempDB') + ')' ELSE '' END + ' FN '
    FROM DOI.MappingSqlServerDMVToDOITables M 
    WHERE M.DOITableName = @TableName
END
ELSE
IF @TableName = 'SysIndexes'
BEGIN
    SELECT TOP 1 @SQL += '

    SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *, NULL AS key_column_list, NULL AS included_column_list, NULL AS has_LOB_columns
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '
    WHERE 1 = 2'
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END

    SELECT @SQL += '

    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *, NULL, NULL, NULL
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ''
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END
END
ELSE
IF @TableName = 'SysForeignKeys'
BEGIN
    SELECT TOP 1 @SQL += '

    SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *, NULL AS ParentColumnList_Actual, NULL AS ReferencedColumnList_Actual, NULL AS DeploymentTime
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '
    WHERE 1 = 2'
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END

    SELECT @SQL += '

    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *, NULL, NULL, NULL
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ''
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END
END
ELSE
IF @TableName = 'SysStats'
BEGIN
    SELECT TOP 1 @SQL += '
    SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *, SPACE(0) AS ColumnList
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '
    WHERE 1 = 2'
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName 
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END

    SELECT @SQL += '

    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *, NULL
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ''

    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName 
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END
END
ELSE
IF @TableName = 'SysPartitionRangeValues'
BEGIN
    SELECT TOP 1 @SQL += '
    SELECT TOP 1 DB_ID(''' + D.DatabaseName + ''') AS database_id, function_id, boundary_id, parameter_id, CAST(value AS VARCHAR(100)) AS value
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '
    WHERE 1 = 2'
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END

    SELECT @SQL += '

    INSERT INTO #' + @TableName + '
    SELECT DB_ID(''' + D.DatabaseName + ''') AS database_id, function_id, boundary_id, parameter_id, CAST(value AS VARCHAR(100)) AS value
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ''
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END
END
ELSE
IF @TableName IN ('SysDatabases', 'SysMasterFiles')
BEGIN
    SELECT TOP 1 @SQL += '
    SELECT TOP 1 *
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '
    WHERE 1 = 2

    INSERT INTO #' + @TableName + '
    SELECT *
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ''
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END
END
ELSE
BEGIN
    SELECT TOP 1 @SQL += '
    SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '
    WHERE 1 = 2'
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END

    SELECT @SQL += '

    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ''
    --select count(*)
    FROM DOI.Databases D
        INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = @TableName
    WHERE D.DatabaseName = CASE WHEN @DatabaseId IS NULL THEN D.DatabaseName ELSE DB_NAME(@DatabaseId) END
END


SELECT @SQL += '    
INSERT INTO DOI.' + @TableName + '
SELECT *
FROM #' + @TableName + '

    DROP TABLE IF EXISTS #' + @TableName + CHAR(13) + CHAR(10)

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