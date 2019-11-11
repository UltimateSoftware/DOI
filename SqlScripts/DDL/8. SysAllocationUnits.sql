USE DDI
GO

DROP TABLE DDI.SysAllocationUnits
GO 

CREATE TABLE DDI.SysAllocationUnits (
    database_id INT NOT NULL, 
    allocation_unit_id BIGINT NOT NULL , 
    type TINYINT NOT NULL , 
    type_desc NVARCHAR(60) NULL , 
    container_id BIGINT NOT NULL , 
    data_space_id INT NULL , 
    total_pages BIGINT NOT NULL , 
    used_pages BIGINT NOT NULL , 
    data_pages BIGINT NOT NULL 

    CONSTRAINT PK_SysAllocationUnits
        PRIMARY KEY NONCLUSTERED (database_id, allocation_unit_id)
   )
        WITH (MEMORY_OPTIMIZED = ON)

GO

ALTER TABLE DDI.SysAllocationUnits ADD 
    CONSTRAINT UQ_SysAllocationUnits
        UNIQUE NONCLUSTERED (container_id, data_space_id, type)

GO

DELETE DDI.SysAllocationUnits

SELECT DB_ID('PaymentReporting') AS database_id, *
INTO #SysAllocationUnits
FROM PaymentReporting.sys.allocation_units


INSERT INTO DDI.SysAllocationUnits 
SELECT *
FROM #SysAllocationUnits

DROP TABLE #SysAllocationUnits
GO
