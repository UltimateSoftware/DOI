
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeys]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys]
    @DatabaseName NVARCHAR(128) = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys]
        @DatabaseId = 18
*/


EXEC DOI.spRefreshMetadata_System_SysForeignKeys_InsertData
    @DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysForeignKeys_UpdateData
    @DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_System_SysForeignKeyColumns_InsertData
    @DatabaseName = @DatabaseName

GO
