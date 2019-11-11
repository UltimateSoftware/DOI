USE DDI
GO

DROP TABLE IF EXISTS DDI.SysIndexColumns 

CREATE TABLE DDI.SysIndexColumns (
    database_id INT NOT NULL,
    object_id	INT NOT NULL,
    index_id	INT NOT NULL,
    index_column_id	INT NOT NULL,
    column_id	INT NOT NULL,
    key_ordinal	TINYINT NOT NULL,
    partition_ordinal	TINYINT NOT NULL,
    is_descending_key	BIT NULL,
    is_included_column	BIT NULL 

    CONSTRAINT PK_SysIndexColumns
        PRIMARY KEY NONCLUSTERED (database_id, object_id, index_id, index_column_id))

    WITH (MEMORY_OPTIMIZED = ON)
GO

SELECT DB_ID('PaymentReporting') AS database_id, * 
INTO #SysIndexColumns
FROM SYS.index_columns

INSERT INTO DDI.SysIndexColumns 
SELECT * FROM #SysIndexColumns
GO
