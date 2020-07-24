
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysTables]

AS

DELETE DOI.SysTables


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysTables'


GO
