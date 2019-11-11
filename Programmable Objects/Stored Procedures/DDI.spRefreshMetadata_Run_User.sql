IF OBJECT_ID('[DDI].[spRefreshMetadata_Run_User]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_Run_User];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_Run_User]
    @Debug BIT = 0
AS

/*
    EXEC DDI.spRefreshMetadata_Run_User @Debug = 1
*/

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL += 'EXEC ' + s.name + '.' + p.name + CHAR(13) + CHAR(10)
FROM SYS.procedures P
    INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE p.NAME LIKE 'spRefreshMetadata_User%'
    AND ISNUMERIC(SUBSTRING(p.NAME, 24, 1)) = 1
	AND p.name NOT LIKE '%CreateTables'
ORDER BY p.name

IF @Debug = 1
BEGIN
    PRINT @SQL
END
ELSE
BEGIN
    EXEC(@SQL)
END

GO
