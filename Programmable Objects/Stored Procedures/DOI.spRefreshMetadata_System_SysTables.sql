
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysTables]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysTables]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE T
FROM DOI.SysTables T
    INNER JOIN DOI.SysDatabases D ON T.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT TOP 1 @SQL += '

SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
INTO #SysTables
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + '
WHERE 1 = 2'
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysTables'
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO #SysTables
SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' *
FROM ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ''
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysTables'
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO DOI.SysTables([database_id], [name], [object_id], [principal_id], [schema_id], [parent_object_id], [type], [type_desc], [create_date], [modify_date], [is_ms_shipped], [is_published], [is_schema_published], [lob_data_space_id], [filestream_data_space_id], [max_column_id_used], [lock_on_bulk_load], [uses_ansi_nulls], [is_replicated], [has_replication_filter], [is_merge_published], [is_sync_tran_subscribed], [has_unchecked_assembly_data], [text_in_row_limit], [large_value_types_out_of_row], [is_tracked_by_cdc], [lock_escalation], [lock_escalation_desc], [is_filetable], [is_memory_optimized], [durability], [durability_desc], [temporal_type], [temporal_type_desc], [history_table_id], [is_remote_data_archive_enabled], [is_external])
SELECT [database_id], [name], [object_id], [principal_id], [schema_id], [parent_object_id], [type], [type_desc], [create_date], [modify_date], [is_ms_shipped], [is_published], [is_schema_published], [lob_data_space_id], [filestream_data_space_id], [max_column_id_used], [lock_on_bulk_load], [uses_ansi_nulls], [is_replicated], [has_replication_filter], [is_merge_published], [is_sync_tran_subscribed], [has_unchecked_assembly_data], [text_in_row_limit], [large_value_types_out_of_row], [is_tracked_by_cdc], [lock_escalation], [lock_escalation_desc], [is_filetable], [is_memory_optimized], [durability], [durability_desc], [temporal_type], [temporal_type_desc], [history_table_id], [is_remote_data_archive_enabled], [is_external]
FROM #SysTables
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