IF OBJECT_ID('[DOI].[spRefreshMetadata_3_Indexes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_3_Indexes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_3_Indexes]
    @DatabaseName NVARCHAR(128) = NULL

AS
    --Level 0
	EXEC DOI.spRefreshMetadata_System_SysDatabases
		@DatabaseName = @DatabaseName

    --Level 1
    EXEC [DOI].[spRefreshMetadata_System_SysAllocationUnits]
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysMasterFiles
	    @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles
	    @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysDataSpaces]
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces
	    @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysPartitionFunctions]
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData
        @DatabaseName = @DatabaseName
		 
    EXEC [DOI].[spRefreshMetadata_System_SysPartitions]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysPartitionSchemes]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysTypes]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysSchemas]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysColumns]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysIndexColumns]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]
        @DatabaseName = @DatabaseName

	--Level 2
    EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats
	    @DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_System_SysStats_UpdateData
		@DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_User_Statistics_UpdateData
		@DatabaseName = @DatabaseName

    --Level 3
	EXEC DOI.spRefreshMetadata_System_SysIndexes
		@DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_System_SysIndexes_UpdateData		
		@DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_System_SysTables	
		@DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_User_IndexesColumnStore_UpdateData
		@DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_User_IndexesRowStore_UpdateData
		@DatabaseName = @DatabaseName

GO