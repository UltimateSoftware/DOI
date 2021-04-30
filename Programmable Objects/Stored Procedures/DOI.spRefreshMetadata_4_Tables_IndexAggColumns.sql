

IF OBJECT_ID('[DOI].[spRefreshMetadata_4_Tables_IndexAggColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_4_Tables_IndexAggColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_4_Tables_IndexAggColumns]
    @DatabaseName NVARCHAR(128) = NULL
AS

EXEC [DOI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData]
    @DatabaseName = @DatabaseName
GO