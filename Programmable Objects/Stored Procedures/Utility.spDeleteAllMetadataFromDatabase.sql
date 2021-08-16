IF OBJECT_ID('[Utility].[spDeleteAllMetadataFromDatabase]') IS NOT NULL
	DROP PROCEDURE [Utility].[spDeleteAllMetadataFromDatabase];
GO

CREATE PROCEDURE [Utility].[spDeleteAllMetadataFromDatabase]
	@DatabaseName SYSNAME,
    @OneTimeTearDown BIT = 0,
    @Debug BIT = 0
AS

/*
EXEC [Utility].[spDeleteAllMetadataFromDatabase] @DatabaseName = 'DOIUnitTests'
    , @dEBUG = 1

*/

DECLARE @SQL VARCHAR(MAX) = '',
        @DBID INT = (   SELECT database_id FROM sys.databases WHERE NAME = @DatabaseName)

SELECT @SQL += 'DELETE FROM DOI.[' + t.name + '] WHERE DatabaseName = ''' + @DatabaseName + '''' + CHAR(13) + CHAR(10)
FROM sys.tables t
    INNER JOIN sys.schemas s ON s.schema_id = T.schema_id
WHERE s.name = 'DOI'
    AND t.name <> CASE WHEN @OneTimeTearDown = 0 THEN 'Databases' ELSE '' END
    AND t.name <> CASE WHEN @OneTimeTearDown = 0 THEN 'DOISettings' ELSE '' END
    AND EXISTS (SELECT 'True' FROM sys.columns c WHERE c.object_id = t.object_id AND c.name = 'DatabaseName')

SELECT @SQL += 'DELETE FROM DOI.[' + t.name + '] WHERE database_id = ' + CAST(@DBID AS VARCHAR(20)) + CHAR(13) + CHAR(10)
FROM sys.tables t
    INNER JOIN sys.schemas s ON s.schema_id = T.schema_id
WHERE s.name = 'DOI'
    AND t.name <> CASE WHEN @OneTimeTearDown = 0 THEN 'SysDatabases' ELSE '' END
    AND t.name <> CASE WHEN @OneTimeTearDown = 0 THEN 'DOISettings' ELSE '' END
    AND EXISTS (SELECT 'True' FROM sys.columns c WHERE c.object_id = t.object_id AND c.name = 'DATABASE_ID')

SELECT @SQL += 'DELETE T FROM DOI.[' + t.name + '] T WHERE NOT EXISTS (SELECT ''True'' FROM sys.databases D WHERE D.database_id = T.database_id)' + CHAR(13) + CHAR(10)
FROM sys.tables t
    INNER JOIN sys.schemas s ON s.schema_id = T.schema_id
WHERE s.name = 'DOI'
    AND t.name <> CASE WHEN @OneTimeTearDown = 0 THEN 'SysDatabases' ELSE '' END
    AND t.name <> CASE WHEN @OneTimeTearDown = 0 THEN 'DOISettings' ELSE '' END
    AND EXISTS (SELECT 'True' FROM sys.columns c WHERE c.object_id = t.object_id AND c.name = 'DATABASE_ID')

IF @Debug = 1
BEGIN
    EXEC DOI.spPrintOutLongSQL 
        @SQLInput = @SQL,
        @VariableName = N'@SQL'
END
ELSE
BEGIN
    EXEC(@SQL)
END

GO