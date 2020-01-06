-- <Migration ID="b24fe523-c6f3-4b5c-b70c-b41d635e0248" TransactionHandling="Custom" />
PRINT N'Creating [DDI].[IndexesNotInMetadata]'
GO
DROP TABLE IF EXISTS [DDI].[IndexesNotInMetadata]
GO
CREATE TABLE [DDI].[IndexesNotInMetadata]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [Def_IndexesNotInMetadata_DateInserted] DEFAULT (getdate()),
[DropSQLScript] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Ignore] [bit] NOT NULL CONSTRAINT [Def_IndexesNotInMetadata_Ignore] DEFAULT ((0)),
CONSTRAINT [PK_IndexesNotInMetadata] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [DateInserted])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[DefaultConstraintsNotInMetadata]'
GO
DROP TABLE IF EXISTS [DDI].[DefaultConstraintsNotInMetadata]
GO
CREATE TABLE [DDI].[DefaultConstraintsNotInMetadata]
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

PRINT N'Creating [DDI].[CheckConstraintsNotInMetadata]'
GO
DROP TABLE IF EXISTS [DDI].[CheckConstraintsNotInMetadata]
GO
CREATE TABLE [DDI].[CheckConstraintsNotInMetadata]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDisabled] [bit] NOT NULL,
[CheckConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CONSTRAINT [PK_CheckConstraintsNotInMetadata] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [CheckConstraintName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
