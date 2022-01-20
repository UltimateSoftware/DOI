
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysPartitions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitions]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysPartitions]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE P
FROM DOI.SysPartitions P
    INNER JOIN DOI.SysDatabases D ON P.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL += '
SELECT TOP 1 DB_ID(''model'') AS database_id, *
INTO #SysPartitions
FROM model.sys.partitions FN
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysPartitions
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.partitions'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysPartitions
SELECT *
FROM #SysPartitions

DROP TABLE IF EXISTS #SysPartitions' + CHAR(13) + CHAR(10)

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