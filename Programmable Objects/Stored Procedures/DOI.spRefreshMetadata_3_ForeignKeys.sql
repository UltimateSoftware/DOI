IF OBJECT_ID('[DOI].[spRefreshMetadata_3_ForeignKeys]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_3_ForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_3_ForeignKeys]
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

    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeyColumns]
        @DatabaseName = @DatabaseName
        
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys]
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_User_Tables_UpdateData
		@DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys_UpdateData]
        @DatabaseName = @DatabaseName

    EXEC [DOI].[spRefreshMetadata_User_ForeignKeys_UpdateData]
        @DatabaseName = @DatabaseName
    --also, the 'DeploymentTime' column exists in both SysForeignKeys and ForeignKeys tables.  Why both?
    --only depends on the 'Tables' table because we need to find out when to deploy the FK...once we move everything to jobs we don't need this anymore.
GO