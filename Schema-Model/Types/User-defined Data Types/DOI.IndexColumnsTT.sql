IF TYPE_ID('[DOI].[IndexColumnsTT]') IS NOT NULL
	DROP TYPE [DOI].[IndexColumnsTT];

GO
CREATE TYPE [DOI].[IndexColumnsTT] AS TABLE
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[TableName] [sys].[sysname] NOT NULL,
[IndexName] [sys].[sysname] NOT NULL,
[KeyColumnList_Desired] [varchar] (max) NOT NULL,
[IncludedColumnList_Desired] [varchar] (max) NULL,
PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [TableName], [IndexName])
)
GO
