CREATE TABLE [DDI].[IndexColumns]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[TableName] [sys].[sysname] NOT NULL,
[IndexName] [sys].[sysname] NOT NULL,
[ColumnName] [sys].[sysname] NOT NULL,
[IsKeyColumn] [bit] NOT NULL,
[KeyColumnPosition] [smallint] NULL,
[IsIncludedColumn] [bit] NOT NULL,
[IncludedColumnPosition] [smallint] NULL,
[IsFixedSize] [bit] NOT NULL CONSTRAINT [Def_IndexColumns_IsFixedSize] DEFAULT ((0)),
[ColumnSize] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexColumns_ColumnSize] DEFAULT ((0)),
CONSTRAINT [PK_IndexColumns] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DDI].[IndexColumns] ADD CONSTRAINT [FK_IndexColumns_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
