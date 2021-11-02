-- <Migration ID="272186f4-7737-473e-930c-b622a49bca27" />
GO
IF OBJECT_ID('[DOI].[vwPartitioning_Tables_NewPartitionedTable]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitioning_Tables_NewPartitionedTable];

GO


CREATE     VIEW [DOI].[vwPartitioning_Tables_NewPartitionedTable]

/*
	select top 10 CreateViewForBCPSQL
	from DOI.[vwPartitioning_Tables_NewPartitionedTable]
    where tablename = 'BAI2BANKTRANSACTIONS'
	order by tablename, partitionnumber
 */ 
AS

        SELECT	*,
				1 AS IsNewPartitionedTable
                ,'
CREATE OR ALTER TRIGGER ' + T.SchemaName + '.tr' + T.TableName + '_DataSynch
ON ' + T.SchemaName + '.' + T.TableName + '
AFTER INSERT, UPDATE, DELETE
AS
' + 		DSTrigger.DSTriggerSQL AS CreateDataSynchTriggerSQL,

'
DROP TABLE IF EXISTS ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch

IF OBJECT_ID(''' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch'') IS NULL
BEGIN
	CREATE TABLE ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + CHAR(13) + CHAR(10) + T.ColumnListWithTypes + CHAR(13) + CHAR(10) + ' ,DMLType CHAR(1) NOT NULL) ON [' + T.Storage_Desired + '] (' + T.PartitionColumn + ')
END
'		AS CreateFinalDataSynchTableSQL,
		'
CREATE OR ALTER TRIGGER ' + T.SchemaName + '.tr' + T.TableName + '_DataSynch
ON ' + T.SchemaName + '.' + T.TableName + '
AFTER INSERT, UPDATE, DELETE
AS

INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + T.ColumnListForDataSynchTriggerInsert + ', DMLType)
SELECT ' + REPLACE(T.ColumnListForDataSynchTriggerSelect, 'PT.', 'ST.') + ', ''I''
FROM inserted T ' + 
CASE 
	WHEN T.TableHasOldBlobColumns = 1 
	THEN '
	INNER JOIN ' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'ST.') + CHAR(13) + CHAR(10) 
	ELSE '' 
END + '
WHERE NOT EXISTS(SELECT ''True'' FROM deleted PT WHERE ' + T.PKColumnListJoinClause + ')

INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + T.ColumnListForDataSynchTriggerInsert + ', DMLType)
SELECT ' + REPLACE(T.ColumnListForDataSynchTriggerSelect, 'PT.', 'ST.') + ', ''U''
FROM inserted T' + 
CASE 
	WHEN T.TableHasOldBlobColumns = 1 
	THEN '
	INNER JOIN ' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'ST.') + CHAR(13) + CHAR(10) 
	ELSE '' 
END + '
WHERE EXISTS (SELECT * FROM deleted PT WHERE ' + T.PKColumnListJoinClause + ')

INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + T.ColumnListForDataSynchTriggerInsert + ', DMLType)
SELECT ' + T.ColumnListForDataSynchTriggerSelect + ', ''D''
FROM deleted T
WHERE NOT EXISTS(SELECT ''True'' FROM inserted PT WHERE ' + T.PKColumnListJoinClause + ')
'		AS CreateFinalDataSynchTriggerSQL,

'UPDATE DOI.DOI.Run_PartitionState
SET DataSynchState = 0
WHERE DatabaseName = ''' + T.DatabaseName + '''
	AND SchemaName = ''' + T.SchemaName + '''
	AND ParentTableName = ''' + T.TableName + '''
'		AS TurnOffDataSynchSQL,

		'
USE ' + T.DatabaseName + '
IF EXISTS(SELECT * FROM sys.triggers tr WHERE tr.name = ''tr' + T.TableName + '_DataSynch'' AND OBJECT_NAME(parent_id) = ''' + T.TableName + '_OLD'')
BEGIN
	DROP TRIGGER tr' + T.TableName + '_DataSynch
END' 
		AS DropDataSynchTriggerSQL,
		'
IF OBJECT_ID(''' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch'') IS NOT NULL
	AND OBJECT_ID(''' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ''') IS NOT NULL
BEGIN
	IF (SELECT SUM(Counts)
		FROM (
				SELECT ''Inserts Left'' AS Type, COUNT(*) AS Counts
				FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch PT
				WHERE PT.DMLType = ''I''
					AND NOT EXISTS (SELECT ''True'' 
									FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' T
									WHERE ' + T.PKColumnListJoinClause + ')
				UNION ALL
				SELECT ''Updates Left'' AS Type, COUNT(*)
				FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch PT
				WHERE PT.DMLType = ''U''
					AND EXISTS (SELECT ''True'' 
								FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' T
								WHERE ' + T.PKColumnListJoinClause + '
									AND T.UpdatedUtcDt < PT.UpdatedUtcDt)
				UNION ALL
				SELECT ''Deletes Left'' AS Type, COUNT(*)
				FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch PT
				WHERE PT.DMLType = ''D''
					AND EXISTS (SELECT ''True'' 
								FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' T
								WHERE ' + T.PKColumnListJoinClause + '))c) = 0
	BEGIN
		DROP TABLE ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch
	END
	ELSE
	BEGIN
		RAISERROR(''Not all data was synched to the new table.  ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch Table was not dropped'', 10, 1)
	END
END
ELSE
BEGIN
	RAISERROR(''Not all necessary tables have been created.'' , 16 , 1);
END'
AS DropDataSynchTableSQL,
'
DELETE DOI.DOI.Run_PartitionState 
WHERE DatabaseName = ''' + T.DatabaseName + '''
	AND SchemaName = ''' + T.SchemaName + ''' 
    AND ParentTableName = ''' + T.TableName + '''' 
AS DeletePartitionStateMetadataSQL,
'
INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '(' + T.ColumnListForDataSynchTriggerInsert + ')
SELECT ' + REPLACE(T.ColumnListForDataSynchTriggerSelect, 'PT.', 'ST.') + '
FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch T ' + 
CASE WHEN T.TableHasOldBlobColumns = 1 THEN '
	INNER JOIN ' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'ST.') ELSE '' END + '
WHERE T.DMLType = ''I''
	AND NOT EXISTS (SELECT ''True'' 
					FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' PT WITH (TABLOCKX, XLOCK)
					WHERE ' + T.PKColumnListJoinClause + ')

SET @RowCountOUT = @@ROWCOUNT

IF EXISTS(	SELECT ''True''
			FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch T
			WHERE T.DMLType = ''I''
				AND NOT EXISTS (SELECT ''True'' 
								FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' PT WITH (TABLOCKX, XLOCK) 
								WHERE ' + T.PKColumnListJoinClause + '))
BEGIN
	RAISERROR(''Not all INSERTs were synched to the new table for ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '.'', 10, 1)
END' AS SynchInsertsPrepTableSQL,
'
UPDATE PT
SET ' + T.ColumnListForDataSynchTriggerUpdate + '
FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch T' + 
CASE WHEN T.TableHasOldBlobColumns = 1 THEN '
	INNER JOIN ' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'ST.') ELSE '' END + '
	INNER JOIN ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' PT WITH (TABLOCKX, XLOCK) ON ' + T.PKColumnListJoinClause + '
	INNER JOIN (SELECT ' + T.PKColumnList + ', MAX(UpdatedUtcDt) AS UpdatedUtcDt 
				FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch
				WHERE  DMLType = ''U''
				GROUP BY ' + T.PKColumnList + ') O2
		ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'O2.') + '
			AND O2.UpdatedUtcDt = T.UpdatedUtcDt
WHERE T.DMLType = ''U''
	AND T.UpdatedUtcDt > PT.UpdatedUtcDt

SET @RowCountOUT = @@ROWCOUNT

IF EXISTS(	SELECT ''True'' 
			FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch T
				INNER JOIN ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' PT WITH (TABLOCKX, XLOCK) ON ' + T.PKColumnListJoinClause + '
				INNER JOIN (SELECT ' + T.PKColumnList + ', MAX(UpdatedUtcDt) AS UpdatedUtcDt 
							FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch
							WHERE  DMLType = ''U''
							GROUP BY ' + T.PKColumnList + ') O2
					ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'O2.') + '
						AND O2.UpdatedUtcDt = T.UpdatedUtcDt
			WHERE T.DMLType = ''U''
				AND T.UpdatedUtcDt > PT.UpdatedUtcDt)
BEGIN
	RAISERROR(''Not all UPDATEs were synched to the new table for ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '.'', 10, 1)
END' AS SynchUpdatesPrepTableSQL,

'
DELETE PT
FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' PT WITH (TABLOCKX, XLOCK)
WHERE EXISTS (	SELECT ''True'' 
				FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch T
				WHERE T.DMLType = ''D'' 
					AND ' + T.PKColumnListJoinClause + ')

SET @RowCountOUT = @@ROWCOUNT

IF EXISTS(	SELECT ''True''
			FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch T
			WHERE T.DMLType = ''D''
				AND EXISTS (SELECT ''True'' 
							FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' PT WITH (TABLOCKX, XLOCK) 
							WHERE ' + T.PKColumnListJoinClause + '))
BEGIN
	RAISERROR(''Not all DELETEs were synched to the new table for ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '.'', 10, 1)
END' AS SynchDeletesPrepTableSQL,
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + T.SchemaName + '.' + T.PrepTableName + ''',
	@newname = ''' + T.TableName + ''',
	@objtype = ''OBJECT''' 
AS RenameNewPartitionedPrepTableSQL,
'SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + T.SchemaName + '.' + T.TableName + ''',
	@newname = ''' + T.TableName + '_OLD'',
	@objtype = ''OBJECT''' 
AS RenameExistingTableSQL,
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + T.SchemaName + '.' + T.TableName + ''',
	@newname = ''' + T.PrepTableName + ''',
	@objtype = ''OBJECT''' 
AS RevertRenameNewPartitionedPrepTableSQL,

'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + T.SchemaName + '.' + T.TableName + '_OLD'',
	@newname = ''' + T.TableName + ''',
	@objtype = ''OBJECT''' 
AS RevertRenameExistingTableSQL,
'
SELECT *
FROM (

		SELECT ''Inserts Left'' AS Type, COUNT(*) AS Counts
		FROM ' + T.SchemaName + '.' + T.TableName + '_DataSynch PT WITH (NOLOCK)
		WHERE PT.DMLType = ''I''
			AND NOT EXISTS (SELECT ''True'' 
							FROM ' + T.SchemaName + '.' + T.TableName + ' T WITH (NOLOCK)
							WHERE ' + T.PKColumnListJoinClause + ')
		UNION ALL
		SELECT ''Updates Left'' AS Type, COUNT(*)
		FROM ' + T.SchemaName + '.' + T.TableName + '_DataSynch PT WITH (NOLOCK)
		WHERE PT.DMLType = ''U''
			AND EXISTS (SELECT ''True'' 
						FROM ' + T.SchemaName + '.' + T.TableName + ' T WITH (NOLOCK)
						WHERE ' + T.PKColumnListJoinClause + '
							AND O.UpdatedUtcDt = PT.UpdatedUtcDt)
		UNION ALL
		SELECT ''Deletes Left'' AS Type, COUNT(*)
		FROM ' + T.SchemaName + '.' + T.TableName + '_DataSynch PT WITH (NOLOCK)
		WHERE PT.DMLType = ''D''
			AND EXISTS (SELECT ''True'' 
						FROM ' + T.SchemaName + '.' + T.TableName + ' T WITH (NOLOCK)
						WHERE ' + T.PKColumnListJoinClause + '))c
' AS DataSynchProgressSQL,
'
IF (SELECT * FROM dbo.fnCompareTableStructures(''' + T.SchemaName + ''',''' + T.TableName + ''',''' + T.SchemaName + ''',''' + T.NewPartitionedPrepTableName + ''', ''_NewPartitionedTableFromPrep'',''' + T.PartitionColumn + ''')) > 0
BEGIN
    DECLARE @ErrorMessage VARCHAR(MAX) = ''Schemas from the 2 tables do not match!!''

    SELECT @ErrorMessage += CHAR(13) + CHAR(10) + ''***'' + IndexName + space(1) + SchemaDifferences + ''***'' + CHAR(13) + CHAR(10)
    FROM dbo.fnCompareTableStructuresDetails(''' + T.SchemaName + ''',''' + T.TableName + ''',''' + T.SchemaName + ''',''' + T.NewPartitionedPrepTableName + ''', ''_NewPartitionedTableFromPrep'',''' + T.PartitionColumn + ''')

	RAISERROR(@ErrorMessage, 16, 1)
END

IF NOT EXISTS(	 SELECT * 
		  	     FROM sys.schemas s 
				    INNER JOIN sys.tables t ON s.schema_id = t.schema_id 
			     WHERE s.name = ''' + T.SchemaName + ''' 
				    AND t.name = ''' + T.NewPartitionedPrepTableName + ''') 
BEGIN
	RAISERROR(''NewPartitionedPrepTable does not exist!!'', 16, 1)
END

IF NOT EXISTS(	 SELECT * 
		  	     FROM sys.schemas s 
		  		    INNER JOIN sys.tables t ON s.schema_id = t.schema_id 
			     WHERE s.name = ''' + T.SchemaName + ''' 
				    AND t.name = ''' + T.TableName + ''')
BEGIN
	RAISERROR(''Live table does not exist!!'', 16, 1)
END

IF EXISTS(  SELECT *
		    FROM sys.tables t 
		    WHERE name <> ''' + T.NewPartitionedPrepTableName + ''' 
		        AND name LIKE ''%' + T.TableName + '%Prep%'')
BEGIN
	RAISERROR(''Some Prep tables still exist!!'', 16, 1)
END

DECLARE @RowCount_NewPrepTable int = (SELECT SUM(ROWS)
									  FROM sys.partitions 
									  WHERE object_id = OBJECT_ID(''' + T.SchemaName + '.' + T.NewPartitionedPrepTableName + ''') 
										 AND index_id in (0,1))

DECLARE @RowCount_OldTable int = (SELECT SUM(ROWS) 
								  FROM sys.partitions 
								  WHERE object_id = OBJECT_ID(''' + T.SchemaName + '.' + T.TableName + ''') 
									 AND index_id in (0,1))

DECLARE @MaximumAllowedRowsDifference DECIMAL(18,4) =  (	SELECT SUM(ROWS) * 0.1 
															FROM sys.partitions 
															WHERE object_id = OBJECT_ID(''' + T.SchemaName + '.' + T.TableName + ''') 
																AND index_id in (0,1))

IF ABS( @RowCount_NewPrepTable - @RowCount_OldTable ) > @MaximumAllowedRowsDifference 
BEGIN
	RAISERROR(''RowCounts from 2 tables are too far apart!!'', 16, 1)
END'
AS FinalRepartitioningValidationSQL
FROM (	SELECT DatabaseName
                ,SchemaName
				,TableName
				,0 AS DateDiffs
				,TableName + '_NewPartitionedTableFromPrep' AS PrepTableName
				,'_NewPartitionedTableFromPrep' AS PrepTableNameSuffix
				,TableName + '_NewPartitionedTableFromPrep' AS NewPartitionedPrepTableName
				,PartitionFunctionName
				,'9999-12-31' AS NextBoundaryValue
				,'0001-01-01' AS BoundaryValue
				,ColumnListWithTypes
				,ColumnListNoTypes
				,ColumnListForDataSynchTriggerInsert
				,ColumnListForDataSynchTriggerUpdate
				,ColumnListForDataSynchTriggerSelect
				,UpdateColumnList
    			,PartitionColumn
    			,PKColumnList
				,PKColumnListJoinClause
				,Storage_Desired
				,StorageType_Desired
				,0 AS PartitionNumber
                ,SPACE(0) AS PrepTableFilegroup
				,TableHasOldBlobColumns
		FROM DOI.Tables
		WHERE IntendToPartition = 1) T
    CROSS APPLY(SELECT STUFF((  SELECT PT.PrepTableTriggerSQLFragment
								FROM DOI.vwPartitioning_Tables_PrepTables PT
								WHERE PT.DatabaseName = T.DatabaseName
									AND PT.SchemaName = T.SchemaName
									AND PT.TableName = T.TableName
								FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)'), 1, 1, '')) DSTrigger(DSTriggerSQL)
GO