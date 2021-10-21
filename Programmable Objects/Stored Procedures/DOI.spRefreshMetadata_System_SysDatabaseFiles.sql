
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDatabaseFiles]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabaseFiles];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDatabaseFiles]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDatabaseFiles]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE DF
FROM DOI.SysDatabaseFiles DF
    INNER JOIN DOI.SysDatabases D ON DF.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DELETE DOI.SysDatabaseFiles
WHERE database_id = 2 --TEMPDB

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT TOP 1 @SQL += '
SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + D.DatabaseName + ''') AS database_id,' END + ' FN.*
INTO #SysDatabaseFiles
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE d.DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', d.DatabaseName) + ')' ELSE '' END + ' FN 
WHERE 1 = 2'
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysDatabaseFiles'
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO #SysDatabaseFiles
SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + D.DatabaseName + ''') AS database_id,' END + ' FN.*
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE d.DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', d.DatabaseName) + ')' ELSE '' END + ' FN '
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysDatabaseFiles'
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO #SysDatabaseFiles
SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''TempDB'') AS database_id,' END + ' FN.*
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'TempDB' + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', 'TempDB') + ')' ELSE '' END + ' FN '
FROM DOI.MappingSqlServerDMVToDOITables M 
WHERE M.DOITableName = 'SysDatabaseFiles'


SELECT @SQL += '
    INSERT INTO DOI.SysDatabaseFiles([database_id], [file_id], [file_guid], [type], [type_desc], [data_space_id], [name], [physical_name], [state], [state_desc], [size], [max_size], [growth], [is_media_read_only], [is_read_only], [is_sparse], [is_percent_growth], [is_name_reserved], [create_lsn], [drop_lsn], [read_only_lsn], [read_write_lsn], [differential_base_lsn], [differential_base_guid], [differential_base_time], [redo_start_lsn], [redo_start_fork_guid], [redo_target_lsn], [redo_target_fork_guid], [backup_lsn])
    SELECT [database_id], [file_id], [file_guid], [type], [type_desc], [data_space_id], [name], [physical_name], [state], [state_desc], [size], [max_size], [growth], [is_media_read_only], [is_read_only], [is_sparse], [is_percent_growth], [is_name_reserved], [create_lsn], [drop_lsn], [read_only_lsn], [read_write_lsn], [differential_base_lsn], [differential_base_guid], [differential_base_time], [redo_start_lsn], [redo_start_fork_guid], [redo_target_lsn], [redo_target_fork_guid], [backup_lsn]
    FROM #SysDatabaseFiles' + CHAR(13) + CHAR(10)

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