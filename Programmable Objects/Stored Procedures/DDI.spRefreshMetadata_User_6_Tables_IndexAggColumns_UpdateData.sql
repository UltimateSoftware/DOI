IF OBJECT_ID('[DDI].[spRefreshMetadata_User_6_Tables_IndexAggColumns_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_6_Tables_IndexAggColumns_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_6_Tables_IndexAggColumns_UpdateData]
AS

EXEC [DDI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData]
GO
