IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysForeignKeys]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DDI].[spRefreshMetadata_System_SysForeignKeys]

AS


EXEC DDI.spRefreshMetadata_System_SysForeignKeys_InsertData
EXEC DDI.spRefreshMetadata_System_SysForeignKeys_UpdateData
EXEC DDI.spRefreshMetadata_System_SysForeignKeyColumns_InsertData

GO
