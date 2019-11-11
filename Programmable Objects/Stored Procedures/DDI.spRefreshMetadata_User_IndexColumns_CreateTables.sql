IF OBJECT_ID('[DDI].[spRefreshMetadata_User_IndexColumns_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_IndexColumns_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_IndexColumns_CreateTables]

AS


DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'IndexColumns',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DDI.IndexColumns


CREATE TABLE DDI.IndexColumns (
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
            REFERENCES DDI.Tables(DatabaseName, SchemaName, TableName)
    )

    WITH (MEMORY_OPTIMIZED = ON)


EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL
GO
