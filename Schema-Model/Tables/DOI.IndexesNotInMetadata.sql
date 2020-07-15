USE [$(DatabaseName2)]
GO

CREATE TABLE [DOI].[IndexesNotInMetadata]
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
