IF OBJECT_ID('[DOI].[spRefreshMetadata_1_Schemas]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_1_Schemas];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_1_Schemas]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysSchemas]
        @DatabaseName = @DatabaseName

GO