
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_Run_System]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_Run_System];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_Run_System]
    @Debug BIT = 0
AS

/*
    EXEC DOI.spRefreshMetadata_Run_System
        @Debug = 1
*/

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL += 'EXEC ' + s.name + '.' + p.name + CHAR(13) + CHAR(10)
FROM SYS.procedures P
    INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE p.NAME LIKE 'spRefreshMetadata_System%'
    AND p.name NOT LIKE '%CreateTables'

SELECT @SQL += 'EXEC ' + s.name + '.' + p.name + CHAR(13) + CHAR(10)
FROM SYS.procedures P
    INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
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
