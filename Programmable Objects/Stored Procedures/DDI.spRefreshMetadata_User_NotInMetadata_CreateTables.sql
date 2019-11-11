IF OBJECT_ID('[DDI].[spRefreshMetadata_User_NotInMetadata_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_NotInMetadata_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_NotInMetadata_CreateTables]

AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'IndexesNotInMetadata',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

EXEC DDI.spBackupTableWithDateName 
	@SchemaName = 'DDI',
	@TableName = 'IndexesNotInMetadata'

DROP TABLE IF EXISTS DDI.IndexesNotInMetadata


	CREATE TABLE DDI.IndexesNotInMetadata (
		SchemaName NVARCHAR(128) NOT NULL,
		TableName NVARCHAR(128) NOT NULL,
		IndexName NVARCHAR(128) NOT NULL,
		DateInserted DATETIME NOT NULL
			CONSTRAINT Def_IndexesNotInMetadata_DateInserted
				DEFAULT(GETDATE()),
		DropSQLScript VARCHAR(500) NOT NULL,
		Ignore BIT NOT NULL
			CONSTRAINT Def_IndexesNotInMetadata_Ignore
				DEFAULT 0
		CONSTRAINT PK_IndexesNotInMetadata
			PRIMARY KEY NONCLUSTERED (SchemaName, TableName, IndexName, DateInserted))

WITH (MEMORY_OPTIMIZED = ON)


EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL


EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'CheckConstraintsNotInMetadata',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

EXEC DDI.spBackupTableWithDateName 
	@SchemaName = 'DDI',
	@TableName = 'CheckConstraintsNotInMetadata'


DROP TABLE IF EXISTS DDI.CheckConstraintsNotInMetadata


	CREATE TABLE DDI.CheckConstraintsNotInMetadata(
		SchemaName					NVARCHAR(128)	NOT NULL,
		TableName					NVARCHAR(128)	NOT NULL,
		ColumnName					NVARCHAR(128)	NULL,
		CheckDefinition				NVARCHAR(MAX)	NOT NULL,
		IsDisabled					BIT				NOT NULL,
		CheckConstraintName			NVARCHAR(128)	NOT NULL
		CONSTRAINT PK_CheckConstraintsNotInMetadata
			PRIMARY KEY NONCLUSTERED(SchemaName, TableName, ColumnName))

WITH (MEMORY_OPTIMIZED = ON)


EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'DefaultConstraintsNotInMetadata',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.spBackupTableWithDateName 
	@SchemaName = 'DDI',
	@TableName = 'DefaultConstraintsNotInMetadata'


DROP TABLE IF EXISTS DDI.DefaultConstraintsNotInMetadata


	CREATE TABLE DDI.DefaultConstraintsNotInMetadata(
		SchemaName					NVARCHAR(128) NOT NULL,
		TableName					NVARCHAR(128) NOT NULL,
		ColumnName					NVARCHAR(128) NOT NULL,
		DefaultDefinition			NVARCHAR(MAX) NOT NULL,
		DefaultConstraintName       NVARCHAR(128) NULL
		CONSTRAINT PK_DefaultConstraintsNotInMetadata
			PRIMARY KEY NONCLUSTERED(SchemaName, TableName, ColumnName))

WITH (MEMORY_OPTIMIZED = ON)


EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL
GO
