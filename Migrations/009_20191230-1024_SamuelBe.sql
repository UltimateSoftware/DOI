-- <Migration ID="c9513f69-371b-4857-aea1-9423d34a5c71" TransactionHandling="Custom" />
GO

PRINT N'Dropping constraints from [DDI].[RefreshIndexesLog]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_RefreshIndexesLog_RunStatus]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[RefreshIndexesLog]', 'U'))
ALTER TABLE [DDI].[RefreshIndexesLog] DROP CONSTRAINT [Chk_RefreshIndexesLog_RunStatus]
GO
PRINT N'Dropping constraints from [DDI].[RefreshIndexesQueue]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_RefreshIndexesQueue_IndexOperation]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[RefreshIndexesQueue]', 'U'))
ALTER TABLE [DDI].[RefreshIndexesQueue] DROP CONSTRAINT [Chk_RefreshIndexesQueue_IndexOperation]
GO
PRINT N'Dropping constraints from [DDI].[RefreshIndexesQueue]'
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DDI].[Chk_RefreshIndexesQueue_RunStatus]', 'C') AND parent_object_id = OBJECT_ID(N'[DDI].[RefreshIndexesQueue]', 'U'))
ALTER TABLE [DDI].[RefreshIndexesQueue] DROP CONSTRAINT [Chk_RefreshIndexesQueue_RunStatus]
GO
PRINT N'Dropping [DDI].[RefreshIndexesQueue]'
GO
IF OBJECT_ID(N'[DDI].[RefreshIndexesQueue]', 'U') IS NOT NULL
DROP TABLE [DDI].[RefreshIndexesQueue]
GO
PRINT N'Dropping [DDI].[RefreshIndexesLog]'
GO
IF OBJECT_ID(N'[DDI].[RefreshIndexesLog]', 'U') IS NOT NULL
DROP TABLE [DDI].[RefreshIndexesLog]
GO
PRINT N'Dropping [DDI].[RefreshIndexes_PartitionState]'
GO
IF OBJECT_ID(N'[DDI].[RefreshIndexes_PartitionState]', 'U') IS NOT NULL
DROP TABLE [DDI].[RefreshIndexes_PartitionState]
GO
