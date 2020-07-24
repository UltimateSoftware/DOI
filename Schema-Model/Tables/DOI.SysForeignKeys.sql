
GO

CREATE TABLE [DOI].[SysForeignKeys]
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
ALTER TABLE [DOI].[SysForeignKeys] ADD CONSTRAINT [Chk_SysForeignKeys_DeploymentTime] CHECK (([DeploymentTime]='Deployment' OR [DeploymentTime]='Job'))
GO
