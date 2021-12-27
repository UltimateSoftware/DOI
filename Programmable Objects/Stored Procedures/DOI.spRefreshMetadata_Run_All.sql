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
    @Debug BIT = 0

AS

/*
    EXEC DOI.spRefreshMetadata_Run_All
        @Debug = 1
*/

BEGIN TRY
	--level 0

    PRINT 'Starting SysDatabases'
	EXEC DOI.spRefreshMetadata_System_SysDatabases
		@DatabaseName = @DatabaseName

	--level 1

    PRINT 'Starting SysFileGroups'
    EXEC [DOI].[spRefreshMetadata_System_SysFileGroups]
        @DatabaseName = @DatabaseName

    PRINT 'Starting SysMasterFiles'
    EXEC DOI.spRefreshMetadata_System_SysMasterFiles
	    @DatabaseName = @DatabaseName

    PRINT 'Starting SysDatabaseFiles'
    EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles
	    @DatabaseName = @DatabaseName

    PRINT 'Starting SysPartitionFunctions'
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionFunctions]
        @DatabaseName = @DatabaseName

    PRINT 'Starting PartitionFunctions Update'
    EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData
        @DatabaseName = @DatabaseName

    PRINT 'Starting SysAllocationUnits'
    EXEC [DOI].[spRefreshMetadata_System_SysAllocationUnits]
        @DatabaseName = @DatabaseName

    PRINT 'Starting SysDataSpaces'
    EXEC [DOI].[spRefreshMetadata_System_SysDataSpaces]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysDestinationDataSpaces'
    EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces
	    @DatabaseName = @DatabaseName


    PRINT 'Starting SysPartitionRangeValues'
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysPartitions'
    EXEC [DOI].[spRefreshMetadata_System_SysPartitions]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysPartitionSchemes'
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionSchemes]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysSchemas'
    EXEC [DOI].[spRefreshMetadata_System_SysSchemas]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysTypes'
    EXEC [DOI].[spRefreshMetadata_System_SysTypes]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysColumns'
    EXEC [DOI].[spRefreshMetadata_System_SysColumns]
        @DatabaseName = @DatabaseName

    PRINT 'Starting SysIdentityColumns'
    EXEC [DOI].[spRefreshMetadata_System_SysIdentityColumns]
        @DatabaseName = @DatabaseName

    PRINT 'Starting SysColumns Update'
        EXEC [DOI].[spRefreshMetadata_System_SysColumns_UpdateData]
        @DatabaseName = @DatabaseName

    PRINT 'Starting SysCheckConstraints'
    EXEC DOI.spRefreshMetadata_System_SysCheckConstraints
        @DatabaseName = @DatabaseName

    PRINT 'Starting SysForeignKeyColumns'
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeyColumns]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysIndexColumns'
    EXEC [DOI].[spRefreshMetadata_System_SysIndexColumns]
        @DatabaseName = @DatabaseName

    IF @IncludeMaintenance = 1
    BEGIN
       PRINT 'Starting SysIndexPhysicalStats'
       EXEC [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]
            @DatabaseName = @DatabaseName
    END


    PRINT 'Starting SysStatsColumns'
    EXEC [DOI].[spRefreshMetadata_System_SysStatsColumns]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysSqlModules'
    EXEC [DOI].[spRefreshMetadata_System_SysSqlModules]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysTriggers'
    EXEC DOI.spRefreshMetadata_System_SysTriggers
	    @DatabaseName = @DatabaseName


    PRINT 'Starting SysStats'
    EXEC DOI.spRefreshMetadata_System_SysStats
        @DatabaseName = @DatabaseName

    --EXEC [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]    
    --    @DatabaseName = @DatabaseName


    PRINT 'Starting SysDefaultConstraints'
    EXEC DOI.spRefreshMetadata_System_SysDefaultConstraints
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysTables'
    EXEC [DOI].[spRefreshMetadata_System_SysTables]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysIndexes'
    EXEC [DOI].[spRefreshMetadata_System_SysIndexes]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysForeignKeys'
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys]
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysColumnStoreRowGroups'
    EXEC [DOI].[spRefreshMetadata_System_SysColumnStoreRowGroups]
        @DatabaseName = @DatabaseName


    --level 2

    PRINT 'Starting SysDmOsVolumeStats'
    EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats
	    @DatabaseName = @DatabaseName


    PRINT 'Starting SysStats Update'
	EXEC DOI.spRefreshMetadata_System_SysStats_UpdateData
		@DatabaseName = @DatabaseName


    PRINT 'Starting Statistics Update'
	EXEC DOI.spRefreshMetadata_User_Statistics_UpdateData
		@DatabaseName = @DatabaseName
     

    PRINT 'Starting Tables Update'
    EXEC DOI.spRefreshMetadata_User_Tables_UpdateData
		@DatabaseName = @DatabaseName

    --level 3

    PRINT 'Starting SysForeignKeys Update'
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys_UpdateData] --only depends on the 'Tables' table because we need to find out when to deploy the FK...once we move everything to jobs we don't need this anymore.
        @DatabaseName = @DatabaseName


    PRINT 'Starting ForeignKeys Update'
    EXEC [DOI].[spRefreshMetadata_User_ForeignKeys_UpdateData] --also, the 'DeploymentTime' column exists in both SysForeignKeys and ForeignKeys tables.  Why both?
        @DatabaseName = @DatabaseName


    PRINT 'Starting SysIndexes Update'
	EXEC DOI.spRefreshMetadata_System_SysIndexes_UpdateData		
		@DatabaseName = @DatabaseName


    PRINT 'Starting IndexesColumnStore Update'
	EXEC DOI.spRefreshMetadata_User_IndexesColumnStore_UpdateData
		@DatabaseName = @DatabaseName


    PRINT 'Starting IndexesRowStore Update'
	EXEC DOI.spRefreshMetadata_User_IndexesRowStore_UpdateData
		@DatabaseName = @DatabaseName

    --level 4

    PRINT 'Starting Tables_IndexAggColumns'
    EXEC [DOI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData]
        @DatabaseName = @DatabaseName


    PRINT 'Starting IndexPartitions_RowStore Insert'
    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_InsertData]
        @DatabaseName = @DatabaseName


    PRINT 'Starting IndexPartitions_RowStore Update'
    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData]
        @DatabaseName = @DatabaseName


    PRINT 'Starting IndexPartitions_ColumnStore Insert'
    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData]
        @DatabaseName = @DatabaseName


    PRINT 'Starting IndexPartitions_ColumnStore Update'
    EXEC [DOI].[spRefreshMetadata_User_IndexPartitions_ColumnStore_UpdateData]
        @DatabaseName = @DatabaseName


    PRINT 'Starting IndexColumns'
    EXEC DOI.spRefreshMetadata_User_IndexColumns_InsertData
		@DatabaseName = @DatabaseName
       
    IF @RunValidations = 1
    BEGIN
        PRINT 'Starting Index Validations'
        EXEC DOI.spIndexValidations 
            @DatabaseName = @DatabaseName
    END

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH
GO