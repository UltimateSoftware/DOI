CREATE TABLE [DDI].[MappingSqlServerDMVToDDITables]
(
[DDITableName] [sys].[sysname] NOT NULL,
[SQLServerObjectName] [sys].[sysname] NOT NULL,
[SQLServerObjectType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasDatabaseIdInOutput] [bit] NOT NULL,
[FunctionParameterList] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FunctionParentDMV] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_MappingSqlServerDMVToDDITables] PRIMARY KEY NONCLUSTERED  ([DDITableName], [SQLServerObjectName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
