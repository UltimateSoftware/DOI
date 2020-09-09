
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_Run_User]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_Run_User];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_Run_User]
    @DatabaseName NVARCHAR(128) = NULL,    
    @Debug BIT = 0
AS

/*
        EXEC DOI.spRefreshMetadata_Run_User 
        @Debug = 1
*/

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT @SQL += 'EXEC ' + s.name + '.' + p.name + ' @DatabaseName = ' + CASE WHEN @DatabaseName IS NOT NULL THEN '''' + @DatabaseName + '''' ELSE 'NULL' END + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
FROM SYS.procedures P
    INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE p.NAME LIKE 'spRefreshMetadata_User%'
    AND ISNUMERIC(SUBSTRING(p.NAME, 24, 1)) = 1
	AND p.name NOT LIKE '%CreateTables'
    AND p.name NOT LIKE '%DOISettings%'
ORDER BY p.name

IF @Debug = 1
BEGIN
    PRINT @SQL
END
ELSE
BEGIN
    EXEC DOI.sp_ExecuteSQLByBatch 
        @SQL = @SQL
END

GO
