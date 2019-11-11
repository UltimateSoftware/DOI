IF OBJECT_ID('[DDI].[spRefreshMetadata_User_95_ForeignKeys]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_95_ForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE     PROCEDURE [DDI].[spRefreshMetadata_User_95_ForeignKeys]

AS

EXEC DDI.spRefreshMetadata_User_ForeignKeys_InsertData
EXEC DDI.spRefreshMetadata_User_ForeignKeys_UpdateData

GO
