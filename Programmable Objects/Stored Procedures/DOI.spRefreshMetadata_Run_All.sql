IF OBJECT_ID('[DOI].[spRefreshMetadata_Run_All]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_Run_All];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_Run_All]
    @DatabaseName NVARCHAR(128) = NULL,
    @IncludeMaintenance BIT = 0,
    @Debug BIT = 0

AS

/*
    EXEC DOI.spRefreshMetadata_Run_All
        @Debug = 1
*/

BEGIN TRY
	--level 0
	EXEC DOI.spRefreshMetadata_System_SysDatabases
		@DatabaseName = @DatabaseName

	--level 1
    EXEC [DOI].[spRefreshMetadata_System_SysFileGroups]
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysMasterFiles
	    @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles
	    @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysPartitionFunctions]
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysAllocationUnits]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysDataSpaces]
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces
	    @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysPartitions]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysPartitionSchemes]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysSchemas]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysTypes]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysColumns]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysIdentityColumns]
        @DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_System_SysCheckConstraints
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeyColumns]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysIndexColumns]
        @DatabaseName = @DatabaseName

    IF @IncludeMaintenance = 1
    BEGIN
        EXEC [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]
            @DatabaseName = @DatabaseName
    END

    EXEC [DOI].[spRefreshMetadata_System_SysStatsColumns]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysSqlModules]
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysTriggers
	    @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysStats
        @DatabaseName = @DatabaseName

    --EXEC [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]    
    --    @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysDefaultConstraints
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysTables]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysIndexes]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys]
        @DatabaseName = @DatabaseName

    --level 2
    EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats
	    @DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_System_SysStats_UpdateData
		@DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_User_Statistics_UpdateData
		@DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_User_Tables_UpdateData
		@DatabaseName = @DatabaseName

    --level 3
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys_UpdateData] --only depends on the 'Tables' table because we need to find out when to deploy the FK...once we move everything to jobs we don't need this anymore.
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_User_ForeignKeys_UpdateData] --also, the 'DeploymentTime' column exists in both SysForeignKeys and ForeignKeys tables.  Why both?
        @DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_System_SysIndexes_UpdateData		
		@DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_User_IndexesColumnStore_UpdateData
		@DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_User_IndexesRowStore_UpdateData
		@DatabaseName = @DatabaseName

    --level 4
    EXEC [DOI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_UpdateData]
        @DatabaseName = @DatabaseName
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH
GO