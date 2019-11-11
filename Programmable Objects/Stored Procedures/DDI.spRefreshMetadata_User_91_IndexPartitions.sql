IF OBJECT_ID('[DDI].[spRefreshMetadata_User_91_IndexPartitions]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_91_IndexPartitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_91_IndexPartitions]

AS

--EXEC DDI.spRefreshMetadata_User_IndexPartitions_RowStore_CreateTables
--EXEC DDI.spRefreshMetadata_User_IndexPartitions_ColumnStore_CreateTables
EXEC DDI.spRefreshMetadata_User_IndexPartitions_RowStore_InsertData
EXEC DDI.spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData
EXEC DDI.spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData

GO
