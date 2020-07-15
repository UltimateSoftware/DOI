USE [$(DatabaseName2)]
GO

CREATE TABLE [DOI].[IndexColumnStorePartitions]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionDataCompression] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexColumnStorePartitions_OptionDataCompression] DEFAULT ('COLUMNSTORE'),
CONSTRAINT [PK_IndexColumnStorePartitions] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DOI].[IndexColumnStorePartitions] ADD CONSTRAINT [Chk_IndexColumnStorePartitions_OptionDataCompression] CHECK (([OptionDataCompression]='COLUMNSTORE_ARCHIVE' OR [OptionDataCompression]='COLUMNSTORE'))
GO
ALTER TABLE [DOI].[IndexColumnStorePartitions] ADD CONSTRAINT [FK_IndexColumnStorePartitions_IndexesColumnStore] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName], [IndexName]) REFERENCES [DOI].[IndexesColumnStore] ([DatabaseName], [SchemaName], [TableName], [IndexName])
GO
ALTER TABLE [DOI].[IndexColumnStorePartitions] NOCHECK CONSTRAINT [FK_IndexColumnStorePartitions_IndexesColumnStore]
GO
