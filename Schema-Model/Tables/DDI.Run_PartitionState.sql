CREATE TABLE [DDI].[Run_PartitionState]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SchemaName] [sys].[sysname] NOT NULL,
[ParentTableName] [sys].[sysname] NOT NULL,
[PrepTableName] [sys].[sysname] NOT NULL,
[PartitionFromValue] [date] NOT NULL,
[PartitionToValue] [date] NOT NULL,
[DataSynchState] [bit] NOT NULL,
[LastUpdateDateTime] [datetime] NULL CONSTRAINT [Def_Run_PartitionState_LastUpdateDateTime] DEFAULT (getdate())
)
GO
ALTER TABLE [DDI].[Run_PartitionState] ADD CONSTRAINT [PK_Run_PartitionState] PRIMARY KEY CLUSTERED  ([DatabaseName], [SchemaName], [ParentTableName], [PrepTableName], [PartitionFromValue])
GO
