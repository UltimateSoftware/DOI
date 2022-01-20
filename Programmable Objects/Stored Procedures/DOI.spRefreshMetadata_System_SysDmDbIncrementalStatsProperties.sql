-- <Migration ID="99a496ee-f4bd-49cf-b5db-0eead8e91844" />
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDmDbIncrementalStatsProperties]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDmDbIncrementalStatsProperties];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDmDbIncrementalStatsProperties]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDmDbIncrementalStatsProperties]
         @DatabaseName = 'DOIUnitTests'
*/

DELETE SP
FROM DOI.SysDmDbIncrementalStatsProperties SP
    INNER JOIN DOI.SysDatabases D ON SP.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT @SQL += '

SELECT TOP 1 DB_ID(''model'') AS database_id, FN.*
INTO #SysDmDbIncrementalStatsProperties
FROM model.sys.stats p
    CROSS APPLY model.sys.dm_db_incremental_stats_properties(p.object_id, p.stats_id) FN  
WHERE 1 = 2' + CHAR(13) + CHAR(10)

SELECT @SQL += '

USE ' + D.DatabaseName + '

INSERT INTO #SysDmDbIncrementalStatsProperties
SELECT DB_ID(''' + D.DatabaseName + ''') AS database_id, FN.*
FROM sys.stats p
    CROSS APPLY sys.dm_db_incremental_stats_properties(p.object_id, p.stats_id) FN  
    INNER JOIN sys.databases D ON D.database_id = DB_ID(''' + DatabaseName + ''')'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO DOI.DOI.SysDmDbIncrementalStatsProperties([database_id], [object_id], [stats_id], [partition_number], [last_updated], [rows], [rows_sampled], [steps], [unfiltered_rows], [modification_counter])
SELECT [database_id], [object_id], [stats_id], [partition_number], [last_updated], [rows], [rows_sampled], [steps], [unfiltered_rows], [modification_counter]
FROM #SysDmDbIncrementalStatsProperties

DROP TABLE IF EXISTS #SysDmDbIncrementalStatsProperties
'

IF @Debug = 1
BEGIN
    EXEC DOI.spPrintOutLongSQL
        @SQLInput = @SQL,
        @VariableName = '@SQL'
END
ELSE
BEGIN
    EXEC(@SQL)
END

GO