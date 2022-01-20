
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysDataSpaces]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysDataSpaces];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysDataSpaces]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysDataSpaces]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE DS
FROM DOI.SysDataSpaces DS
    INNER JOIN DOI.SysDatabases D ON DS.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END 

DECLARE @SQL VARCHAR(MAX) = ''


SELECT @SQL += '
SELECT TOP 1 DB_ID(''model'') AS database_id, *
INTO #SysDataSpaces
FROM model.sys.data_spaces FN
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysDataSpaces
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.data_spaces'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysDataSpaces
SELECT *
FROM #SysDataSpaces

DROP TABLE IF EXISTS #SysDataSpaces' + CHAR(13) + CHAR(10)

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

GO


GO