IF OBJECT_ID('[DDI].[spRefreshMetadata_User_3_DDISettings]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_3_DDISettings];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_3_DDISettings]
AS

--EXEC DDI.spRefreshMetadata_User_DDISettings_CreateTables
EXEC DDI.spRefreshMetadata_User_DDISettings_InsertData
GO
