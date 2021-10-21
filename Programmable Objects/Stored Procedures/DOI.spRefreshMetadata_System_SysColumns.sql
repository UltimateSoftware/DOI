
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysColumns]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysColumns]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE C
FROM DOI.SysColumns C
    INNER JOIN DOI.SysDatabases D ON C.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT TOP 1 @SQL += '

SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
INTO #SysColumns
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '
WHERE 1 = 2'
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysColumns'
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO #SysColumns
SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ''
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysColumns'
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '
INSERT INTO DOI.SysColumns([database_id], [object_id], [name], [column_id], [system_type_id], [user_type_id], [max_length], [precision], [scale], [collation_name], [is_nullable], [is_ansi_padded], [is_rowguidcol], [is_identity], [is_computed], [is_filestream], [is_replicated], [is_non_sql_subscribed], [is_merge_published], [is_dts_replicated], [is_xml_document], [xml_collection_id], [default_object_id], [rule_object_id], [is_sparse], [is_column_set], [generated_always_type], [generated_always_type_desc], [encryption_type], [encryption_type_desc], [encryption_algorithm_name], [column_encryption_key_id], [column_encryption_key_database_name], [is_hidden], [is_masked])
SELECT [database_id], [object_id], [name], [column_id], [system_type_id], [user_type_id], [max_length], [precision], [scale], [collation_name], [is_nullable], [is_ansi_padded], [is_rowguidcol], [is_identity], [is_computed], [is_filestream], [is_replicated], [is_non_sql_subscribed], [is_merge_published], [is_dts_replicated], [is_xml_document], [xml_collection_id], [default_object_id], [rule_object_id], [is_sparse], [is_column_set], [generated_always_type], [generated_always_type_desc], [encryption_type], [encryption_type_desc], [encryption_algorithm_name], [column_encryption_key_id], [column_encryption_key_database_name], [is_hidden], [is_masked]
FROM #SysColumns

DROP TABLE IF EXISTS #SysColumns
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