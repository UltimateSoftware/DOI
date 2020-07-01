IF OBJECT_ID('[DOI].[spRefreshMetadata_User_9_Statistics]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_9_Statistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_9_Statistics]
AS

--EXEC DOI.spRefreshMetadata_User_Statistics_CreateTables
EXEC DOI.spRefreshMetadata_User_Statistics_InsertData
EXEC DOI.spRefreshMetadata_User_Statistics_UpdateData

GO
