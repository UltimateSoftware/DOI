-- <Migration ID="c3508311-2655-42d5-a7c7-fae00f921dd0" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysCheckConstraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysCheckConstraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysCheckConstraints]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysCheckConstraints]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE CC
FROM DOI.SysCheckConstraints CC
    INNER JOIN DOI.SysDatabases D ON CC.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


DECLARE @SQL VARCHAR(MAX) = ''


SELECT @SQL += '
SELECT TOP 1 DB_ID(''model'') AS database_id, *
INTO #SysCheckConstraints
FROM model.sys.check_constraints FN
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysCheckConstraints
SELECT DB_ID(''' + DatabaseName + ''') AS database_id, *
FROM ' + DatabaseName + '.sys.check_constraints'
--select count(*)
FROM DOI.Databases D
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysCheckConstraints
SELECT *
FROM #SysCheckConstraints

DROP TABLE IF EXISTS #SysCheckConstraints' + CHAR(13) + CHAR(10)

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

GO