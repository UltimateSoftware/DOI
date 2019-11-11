IF OBJECT_ID('[DDI].[spRefreshMetadata_User_2_Constraints]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_2_Constraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- <Migration ID="97202a2f-ee2c-4ac4-9e07-9ee58e0fed22" />
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_2_Constraints]
AS

--EXEC DDI.spRefreshMetadata_User_Constraints_CreateTables
EXEC DDI.spRefreshMetadata_User_Constraints_InsertData
EXEC DDI.spRefreshMetadata_User_Constraints_UpdateData

GO
