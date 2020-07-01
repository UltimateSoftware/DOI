IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStatsColumns_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysStatsColumns_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysStatsColumns_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'SysStatsColumns',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS #SysStatsColumns

DROP TABLE IF EXISTS DOI.SysStatsColumns

CREATE TABLE DOI.SysStatsColumns (
    database_id     INT NOT NULL,
    object_id	    INT NOT NULL,
    stats_id	    INT NOT NULL,
    stats_column_id	INT NOT NULL,
    column_id	    INT NOT NULL

    CONSTRAINT PK_SysStatsColumns
        PRIMARY KEY NONCLUSTERED (database_id, object_id, stats_id, stats_column_id))
WITH (MEMORY_OPTIMIZED = ON)


EXEC DOI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysStatsColumns'

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL

GO
