CREATE TABLE [DOI].[DefaultConstraints]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_DefaultConstraints] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DOI].[DefaultConstraints] ADD CONSTRAINT [FK_DefaultConstraints_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName]) REFERENCES [DOI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
ALTER TABLE [DOI].[DefaultConstraints] NOCHECK CONSTRAINT [FK_DefaultConstraints_Tables]
GO
