﻿IF OBJECT_ID('[Utility].[spDeleteAllMetadataFromDatabase]') IS NOT NULL
	DROP PROCEDURE [Utility].[spDeleteAllMetadataFromDatabase];
GO

CREATE PROCEDURE [Utility].[spDeleteAllMetadataFromDatabase]
	@DatabaseName SYSNAME,
    @Debug BIT = 0
AS

/*
EXEC [Utility].[spDeleteAllMetadataFromDatabase] @DatabaseName = 'DOIUnitTests'
    , @dEBUG = 1

*/

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL += 'DELETE FROM DOI.[' + t.name + '] WHERE DatabaseName = ''' + @DatabaseName + '''' + CHAR(13) + CHAR(10)
FROM sys.tables t
    INNER JOIN sys.schemas s ON s.schema_id = T.schema_id
WHERE s.name = 'DOI'
    AND EXISTS (SELECT 'True' FROM sys.columns c WHERE c.object_id = t.object_id AND c.name = 'DatabaseName')

SELECT @SQL += 'DELETE FROM DOI.[' + t.name + '] WHERE EXISTS (SELECT ''True'' FROM DOI.SysDatabases d WHERE database_id = d.database_id AND d.name = ''' + @DatabaseName + ''' )' + CHAR(13) + CHAR(10)
FROM sys.tables t
    INNER JOIN sys.schemas s ON s.schema_id = T.schema_id
WHERE s.name = 'DOI'
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