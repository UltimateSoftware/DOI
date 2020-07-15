USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeyColumns_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeyColumns_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeyColumns_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'SysForeignKeyColumns',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS #SysForeignKeyColumns

DROP TABLE IF EXISTS DOI.SysForeignKeyColumns


CREATE TABLE DOI.SysForeignKeyColumns (
    database_id INT NOT null,
    constraint_object_id	int	NOT NULL,
    constraint_column_id	int	NOT NULL,
    parent_object_id	    INT	NOT NULL,
    parent_column_id	    int	NOT NULL,
    referenced_object_id	int	NOT NULL,
    referenced_column_id	int	NOT NULL,

    CONSTRAINT PK_SysForeignKeyColumns
        PRIMARY KEY NONCLUSTERED (database_id, constraint_object_id, constraint_column_id)
    )

    WITH (MEMORY_OPTIMIZED = ON)


GO
