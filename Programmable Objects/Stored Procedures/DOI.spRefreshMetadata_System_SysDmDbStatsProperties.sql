-- <Migration ID="99a496ee-f4bd-49cf-b5db-0eead8e91844" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

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

    NOTE:  THIS SP IS FLAWED!  sys.dm_db_stats_properties only returns its data when called from its current database.  3 part-name calls work but they return null data.
    need to figure out how to get around this.  if we try to use dynamic sql we get the error stating that a "user transaction that accesses memory-optimized tables cannot read from 2 databases".
*/

DELETE SP
FROM DOI.SysDmDbStatsProperties SP
    INNER JOIN DOI.SysDatabases D ON SP.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT TOP 1 @SQL += '

SELECT TOP 1 DB_ID(''' + DatabaseName + ''') AS database_id, FN.*
INTO #SysDmDbStatsProperties
FROM sys.stats p
    CROSS APPLY sys.dm_db_stats_properties(p.object_id, p.stats_id) FN  
WHERE 1 = 2' + CHAR(13) + CHAR(10)
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

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