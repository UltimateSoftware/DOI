-- </>
IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDmDbStatsProperties]
         @DatabaseName = 'DOIUnitTests'
*/

DELETE SP
FROM DOI.SysDmDbStatsProperties SP
    INNER JOIN DOI.SysDatabases D ON SP.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT @SQL += '

SELECT TOP 1 DB_ID(''model'') AS database_id, FN.*
INTO #SysDmDbStatsProperties
FROM model.sys.stats p
    CROSS APPLY model.sys.dm_db_stats_properties(p.object_id, p.stats_id) FN  
WHERE 1 = 2 '

SELECT @SQL += '
USE ' + D.DatabaseName + '

INSERT INTO #SysDmDbStatsProperties
SELECT DB_ID(''' + D.DatabaseName + ''') AS database_id, FN.*
FROM sys.stats p
    CROSS APPLY sys.dm_db_stats_properties(p.object_id, p.stats_id) FN  
    INNER JOIN sys.databases D ON D.database_id = DB_ID(''' + DatabaseName + ''')'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO DOI.DOI.SysDmDbStatsProperties([database_id], [object_id], [stats_id], [last_updated], [rows], [rows_sampled], [steps], [unfiltered_rows], [modification_counter], [persisted_sample_percent])
SELECT [database_id], [object_id], [stats_id], [last_updated], [rows], [rows_sampled], [steps], [unfiltered_rows], [modification_counter], [persisted_sample_percent]
FROM #SysDmDbStatsProperties

DROP TABLE IF EXISTS #SysDmDbStatsProperties
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