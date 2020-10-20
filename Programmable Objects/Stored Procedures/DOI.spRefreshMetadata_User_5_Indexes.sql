
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_5_Indexes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_5_Indexes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_5_Indexes]
    @DatabaseName NVARCHAR(128) = NULL
AS

--EXEC DOI.spRefreshMetadata_User_IndexesRowStore_CreateTables
--EXEC DOI.spRefreshMetadata_User_IndexesColumnStore_CreateTables
--EXEC DOI.spRefreshMetadata_User_IndexesRowStore_InsertData
--EXEC DOI.spRefreshMetadata_User_IndexesColumnStore_InsertData
EXEC DOI.spRefreshMetadata_User_IndexesRowStore_UpdateData
    @DatabaseName = @DatabaseName
EXEC DOI.spRefreshMetadata_User_IndexesColumnStore_UpdateData
    @DatabaseName = @DatabaseName
GO
