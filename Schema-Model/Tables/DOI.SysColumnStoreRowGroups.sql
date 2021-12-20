IF OBJECT_ID('[DOI].[SysColumStoreRowGroups]') IS NULL
CREATE TABLE DOI.SysColumStoreRowGroups (
    [database_id]                           INT NOT NULL,
    [object_id]	                            INT NOT NULL,
    [index_id]                              INT NOT NULL,
    [partition_number]                      INT NOT NULL,
    [row_group_id]                          INT NOT NULL,
    [delta_store_hobt_id]                   BIGINT NULL,
    [state]                                 TINYINT NOT NULL,
    [state_description]                     NVARCHAR(60) NOT NULL,
    [total_rows]                            BIGINT NOT NULL,
    [deleted_rows]                          BIGINT NULL,
    [size_in_bytes]                         BIGINT NOT NULL
    CONSTRAINT PK_SysColumStoreRowGroups PRIMARY KEY NONCLUSTERED (database_id, object_id, index_id, partition_number, row_group_id))
WITH
(
MEMORY_OPTIMIZED = ON
)
GO