USE [$(DatabaseName2)]
GO

CREATE TABLE [DOI].[SysForeignKeyColumns]
(
[database_id] [int] NOT NULL,
[constraint_object_id] [int] NOT NULL,
[constraint_column_id] [int] NOT NULL,
[parent_object_id] [int] NOT NULL,
[parent_column_id] [int] NOT NULL,
[referenced_object_id] [int] NOT NULL,
[referenced_column_id] [int] NOT NULL,
CONSTRAINT [PK_SysForeignKeyColumns] PRIMARY KEY NONCLUSTERED  ([database_id], [constraint_object_id], [constraint_column_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
