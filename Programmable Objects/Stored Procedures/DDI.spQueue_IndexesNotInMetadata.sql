IF OBJECT_ID('[DDI].[spQueue_IndexesNotInMetadata]') IS NOT NULL
	DROP PROCEDURE [DDI].[spQueue_IndexesNotInMetadata];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spQueue_IndexesNotInMetadata]


AS

/*
	EXEC DDI.spRun_IndexesNotInMetadata
*/

	DELETE INIM
	FROM DDI.IndexesNotInMetadata INIM
	WHERE EXISTS  (	SELECT 'T' 
					FROM DDI.IndexesRowStore IRS 
					WHERE IRS.SchemaName = INIM.SchemaName
						AND IRS.TableName = INIM.TableName
						AND IRS.IndexName = INIM.IndexName
					UNION ALL 
					SELECT 'T' 
					FROM DDI.IndexesColumnStore ICS 
					WHERE ICS.SchemaName = INIM.SchemaName 
						AND ICS.TableName = INIM.TableName
						AND ICS.IndexName = INIM.IndexName)
		OR (INIM.TableName LIKE '%|_OLD' ESCAPE '|'
				OR INIM.TableName LIKE '%|_NewPartitionedTableFromPrep' ESCAPE '|')

	INSERT INTO DDI.IndexesNotInMetadata ( SchemaName ,TableName ,IndexName ,DropSQLScript )
	SELECT S.NAME AS SchemaName, T.NAME AS TableName, I.NAME AS IndexName, 'DROP INDEX ' + S.NAME + '.' + T.NAME + '.' + I.NAME AS ScriptToDropIndex
	FROM SYS.INDEXES I
		INNER JOIN SYS.TABLES T ON T.object_id = I.object_id
		INNER JOIN SYS.SCHEMAS S ON S.schema_id = T.schema_id
		INNER JOIN DDI.Tables T2 ON T2.SchemaName = s.name	COLLATE DATABASE_DEFAULT
			AND T2.TableName = t.name	COLLATE DATABASE_DEFAULT
	WHERE NOT EXISTS (	SELECT 'T' 
						FROM DDI.IndexesRowStore IRS 
						WHERE IRS.SchemaName = S.NAME 	COLLATE DATABASE_DEFAULT
							AND IRS.TableName = T.NAME 	COLLATE DATABASE_DEFAULT
							AND IRS.IndexName = I.NAME	COLLATE DATABASE_DEFAULT
						UNION ALL 
						SELECT 'T' 
						FROM DDI.IndexesColumnStore ICS 
						WHERE ICS.SchemaName = S.NAME 	COLLATE DATABASE_DEFAULT
							AND ICS.TableName = T.NAME 	COLLATE DATABASE_DEFAULT
							AND ICS.IndexName = I.NAME	COLLATE DATABASE_DEFAULT)
		AND NOT EXISTS (SELECT 'True' 
						FROM DDI.IndexesNotInMetadata INIM 
						WHERE INIM.SchemaName = s.name 	COLLATE DATABASE_DEFAULT
							AND INIM.TableName = t.name COLLATE DATABASE_DEFAULT
							AND INIM.IndexName = i.name	COLLATE DATABASE_DEFAULT)
		AND S.NAME IN ('dbo', 'DataMart')
		AND I.type_desc <> 'HEAP'
		AND t.name NOT LIKE '%|_OLD' ESCAPE '|'
		AND t.name NOT LIKE '%|_NewPartitionedTableFromPrep' ESCAPE '|'

	UPDATE INIM
	SET ignore = 1
	--SELECT *
	FROM DDI.IndexesNotInMetadata INIM
	WHERE IndexName = 'IDX_Pays_CheckSummaryReportCover2'

GO
