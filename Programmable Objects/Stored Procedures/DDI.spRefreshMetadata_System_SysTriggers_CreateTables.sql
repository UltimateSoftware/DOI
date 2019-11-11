IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysTriggers_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysTriggers_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysTriggers_CreateTables]

AS

DROP TABLE IF EXISTS #SysTriggers

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'SysTriggers',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DDI.SysTriggers


CREATE TABLE DDI.SysTriggers(
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

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL
GO
