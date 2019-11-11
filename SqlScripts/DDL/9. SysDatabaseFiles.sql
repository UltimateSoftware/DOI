USE DDI
GO

DROP TABLE DDI.SysDatabaseFiles
GO

CREATE TABLE DDI.SysDatabaseFiles (
    database_id INT NOT NULL,
    file_id INT NOT NULL, 
    file_guid UNIQUEIDENTIFIER NULL, 
    type TINYINT NOT NULL, 
    type_desc NVARCHAR(60) NULL, 
    data_space_id INT NOT NULL, 
    name SYSNAME, 
    physical_name NVARCHAR(260) NULL, 
    state TINYINT NULL, 
    state_desc NVARCHAR(60) NULL, 
    size INT NOT NULL, 
    max_size INT NOT NULL, 
    growth INT NOT NULL, 
    is_media_read_only BIT NOT NULL, 
    is_read_only BIT NOT NULL, 
    is_sparse BIT NOT NULL, 
    is_percent_growth BIT NOT NULL, 
    is_name_reserved BIT NOT NULL, 
    create_lsn NUMERIC(25,0) NULL, 
    drop_lsn NUMERIC(25,0) NULL, 
    read_only_lsn NUMERIC(25,0) NULL,  
    read_write_lsn NUMERIC(25,0) NULL,  
    differential_base_lsn NUMERIC(25,0) NULL,  
    differential_base_guid UNIQUEIDENTIFIER NULL, 
    differential_base_time DATETIME NULL, 
    redo_start_lsn NUMERIC(25,0) NULL,  
    redo_start_fork_guid UNIQUEIDENTIFIER NULL, 
    redo_target_lsn NUMERIC(25,0) NULL,  
    redo_target_fork_guid UNIQUEIDENTIFIER NULL, 
    backup_lsn NUMERIC(25,0) NULL

    CONSTRAINT PK_SysDatabaseFiles
        PRIMARY KEY NONCLUSTERED (database_id, file_id)
   )
        WITH (MEMORY_OPTIMIZED = ON)

GO

ALTER TABLE DDI.SysDatabaseFiles ADD 
    CONSTRAINT UQ_SysDatabaseFiles_FileGUID
        UNIQUE NONCLUSTERED (database_id, file_guid)

ALTER TABLE DDI.SysDatabaseFiles ADD 
    CONSTRAINT UQ_SysDatabaseFiles_Name
        UNIQUE NONCLUSTERED (database_id, name)

ALTER TABLE DDI.SysDatabaseFiles ADD 
    CONSTRAINT UQ_SysDatabaseFiles_PhysicalName
        UNIQUE NONCLUSTERED (database_id, physical_name)

SELECT DB_ID('PaymentReporting') AS database_id, *
INTO #SysDatabaseFiles
FROM PaymentReporting.sys.database_files


INSERT INTO DDI.SysDatabaseFiles 
SELECT *
FROM #SysDatabaseFiles

DROP TABLE #SysDatabaseFiles
GO
