
GO

CREATE TABLE [DOI].[IndexPartitionsRowStore]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionResumable] [bit] NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_OptionResumable] DEFAULT ((0)),
[OptionMaxDuration] [smallint] NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_OptionMaxDuration] DEFAULT ((0)),
[OptionDataCompression] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_OptionDataCompression] DEFAULT ('PAGE'),
[NumRows] [bigint] NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_NumRows] DEFAULT ((0)),
[TotalPages] [bigint] NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_TotalPages] DEFAULT ((0)),
[PartitionType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_PartitionType] DEFAULT ('RowStore'),
[TotalIndexPartitionSizeInMB] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_TotalIndexPartitionSizeInMB] DEFAULT ((0.00)),
[Fragmentation] [float] NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_Fragmentation] DEFAULT ((0)),
[DataFileName] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_DataFileName] DEFAULT (''),
[DriveLetter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_DriveLetter] DEFAULT (''),
[PartitionUpdateType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_PartitionUpdateType] DEFAULT ('None'),
[IsMissingFromSQLServer] BIT NOT NULL CONSTRAINT [Def_IndexPartitionsRowStore_IsMissingFromSQLServer] DEFAULT ((0)),
CONSTRAINT [PK_IndexPartitionsRowStore] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DOI].[IndexPartitionsRowStore] ADD CONSTRAINT [Chk_IndexPartitionsRowStore_OptionDataCompression] CHECK (([OptionDataCompression]='PAGE' OR [OptionDataCompression]='ROW' OR [OptionDataCompression]='NONE'))
GO
ALTER TABLE [DOI].[IndexPartitionsRowStore] ADD CONSTRAINT [Chk_IndexPartitionsRowStore_PartitionType] CHECK (([PartitionType]='RowStore'))
GO
ALTER TABLE [DOI].[IndexPartitionsRowStore] ADD CONSTRAINT [FK_IndexPartitionsRowStore_IndexesRowStore] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName], [IndexName]) REFERENCES [DOI].[IndexesRowStore] ([DatabaseName], [SchemaName], [TableName], [IndexName])
GO
ALTER TABLE [DOI].[IndexPartitionsRowStore] NOCHECK CONSTRAINT [FK_IndexPartitionsRowStore_IndexesRowStore]
GO
