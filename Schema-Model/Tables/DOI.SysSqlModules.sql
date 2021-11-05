

IF OBJECT_ID('[DOI].[SysSqlModules]') IS NULL
CREATE TABLE DOI.SysSqlModules (
    database_id INT NOT NULL,
    object_id	int NOT NULL,
    definition	NVARCHAR(MAX) NULL,
    uses_ansi_nulls	bit NULL,
    uses_quoted_identifier	bit NULL,
    is_schema_bound	bit NULL,
    uses_database_collation	bit NULL,
    is_recompiled	bit NULL,
    null_on_null_input	bit NULL,
    execute_as_principal_id	int NULL,
    uses_native_compilation	bit NULL,
    inline_type	bit NULL,
    is_inlineable	bit	NULL,
    CONSTRAINT PK_SysSqlModules PRIMARY KEY NONCLUSTERED (database_id, object_id))
WITH
(
MEMORY_OPTIMIZED = ON
)
GO