IF OBJECT_ID('[DDI].[spRefreshMetadataForView]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadataForView];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadataForView]
    @ViewName SYSNAME
    
AS

DECLARE @SQL VARCHAR(MAX) = DDI.fnRefreshMetadataForViewSQL(@ViewName)

EXEC(@SQL)
GO
