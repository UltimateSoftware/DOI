CREATE TABLE [DDI].[RefreshIndexes_PartitionState]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[PrepTableName] [sys].[sysname] NOT NULL,
[PartitionFromValue] [date] NOT NULL,
[PartitionToValue] [date] NOT NULL,
[DataSynchState] [bit] NOT NULL,
[LastUpdateDateTime] [datetime] NULL CONSTRAINT [Def_RefreshIndexes_PartitionState_LastUpdateDateTime] DEFAULT (getdate()),
CONSTRAINT [PK_RefreshIndexes_PartitionState] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [ParentTableName], [PrepTableName], [PartitionFromValue])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
