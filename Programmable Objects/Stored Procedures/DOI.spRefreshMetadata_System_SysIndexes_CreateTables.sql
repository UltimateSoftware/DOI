
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexes_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexes_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexes_CreateTables]

AS

DROP TABLE IF EXISTS #SysIndexes

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'SysIndexes',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DOI.SysIndexes


CREATE TABLE DOI.SysIndexes(
    database_id INT NOT NULL,
    object_id INT NOT NULL,
    name NVARCHAR(128) NULL ,
    index_id INT NOT NULL,
    type TINYINT NOT NULL ,
    type_desc NVARCHAR(60) NOT NULL ,
    is_unique BIT NOT NULL ,
    data_space_id INT NULL, 
    ignore_dup_key BIT NOT NULL ,
    is_primary_key BIT NOT NULL ,
    is_unique_constraint BIT NOT NULL ,
    fill_factor TINYINT NOT NULL ,
    is_padded BIT NOT NULL ,
    is_disabled BIT NOT NULL ,
    is_hypothetical BIT NOT NULL ,
    allow_row_locks BIT NOT NULL ,
    allow_page_locks BIT NOT NULL ,
    has_filter BIT NOT NULL ,
    filter_definition NVARCHAR(MAX) NULL ,
    compression_delay INT NULL
    
    CONSTRAINT PK_SysIndexes 
        PRIMARY KEY NONCLUSTERED (database_id, object_id, index_id))
WITH (MEMORY_OPTIMIZED = ON)




--ADD DERIVED COLUMNS
ALTER TABLE DOI.SysIndexes ADD 
    key_column_list NVARCHAR(MAX) NULL,
    included_column_list NVARCHAR(MAX) NULL,
    has_LOB_columns BIT NULL

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL
GO
