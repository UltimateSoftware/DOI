IF OBJECT_ID('[DDI].[spRefreshMetadata_User_4_Tables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_4_Tables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_4_Tables]

AS
    --EXEC DDI.spRefreshMetadata_User_Tables_CreateTables
    EXEC DDI.spRefreshMetadata_User_Tables_InsertData
    EXEC DDI.spRefreshMetadata_User_Tables_UpdateData
GO
