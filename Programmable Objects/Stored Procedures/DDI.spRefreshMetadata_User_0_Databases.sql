IF OBJECT_ID('[DDI].[spRefreshMetadata_User_0_Databases]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_0_Databases];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_0_Databases]
AS

EXEC [DDI].[spRefreshMetadata_User_Databases_InsertData]

GO