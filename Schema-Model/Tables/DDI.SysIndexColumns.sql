CREATE TABLE [DDI].[SysIndexColumns]
(
[database_id] [int] NOT NULL,
[object_id] [int] NOT NULL,
[index_id] [int] NOT NULL,
[index_column_id] [int] NOT NULL,
[column_id] [int] NOT NULL,
[key_ordinal] [tinyint] NOT NULL,
[partition_ordinal] [tinyint] NOT NULL,
[is_descending_key] [bit] NULL,
[is_included_column] [bit] NULL,
CONSTRAINT [PK_SysIndexColumns] PRIMARY KEY NONCLUSTERED  ([database_id], [object_id], [index_id], [index_column_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
