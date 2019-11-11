IF OBJECT_ID('[DDI].[spRefreshMetadata_Run_All]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_Run_All];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_Run_All]

AS

/*
    EXEC DDI.spRefreshMetadata_Run_All
*/

EXEC [DDI].[spRefreshMetadata_Run_System]
EXEC [DDI].[spRefreshMetadata_Run_User]

GO
