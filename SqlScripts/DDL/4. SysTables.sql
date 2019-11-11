USE DDI
GO

DROP TABLE DDI.SysTables
GO

CREATE TABLE DDI.SysTables (
    database_id INT NOT NULL,
    name SYSNAME,
    object_id INT NOT NULL,
    principal_id INT NULL,
    schema_id INT NOT NULL,
    parent_object_id INT NOT NULL,
    type CHAR(2) NULL,
    type_desc NVARCHAR(60) NULL,
    create_date DATETIME NOT NULL,
    modify_date DATETIME NOT NULL,
    is_ms_shipped BIT NOT NULL,
    is_published BIT NOT NULL,
    is_schema_published  BIT NOT NULL,
    lob_data_space_id INT NOT NULL ,
    filestream_data_space_id INT NULL,
    max_column_id_used INT NOT NULL,
    lock_on_bulk_load  BIT NOT NULL,
    uses_ansi_nulls  BIT NULL,
    is_replicated  BIT NULL,
    has_replication_filter  BIT NULL,
    is_merge_published  BIT NULL,
    is_sync_tran_subscribed  BIT NULL,
    has_unchecked_assembly_data BIT NOT NULL ,
    text_in_row_limit INT NULL,
    large_value_types_out_of_row BIT NULL,
    is_tracked_by_cdc BIT NULL,
    lock_escalation TINYINT NULL,
    lock_escalation_desc NVARCHAR(60) NULL,
    is_filetable BIT NULL,
    is_memory_optimized BIT NULL,
    durability TINYINT NULL,
    durability_desc NVARCHAR(60) NULL,
    temporal_type TINYINT NULL,
    temporal_type_desc NVARCHAR(60) NULL,
    history_table_id INT NULL,
    is_remote_data_archive_enabled BIT NULL,
    is_external BIT NOT NULL

    CONSTRAINT PK_SysTables 
        PRIMARY KEY NONCLUSTERED (database_id, SCHEMA_ID, object_id))
WITH (MEMORY_OPTIMIZED = ON)
GO

SELECT DB_ID('PaymentReporting') AS database_id, *
INTO #SysTables
FROM PaymentReporting.sys.tables
GO


INSERT INTO DDI.SysTables 
SELECT * FROM #SysTables
GO

DROP TABLE #SysTables
GO
