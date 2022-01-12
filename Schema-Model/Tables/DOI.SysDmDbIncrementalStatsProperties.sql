
GO

CREATE TABLE DOI.SysDmDbIncrementalStatsProperties (
    database_id             int NOT NULL,
    object_id	            int	NOT NULL,
    stats_id	            int	NOT NULL,
    partition_number	    int	NOT NULL,
    last_updated	        datetime2 NULL,
    rows	                bigint NULL,
    rows_sampled	        bigint NULL,
    steps	                int	NULL,
    unfiltered_rows	        bigint NULL,
    modification_counter	bigint NULL,
    CONSTRAINT PK_SysDmDbIncrementalStatsProperties
        PRIMARY KEY NONCLUSTERED (database_id, object_id, stats_id, partition_number))
WITH
(
MEMORY_OPTIMIZED = OFF
)