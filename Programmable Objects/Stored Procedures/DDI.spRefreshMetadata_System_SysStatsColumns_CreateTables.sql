IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysStatsColumns_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysStatsColumns_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysStatsColumns_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'SysStatsColumns',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS #SysStatsColumns

DROP TABLE IF EXISTS DDI.SysStatsColumns

CREATE TABLE DDI.SysStatsColumns (
    database_id     INT NOT NULL,
    object_id	    INT NOT NULL,
    stats_id	    INT NOT NULL,
    stats_column_id	INT NOT NULL,
    column_id	    INT NOT NULL

    CONSTRAINT PK_SysStatsColumns
        PRIMARY KEY NONCLUSTERED (database_id, object_id, stats_id, stats_column_id))
WITH (MEMORY_OPTIMIZED = ON)


EXEC DDI.spRefreshMetadata_LoadSQLMetadataFromTableForAllDBs
    @TableName = 'SysStatsColumns'

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL

GO
