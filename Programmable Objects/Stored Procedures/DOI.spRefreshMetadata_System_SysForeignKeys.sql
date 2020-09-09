
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeys]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys]
    @DatabaseId INT = NULL
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys]
        @DatabaseId = 18
*/


EXEC DOI.spRefreshMetadata_System_SysForeignKeys_InsertData
    @DatabaseId = @DatabaseId
EXEC DOI.spRefreshMetadata_System_SysForeignKeys_UpdateData
    @DatabaseId = @DatabaseId
EXEC DOI.spRefreshMetadata_System_SysForeignKeyColumns_InsertData
    @DatabaseId = @DatabaseId

GO
