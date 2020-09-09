
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysAllocationUnits]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysAllocationUnits];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysAllocationUnits]
    @DatabaseId INT = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysAllocationUnits]
        @Debug = 1
*/

DELETE DOI.SysAllocationUnits
WHERE database_id = CASE WHEN @DatabaseId IS NULL THEN database_id ELSE @DatabaseId END

EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @DatabaseId = @DatabaseId,
    @TableName = 'SysAllocationUnits',
    @Debug = @Debug

GO
