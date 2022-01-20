
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexes]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysIndexes]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE I
FROM DOI.SysIndexes I
    INNER JOIN DOI.SysDatabases D ON I.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT @SQL += '

SELECT TOP 1 DB_ID(''model'') AS database_id, *, NULL AS key_column_list, NULL AS included_column_list, NULL AS has_LOB_columns
INTO #SysIndexes
FROM model.sys.indexes
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysIndexes
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *, NULL, NULL, NULL
FROM ' + DatabaseName + '.sys.indexes'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO DOI.SysIndexes([database_id], [object_id], [name], [index_id], [type], [type_desc], [is_unique], [data_space_id], [ignore_dup_key], [is_primary_key], [is_unique_constraint], [fill_factor], [is_padded], [is_disabled], [is_hypothetical], [allow_row_locks], [allow_page_locks], [has_filter], [filter_definition], [compression_delay], [key_column_list], [included_column_list], [has_LOB_columns])
SELECT [database_id], [object_id], [name], [index_id], [type], [type_desc], [is_unique], [data_space_id], [ignore_dup_key], [is_primary_key], [is_unique_constraint], [fill_factor], [is_padded], [is_disabled], [is_hypothetical], [allow_row_locks], [allow_page_locks], [has_filter], [filter_definition], [compression_delay], [key_column_list], [included_column_list], [has_LOB_columns]
FROM #SysIndexes
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