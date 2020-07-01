IF OBJECT_ID('[DOI].[spRefreshMetadata_User_91_IndexPartitions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_91_IndexPartitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_91_IndexPartitions]

AS

--EXEC DOI.spRefreshMetadata_User_IndexPartitions_RowStore_CreateTables
--EXEC DOI.spRefreshMetadata_User_IndexPartitions_ColumnStore_CreateTables
EXEC DOI.spRefreshMetadata_User_IndexPartitions_RowStore_InsertData
EXEC DOI.spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData
EXEC DOI.spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData

GO
