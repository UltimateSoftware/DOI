IF OBJECT_ID('[DOI].[spRefreshMetadata_4_IndexColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_4_IndexColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_4_IndexColumns]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC [DOI].[spRefreshMetadata_3_Indexes]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysIndexColumns]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_User_IndexColumns_InsertData]
        @DatabaseName = @DatabaseName

GO