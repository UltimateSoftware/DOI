IF OBJECT_ID('[DOI].[spRefreshMetadata_User_7_IndexColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_7_IndexColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_7_IndexColumns]

AS

	--EXEC DOI.spRefreshMetadata_User_IndexColumns_CreateTables
	EXEC DOI.spRefreshMetadata_User_IndexColumns_InsertData

GO
