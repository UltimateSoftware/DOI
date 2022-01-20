-- <Migration ID="b100af80-69cf-4c9e-91d3-f3cd0d873f3c" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!


IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIdentityColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIdentityColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIdentityColumns]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysIdentityColumns]
        @DatabaseName = 'ULTIPRO_CALENDAR'
*/

DELETE C
FROM DOI.SysIdentityColumns C
    INNER JOIN DOI.SysDatabases D ON C.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL NVARCHAR(MAX) = ''
DECLARE @ColumnList VARCHAR(MAX) = '[database_id], [object_id], [name], [column_id], [system_type_id], [user_type_id], [max_length], [precision], [scale], [collation_name], [is_nullable], [is_ansi_padded], [is_rowguidcol], [is_identity], [is_filestream], [is_replicated], [is_non_sql_subscribed], [is_merge_published], [is_dts_replicated], [is_xml_document], [xml_collection_id], [default_object_id], [rule_object_id], [seed_value], [increment_value], [last_value], [is_not_for_replication], [is_computed], [is_sparse], [is_column_set], [generated_always_type], [generated_always_type_desc], [encryption_type], [encryption_type_desc], [encryption_algorithm_name], [column_encryption_key_id], [column_encryption_key_database_name], [is_hidden], [is_masked]'

IF   SERVERPROPERTY('ProductMajorVersion') > 13
BEGIN
    SET @ColumnList += ', [graph_type], [graph_type_desc]'
END

SELECT @SQL += '

SELECT TOP 1 DB_ID(''model'') AS database_id, ' + REPLACE(@ColumnList, '[database_id], ', SPACE(0)) + '
INTO #SysIdentityColumns
FROM model.sys.identity_columns
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysIdentityColumns
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, ' + REPLACE(@ColumnList, '[database_id], ', SPACE(0)) + '
FROM ' + D.DatabaseName + '.sys.identity_columns
'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SET @SQL += 'INSERT INTO DOI.SysIdentityColumns(' + @ColumnList + ')
SELECT [database_id], [object_id], [name], [column_id], [system_type_id], [user_type_id], [max_length], [precision], [scale], [collation_name], [is_nullable], [is_ansi_padded], [is_rowguidcol], [is_identity], [is_filestream], [is_replicated], [is_non_sql_subscribed], [is_merge_published], [is_dts_replicated], [is_xml_document], [xml_collection_id], [default_object_id], [rule_object_id], CAST([seed_value] AS BIGINT), CAST([increment_value] AS BIGINT), CAST([last_value] AS BIGINT), [is_not_for_replication], [is_computed], [is_sparse], [is_column_set], [generated_always_type], [generated_always_type_desc], [encryption_type], [encryption_type_desc], [encryption_algorithm_name], [column_encryption_key_id], [column_encryption_key_database_name], [is_hidden], [is_masked]
FROM #SysIdentityColumns

DROP TABLE IF EXISTS #SysIdentityColumns
GO'

IF @Debug = 1
BEGIN
    EXEC DOI.spPrintOutLongSQL
        @SQLInput = @SQL,
        @VariableName = '@SQL'
END
ELSE
BEGIN
    EXEC DOI.sp_ExecuteSQLByBatch 
        @SQL = @SQL
END

GO