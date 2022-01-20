
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysTypes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysTypes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysTypes]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysTypes]
         @DatabaseName = 'DOIUnitTests'
*/

DELETE S
FROM DOI.SysTypes S
    INNER JOIN DOI.SysDatabases D ON S.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END 


DECLARE @SQL NVARCHAR(MAX) = ''
SELECT @SQL += '

SELECT TOP 1 DB_ID(''model'') AS database_id, *
INTO #SysTypes
FROM model.sys.types
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysTypes
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.types '
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END


SELECT @SQL += '    
INSERT INTO DOI.SysTypes
SELECT *
FROM #SysTypes

DROP TABLE IF EXISTS #SysTypes' + CHAR(13) + CHAR(10)

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