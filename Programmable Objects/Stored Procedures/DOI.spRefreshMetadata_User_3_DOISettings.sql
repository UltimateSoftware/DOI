USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_3_DOISettings]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_3_DOISettings];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_3_DOISettings]
AS

--EXEC DOI.spRefreshMetadata_User_DOISettings_CreateTables
EXEC DOI.spRefreshMetadata_User_DOISettings_InsertData
GO
