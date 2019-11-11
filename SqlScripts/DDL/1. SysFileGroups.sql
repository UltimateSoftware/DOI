USE DDI
GO


DROP TABLE IF EXISTS DDI.SysFilegroups
GO

CREATE TABLE DDI.SysFilegroups (
    database_id INT NOT NULL,
    name	sysname,
    data_space_id	INT NOT NULL,
    type	CHAR(2) NOT NULL,
    type_desc	NVARCHAR(60) NULL,
    is_default	bit NULL,
    is_system	bit NULL,
    filegroup_guid	uniqueidentifier NULL,
    log_filegroup_id	int NULL,
    is_read_only	bit NULL,
    is_autogrow_all_files	bit NULL,
    
    CONSTRAINT PK_SysFilegroups
        PRIMARY KEY NONCLUSTERED (database_id, data_space_id))
WITH (MEMORY_OPTIMIZED = ON)
GO

DELETE DDI.SysFilegroups
GO

SELECT DB_ID('PaymentReporting') AS database_id, *
INTO #SysFilegroups
FROM PaymentReporting.sys.filegroups
GO

INSERT INTO DDI.SysFilegroups
SELECT * FROM #SysFilegroups
GO

DROP TABLE #SysFilegroups
GO
