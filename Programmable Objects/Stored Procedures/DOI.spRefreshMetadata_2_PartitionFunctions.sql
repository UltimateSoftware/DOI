IF OBJECT_ID('[DOI].[spRefreshMetadata_2_PartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_2_PartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_2_PartitionFunctions]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_1_DataSpaces
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysMasterFiles
	    @DatabaseName = @DatabaseName
    EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles
	    @DatabaseName = @DatabaseName


    --DROP TRIGGER IF EXISTS DOI.trUpdPartitionFunctions --this trigger is disabled in V2.
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysPartitionFunctions]
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData
        @DatabaseName = @DatabaseName

GO