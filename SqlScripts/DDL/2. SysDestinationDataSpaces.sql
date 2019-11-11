USE DDI
GO


DROP TABLE IF EXISTS DDI.SysDestinationDataSpaces
GO


CREATE TABLE DDI.SysDestinationDataSpaces (
    database_id INT NOT NULL,
    partition_scheme_id	int NOT NULL,
    destination_id	int NOT NULL,
    data_space_id	int NOT NULL,
    
    CONSTRAINT PK_SysDestinationDataSpaces
        PRIMARY KEY NONCLUSTERED (database_id, partition_scheme_id, destination_id))
WITH (MEMORY_OPTIMIZED = ON)
GO

DELETE DDI.SysDestinationDataSpaces
GO

SELECT DB_ID('PaymentReporting') AS database_id, *
INTO #SysDestinationDataSpaces
FROM PaymentReporting.sys.destination_data_spaces
GO

INSERT INTO DDI.SysDestinationDataSpaces
SELECT * FROM #SysDestinationDataSpaces
GO

DROP TABLE #SysDestinationDataSpaces
GO
