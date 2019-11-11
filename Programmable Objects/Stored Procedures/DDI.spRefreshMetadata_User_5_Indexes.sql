IF OBJECT_ID('[DDI].[spRefreshMetadata_User_5_Indexes]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_5_Indexes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_5_Indexes]
AS

--EXEC DDI.spRefreshMetadata_User_IndexesRowStore_CreateTables
--EXEC DDI.spRefreshMetadata_User_IndexesColumnStore_CreateTables
EXEC DDI.spRefreshMetadata_User_IndexesRowStore_InsertData
EXEC DDI.spRefreshMetadata_User_IndexesColumnStore_InsertData
EXEC DDI.spRefreshMetadata_User_IndexesRowStore_UpdateData
EXEC DDI.spRefreshMetadata_User_IndexesColumnStore_UpdateData
GO
