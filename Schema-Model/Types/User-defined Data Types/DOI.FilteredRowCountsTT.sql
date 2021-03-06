
GO

IF TYPE_ID('[DOI].[FilteredRowCountsTT]') IS NOT NULL
	DROP TYPE [DOI].[FilteredRowCountsTT];

GO
CREATE TYPE [DOI].[FilteredRowCountsTT] AS TABLE
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[TableName] [sys].[sysname] NOT NULL,
[IndexName] [sys].[sysname] NOT NULL,
[NumRows] [bigint] NOT NULL,
PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
