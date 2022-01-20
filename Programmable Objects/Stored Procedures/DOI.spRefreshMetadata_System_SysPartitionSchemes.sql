-- <Migration ID="03153ead-8b84-48cd-81c7-41d4c7262015" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysPartitionSchemes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionSchemes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysPartitionSchemes]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysPartitionSchemes]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE PS
FROM DOI.SysPartitionSchemes PS
    INNER JOIN DOI.SysDatabases D ON PS.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL += '
SELECT TOP 1 DB_ID(''model'') AS database_id, *
INTO #SysPartitionSchemes
FROM model.sys.partition_schemes FN
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysPartitionSchemes
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.partition_schemes'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysPartitionSchemes
SELECT *
FROM #SysPartitionSchemes

DROP TABLE IF EXISTS #SysPartitionSchemes' + CHAR(13) + CHAR(10)

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