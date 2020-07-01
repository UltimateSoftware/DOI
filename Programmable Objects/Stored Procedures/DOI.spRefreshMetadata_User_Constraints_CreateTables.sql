IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Constraints_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_Constraints_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_Constraints_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'CheckConstraints',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DOI.CheckConstraints


CREATE TABLE DOI.CheckConstraints(
    DatabaseName                NVARCHAR(128) NOT NULL,
	SchemaName					NVARCHAR(128) NOT NULL,
	TableName					NVARCHAR(128) NOT NULL,
	ColumnName					NVARCHAR(128) NULL,
	CheckDefinition				NVARCHAR(MAX) NOT NULL,
	IsDisabled					BIT NOT NULL,
	CheckConstraintName			NVARCHAR(128) NOT NULL
	CONSTRAINT PK_CheckConstraints
		PRIMARY KEY NONCLUSTERED(DatabaseName, SchemaName, TableName, CheckConstraintName),
    CONSTRAINT FK_CheckConstraints_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DOI.Tables(DatabaseName, SchemaName, TableName))
    WITH (MEMORY_OPTIMIZED = ON)

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL


DROP TABLE IF EXISTS DOI.DefaultConstraints

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'DefaultConstraints',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL


--default constraints
CREATE TABLE DOI.DefaultConstraints(
    DatabaseName                NVARCHAR(128) NOT NULL,
	SchemaName					NVARCHAR(128) NOT NULL,
	TableName					NVARCHAR(128) NOT NULL,
	ColumnName					NVARCHAR(128) NOT NULL,
	DefaultDefinition			NVARCHAR(MAX) NOT NULL,
	DefaultConstraintName       NVARCHAR(128) NULL
	CONSTRAINT PK_DefaultConstraints
		PRIMARY KEY NONCLUSTERED(DatabaseName, SchemaName, TableName, ColumnName),
    CONSTRAINT FK_DefaultConstraints_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DOI.Tables(DatabaseName, SchemaName, TableName))
    WITH (MEMORY_OPTIMIZED = ON)

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL
GO
