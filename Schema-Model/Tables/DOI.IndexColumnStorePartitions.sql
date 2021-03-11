
GO

CREATE TABLE [DOI].[IndexPartitionsColumnStore]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionDataCompression] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_OptionDataCompression] DEFAULT ('COLUMNSTORE'),
[NumRows] [BIGINT] NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_NumRows] DEFAULT ((0)),
[TotalPages] [BIGINT] NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_TotalPages] DEFAULT ((0)),
[PartitionType] [VARCHAR] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_PartitionType] DEFAULT ('ColumnStore'),
[TotalIndexPartitionSizeInMB] [DECIMAL] (10, 2) NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_TotalIndexPartitionSizeInMB] DEFAULT ((0.00)),
[Fragmentation] [FLOAT] NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_Fragmentation] DEFAULT ((0)),
[DataFileName] [NVARCHAR] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_DataFileName] DEFAULT (''),
[DriveLetter] [CHAR] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_DriveLetter] DEFAULT (''),
[PartitionUpdateType] [VARCHAR] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_PartitionUpdateType] DEFAULT ('None'),
[IsMissingFromSQLServer] BIT NOT NULL CONSTRAINT [Def_IndexPartitionsColumnStore_IsMissingFromSQLServer] DEFAULT ((0)),
CONSTRAINT [PK_IndexPartitionsColumnStore] PRIMARY KEY NONCLUSTERED  ([SchemaName], [TableName], [IndexName], [PartitionNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DOI].[IndexPartitionsColumnStore] ADD CONSTRAINT [Chk_IndexPartitionsColumnStore_OptionDataCompression] CHECK (([OptionDataCompression]='COLUMNSTORE_ARCHIVE' OR [OptionDataCompression]='COLUMNSTORE'))
GO
ALTER TABLE [DOI].[IndexPartitionsColumnStore] ADD CONSTRAINT [FK_IndexPartitionsColumnStore_IndexesColumnStore] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName], [IndexName]) REFERENCES [DOI].[IndexesColumnStore] ([DatabaseName], [SchemaName], [TableName], [IndexName])
GO
ALTER TABLE [DOI].[IndexPartitionsColumnStore] NOCHECK CONSTRAINT [FK_IndexPartitionsColumnStore_IndexesColumnStore]
GO
