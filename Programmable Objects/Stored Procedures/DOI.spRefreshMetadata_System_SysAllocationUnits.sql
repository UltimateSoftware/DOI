
IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysAllocationUnits]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysAllocationUnits];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysAllocationUnits]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysAllocationUnits]
        @DatabaseName = 'DOIUnitTests',
        @Debug = 1
*/
DELETE AU 
FROM DOI.SysAllocationUnits AU
    INNER JOIN sys.databases D ON AU.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DELETE AU 
FROM DOI.SysAllocationUnits AU
WHERE NOT EXISTS (SELECT 'True' FROM sys.databases D WHERE AU.database_id = D.database_id)

DECLARE @SQL VARCHAR(MAX) = ''


SELECT @SQL += '
SELECT DB_ID(''model'') AS database_id, *
INTO #SysAllocationUnits
FROM model.sys.allocation_units FN
WHERE 1 = 2'


SELECT @SQL += '

INSERT INTO #SysAllocationUnits
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.allocation_units'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysAllocationUnits
SELECT *
FROM #SysAllocationUnits

DROP TABLE IF EXISTS #SysAllocationUnits' + CHAR(13) + CHAR(10)

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