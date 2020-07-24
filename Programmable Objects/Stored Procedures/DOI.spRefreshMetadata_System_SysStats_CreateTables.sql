
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStats_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysStats_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysStats_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'SysStats',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS #SysStats

DROP TABLE IF EXISTS DOI.SysStats

CREATE TABLE DOI.SysStats (
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

INSERT INTO DOI.SysStats 
SELECT * FROM #SysStats

DROP TABLE #SysStats

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL

GO
