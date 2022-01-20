
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysPartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionFunctions]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionFunctions]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE PF
FROM DOI.SysPartitionFunctions PF
    INNER JOIN DOI.SysDatabases D ON PF.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL += '
SELECT TOP 1 DB_ID(''model'') AS database_id, *
INTO #SysPartitionFunctions
FROM model.sys.partition_functions FN
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysPartitionFunctions
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.partition_functions'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysPartitionFunctions
SELECT *
FROM #SysPartitionFunctions

DROP TABLE IF EXISTS #SysPartitionFunctions' + CHAR(13) + CHAR(10)

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