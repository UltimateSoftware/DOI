
GO

IF OBJECT_ID('[DOI].[spQueue_IndexesNotInMetadata]') IS NOT NULL
	DROP PROCEDURE [DOI].[spQueue_IndexesNotInMetadata];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spQueue_IndexesNotInMetadata]
	@DatabaseName NVARCHAR(128) = NULL


AS

/*
	EXEC DOI.spRun_IndexesNotInMetadata
*/

	DELETE INIM
	FROM DOI.IndexesNotInMetadata INIM
	WHERE EXISTS  (	SELECT 'T' 
					FROM DOI.IndexesRowStore IRS 
					WHERE IRS.SchemaName = INIM.SchemaName
						AND IRS.TableName = INIM.TableName
						AND IRS.IndexName = INIM.IndexName
					UNION ALL 
					SELECT 'T' 
					FROM DOI.IndexesColumnStore ICS 
					WHERE ICS.SchemaName = INIM.SchemaName 
						AND ICS.TableName = INIM.TableName
						AND ICS.IndexName = INIM.IndexName)
		OR (INIM.TableName LIKE '%|_OLD' ESCAPE '|'
				OR INIM.TableName LIKE '%|_NewPartitionedTableFromPrep' ESCAPE '|')
		AND INIM.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN INIM.DatabaseName ELSE @DatabaseName END

	DECLARE @InsertSQL VARCHAR(2000) = '
	INSERT INTO DOI.IndexesNotInMetadata ( DatabaseName, SchemaName ,TableName ,IndexName ,DropSQLScript )
	SELECT d.name, S.NAME AS SchemaName, T.NAME AS TableName, I.NAME AS IndexName, ''DROP INDEX '' + S.NAME + ''.'' + T.NAME + ''.'' + I.NAME AS ScriptToDropIndex
	FROM DOI.SysIndexes I
		INNER JOIN DOI.SysDatabases d ON d.database_id = i.database_id
		INNER JOIN DOI.SysTables T ON T.object_id = I.object_id
		INNER JOIN DOI.SysSchemas S ON S.schema_id = T.schema_id
		INNER JOIN DOI.Tables T2 ON T2.DatabaseName = d.name	COLLATE DATABASE_DEFAULT
			AND T2.SchemaName = s.name	COLLATE DATABASE_DEFAULT
			AND T2.TableName = t.name	COLLATE DATABASE_DEFAULT
	WHERE NOT EXISTS (	SELECT ''T'' 
						FROM DOI.IndexesRowStore IRS 
						WHERE IRS.DatabaseName = d.name COLLATE DATABASE_DEFAULT
							AND IRS.SchemaName = S.NAME COLLATE DATABASE_DEFAULT
							AND IRS.TableName = T.NAME 	COLLATE DATABASE_DEFAULT
							AND IRS.IndexName = I.NAME	COLLATE DATABASE_DEFAULT
						UNION ALL 
						SELECT ''T'' 
						FROM DOI.IndexesColumnStore ICS 
						WHERE ICS.DatabaseName = d.name COLLATE DATABASE_DEFAULT
							AND ICS.SchemaName = S.NAME COLLATE DATABASE_DEFAULT
							AND ICS.TableName = T.NAME 	COLLATE DATABASE_DEFAULT
							AND ICS.IndexName = I.NAME	COLLATE DATABASE_DEFAULT)
		AND NOT EXISTS (SELECT ''True'' 
						FROM DOI.IndexesNotInMetadata INIM 
						WHERE INIM.DatabaseName = d.name COLLATE DATABASE_DEFAULT
							AND INIM.SchemaName = s.name 	COLLATE DATABASE_DEFAULT
							AND INIM.TableName = t.name COLLATE DATABASE_DEFAULT
							AND INIM.IndexName = i.name	COLLATE DATABASE_DEFAULT)
		--AND S.NAME IN (''dbo'', ''DataMart'')
		AND I.type_desc <> ''HEAP''
		AND t.name NOT LIKE ''%|_OLD'' ESCAPE ''|''
		AND t.name NOT LIKE ''%|_NewPartitionedTableFromPrep'' ESCAPE ''|''' + 
CASE 
	WHEN @DatabaseName IS NULL 
	THEN SPACE(0) 
	ELSE '
		AND T2.DatabaseName = ''' + @DatabaseName + ''''
END

	EXEC(@InsertSQL)

	UPDATE INIM
	SET ignore = 1
	--SELECT *
	FROM DOI.IndexesNotInMetadata INIM
	WHERE DatabaseName = 'PaymentReporting'
		AND IndexName = 'IDX_Pays_CheckSummaryReportCover2' --need to remove this!!!

GO