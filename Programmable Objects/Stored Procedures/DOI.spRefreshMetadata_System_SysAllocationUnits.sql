
IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysAllocationUnits]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysAllocationUnits];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysAllocationUnits]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysAllocationUnits]
        @DatabaseName = 'DOIUnitTests',
        @Debug = 1
*/
    DELETE AU 
    FROM DOI.SysAllocationUnits AU
        INNER JOIN sys.databases D ON AU.database_id = D.database_id
    WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

    DELETE AU 
    FROM DOI.SysAllocationUnits AU
    WHERE NOT EXISTS (SELECT 'True' FROM sys.databases D WHERE AU.database_id = D.database_id)

    EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
        @DatabaseName = @DatabaseName,
        @TableName = 'SysAllocationUnits',
        @Debug = @Debug
GO
