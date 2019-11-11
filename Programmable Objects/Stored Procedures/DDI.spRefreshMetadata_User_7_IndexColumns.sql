IF OBJECT_ID('[DDI].[spRefreshMetadata_User_7_IndexColumns]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_7_IndexColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_7_IndexColumns]

AS

	--EXEC DDI.spRefreshMetadata_User_IndexColumns_CreateTables
	EXEC DDI.spRefreshMetadata_User_IndexColumns_InsertData

GO
