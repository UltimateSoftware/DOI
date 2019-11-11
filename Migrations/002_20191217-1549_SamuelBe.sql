-- <Migration ID="b24fe523-c6f3-4b5c-b70c-b41d635e0248" TransactionHandling="Custom" />
PRINT N'Rebuilding [DDI].[MappingSqlServerDMVToDDITables]'
GO

DROP TABLE [DDI].[MappingSqlServerDMVToDDITables]
GO

CREATE TABLE [DDI].[MappingSqlServerDMVToDDITables]
(
[DDITableName] [sys].[sysname] NOT NULL,
[SQLServerObjectName] [sys].[sysname] NOT NULL,
[SQLServerObjectType] [VARCHAR] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasDatabaseIdInOutput] [BIT] NOT NULL,
[FunctionParameterList] [VARCHAR] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FunctionParentDMV] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_MappingSqlServerDMVToDDITables] PRIMARY KEY NONCLUSTERED  ([DDITableName], [SQLServerObjectName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO

PRINT N'Rebuilding [DDI].[SysTypes]'
GO

DROP TABLE [DDI].[SysTypes]
GO
CREATE TABLE [DDI].[SysTypes]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[system_type_id] [tinyint] NOT NULL,
[user_type_id] [int] NOT NULL,
[schema_id] [int] NOT NULL,
[principal_id] [int] NULL,
[max_length] [smallint] NOT NULL,
[precision] [tinyint] NOT NULL,
[scale] [tinyint] NOT NULL,
[collation_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_nullable] [bit] NULL,
[is_user_defined] [bit] NOT NULL,
[is_assembly_type] [bit] NOT NULL,
[default_object_id] [int] NOT NULL,
[rule_object_id] [int] NOT NULL,
[is_table_type] [bit] NOT NULL,
CONSTRAINT [PK_SysTypes] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [user_type_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO