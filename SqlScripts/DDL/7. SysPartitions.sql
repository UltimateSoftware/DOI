USE DDI
GO

DROP TABLE DDI.SysPartitions
GO

CREATE TABLE DDI.SysPartitions(
    database_id INT NOT NULL,
    partition_id BIGINT NOT NULL , 
    object_id INT NOT NULL , 
    index_id INT NOT NULL , 
    partition_number INT NOT NULL , 
    hobt_id BIGINT NOT NULL , 
    rows BIGINT NULL , 
    filestream_filegroup_id SMALLINT NOT NULL , 
    data_compression TINYINT NOT NULL , 
    data_compression_desc NVARCHAR(60) NULL 

    CONSTRAINT PK_SysPartitions
        PRIMARY KEY NONCLUSTERED (database_id, partition_id)
   )
        WITH (MEMORY_OPTIMIZED = ON)

GO

ALTER TABLE DDI.SysPartitions ADD 
    CONSTRAINT UQ_SysPartitions
        UNIQUE NONCLUSTERED (database_id, OBJECT_ID, index_id, partition_number)

ALTER TABLE DDI.SysPartitions ADD 
    CONSTRAINT UQ_SysPartitions2
        UNIQUE NONCLUSTERED (database_id, hobt_id)

DELETE DDI.SysPartitions

SELECT DB_ID('PaymentReporting') AS database_id, *
INTO #SysPartitions
FROM PaymentReporting.sys.partitions


INSERT INTO DDI.SysPartitions 
SELECT *
FROM #SysPartitions

DROP TABLE #SysPartitions
GO
