IF OBJECT_ID('[DOI].[spRefreshMetadata_1_PartitionSchemes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_1_PartitionSchemes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_1_PartitionSchemes]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysPartitionSchemes]
        @DatabaseName = @DatabaseName

GO