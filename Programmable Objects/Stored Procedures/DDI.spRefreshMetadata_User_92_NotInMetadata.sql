IF OBJECT_ID('[DDI].[spRefreshMetadata_User_92_NotInMetadata]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_92_NotInMetadata];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_92_NotInMetadata]

AS

	EXEC [DDI].[spRefreshMetadata_User_NotInMetadata_CreateTables]
GO
