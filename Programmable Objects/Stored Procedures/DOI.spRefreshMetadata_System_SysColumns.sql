-- <Migration ID="5be8f60f-4405-4c64-b1ed-e65389693f92" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

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

SELECT @SQL += '

SELECT DB_ID(''model'') AS database_id, *
INTO #SysColumns
FROM model.sys.columns
WHERE 1 = 2'


SELECT @SQL += '

INSERT INTO #SysColumns
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.columns'
--select count(*)
FROM DOI.Databases D
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