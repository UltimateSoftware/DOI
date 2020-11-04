
GO

CREATE TABLE [DOI].[ForeignKeys]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[ParentSchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[FKName] [sys].[sysname] NOT NULL,
[ParentColumnList_Desired] [varchar] (MAX) NOT NULL,
[ReferencedSchemaName] [sys].[sysname] NOT NULL,
[ReferencedTableName] [sys].[sysname] NOT NULL,
[ReferencedColumnList_Desired] [varchar] (MAX) NOT NULL,
[ParentColumnList_Actual] [varchar] (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferencedColumnList_Actual] [varchar] (MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeploymentTime] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_ForeignKeys] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [ParentSchemaName], [ParentTableName], [FKName])
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
