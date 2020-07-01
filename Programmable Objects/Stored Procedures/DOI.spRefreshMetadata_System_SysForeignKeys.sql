IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeys]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys]

AS


EXEC DOI.spRefreshMetadata_System_SysForeignKeys_InsertData
EXEC DOI.spRefreshMetadata_System_SysForeignKeys_UpdateData
EXEC DOI.spRefreshMetadata_System_SysForeignKeyColumns_InsertData

GO
