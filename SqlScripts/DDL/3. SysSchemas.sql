USE DDI
GO

DROP TABLE DDI.SysSchemas
GO


CREATE TABLE DDI.SysSchemas (
    database_id INT NOT NULL,
    name sysname,
    schema_id INT NOT NULL,
    principal_id INT NULL
    
    CONSTRAINT PK_SysSchemas
        PRIMARY KEY NONCLUSTERED (database_id, schema_id))
WITH (MEMORY_OPTIMIZED = ON)
GO

DELETE DDI.SysSchemas
GO

SELECT DB_ID('PaymentReporting') AS database_id, *
INTO #SysSchemas
FROM PaymentReporting.sys.schemas
GO

INSERT INTO DDI.SysSchemas
SELECT * FROM #SysSchemas
GO

DROP TABLE #SysSchemas
GO
