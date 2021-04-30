IF OBJECT_ID('[DOI].[spRefreshMetadata_1_Triggers]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_1_Triggers];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_1_Triggers]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysTriggers --SysDatabases, SysTriggers
	    @DatabaseName = @DatabaseName

GO