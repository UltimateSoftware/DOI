
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeyColumns]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeyColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeyColumns]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0
AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysForeignKeyColumns]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE FKC
FROM DOI.SysForeignKeyColumns FKC
    INNER JOIN DOI.SysDatabases D ON FKC.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL VARCHAR(MAX) = ''


SELECT @SQL += '
SELECT TOP 1 DB_ID(''model'') AS database_id, *
INTO #SysForeignKeyColumns
FROM model.sys.foreign_key_columns FN
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysForeignKeyColumns
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.foreign_key_columns'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysForeignKeyColumns
SELECT *
FROM #SysForeignKeyColumns

DROP TABLE IF EXISTS #SysForeignKeyColumns' + CHAR(13) + CHAR(10)

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