IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysStats_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysStats_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysStats_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'SysStats',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS #SysStats

DROP TABLE IF EXISTS DDI.SysStats

CREATE TABLE DDI.SysStats (
    database_id         INT NOT NULL,
    object_id	        INT NOT NULL,
    name	            NVARCHAR(128) NULL,
    stats_id	        INT NOT NULL,
    auto_created	    BIT NULL,
    user_created	    BIT NULL,
    no_recompute	    BIT NULL,
    has_filter	        BIT NULL,
    filter_definition	NVARCHAR(MAX) NULL,
    is_temporary	    BIT NULL,
    is_incremental	    BIT NULL,
    column_list         NVARCHAR(max) NULL

    CONSTRAINT PK_SysStats
        PRIMARY KEY NONCLUSTERED (database_id, object_id, stats_id))
WITH (MEMORY_OPTIMIZED = ON)


SELECT DB_ID('PaymentReporting') AS database_id, *, null AS column_list
INTO #SysStats
FROM PaymentReporting.sys.stats

INSERT INTO DDI.SysStats 
SELECT * FROM #SysStats

DROP TABLE #SysStats

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL

GO
