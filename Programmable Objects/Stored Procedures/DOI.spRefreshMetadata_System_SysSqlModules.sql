
IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysSqlModules]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysSqlModules];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysSqlModules]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysSqlModules]
        @DatabaseName = 'ULTIPRO_CALENDAR'
*/

DELETE T
FROM DOI.SysSqlModules T
    INNER JOIN DOI.SysDatabases D ON T.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

CREATE TABLE #SysSqlModules (
	database_id	int NOT NULL,
	object_id	int	NOT NULL,
	definition	NVARCHAR(MAX) NULL,
	uses_ansi_nulls	BIT NULL,
	uses_quoted_identifier	BIT NULL,
	is_schema_bound	bit	NULL,
	uses_database_collation	BIT NULL,
	is_recompiled	bit	NULL,
	null_on_null_input	bit	NULL,
	execute_as_principal_id	int	NULL,
	uses_native_compilation	bit	NULL,
	inline_type	bit	NULL,
	is_inlineable	bit	NULL 
)

INSERT INTO #SysSqlModules
(
    database_id,
    object_id,
    definition,
    uses_ansi_nulls,
    uses_quoted_identifier,
    is_schema_bound,
    uses_database_collation,
    is_recompiled,
    null_on_null_input,
    execute_as_principal_id,
    uses_native_compilation,
    inline_type,
    is_inlineable
)
EXEC('
SELECT database_id,object_id,definition,uses_ansi_nulls,uses_quoted_identifier,is_schema_bound,uses_database_collation,is_recompiled,null_on_null_input,execute_as_principal_id,uses_native_compilation,inline_type,is_inlineable 
FROM ' + @DatabaseName + '.sys.sql_modules
	INNER JOIN sys.databases d ON d.name = ''' + @DatabaseName + '''')


INSERT INTO DOI.SysSqlModules(database_id,object_id,definition,uses_ansi_nulls,uses_quoted_identifier,is_schema_bound,uses_database_collation,is_recompiled,null_on_null_input,execute_as_principal_id,uses_native_compilation,inline_type,is_inlineable)
SELECT database_id,object_id,definition,uses_ansi_nulls,uses_quoted_identifier,is_schema_bound,uses_database_collation,is_recompiled,null_on_null_input,execute_as_principal_id,uses_native_compilation,inline_type,is_inlineable 
FROM #SysSqlModules

DROP TABLE IF EXISTS #SysSqlModules

GO