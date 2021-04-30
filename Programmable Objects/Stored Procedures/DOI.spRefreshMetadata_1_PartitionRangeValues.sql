IF OBJECT_ID('[DOI].[spRefreshMetadata_1_PartitionRangeValues]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_1_PartitionRangeValues];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_1_PartitionRangeValues]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName

    --DROP TRIGGER IF EXISTS DOI.trUpdPartitionFunctions --this trigger is disabled in V2.
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
        @DatabaseName = @DatabaseName


GO