CREATE TABLE [DOI].[SysSchemas]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[schema_id] [int] NOT NULL,
[principal_id] [int] NULL,
CONSTRAINT [PK_SysSchemas] PRIMARY KEY NONCLUSTERED  ([database_id], [schema_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
