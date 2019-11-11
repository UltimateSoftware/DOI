IF OBJECT_ID('[DDI].[spRefreshMetadata_User_9_Statistics]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_9_Statistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_9_Statistics]
AS

--EXEC DDI.spRefreshMetadata_User_Statistics_CreateTables
EXEC DDI.spRefreshMetadata_User_Statistics_InsertData
EXEC DDI.spRefreshMetadata_User_Statistics_UpdateData

GO
