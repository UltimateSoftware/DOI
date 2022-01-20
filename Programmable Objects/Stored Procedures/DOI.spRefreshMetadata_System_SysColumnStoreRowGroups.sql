-- <Migration ID="f06ad03a-b0c1-4026-98d6-eae3dc02f509" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysColumnStoreRowGroups]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysColumnStoreRowGroups];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysColumnStoreRowGroups]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysColumnStoreRowGroups]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE P
FROM DOI.SysColumnStoreRowGroups P
    INNER JOIN DOI.SysDatabases D ON P.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL += '
SELECT TOP 1  DB_ID(''model'') AS database_id, csrg.*
INTO #SysColumnStoreRowGroups
FROM model.sys.column_store_row_groups csrg 
WHERE 1 = 2'

SELECT @SQL += '

INSERT INTO #SysColumnStoreRowGroups
SELECT  DB_ID(''' + DatabaseName + '''), csrg.*
FROM ' + DatabaseName + '.sys.column_store_row_groups csrg '
FROM DOI.Databases
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END


SELECT @SQL += '

INSERT INTO DOI.SysColumnStoreRowGroups(database_id,object_id,index_id,partition_number,row_group_id,delta_store_hobt_id,state,state_description,total_rows,deleted_rows,size_in_bytes)
SELECT * FROM #SysColumnStoreRowGroups

DROP TABLE IF EXISTS #SysColumnStoreRowGroups
GO
'

IF @Debug = 1
BEGIN
    EXEC DOI.spPrintOutLongSQL 
        @SQLInput = @SQL,
        @VariableName = N'@SQL'
END
ELSE
BEGIN
    EXEC DOI.sp_ExecuteSQLByBatch 
        @SQL = @SQL
END
GO