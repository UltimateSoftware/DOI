
IF OBJECT_ID('[DOI].[spRefreshMetadata_Run_System]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_Run_System];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_Run_System]
    @DatabaseName SYSNAME = NULL,
    @Debug BIT = 0
AS

/*
    EXEC DOI.spRefreshMetadata_Run_System
        @DatabaseId = 18,
        @Debug = 1

        select * from doi.sysdatabases
*/
EXEC DOI.spRefreshMetadata_System_SysDatabases
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysFileGroups
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysMasterFiles
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysAllocationUnits
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysDataSpaces
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats
	@DatabaseName = @DatabaseName


EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysPartitionRangeValues
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysPartitions
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysPartitionSchemes
	@DatabaseName = @DatabaseName


EXEC DOI.spRefreshMetadata_System_SysSchemas
	@DatabaseName = @DatabaseName

EXEC DOI.spRefreshMetadata_System_SysTypes
	@DatabaseName = @DatabaseName
 
--TABLES
EXEC DOI.spRefreshMetadata_System_SysTables
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysColumns
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysCheckConstraints
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysDefaultConstraints
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysForeignKeys
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysForeignKeyColumns
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysIndexes
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysIndexColumns
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysIndexes_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysIndexPhysicalStats
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysStats
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysStatsColumns
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysStats_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysTriggers
	@DatabaseName = @DatabaseName

--DERIVED SYSTEM METADATA
EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_User_Tables_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_User_Constraints_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_User_ForeignKeys_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_User_IndexesColumnStore_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_User_IndexesRowStore_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_User_IndexPartitions_ColumnStore_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_User_Statistics_UpdateData
	@DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData
	@DatabaseName = @DatabaseName

GO