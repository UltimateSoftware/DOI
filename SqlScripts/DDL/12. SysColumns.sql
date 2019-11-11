USE DDI
GO

DROP TABLE IF EXISTS DDI.SysColumns
GO 

CREATE TABLE DDI.SysColumns (
    database_id INT NOT NULL,
    object_id	int NOT NULL,
    name	NVARCHAR(128) NULL,
    column_id	int NOT NULL,
    system_type_id	tinyint NOT NULL,
    user_type_id	int NOT NULL,
    max_length	smallint NOT NULL,
    precision	tinyint NOT NULL,
    scale	tinyint NOT NULL,
    collation_name	NVARCHAR(128) NULL,
    is_nullable	bit NULL,
    is_ansi_padded	bit NOT NULL,
    is_rowguidcol	bit NOT NULL,
    is_identity	bit NOT NULL,
    is_computed	bit NOT NULL,
    is_filestream	bit NOT NULL,
    is_replicated	bit NULL,
    is_non_sql_subscribed	bit NULL,
    is_merge_published	bit NULL,
    is_dts_replicated	bit NULL,
    is_xml_document	bit NOT NULL,
    xml_collection_id	int NOT NULL,
    default_object_id	int NOT NULL,
    rule_object_id	int NOT NULL,
    is_sparse	bit NULL,
    is_column_set	bit NULL,
    generated_always_type	tinyint NULL,
    generated_always_type_desc	nvarchar(60)  NULL,
    encryption_type	int NULL,
    encryption_type_desc	nvarchar(64) NULL,
    encryption_algorithm_name	NVARCHAR(128) NULL,
    column_encryption_key_id	int NULL,
    column_encryption_key_database_name	NVARCHAR(128) NULL,
    is_hidden	bit NULL,
    is_masked	bit NULL
    
    CONSTRAINT PK_SysColumns
        PRIMARY KEY NONCLUSTERED(database_id, OBJECT_ID, column_id)
    )
WITH (MEMORY_OPTIMIZED = ON)

SELECT DB_ID('PaymentReporting') AS DatabaseName, *
INTO #SysColumns
FROM PaymentReporting.sys.columns

INSERT INTO DDI.SysColumns
SELECT * FROM #SysColumns

DROP TABLE #SysColumns
GO
