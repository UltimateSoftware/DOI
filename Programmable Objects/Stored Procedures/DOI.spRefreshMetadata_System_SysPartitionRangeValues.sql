
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysPartitionRangeValues]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionRangeValues];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionRangeValues]
         @DatabaseName = 'DOIUnitTests'
*/

DELETE PRV
FROM DOI.SysPartitionRangeValues PRV
    INNER JOIN DOI.SysDatabases D ON PRV.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL += '
SELECT TOP 1 DB_ID(''model'') AS database_id, function_id, boundary_id, parameter_id, CAST(value AS VARCHAR(100)) AS value
INTO #SysPartitionRangeValues
FROM model.sys.partition_range_values FN
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysPartitionRangeValues
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, function_id, boundary_id, parameter_id, CAST(value AS VARCHAR(100)) AS value
FROM ' + DatabaseName + '.sys.partition_range_values'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysPartitionRangeValues
SELECT *
FROM #SysPartitionRangeValues

DROP TABLE IF EXISTS #SysPartitionRangeValues' + CHAR(13) + CHAR(10)

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