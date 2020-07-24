
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_4_Tables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_4_Tables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_4_Tables]

AS
    --EXEC DOI.spRefreshMetadata_User_Tables_CreateTables
    --EXEC DOI.spRefreshMetadata_User_Tables_InsertData
    EXEC DOI.spRefreshMetadata_User_Tables_UpdateData
GO
