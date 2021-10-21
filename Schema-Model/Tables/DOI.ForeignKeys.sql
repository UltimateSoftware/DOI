
CREATE TABLE [DOI].[ForeignKeys]
(
[ForeignKeyId] [uniqueidentifier] NOT NULL CONSTRAINT [Def_ForeignKeys_ForeignKeyId] DEFAULT (newid()),
[DatabaseName] [sys].[sysname] NOT NULL,
[ParentSchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[FKName] [sys].[sysname] NOT NULL CONSTRAINT [Def_ForeignKeys_FKName] DEFAULT ('NameNotUpdatedYet'),
[ParentColumnList_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReferencedSchemaName] [sys].[sysname] NOT NULL,
[ReferencedTableName] [sys].[sysname] NOT NULL,
[ReferencedColumnList_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParentColumnList_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferencedColumnList_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeploymentTime] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_ForeignKeys] PRIMARY KEY NONCLUSTERED ([ForeignKeyId])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DOI].[ForeignKeys] ADD CONSTRAINT [FK_ForeignKeys_ParentTables] FOREIGN KEY ([DatabaseName], [ParentSchemaName], [ParentTableName]) REFERENCES [DOI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
ALTER TABLE [DOI].[ForeignKeys] ADD CONSTRAINT [FK_ForeignKeys_ReferencedTables] FOREIGN KEY ([DatabaseName], [ReferencedSchemaName], [ReferencedTableName]) REFERENCES [DOI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
ALTER TABLE [DOI].[ForeignKeys] NOCHECK CONSTRAINT [FK_ForeignKeys_ParentTables]
GO
ALTER TABLE [DOI].[ForeignKeys] NOCHECK CONSTRAINT [FK_ForeignKeys_ReferencedTables]
GO
