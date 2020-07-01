IF OBJECT_ID('[DOI].[spRefreshMetadataForView]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadataForView];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadataForView]
    @ViewName SYSNAME
    
AS

DECLARE @SQL VARCHAR(MAX) = DOI.fnRefreshMetadataForViewSQL(@ViewName)

EXEC(@SQL)
GO
