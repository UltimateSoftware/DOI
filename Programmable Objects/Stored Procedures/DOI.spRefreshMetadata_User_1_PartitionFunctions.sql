IF OBJECT_ID('[DOI].[spRefreshMetadata_User_1_PartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_1_PartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_1_PartitionFunctions]
    @DatabaseName NVARCHAR(128) = NULL

AS
    DROP TRIGGER IF EXISTS DOI.trUpdPartitionFunctions

    EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData
        @DatabaseName = @DatabaseName

GO