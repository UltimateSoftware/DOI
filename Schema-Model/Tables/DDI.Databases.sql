CREATE TABLE [DOI].[Databases]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CONSTRAINT [PK_Databases] PRIMARY KEY NONCLUSTERED  ([DatabaseName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
