IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysDefaultConstraints_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysDefaultConstraints_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysDefaultConstraints_CreateTables]

AS

DROP TABLE IF EXISTS #SysDefaultConstraints

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'SysDefaultConstraints',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DDI.SysDefaultConstraints


CREATE TABLE DDI.SysDefaultConstraints(
    database_id                 INT NOT NULL,
    name	            SYSNAME,
    object_id	        INT NOT NULL,
    principal_id	    INT NULL,
    parent_object_id	INT NOT NULL, 
    schema_id	        INT NOT NULL, 
    type	            CHAR(2) NULL,
    type_desc	        NVARCHAR(60) NULL,
    create_date	        DATETIME NOT NULL,
    modify_date	        DATETIME NOT NULL,
    is_ms_shipped	    BIT NOT NULL,
    is_published	    BIT NOT NULL,
    is_schema_published	BIT NOT NULL,
    parent_column_id	INT NOT NULL,
    definition	        NVARCHAR(MAX) NULL,
    is_system_named	    BIT NOT NULL
    
    CONSTRAINT PK_SysDefaultConstraints
        PRIMARY KEY NONCLUSTERED (database_id, object_id))
WITH (MEMORY_OPTIMIZED = ON)

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL
GO
