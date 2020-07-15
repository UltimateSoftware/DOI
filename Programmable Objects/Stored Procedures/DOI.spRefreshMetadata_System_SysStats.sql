USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysStats]

AS


EXEC DOI.spRefreshMetadata_System_SysStats_InsertData
EXEC DOI.spRefreshMetadata_System_SysStats_UpdateData

GO
