IF OBJECT_ID('[DOI].[spRefreshMetadata_1_IndexColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_1_IndexColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_1_IndexColumns]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysIndexColumns]
        @DatabaseName = @DatabaseName

GO