IF OBJECT_ID('[DOI].[spRefreshMetadata_2_Statistics]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_2_Statistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_2_Statistics]
    @DatabaseName NVARCHAR(128) = NULL

AS
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName
	EXEC [DOI].[spRefreshMetadata_System_SysSchemas]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysTables]
        @DatabaseName = @DatabaseName
    EXEC [DOI].[spRefreshMetadata_System_SysColumns]
        @DatabaseName = @DatabaseName
	EXEC [DOI].[spRefreshMetadata_System_SysStats]
        @DatabaseName = @DatabaseName
	EXEC [DOI].[spRefreshMetadata_System_SysStatsColumns]
        @DatabaseName = @DatabaseName
    EXEC [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]    
        @DatabaseName = @DatabaseName

	EXEC DOI.spRefreshMetadata_System_SysStats_UpdateData
		@DatabaseName = @DatabaseName
	EXEC DOI.spRefreshMetadata_User_Statistics_UpdateData
		@DatabaseName = @DatabaseName
GO