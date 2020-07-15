USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysCheckConstraints_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysCheckConstraints_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysCheckConstraints_CreateTables]

AS

DROP TABLE IF EXISTS #SysCheckConstraints

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'SysCheckConstraints',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DOI.SysCheckConstraints


CREATE TABLE DOI.SysCheckConstraints(
    database_id                 INT NOT NULL,
    name	                    sysname,
    object_id	                int	NOT NULL,
    principal_id	            INT	NULL,
    schema_id	                INT	NOT NULL,
    parent_object_id	        INT	NOT NULL,
    type	                    CHAR(2) NULL,
    type_desc	                NVARCHAR(60) NULL,
    create_date	                DATETIME NOT NULL,
    modify_date	                DATETIME NOT NULL,
    is_ms_shipped	            BIT	NOT NULL,
    is_published	            BIT	NOT NULL,
    is_schema_published	        BIT	NOT NULL,
    is_disabled	                BIT	NOT NULL,
    is_not_for_replication	    BIT	NOT NULL,
    is_not_trusted	            BIT	NOT NULL,
    parent_column_id	        INT	NOT NULL,
    definition	                NVARCHAR(MAX) NULL,
    uses_database_collation	    BIT	NULL,
    is_system_named	            BIT	NOT NULL
    
    CONSTRAINT PK_SysCheckConstraints
        PRIMARY KEY NONCLUSTERED (database_id, object_id))
WITH (MEMORY_OPTIMIZED = ON)

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL
GO
