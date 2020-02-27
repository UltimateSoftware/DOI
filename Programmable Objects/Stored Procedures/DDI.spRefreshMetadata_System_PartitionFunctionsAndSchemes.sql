IF OBJECT_ID('[DDI].[spRefreshMetadata_System_PartitionFunctionsAndSchemes]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_PartitionFunctionsAndSchemes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE      PROCEDURE [DDI].[spRefreshMetadata_System_PartitionFunctionsAndSchemes]

AS

EXEC DDI.spRefreshMetadata_System_SysDatabases
EXEC DDI.spRefreshMetadata_System_SysDatabaseFiles
EXEC DDI.spRefreshMetadata_System_SysDestinationDataSpaces
EXEC DDI.spRefreshMetadata_System_SysFileGroups
EXEC DDI.spRefreshMetadata_System_SysPartitionFunctions
EXEC DDI.spRefreshMetadata_System_SysPartitionRangeValues
EXEC DDI.spRefreshMetadata_System_SysPartitionSchemes

GO
