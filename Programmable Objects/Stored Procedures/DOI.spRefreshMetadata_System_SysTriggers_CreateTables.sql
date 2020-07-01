IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysTriggers_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysTriggers_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysTriggers_CreateTables]

AS

DROP TABLE IF EXISTS #SysTriggers

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'SysTriggers',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DOI.SysTriggers


CREATE TABLE DOI.SysTriggers(
    database_id             INT NOT NULL,
    name	                SYSNAME,
    object_id	            INT NOT NULL,
    parent_class	        TINYINT NOT NULL,
    parent_class_desc	    NVARCHAR(60) NULL,
    parent_id	            INT NOT NULL,
    type	                CHAR(2) NULL,
    type_desc	            NVARCHAR(60) NULL,
    create_date	            DATETIME NOT NULL,
    modify_date	            DATETIME NOT NULL,
    is_ms_shipped	        BIT NOT NULL,
    is_disabled	            BIT NOT NULL,
    is_not_for_replication	BIT NOT NULL,
    is_instead_of_trigger	BIT NOT NULL,
   
    CONSTRAINT PK_SysTriggers 
        PRIMARY KEY NONCLUSTERED (database_id, parent_id, object_id))
WITH (MEMORY_OPTIMIZED = ON)

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL
GO
