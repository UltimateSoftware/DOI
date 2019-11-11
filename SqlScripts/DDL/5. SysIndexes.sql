USE DDI
GO

DROP TABLE DDI.SysIndexes
GO

CREATE TABLE DDI.SysIndexes(
    database_id INT NOT NULL,
    object_id INT NOT NULL,
    name NVARCHAR(128) NULL ,
    index_id INT NOT NULL,
    type TINYINT NOT NULL ,
    type_desc NVARCHAR(60) NOT NULL ,
    is_unique BIT NOT NULL ,
    data_space_id INT NULL, 
    ignore_dup_key BIT NOT NULL ,
    is_primary_key BIT NOT NULL ,
    is_unique_constraint BIT NOT NULL ,
    fill_factor TINYINT NOT NULL ,
    is_padded BIT NOT NULL ,
    is_disabled BIT NOT NULL ,
    is_hypothetical BIT NOT NULL ,
    allow_row_locks BIT NOT NULL ,
    allow_page_locks BIT NOT NULL ,
    has_filter BIT NOT NULL ,
    filter_definition NVARCHAR(MAX) NULL ,
    compression_delay INT NULL,
    key_column_list NVARCHAR(MAX) NULL,
    included_column_list NVARCHAR(MAX) NULL,
    
    CONSTRAINT PK_SysIndexes 
        PRIMARY KEY NONCLUSTERED (database_id, object_id, index_id))
WITH (MEMORY_OPTIMIZED = ON)
GO

SELECT DB_ID('PaymentReporting') AS database_id, *
INTO #SysIndexes
FROM PaymentReporting.sys.indexes

INSERT INTO DDI.SysIndexes
SELECT *
FROM #SysIndexes


DROP TABLE #SysIndexes
GO
