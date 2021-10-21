-- <Migration ID="13e26fae-cce3-4e03-9b0e-bc5e296f3582" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysIndexPhysicalStats]
        @DatabaseName = 'DOIUnitTests'
*/


DELETE IPS
FROM DOI.SysIndexPhysicalStats IPS
    INNER JOIN DOI.SysDatabases D ON IPS.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

CREATE TABLE #SysIndexPhysicalStats (
    database_id	                            SMALLINT,
    object_id	                            INT,
    index_id	                            INT,
    partition_number	                    INT,
    index_type_desc	                        NVARCHAR(120),
    alloc_unit_type_desc	                NVARCHAR(120),
    index_depth	                            TINYINT,
    index_level	                            TINYINT,
    avg_fragmentation_in_percent            FLOAT,
    fragment_count	                        BIGINT,
    avg_fragment_size_in_pages	            FLOAT,
    page_count	                            BIGINT,
    avg_page_space_used_in_percent          FLOAT,
    record_count	                        BIGINT,
    ghost_record_count	                    BIGINT,
    version_ghost_record_count	            BIGINT,
    min_record_size_in_bytes	            INT,
    max_record_size_in_bytes	            INT,
    avg_record_size_in_bytes	            FLOAT,
    forwarded_record_count	                BIGINT,
    compressed_page_count	                BIGINT,
    hobt_id	                                BIGINT,
    columnstore_delete_buffer_state         TINYINT,
    columnstore_delete_buffer_state_desc	NVARCHAR(120))

INSERT INTO #SysIndexPhysicalStats
SELECT  [database_id], [object_id], [index_id], [partition_number], [index_type_desc], [alloc_unit_type_desc], [index_depth], [index_level], [avg_fragmentation_in_percent], [fragment_count], [avg_fragment_size_in_pages], [page_count], [avg_page_space_used_in_percent], [record_count], [ghost_record_count], [version_ghost_record_count], [min_record_size_in_bytes], [max_record_size_in_bytes], [avg_record_size_in_bytes], [forwarded_record_count], [compressed_page_count], [hobt_id], [columnstore_delete_buffer_state], [columnstore_delete_buffer_state_desc]
FROM sys.dm_db_index_physical_stats(DB_ID(@DatabaseName), NULL, NULL, NULL, 'LIMITED')    

INSERT INTO DOI.SysIndexPhysicalStats([database_id], [object_id], [index_id], [partition_number], [index_type_desc], [alloc_unit_type_desc], [index_depth], [index_level], [avg_fragmentation_in_percent], [fragment_count], [avg_fragment_size_in_pages], [page_count], [avg_page_space_used_in_percent], [record_count], [ghost_record_count], [version_ghost_record_count], [min_record_size_in_bytes], [max_record_size_in_bytes], [avg_record_size_in_bytes], [forwarded_record_count], [compressed_page_count], [hobt_id], [columnstore_delete_buffer_state], [columnstore_delete_buffer_state_desc])
SELECT [database_id], [object_id], [index_id], [partition_number], [index_type_desc], [alloc_unit_type_desc], [index_depth], [index_level], [avg_fragmentation_in_percent], [fragment_count], [avg_fragment_size_in_pages], [page_count], [avg_page_space_used_in_percent], [record_count], [ghost_record_count], [version_ghost_record_count], [min_record_size_in_bytes], [max_record_size_in_bytes], [avg_record_size_in_bytes], [forwarded_record_count], [compressed_page_count], [hobt_id], [columnstore_delete_buffer_state], [columnstore_delete_buffer_state_desc]
FROM #SysIndexPhysicalStats

DROP TABLE IF EXISTS #SysIndexPhysicalStats
GO