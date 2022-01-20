

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeys]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeys]
        @DatabaseName = 'DOIUnitTests'
*/


DELETE FK
FROM DOI.SysForeignKeys FK
    INNER JOIN DOI.SysDatabases D ON FK.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL VARCHAR(MAX) = ''


SELECT @SQL += '
SELECT TOP 1 DB_ID(''model'') AS database_id, *, NULL AS ParentColumnList_Actual, NULL AS ReferencedColumnList_Actual, NULL AS DeploymentTime
INTO #SysForeignKeys
FROM model.sys.foreign_keys FN
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysForeignKeys
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *, NULL, NULL, NULL
FROM ' + DatabaseName + '.sys.foreign_keys'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysForeignKeys
SELECT *
FROM #SysForeignKeys

DROP TABLE IF EXISTS #SysForeignKeys' + CHAR(13) + CHAR(10)

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