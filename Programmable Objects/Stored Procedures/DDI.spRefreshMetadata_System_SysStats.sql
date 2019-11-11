IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysStats]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysStats]

AS


EXEC DDI.spRefreshMetadata_System_SysStats_InsertData
EXEC DDI.spRefreshMetadata_System_SysStats_UpdateData

GO
