IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysMasterFiles_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysMasterFiles_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysMasterFiles_CreateTables]

AS

DROP TABLE IF EXISTS #SysMasterFiles

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'SysMasterFiles',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DDI.SysMasterFiles


CREATE TABLE DDI.SysMasterFiles(
    database_id	            INT NOT NULL,
    file_id	                INT NOT NULL,
    file_guid	            UNIQUEIDENTIFIER NULL,
    type	                TINYINT NOT NULL,
    type_desc	            NVARCHAR(60) NULL,
    data_space_id	        INT NOT NULL,
    name	                SYSNAME,
    physical_name	        NVARCHAR(260) NOT NULL,
    state	                TINYINT NULL,
    state_desc	            NVARCHAR(60) NULL,
    size	                INT NOT NULL,
    max_size	            INT NOT NULL,
    growth	                INT NOT NULL,
    is_media_read_only	    BIT NOT NULL,
    is_read_only	        BIT NOT NULL,
    is_sparse	            BIT NOT NULL,
    is_percent_growth	    BIT NOT NULL,
    is_name_reserved	    BIT NOT NULL,
    create_lsn	            NUMERIC(25,0) NULL,
    drop_lsn	            NUMERIC(25,0) NULL,
    read_only_lsn	        NUMERIC(25,0) NULL,
    read_write_lsn	        NUMERIC(25,0) NULL,
    differential_base_lsn	NUMERIC(25,0) NULL,
    differential_base_guid	UNIQUEIDENTIFIER NULL,
    differential_base_time	DATETIME NULL,
    redo_start_lsn	        NUMERIC(25,0) NULL,
    redo_start_fork_guid	UNIQUEIDENTIFIER NULL,
    redo_target_lsn	        NUMERIC(25,0) NULL,
    redo_target_fork_guid	UNIQUEIDENTIFIER NULL,
    backup_lsn	            NUMERIC(25,0) NULL,
    credential_id	        INT NULL
    
    CONSTRAINT PK_SysMasterFiles 
        PRIMARY KEY NONCLUSTERED (database_id, file_id))
WITH (MEMORY_OPTIMIZED = ON)

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL
GO
