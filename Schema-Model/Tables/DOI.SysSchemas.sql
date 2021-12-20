
GO

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
IF NOT EXISTS(SELECT 'True' FROM sys.indexes WHERE name = 'IDX_SysSchemas_name')
BEGIN
    ALTER TABLE DOI.SysSchemas ADD INDEX IDX_SysSchemas_name NONCLUSTERED (name)
END
GO