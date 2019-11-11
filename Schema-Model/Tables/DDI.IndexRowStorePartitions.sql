CREATE TABLE [DDI].[IndexRowStorePartitions]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartitionNumber] [smallint] NOT NULL,
[OptionResumable] [bit] NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_OptionResumable] DEFAULT ((0)),
[OptionMaxDuration] [smallint] NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_OptionMaxDuration] DEFAULT ((0)),
[OptionDataCompression] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_OptionDataCompression] DEFAULT ('PAGE'),
[NumRows] [bigint] NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_NumRows] DEFAULT ((0)),
[TotalPages] [bigint] NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_TotalPages] DEFAULT ((0)),
[PartitionType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_PartitionType] DEFAULT ('RowStore'),
[TotalIndexPartitionSizeInMB] [decimal] (10, 2) NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_TotalIndexPartitionSizeInMB] DEFAULT ((0.00)),
[Fragmentation] [float] NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_Fragmentation] DEFAULT ((0)),
[DataFileName] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_DataFileName] DEFAULT (''),
[DriveLetter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_DriveLetter] DEFAULT (''),
[PartitionUpdateType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_IndexRowStorePartitions_PartitionUpdateType] DEFAULT ('None'),
CONSTRAINT [PK_IndexRowStorePartitions] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [Chk_IndexRowStorePartitions_OptionDataCompression] CHECK (([OptionDataCompression]='PAGE' OR [OptionDataCompression]='ROW' OR [OptionDataCompression]='NONE'))
GO
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [Chk_IndexRowStorePartitions_PartitionType] CHECK (([PartitionType]='RowStore'))
GO
ALTER TABLE [DDI].[IndexRowStorePartitions] ADD CONSTRAINT [FK_IndexRowStorePartitions_IndexesRowStore] FOREIGN KEY ([DatabaseName], [SchemaName], [TableName], [IndexName]) REFERENCES [DDI].[IndexesRowStore] ([DatabaseName], [SchemaName], [TableName], [IndexName])
GO
