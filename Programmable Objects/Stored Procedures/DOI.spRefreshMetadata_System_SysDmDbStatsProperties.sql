
GO

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

SELECT TOP 1 @SQL += '
SELECT TOP 1 ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' FN.*
INTO #SysDmDbStatsProperties
FROM DOI.' + M.FunctionParentDMV + ' p
    CROSS APPLY ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ' FN  
WHERE 1 = 2' + CHAR(13) + CHAR(10)
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysDmDbStatsProperties'
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO #SysDmDbStatsProperties
SELECT ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE 'DB_ID(''' + DatabaseName + ''') AS database_id,' END + ' FN.*
FROM DOI.' + M.FunctionParentDMV + ' p
    CROSS APPLY ' + CASE HasDatabaseIdInOutput WHEN 1 THEN '' ELSE DatabaseName + '.' END + M.SQLServerObjectName + CASE WHEN M.SQLServerObjectType = 'FN' THEN '(' + REPLACE(FunctionParameterList, '{DatabaseName}', DatabaseName) + ')' ELSE '' END + ' FN  
    INNER JOIN DOI.SysDatabases D ON D.database_id = p.database_id
WHERE d.name = ''' + CASE WHEN @DatabaseName IS NULL THEN 'd.name' ELSE CAST(@DatabaseName AS VARCHAR(128)) END  + ''''
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.MappingSqlServerDMVToDOITables M ON M.DOITableName = 'SysDmDbStatsProperties'
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '

INSERT INTO DOI.SysDmDbStatsProperties([database_id], [object_id], [stats_id], [last_updated], [rows], [rows_sampled], [steps], [unfiltered_rows], [modification_counter], [persisted_sample_percent])
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