
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysTriggers]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysTriggers];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysTriggers]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysTriggers]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE T
FROM DOI.SysTriggers T
    INNER JOIN DOI.SysDatabases D ON T.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT @SQL += '

SELECT TOP 1 DB_ID(''model'') AS database_id, *
INTO #SysTriggers
FROM model.sys.triggers
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysTriggers
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.triggers '
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END


SELECT @SQL += '    
INSERT INTO DOI.SysTriggers
SELECT *
FROM #SysTriggers

DROP TABLE IF EXISTS #SysTriggers' + CHAR(13) + CHAR(10)

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