IF OBJECT_ID('[DOI].[spRefreshMetadata_2_Tables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_2_Tables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_2_Tables]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_1_Schemas
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_1_Columns
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_1_Types
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_2_PartitionFunctions
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_1_DataSpaces
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_2_PartitionFunctions
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysTables]
        @DatabaseName = @DatabaseName

    --Sysindexes, to get actual storage of table.
    EXEC [DOI].[spRefreshMetadata_System_SysIndexes]
        @DatabaseName = @DatabaseName


    EXEC DOI.spRefreshMetadata_User_Tables_UpdateData
        @DatabaseName = @DatabaseName

GO