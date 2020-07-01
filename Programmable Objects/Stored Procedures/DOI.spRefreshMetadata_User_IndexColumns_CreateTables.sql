IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexColumns_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexColumns_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexColumns_CreateTables]

AS


DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'IndexColumns',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DOI.IndexColumns


CREATE TABLE DOI.IndexColumns (
    DatabaseName SYSNAME,
    SchemaName SYSNAME,
    TableName SYSNAME,
    IndexName SYSNAME,
    ColumnName SYSNAME,
    IsKeyColumn BIT NOT NULL,
    KeyColumnPosition SMALLINT NULL,
    IsIncludedColumn BIT NOT NULL,
    IncludedColumnPosition SMALLINT NULL,
    IsFixedSize BIT NOT NULL
        CONSTRAINT Def_IndexColumns_IsFixedSize
            DEFAULT 0,
    ColumnSize DECIMAL(10,2) NOT NULL
        CONSTRAINT Def_IndexColumns_ColumnSize
            DEFAULT 0

    CONSTRAINT PK_IndexColumns
        PRIMARY KEY NONCLUSTERED (DatabaseName, SchemaName, TableName, IndexName, ColumnName),

    CONSTRAINT FK_IndexColumns_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DOI.Tables(DatabaseName, SchemaName, TableName)
    )

    WITH (MEMORY_OPTIMIZED = ON)


EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL
GO
