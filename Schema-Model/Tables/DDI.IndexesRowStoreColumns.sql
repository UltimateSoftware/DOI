CREATE TABLE [DDI].[IndexesRowStoreColumns]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[TableName] [sys].[sysname] NOT NULL,
[IndexName] [sys].[sysname] NOT NULL,
[ColumnName] [sys].[sysname] NOT NULL,
[IsKeyColumn] [bit] NOT NULL,
[IsIncludedColumn] [bit] NOT NULL,
[IsFixedSize] [bit] NOT NULL,
[ColumnSize] [decimal] (10, 2) NOT NULL,
CONSTRAINT [PK_IndexesRowStoreColumns] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
