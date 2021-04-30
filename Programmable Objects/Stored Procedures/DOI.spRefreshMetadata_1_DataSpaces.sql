IF OBJECT_ID('[DOI].[spRefreshMetadata_1_DataSpaces]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_1_DataSpaces];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_1_DataSpaces]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysDataSpaces]
        @DatabaseName = @DatabaseName
    EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces
	    @DatabaseName = @DatabaseName

GO