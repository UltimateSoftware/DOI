CREATE TABLE [DOI].[DefaultConstraintsNotInMetadata]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_DefaultConstraintsNotInMetadata] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [ColumnName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
