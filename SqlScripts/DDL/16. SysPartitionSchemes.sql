USE DDI
GO

DROP TABLE IF EXISTS DDI.SysPartitionSchemes
GO

CREATE TABLE DDI.SysPartitionSchemes(
    database_id sysname,
    name	sysname,
    data_space_id	int NOT NULL,
    type	CHAR(2) NOT NULL,
    type_desc	NVARCHAR(60) NULL,
    is_default	BIT NULL,
    is_system	BIT NULL,
    function_id	INT NOT NULL,

    CONSTRAINT PK_SysPartitionSchemes
        PRIMARY KEY NONCLUSTERED (function_id)
)
WITH (MEMORY_OPTIMIZED = ON)
GO

SELECT DB_ID('PaymentReporting') AS database_id, *
INTO #SysPartitionSchemes
FROM PaymentReporting.sys.partition_schemes

INSERT INTO DDI.SysPartitionSchemes
SELECT * FROM #SysPartitionSchemes

DROP TABLE IF EXISTS #SysPartitionSchemes
GO
