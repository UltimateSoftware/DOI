USE DDI
GO

DROP TABLE IF EXISTS DDI.SysPartitionRangeValues
GO

CREATE TABLE DDI.SysPartitionRangeValues(
    database_id sysname,
    function_id	INT NOT NULL,
    boundary_id	INT NOT NULL,
    parameter_id	INT NOT NULL,
    value	VARCHAR(100) NULL,

    CONSTRAINT PK_SysPartitionRangeValues
        PRIMARY KEY NONCLUSTERED (database_id, function_id, boundary_id)
)
WITH (MEMORY_OPTIMIZED = ON)
GO

SELECT DB_ID('PaymentReporting') AS database_id, function_id, boundary_id, parameter_id, CAST(value AS VARCHAR(100)) AS value
INTO #SysPartitionRangeValues
FROM PaymentReporting.sys.partition_range_values

INSERT INTO DDI.SysPartitionRangeValues
SELECT * FROM #SysPartitionRangeValues

DROP TABLE IF EXISTS #SysPartitionRangeValues
GO