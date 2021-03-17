
IF OBJECT_ID('[DOI].[spRefreshMetadata_Run_System]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_Run_System];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_Run_System]
    @DatabaseId INT = NULL,
    @Debug BIT = 0
AS

/*
    EXEC DOI.spRefreshMetadata_Run_System
        @DatabaseId = 18,
        @Debug = 1

        select * from doi.sysdatabases
*/
EXEC [DOI].[spRefreshMetadata_System_SysDatabases]

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL += 'EXEC ' + s.name + '.' + p.name + CHAR(13) + CHAR(10) + CHAR(9) + '@DatabaseName = ''' + CASE WHEN @DatabaseId IS NOT NULL THEN D.name ELSE 'NULL' END + '''' + /*',' +*/ CHAR(13) + CHAR(10) COLLATE DATABASE_DEFAULT-- + CHAR(9) + '@Debug = ' + CAST(@Debug AS CHAR(1)) + CHAR(13) + CHAR(10)
FROM SYS.procedures P
    INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
    INNER JOIN DOI.SysDatabases D ON D.database_id = @DatabaseId
WHERE p.NAME LIKE 'spRefreshMetadata_System%'
    AND p.name NOT LIKE '%CreateTables'
    AND p.name NOT IN ('spRefreshMetadata_System_SysDmDbStatsProperties')

SELECT @SQL += 'EXEC ' + s.name + '.' + p.name + CHAR(13) + CHAR(10) + CHAR(9) + '@DatabaseName = ''' + CASE WHEN @DatabaseId IS NOT NULL THEN D.name ELSE 'NULL' END + '''' + CHAR(13) + CHAR(10) COLLATE DATABASE_DEFAULT-- + CHAR(9) + '@Debug = ' + CAST(@Debug AS CHAR(1)) + CHAR(13) + CHAR(10)
FROM SYS.procedures P
    INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
    INNER JOIN DOI.SysDatabases D ON D.database_id = @DatabaseId
WHERE p.NAME LIKE 'spRefreshMetadata_User%_UpdateData'
    AND ISNUMERIC(SUBSTRING(p.name, CHARINDEX('User_', p.name, 1) + 5, 1)) = 0

IF @Debug = 1
BEGIN
    PRINT @SQL
END
ELSE
BEGIN
    EXEC(@SQL)
END
GO
