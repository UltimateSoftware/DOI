-- <Migration ID="150f406d-f790-4d50-a3f9-661f396ef4d3" />
GO

PRINT N'Dropping [DDI].[spRefreshMetadata_User_94_RefreshIndexesQueue]'
GO
IF OBJECT_ID(N'[DDI].[spRefreshMetadata_User_94_RefreshIndexesQueue]', 'P') IS NOT NULL
DROP PROCEDURE [DDI].[spRefreshMetadata_User_94_RefreshIndexesQueue]
GO
PRINT N'Dropping [DDI].[spRefreshMetadata_User_93_RefreshIndexesLog]'
GO
IF OBJECT_ID(N'[DDI].[spRefreshMetadata_User_93_RefreshIndexesLog]', 'P') IS NOT NULL
DROP PROCEDURE [DDI].[spRefreshMetadata_User_93_RefreshIndexesLog]
GO
PRINT N'Dropping [DDI].[spRefreshMetadata_User_92_NotInMetadata]'
GO
IF OBJECT_ID(N'[DDI].[spRefreshMetadata_User_92_NotInMetadata]', 'P') IS NOT NULL
DROP PROCEDURE [DDI].[spRefreshMetadata_User_92_NotInMetadata]
GO
PRINT N'Dropping [DDI].[spRefreshMetadata_User_NotInMetadata_CreateTables]'
GO
IF OBJECT_ID(N'[DDI].[spRefreshMetadata_User_NotInMetadata_CreateTables]', 'P') IS NOT NULL
DROP PROCEDURE [DDI].[spRefreshMetadata_User_NotInMetadata_CreateTables]
GO
PRINT N'Dropping [DDI].[spRefreshMetadata_User_8_RefreshIndexes_PartitionState]'
GO
IF OBJECT_ID(N'[DDI].[spRefreshMetadata_User_8_RefreshIndexes_PartitionState]', 'P') IS NOT NULL
DROP PROCEDURE [DDI].[spRefreshMetadata_User_8_RefreshIndexes_PartitionState]
GO
