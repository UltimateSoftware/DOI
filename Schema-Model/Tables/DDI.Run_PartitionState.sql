CREATE TABLE [DDI].[Run_PartitionState]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[PrepTableName] [sys].[sysname] NOT NULL,
[PartitionFromValue] [date] NOT NULL,
[PartitionToValue] [date] NOT NULL,
[DataSynchState] [bit] NOT NULL,
[LastUpdateDateTime] [datetime] NULL CONSTRAINT [Def_Run_PartitionState_LastUpdateDateTime] DEFAULT (getdate()),
CONSTRAINT [PK_Run_PartitionState] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SchemaName], [ParentTableName], [PrepTableName], [PartitionFromValue])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [DDI].[Run_PartitionState] ADD CONSTRAINT [FK_Run_PartitionState_Tables] FOREIGN KEY ([DatabaseName], [SchemaName], [ParentTableName]) REFERENCES [DDI].[Tables] ([DatabaseName], [SchemaName], [TableName])
GO
ALTER TABLE [DDI].[Run_PartitionState] NOCHECK CONSTRAINT [FK_Run_PartitionState_Tables]
GO
