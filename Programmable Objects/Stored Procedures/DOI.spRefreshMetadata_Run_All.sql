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
    @RunValidations BIT = 1,
    @ShowProgress BIT = 0,
    @Debug BIT = 0

AS

/*
    EXEC DOI.spRefreshMetadata_Run_All
        @Debug = 1
*/

BEGIN TRY
	--level 0
    
    IF @ShowProgress = 1 PRINT 'Starting SysDatabases'
	EXEC DOI.spRefreshMetadata_System_SysDatabases
		@DatabaseName = @DatabaseName

	--level 1

    IF @ShowProgress = 1 PRINT 'Starting SysFileGroups'
    EXEC [DOI].[spRefreshMetadata_System_SysFileGroups]
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysMasterFiles'
    EXEC DOI.spRefreshMetadata_System_SysMasterFiles
	    @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysDatabaseFiles'
    EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles
	    @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysPartitionFunctions'
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionFunctions]
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting PartitionFunctions Update'
    EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysAllocationUnits'
    EXEC [DOI].[spRefreshMetadata_System_SysAllocationUnits]
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysDataSpaces'
    EXEC [DOI].[spRefreshMetadata_System_SysDataSpaces]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysDestinationDataSpaces'
    EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces
	    @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysPartitionRangeValues'
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysPartitions'
    EXEC [DOI].[spRefreshMetadata_System_SysPartitions]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysPartitionSchemes'
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionSchemes]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysSchemas'
    EXEC [DOI].[spRefreshMetadata_System_SysSchemas]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysTypes'
    EXEC [DOI].[spRefreshMetadata_System_SysTypes]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysColumns'
    EXEC [DOI].[spRefreshMetadata_System_SysColumns]
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysIdentityColumns'
    EXEC [DOI].[spRefreshMetadata_System_SysIdentityColumns]
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysColumns Update'
        EXEC [DOI].[spRefreshMetadata_System_SysColumns_UpdateData]
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysCheckConstraints'
    EXEC DOI.spRefreshMetadata_System_SysCheckConstraints
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysForeignKeyColumns'
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeyColumns]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysIndexColumns'
    EXEC [DOI].[spRefreshMetadata_System_SysIndexColumns]
        @DatabaseName = @DatabaseName

    IF @IncludeMaintenance = 1
    BEGIN
       IF @ShowProgress = 1 PRINT 'Starting SysIndexPhysicalStats'
       EXEC [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]
            @DatabaseName = @DatabaseName
    END


    IF @ShowProgress = 1 PRINT 'Starting SysStatsColumns'
    EXEC [DOI].[spRefreshMetadata_System_SysStatsColumns]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysSqlModules'
    EXEC [DOI].[spRefreshMetadata_System_SysSqlModules]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysTriggers'
    EXEC DOI.spRefreshMetadata_System_SysTriggers
	    @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysStats'
    EXEC DOI.spRefreshMetadata_System_SysStats
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysDmDbStatsProperties'
    EXEC DOI.spRefreshMetadata_System_SysDmDbStatsProperties  
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysDmDbIncrementalStatsProperties'
    EXEC DOI.spRefreshMetadata_System_SysDmDbIncrementalStatsProperties
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting SysDefaultConstraints'
    EXEC DOI.spRefreshMetadata_System_SysDefaultConstraints
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysTables'
    EXEC [DOI].[spRefreshMetadata_System_SysTables]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysIndexes'
    EXEC [DOI].[spRefreshMetadata_System_SysIndexes]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysForeignKeys'
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysColumnStoreRowGroups'
    EXEC [DOI].[spRefreshMetadata_System_SysColumnStoreRowGroups]
        @DatabaseName = @DatabaseName


    --level 2

    IF @ShowProgress = 1 PRINT 'Starting SysDmOsVolumeStats'
    EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats
	    @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysStats Update'
	EXEC DOI.spRefreshMetadata_System_SysStats_UpdateData
		@DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting CheckConstraints & DefaultConstraints Update'
	EXEC DOI.spRefreshMetadata_User_Constraints_UpdateData
		@DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting Statistics Update'
	EXEC DOI.spRefreshMetadata_User_Statistics_UpdateData
		@DatabaseName = @DatabaseName
     

    IF @ShowProgress = 1 PRINT 'Starting Tables Update'
    EXEC DOI.spRefreshMetadata_User_Tables_UpdateData
		@DatabaseName = @DatabaseName

    --level 3

    IF @ShowProgress = 1 PRINT 'Starting SysForeignKeys Update'
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys_UpdateData] --only depends on the 'Tables' table because we need to find out when to deploy the FK...once we move everything to jobs we don't need this anymore.
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting ForeignKeys Update'
    EXEC [DOI].[spRefreshMetadata_User_ForeignKeys_UpdateData] --also, the 'DeploymentTime' column exists in both SysForeignKeys and ForeignKeys tables.  Why both?
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting SysIndexes Update'
	EXEC DOI.spRefreshMetadata_System_SysIndexes_UpdateData		
		@DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting IndexesColumnStore Update'
	EXEC DOI.spRefreshMetadata_User_IndexesColumnStore_UpdateData
		@DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting IndexesRowStore Update'
	EXEC DOI.spRefreshMetadata_User_IndexesRowStore_UpdateData
		@DatabaseName = @DatabaseName

    --level 4

    IF @ShowProgress = 1 PRINT 'Starting Tables_IndexAggColumns'
    EXEC [DOI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting IndexPartitions_RowStore Insert'
    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting IndexPartitions_RowStore Update'
    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting IndexPartitions_ColumnStore Insert'
    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting IndexPartitions_ColumnStore Update'
    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_UpdateData]
        @DatabaseName = @DatabaseName


    IF @ShowProgress = 1 PRINT 'Starting IndexColumns'
    EXEC DOI.spRefreshMetadata_User_IndexColumns_InsertData
		@DatabaseName = @DatabaseName
       
    IF @RunValidations = 1
    BEGIN
        IF @ShowProgress = 1 PRINT 'Starting Index Validations'
        EXEC DOI.spIndexValidations 
            @DatabaseName = @DatabaseName
    END

    IF @ShowProgress = 1 PRINT 'Starting NotInMetadata-Constraints'
    EXEC DOI.spRefreshMetadata_NotInMetadata_Constraints
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting NotInMetadata-Indexes'
    EXEC DOI.spRefreshMetadata_NotInMetadata_Indexes
        @DatabaseName = @DatabaseName

    IF @ShowProgress = 1 PRINT 'Starting NotInMetadata-Statistics'
    EXEC DOI.spRefreshMetadata_NotInMetadata_Statistics
        @DatabaseName = @DatabaseName
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH
GO