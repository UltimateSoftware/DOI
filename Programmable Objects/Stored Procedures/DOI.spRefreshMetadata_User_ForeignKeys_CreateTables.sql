
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_ForeignKeys_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_ForeignKeys_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_ForeignKeys_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'ForeignKeys',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DOI.ForeignKeys

CREATE TABLE [DOI].[ForeignKeys](
    [DatabaseName] SYSNAME,
	[ParentSchemaName] SYSNAME,
	[ParentTableName] SYSNAME,
	[ParentColumnList_Desired] SYSNAME,
	[ReferencedSchemaName] SYSNAME,
	[ReferencedTableName] SYSNAME,
	[ReferencedColumnList_Desired] SYSNAME,
	[ParentColumnList_Actual] [VARCHAR](128) NULL,
   	[ReferencedColumnList_Actual] [VARCHAR](128) NULL,
    [DeploymentTime] VARCHAR(10) NULL,
        CONSTRAINT [PK_ForeignKeys] 
            PRIMARY KEY NONCLUSTERED (	DatabaseName, [ParentSchemaName] ASC,[ParentTableName] ASC,[ParentColumnList_Desired] ASC,[ReferencedSchemaName] ASC,[ReferencedTableName] ASC,[ReferencedColumnList_Desired] ASC),
        CONSTRAINT FK_ForeignKeys_ParentTables
            FOREIGN KEY (DatabaseName, ParentSchemaName, ParentTableName)
                REFERENCES DOI.Tables(DatabaseName, SchemaName, TableName),
        CONSTRAINT FK_ForeignKeys_ReferencedTables
            FOREIGN KEY (DatabaseName, ReferencedSchemaName, ReferencedTableName)
                REFERENCES DOI.Tables(DatabaseName, SchemaName, TableName)
)

WITH (MEMORY_OPTIMIZED = ON)

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL


GO
