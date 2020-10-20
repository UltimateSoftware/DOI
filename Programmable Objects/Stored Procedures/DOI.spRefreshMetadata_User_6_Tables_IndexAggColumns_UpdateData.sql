
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_6_Tables_IndexAggColumns_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_6_Tables_IndexAggColumns_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_6_Tables_IndexAggColumns_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL
AS

EXEC [DOI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData]
    @DatabaseName = @DatabaseName
GO
