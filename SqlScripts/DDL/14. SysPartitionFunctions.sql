USE DDI
GO

DROP TABLE IF EXISTS DDI.SysPartitionFunctions
GO

CREATE TABLE DDI.SysPartitionFunctions(
    database_id sysname,
    name	sysname,
    function_id	INT NOT NULL,
    type	CHAR(2) NOT NULL,
    type_desc	nvarchar(60) NULL,
    fanout	int NOT NULL,
    boundary_value_on_right	bit NOT NULL,
    is_system	bit NOT NULL,
    create_date	datetime NOT NULL,
    modify_date	datetime NOT NULL,

    CONSTRAINT PK_SysPartitionFunctions
        PRIMARY KEY NONCLUSTERED (database_id, function_id)
)
WITH (MEMORY_OPTIMIZED = ON)
GO

SELECT DB_ID('PaymentReporting') AS database_id, *
INTO #SysPartitionFunctions
FROM PaymentReporting.sys.partition_functions

INSERT INTO DDI.SysPartitionFunctions
SELECT * FROM #SysPartitionFunctions

DROP TABLE IF EXISTS #SysPartitionFunctions
GO
