IF OBJECT_ID('[DDI].[spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs]
    @TableName SYSNAME,
    @Debug BIT = 0
AS

/*
    EXEC DDI.[spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs]
        @TableName = 'SysDatabaseFiles', @Debug = 1
*/

DECLARE @SQL VARCHAR(MAX) = ''

IF @TableName IN ('SysDmDbStatsProperties')
BEGIN
    SELECT @SQL += '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' FN.*
    INTO #' + @TableName + '
    FROM DDI.' + M.FunctionParentDMV + ' p
        CROSS APPLY ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ' FN  

    INSERT INTO DDI.' + @TableName + '
    SELECT * FROM #' + @TableName + CHAR(13) + CHAR(10) 
    --select count(*)
    FROM DDI.Databases D
        INNER JOIN DDI.MappingSqlServerDMVToDDITables M ON M.DDITableName = @TableName
END
ELSE
IF @TableName IN ('SysDatabaseFiles')
BEGIN
    SELECT @SQL += '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + D.DatabaseName + ''') AS database_id,' END + ' FN.*
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE d.DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', d.DatabaseName) + ')' ELSE '' END + ' FN'
    --select count(*)
    FROM DDI.Databases D
        INNER JOIN DDI.MappingSqlServerDMVToDDITables M ON M.DDITableName = @TableName

    SELECT @SQL += '
    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''TempDB'') AS database_id,' END + ' FN.*
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'TempDB' + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', 'TempDB') + ')' ELSE '' END + ' FN'
    FROM DDI.MappingSqlServerDMVToDDITables M 
    WHERE M.DDITableName = @TableName

    SET @SQL += '
    INSERT INTO DDI.' + @TableName + '
    SELECT * FROM #' + @TableName 
END
ELSE
IF @TableName IN ('SysDmOsVolumeStats')
BEGIN
    SELECT @SQL += '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + d.DatabaseName + ''') AS database_id,' END + ' FN.*
    INTO #' + @TableName + '
    FROM DDI.' + M.FunctionParentDMV + ' p
        CROSS APPLY ' + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', d.DatabaseName) + ')' ELSE '' END + ' FN ' + CHAR(13) + CHAR(10) 
    --select count(*)
    FROM DDI.Databases D
        INNER JOIN DDI.MappingSqlServerDMVToDDITables M ON M.DDITableName = @TableName

    SELECT @SQL += '
    INSERT INTO #' + @TableName + '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''TempDB'') AS database_id,' END + ' FN.*
    FROM DDI.' + M.FunctionParentDMV + ' p
        CROSS APPLY ' + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', 'TempDB') + ')' ELSE '' END + ' FN ' + CHAR(13) + CHAR(10) 
    FROM DDI.MappingSqlServerDMVToDDITables M 
    WHERE M.DDITableName = @TableName

    SET @SQL += '
    INSERT INTO DDI.' + @TableName + '
    SELECT * FROM #' + @TableName 
END
ELSE
IF @TableName IN ('SysIndexes', 'SysForeignKeys')
BEGIN
    SELECT @SQL += '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '

    INSERT INTO DDI.' + @TableName + '
    SELECT *, NULL, NULL, NULL FROM #' + @TableName + CHAR(13) + CHAR(10) 
    --select count(*)
    FROM DDI.Databases D
        INNER JOIN DDI.MappingSqlServerDMVToDDITables M ON M.DDITableName = @TableName
END
ELSE
IF @TableName = 'SysStats'
BEGIN
    SELECT @SQL += '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '

    INSERT INTO DDI.' + @TableName + '
    SELECT *, NULL FROM #' + @TableName + CHAR(13) + CHAR(10) 
    --select count(*)
    FROM DDI.Databases D
        INNER JOIN DDI.MappingSqlServerDMVToDDITables M ON M.DDITableName = @TableName
END
ELSE
IF @TableName = 'SysPartitionRangeValues'
BEGIN
    SELECT @SQL += '
    SELECT DB_ID(''' + D.DatabaseName + ''') AS database_id, function_id, boundary_id, parameter_id, CAST(value AS VARCHAR(100)) AS value
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '

    INSERT INTO DDI.' + @TableName + '
    SELECT * FROM #' + @TableName + CHAR(13) + CHAR(10) 
    --select count(*)
    FROM DDI.Databases D
        INNER JOIN DDI.MappingSqlServerDMVToDDITables M ON M.DDITableName = @TableName
END
ELSE
BEGIN
    SELECT @SQL += '
    SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
    INTO #' + @TableName + '
    FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '

    INSERT INTO DDI.' + @TableName + '
    SELECT * FROM #' + @TableName + CHAR(13) + CHAR(10) 
    --select count(*)
    FROM DDI.Databases D
        INNER JOIN DDI.MappingSqlServerDMVToDDITables M ON M.DDITableName = @TableName
END

IF @Debug = 1
BEGIN
    EXEC DDI.spPrintOutLongSQL
        @SQLInput = @SQL,
        @VariableName = '@SQL'
END
ELSE
BEGIN
    EXEC(@SQL)
END

GO
