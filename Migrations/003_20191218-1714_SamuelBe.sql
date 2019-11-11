-- <Migration ID="a554310f-9be4-40a7-8d38-9daace3f094c" TransactionHandling="Custom" />
GO

PRINT N'Rebuilding [DDI].[SysPartitions]'
GO
CREATE TABLE [DDI].[RG_Recovery_1_SysPartitions]
(
[database_id] [int] NOT NULL,
[partition_id] [bigint] NOT NULL,
[object_id] [int] NOT NULL,
[index_id] [int] NOT NULL,
[partition_number] [int] NOT NULL,
[hobt_id] [bigint] NOT NULL,
[rows] [bigint] NULL,
[filestream_filegroup_id] [smallint] NOT NULL,
[data_compression] [tinyint] NOT NULL,
[data_compression_desc] [nvarchar] (60) NULL
)
GO
INSERT INTO [DDI].[RG_Recovery_1_SysPartitions]([database_id], [partition_id], [object_id], [index_id], [partition_number], [hobt_id], [rows], [filestream_filegroup_id], [data_compression], [data_compression_desc]) SELECT [database_id], [partition_id], [object_id], [index_id], [partition_number], [hobt_id], [rows], [filestream_filegroup_id], [data_compression], [data_compression_desc] FROM [DDI].[SysPartitions]
GO
DROP TABLE [DDI].[SysPartitions]
GO
CREATE TABLE [DDI].[SysPartitions]
(
[database_id] [int] NOT NULL,
[partition_id] [bigint] NOT NULL,
[object_id] [int] NOT NULL,
[index_id] [int] NOT NULL,
[partition_number] [int] NOT NULL,
[hobt_id] [bigint] NOT NULL,
[rows] [bigint] NULL,
[filestream_filegroup_id] [smallint] NOT NULL,
[data_compression] [tinyint] NOT NULL,
[data_compression_desc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_SysPartitions] PRIMARY KEY NONCLUSTERED  ([database_id], [partition_id]),
CONSTRAINT [UQ_SysPartitions] UNIQUE NONCLUSTERED  ([database_id], [object_id], [index_id], [partition_number])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
INSERT INTO [DDI].[SysPartitions]([database_id], [partition_id], [object_id], [index_id], [partition_number], [hobt_id], [rows], [filestream_filegroup_id], [data_compression], [data_compression_desc]) SELECT [database_id], [partition_id], [object_id], [index_id], [partition_number], [hobt_id], [rows], [filestream_filegroup_id], [data_compression], [data_compression_desc] FROM [DDI].[RG_Recovery_1_SysPartitions]
GO
UPDATE STATISTICS [DDI].[SysPartitions] WITH FULLSCAN, NORECOMPUTE
GO
DROP TABLE [DDI].[RG_Recovery_1_SysPartitions]
GO
PRINT N'Creating [DDI].[SysForeignKeys]'
GO
IF OBJECT_ID(N'[DDI].[SysForeignKeys]', 'U') IS NULL
CREATE TABLE [DDI].[SysForeignKeys]
(
[database_id] [int] NOT NULL,
[name] [sys].[sysname] NOT NULL,
[object_id] [int] NOT NULL,
[principal_id] [int] NULL,
[schema_id] [int] NOT NULL,
[parent_object_id] [int] NOT NULL,
[type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NOT NULL,
[modify_date] [datetime] NOT NULL,
[is_ms_shipped] [bit] NOT NULL,
[is_published] [bit] NOT NULL,
[is_schema_published] [bit] NOT NULL,
[referenced_object_id] [int] NULL,
[key_index_id] [int] NULL,
[is_disabled] [bit] NOT NULL,
[is_not_for_replication] [bit] NOT NULL,
[is_not_trusted] [bit] NOT NULL,
[delete_referential_action] [tinyint] NULL,
[delete_referential_action_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_referential_action] [tinyint] NULL,
[update_referential_action_desc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_system_named] [bit] NOT NULL,
[ParentColumnList_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferencedColumnList_Actual] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeploymentTime] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_SysForeignKeys] PRIMARY KEY NONCLUSTERED  ([database_id], [name])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Creating [DDI].[SysForeignKeyColumns]'
GO
IF OBJECT_ID(N'[DDI].[SysForeignKeyColumns]', 'U') IS NULL
CREATE TABLE [DDI].[SysForeignKeyColumns]
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
PRINT N'Creating [DDI].[ForeignKeys]'
GO
IF OBJECT_ID(N'[DDI].[ForeignKeys]', 'U') IS NULL
CREATE TABLE [DDI].[ForeignKeys]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[ParentSchemaName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParentTableName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParentColumnList_Desired] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReferencedSchemaName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReferencedTableName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReferencedColumnList_Desired] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParentColumnList_Actual] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferencedColumnList_Actual] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeploymentTime] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_ForeignKeys] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
PRINT N'Adding constraints to [DDI].[SysForeignKeys]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_SysForeignKeys_DeploymentTime]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[SysForeignKeys]', 'U'))
ALTER TABLE [DDI].[SysForeignKeys] ADD CONSTRAINT [Chk_SysForeignKeys_DeploymentTime] CHECK (([DeploymentTime]='Deployment' OR [DeploymentTime]='Job'))
GO
