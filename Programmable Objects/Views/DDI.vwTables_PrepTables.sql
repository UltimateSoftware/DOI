IF OBJECT_ID('[DDI].[vwTables_PrepTables]') IS NOT NULL
	DROP VIEW [DDI].[vwTables_PrepTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   VIEW [DDI].[vwTables_PrepTables]

/*
	select *
	from DDI.vwTables_PrepTables
    where tablename = 'journalentries'
	order by tablename, partitionnumber

    --to get the PrepTableFilegroup:
SELECT t.TableName, t.Storage_Desired, ds_desired.name, DDS_Desired.data_space_id, UFG_Desired.name
FROM DDI.Tables T
    INNER JOIN DDI.SysDataSpaces DS_Desired ON T.Storage_Desired = DS_Desired.name
    INNER JOIN DDI.SysDestinationDataSpaces DDS_Desired ON DDS_Desired.database_id = DS_Desired.database_id
        AND DDS_Desired.partition_scheme_id = DS_Desired.data_space_id
    INNER JOIN DDI.SysDataSpaces UFG_Desired ON DDS_Desired.database_id = UFG_Desired.database_id
        AND DDS_Desired.data_space_id = UFG_Desired.data_space_id

*/ 
AS

SELECT  AllTables.DatabaseName,
        AllTables.SchemaName,
        AllTables.TableName,
        AllTables.DateDiffs,
        AllTables.PrepTableName,
		AllTables.NewPartitionedPrepTableName,
        AllTables.PartitionFunctionName,
        AllTables.BoundaryValue, 
        AllTables.NextBoundaryValue,
        AllTables.PartitionColumn,
        AllTables.IsNewPartitionedPrepTable,
        AllTables.PKColumnList,
        AllTables.PKColumnListJoinClause,
        AllTables.UpdateColumnList,
        Storage_Desired,
        StorageType_Desired,
        AllTables.PrepTableFilegroup,
        PartitionNumber,
        CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '
IF OBJECT_ID(''' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ''') IS NOT NULL
BEGIN
	DROP TABLE ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + '
END

IF OBJECT_ID(''' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ''') IS NULL
BEGIN
	CREATE TABLE ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' (' + CHAR(13) + CHAR(10) + AllTables.ColumnListWithTypes + ') ON [' + AllTables.Storage_Desired + ']' + CASE WHEN AllTables.PrepTableName LIKE '%NewPartitionedTableFromPrep' THEN '(' + AllTables.PartitionColumn + ')' ELSE '' END + '
END' 
ELSE '
IF OBJECT_ID(''' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ''') IS NOT NULL
BEGIN
	DROP TABLE ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + '
END

IF OBJECT_ID(''' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ''') IS NULL
BEGIN
	CREATE TABLE ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' (' + CHAR(13) + CHAR(10) + AllTables.ColumnListWithTypes + ') ON [' + AllTables.Storage_Desired + ']' + CASE WHEN AllTables.PrepTableName LIKE '%NewPartitionedTableFromPrep' THEN '(' + AllTables.PartitionColumn + ')' ELSE '' END + '
END' END AS CreatePrepTableSQL,
CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '' ELSE 
'
IF NOT EXISTS(SELECT * FROM sys.triggers WHERE name = ''tr' + AllTables.TableName + '_DataSynch'' AND OBJECT_NAME(parent_id) = ''' + AllTables.TableName + ''')
BEGIN
	RAISERROR (''Data Synch Trigger has not been created!!'', 16, 1)
END
ELSE
BEGIN
	DECLARE @T TABLE (XpCmdShellOutput VARCHAR(1000))

	INSERT INTO @T ( XpCmdShellOutput )
	EXEC xp_cmdshell ''' + SS.SettingValue + 'utebcAllTables.exe -query="SELECT * FROM PaymentReporting.' + AllTables.SchemaName + '.' + AllTables.TableName + ' T  WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE AllTables.PartitionColumn + ' >= ''''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''''' + ' AND ' END + AllTables.PartitionColumn + ' < ''''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''''' AND NOT EXISTS (SELECT 1 FROM ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' PT WHERE ' + AllTables.PKColumnListJoinClause + ')" -destination="' + AllTables.SchemaName + '.' + AllTables.PrepTableName + '" -database=PaymentReporting -batch=1000000''

	IF EXISTS(SELECT ''True'' FROM @T where TRY_CAST(XpCmdShellOutput AS INT) IS NULL)
	BEGIN
		DECLARE @ErrorMessage VARCHAR(1000) = ''''

		SELECT @ErrorMessage += XpCmdShellOutput + CHAR(13) + CHAR(10) FROM @T WHERE XpCmdShellOutput IS NOT NULL 

		RAISERROR(@ErrorMessage, 16, 1)
	END
	ELSE
	BEGIN
       SELECT TOP 1 @RowCountOUT = CASE WHEN TRY_CAST(XpCmdShellOutput AS INT) IS NOT NULL THEN CAST(XpCmdShellOutput AS INT) ELSE 0 END
	   FROM @T
     END
END'
END AS BCPSQL,
CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '' ELSE 
'
IF OBJECT_ID(''Chk_' + AllTables.PrepTableName + ''') IS NULL
BEGIN
	ALTER TABLE ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' WITH CHECK ADD
		CONSTRAINT Chk_' + AllTables.PrepTableName + '
			CHECK (' + AllTables.PartitionColumn + ' IS NOT NULL 
					AND ' + AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue , 120) + '''  
					AND ' + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''')
END' END AS CheckConstraintSQL,

CASE WHEN AllTables.IsNewPartitionedPrepTable = 0 THEN '' ELSE '
IF (SELECT * FROM DDI.fnCompareTableStructures(''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''',''' + AllTables.SchemaName + ''',''' + AllTables.NewPartitionedPrepTableName + ''', ''_NewPartitionedTableFromPrep'',''' + AllTables.PartitionColumn + ''')) > 0
BEGIN
    DECLARE @ErrorMessage VARCHAR(MAX) = ''Schemas from the 2 tables do not match!!''

    SELECT @ErrorMessage += CHAR(13) + CHAR(10) + ''***'' + IndexName + space(1) + SchemaDifferences + ''***'' + CHAR(13) + CHAR(10)
    FROM DDI.fnDDI_CompareTableStructuresDetails(''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''',''' + AllTables.SchemaName + ''',''' + AllTables.NewPartitionedPrepTableName + ''', ''_NewPartitionedTableFromPrep'',''' + AllTables.PartitionColumn + ''')

	RAISERROR(@ErrorMessage, 16, 1)
END

IF NOT EXISTS(	 SELECT * 
		  	 FROM sys.schemas s 
				INNER JOIN sys.tables t ON s.schema_id = AllTables.schema_id 
			 WHERE s.name = ''' + AllTables.SchemaName + ''' 
				AND AllTables.name = ''' + AllTables.NewPartitionedPrepTableName + ''') 
BEGIN
	RAISERROR(''NewPartitionedPrepTable does not exist!!'', 16, 1)
END

IF NOT EXISTS(	 SELECT * 
		  	 FROM sys.schemas s 
		  		INNER JOIN sys.tables t ON s.schema_id = AllTables.schema_id 
			 WHERE s.name = ''' + AllTables.SchemaName + ''' 
				AND AllTables.name = ''' + AllTables.TableName + ''')
BEGIN
	RAISERROR(''Live table does not exist!!'', 16, 1)
END

IF EXISTS(SELECT * 
		FROM sys.tables t 
		WHERE name <> ''' + AllTables.NewPartitionedPrepTableName + ''' 
		    AND name LIKE ''%' + AllTables.TableName + '%Prep%'')
BEGIN
	RAISERROR(''Some Prep tables still exist!!'', 16, 1)
END

DECLARE @RowCount_NewPrepTable int = (SELECT SUM(ROWS)
									  FROM sys.partitions 
									  WHERE object_id = OBJECT_ID(''' + AllTables.SchemaName + '.' + AllTables.NewPartitionedPrepTableName + ''') 
										 AND index_id in (0,1))

DECLARE @RowCount_OldTable int = (SELECT SUM(ROWS) 
								  FROM sys.partitions 
								  WHERE object_id = OBJECT_ID(''' + AllTables.SchemaName + '.' + AllTables.TableName + ''') 
									 AND index_id in (0,1))

DECLARE @MaximumAllowedRowsDifference DECIMAL(18,4) =  (	SELECT SUM(ROWS) * 0.1 
															FROM sys.partitions 
															WHERE object_id = OBJECT_ID(''' + AllTables.SchemaName + '.' + AllTables.TableName + ''') 
																AND index_id in (0,1))

IF ABS( @RowCount_NewPrepTable - @RowCount_OldTable ) > @MaximumAllowedRowsDifference 
BEGIN
	RAISERROR(''RowCounts from 2 tables are too far apart!!'', 16, 1)
END'
END AS FinalRepartitioningValidationSQL,

CASE WHEN AllTables.IsNewPartitionedPrepTable = 0 THEN '' ELSE '
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ''',
	@newname = ''' + AllTables.TableName + ''',
	@objtype = ''OBJECT''' 
END AS RenameNewPartitionedPrepTableSQL,
CASE WHEN AllTables.IsNewPartitionedPrepTable = 0 THEN '' ELSE 
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + AllTables.SchemaName + '.' + AllTables.TableName + ''',
	@newname = ''' + AllTables.TableName + '_OLD'',
	@objtype = ''OBJECT''' 
END AS RenameExistingTableSQL,

CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '' ELSE 
'UPDATE DDI.RefreshIndexStructures_PartitionState
SET DataSynchState = 1
WHERE SchemaName = ''' + AllTables.SchemaName + '''
	AND PrepTableName = ''' + AllTables.PrepTableName + '''
	AND PartitionFromValue = ''' + CAST(AllTables.BoundaryValue AS VARCHAR(20)) + '''
'
END AS TurnOnDataSynchSQL,

CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '' ELSE 
'
IF EXISTS (	SELECT ''True''
			FROM DDI.RefreshIndexStructures_PartitionState WITH (NOLOCK)
			WHERE SchemaName = ''' + AllTables.SchemaName + '''
				AND PrepTableName = ''' + AllTables.PrepTableName + '''
				AND DataSynchState = 1)
	AND EXISTS (SELECT ''True''
				FROM inserted
				WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''' + ' AND ' END + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''' 
				UNION ALL
				SELECT ''True''
				FROM deleted
				WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''' + ' AND ' END + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''' )
BEGIN
	INSERT INTO ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + '
	SELECT * 
	FROM inserted T
	WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE 'T.' + AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''' + ' AND ' END + 'T.' + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''' 
		AND NOT EXISTS (SELECT ''True''
						FROM deleted PT 
						WHERE ' + AllTables.PKColumnListJoinClause + ')

	UPDATE PT
	SET ' + AllTables.UpdateColumnList + '
	FROM ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' PT
		INNER JOIN inserted T ON ' + AllTables.PKColumnListJoinClause + '
		INNER JOIN deleted d ON ' + REPLACE(AllTables.PKColumnListJoinClause, 'PT.', 'd.') + '
	WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE 'T.' +AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''' + ' AND ' END + 'T.' + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''' 

	DELETE PT
	FROM ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' PT
		INNER JOIN deleted T ON ' + AllTables.PKColumnListJoinClause + '
	WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE 'T.' + AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''' + ' AND ' END + 'T.' + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''' 
		AND NOT EXISTS (SELECT ''True''
						FROM inserted i 
						WHERE ' + REPLACE(AllTables.PKColumnListJoinClause, 'PT.', 'i.') + ')
END' END AS PrepTableTriggerSQLFragment,

CASE WHEN AllTables.IsNewPartitionedPrepTable = 0 THEN '' ELSE 
'
INSERT INTO ' + AllTables.SchemaName + '.' + AllTables.TableName + '
SELECT ' + AllTables.ColumnListNoTypes + '
FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch O
WHERE O.DMLType = ''I''
	AND NOT EXISTS (SELECT ''True'' 
					FROM ' + + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK)
					WHERE ' + AllTables.PKColumnListJoinClause + ')

SET @RowCountOUT = @@ROWCOUNT

IF EXISTS(	SELECT ''True''
			FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch O
			WHERE O.DMLType = ''I''
				AND NOT EXISTS (SELECT ''True'' 
								FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK) 
								WHERE ' + AllTables.PKColumnListJoinClause + '))
BEGIN
	RAISERROR(''Not all INSERTs were synched to the new table for ' + AllTables.SchemaName + '.' + AllTables.TableName + '.'', 10, 1)
END' 
END AS SynchInsertsPrepTableSQL,
CASE WHEN AllTables.IsNewPartitionedPrepTable = 0 THEN '' ELSE 
'
UPDATE PT
SET ' + AllTables.UpdateColumnList + '
FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch O
	INNER JOIN ' + + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK) ON ' + AllTables.PKColumnListJoinClause + '
	INNER JOIN (SELECT ' + AllTables.PKColumnList + ', MAX(UpdatedUtcDt) AS UpdatedUtcDt 
				FROM ' + + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch
				WHERE  DMLType = ''U''
				GROUP BY ' + AllTables.PKColumnList + ') O2
		ON ' + REPLACE(AllTables.PKColumnListJoinClause, 'PT.', 'O2.') + '
			AND O2.UpdatedUtcDt = O.UpdatedUtcDt
WHERE O.DMLType = ''U''
	AND O.UpdatedUtcDt > PT.UpdatedUtcDt

SET @RowCountOUT = @@ROWCOUNT

IF EXISTS(	SELECT ''True'' 
			FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch O
				INNER JOIN ' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK) ON ' + AllTables.PKColumnListJoinClause + '
				INNER JOIN (SELECT ' + AllTables.PKColumnList + ', MAX(UpdatedUtcDt) AS UpdatedUtcDt 
							FROM ' + + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch
							WHERE  DMLType = ''U''
							GROUP BY ' + AllTables.PKColumnList + ') O2
					ON ' + REPLACE(AllTables.PKColumnListJoinClause, 'PT.', 'O2.') + '
						AND O2.UpdatedUtcDt = O.UpdatedUtcDt
			WHERE O.DMLType = ''U''
				AND O.UpdatedUtcDt > PT.UpdatedUtcDt)
BEGIN
	RAISERROR(''Not all UPDATEs were synched to the new table for ' + AllTables.SchemaName + '.' + AllTables.TableName + '.'', 10, 1)
END' 
END AS SynchUpdatesPrepTableSQL,
CASE WHEN AllTables.IsNewPartitionedPrepTable = 0 THEN '' ELSE 
'
DELETE PT
FROM ' + + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK)
WHERE EXISTS (	SELECT ''True'' 
				FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch O
				WHERE O.DMLType = ''D'' 
					AND ' + AllTables.PKColumnListJoinClause + ')

SET @RowCountOUT = @@ROWCOUNT

IF EXISTS(	SELECT ''True''
			FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch O
			WHERE O.DMLType = ''D''
				AND EXISTS (SELECT ''True'' 
							FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK) 
							WHERE ' + AllTables.PKColumnListJoinClause + '))
BEGIN
	RAISERROR(''Not all DELETEs were synched to the new table for ' + AllTables.SchemaName + '.' + AllTables.TableName + '.'', 10, 1)
END' 
END AS SynchDeletesPrepTableSQL,

CASE WHEN AllTables.IsNewPartitionedPrepTable = 0 THEN '' ELSE '
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + AllTables.SchemaName + '.' + AllTables.TableName + ''',
	@newname = ''' + AllTables.PrepTableName + ''',
	@objtype = ''OBJECT''' 
END AS RevertRenameNewPartitionedPrepTableSQL,

CASE WHEN AllTables.IsNewPartitionedPrepTable = 0 THEN '' ELSE '
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + AllTables.SchemaName + '.' + AllTables.TableName + '_OLD'',
	@newname = ''' + AllTables.TableName + ''',
	@objtype = ''OBJECT''' 
END AS RevertRenameExistingTableSQL,

CASE WHEN AllTables.IsNewPartitionedPrepTable = 0 THEN '' ELSE 
'
SELECT *
FROM (

		SELECT ''Inserts Left'' AS Type, COUNT(*) AS Counts
		FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch PT WITH (NOLOCK)
		WHERE PT.DMLType = ''I''
			AND NOT EXISTS (SELECT ''True'' 
							FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' O WITH (NOLOCK)
							WHERE ' + AllTables.PKColumnListJoinClause + ')
		UNION ALL
		SELECT ''Updates Left'' AS Type, COUNT(*)
		FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch PT WITH (NOLOCK)
		WHERE PT.DMLType = ''U''
			AND EXISTS (SELECT ''True'' 
						FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' O WITH (NOLOCK)
						WHERE ' + AllTables.PKColumnListJoinClause + '
							AND O.UpdatedUtcDt = PT.UpdatedUtcDt)
		UNION ALL
		SELECT ''Deletes Left'' AS Type, COUNT(*)
		FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch PT WITH (NOLOCK)
		WHERE PT.DMLType = ''D''
			AND EXISTS (SELECT ''True'' 
						FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' O WITH (NOLOCK)
						WHERE ' + AllTables.PKColumnListJoinClause + '))c
' END AS DataSynchProgressSQL,
'
SELECT COUNT(*), ''MissingInserts''
FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_OLD O
WHERE NOT EXISTS (	SELECT ''True''
					FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT 
					WHERE ' + AllTables.PKColumnListJoinClause + ')
UNION ALL
SELECT COUNT(*), ''MissingUpdates''
FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT
	INNER JOIN ' + AllTables.SchemaName + '.' + AllTables.TableName + '_OLD O ON ' + AllTables.PKColumnListJoinClause + '
WHERE O.UpdatedUtcDt > PT.UpdatedUtcDt
UNION ALL
--missing deletes
SELECT COUNT(*), ''Missing Deletes'' 
FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT
WHERE NOT EXISTS(	SELECT ''True'' 
					FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_OLD O 
					WHERE ' + AllTables.PKColumnListJoinClause + ')
	AND PT.UpdatedUtcDt < (SELECT MAX(UpdatedUtcDt) FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_OLD)' AS PostDataValidationMissingEventsSQL,
'
SELECT NewTable.DatePeriod, ISNULL(OldTable.NumRows, 0) AS OldTableNumRows, NewTable.NumRows AS NewTableNumRows, (NewTable.NumRows - ISNULL(OldTable.NumRows, 0)) AS Diff 
FROM (	SELECT CAST(YEAR(' + AllTables.PartitionColumn + ') AS CHAR(4)) + ''-'' + CASE WHEN MONTH(' + AllTables.PartitionColumn + ') < 10 THEN ''0'' ELSE SPACE(0) END + CAST(MONTH(' + AllTables.PartitionColumn + ') AS VARCHAR(2)) AS DatePeriod, COUNT(*) AS NumRows
		FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '
		GROUP BY CAST(YEAR(' + AllTables.PartitionColumn + ') AS CHAR(4)) + ''-'' + CASE WHEN MONTH(' + AllTables.PartitionColumn + ') < 10 THEN ''0'' ELSE SPACE(0) END + CAST(MONTH(' + AllTables.PartitionColumn + ') AS VARCHAR(2))) NewTable
	LEFT JOIN (	SELECT CAST(YEAR(' + AllTables.PartitionColumn + ') AS CHAR(4)) + ''-'' + CASE WHEN MONTH(' + AllTables.PartitionColumn + ') < 10 THEN ''0'' ELSE SPACE(0) END + CAST(MONTH(' + AllTables.PartitionColumn + ') AS VARCHAR(2)) AS DatePeriod, COUNT(*) AS NumRows
				FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_OLD
				GROUP BY CAST(YEAR(' + AllTables.PartitionColumn + ') AS CHAR(4)) + ''-'' + CASE WHEN MONTH(' + AllTables.PartitionColumn + ') < 10 THEN ''0'' ELSE SPACE(0) END + CAST(MONTH(' + AllTables.PartitionColumn + ') AS VARCHAR(2))) OldTable
		ON OldTable.DatePeriod = NewTable.DatePeriod
WHERE (NewTable.NumRows - ISNULL(OldTable.NumRows, 0)) <> 0
ORDER BY NewTable.DatePeriod' AS PostDataValidationCompareByPartitionSQL
FROM (  SELECT T.DatabaseName
                ,T.SchemaName
				,T.TableName
				,P.DateDiffs
				,P.PrepTableName
				,T.NewPartitionedPrepTableName
				,T.PartitionFunctionName
				,P.NextBoundaryValue
				,P.BoundaryValue
				,DDI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'CREATETABLE', 1, NULL, NULL) AS ColumnListWithTypes
				,DDI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'INSERT', 1, NULL, NULL) AS ColumnListNoTypes
				,DDI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'UPDATE', 1, 'PT', 'O') AS UpdateColumnList
    			,T.PartitionColumn
    			,T.PKColumnList
				,T.PKColumnListJoinClause
				,T.Storage_Desired
				,T.StorageType_Desired
				,P.PartitionNumber
                ,UFG_Desired.name AS PrepTableFilegroup
				,0 AS IsNewPartitionedPrepTable
        --SELECT COUNT(*)
        FROM DDI.Tables T
            CROSS APPLY (   SELECT *, T.TableName + P.PrepTableNameSuffix AS PrepTableName, 0 AS IsNewPartitionedPrepTable
                            FROM DDI.vwPartitionFunctionPartitions P 
                            WHERE T.Storage_Desired = PartitionSchemeName) P
                INNER JOIN DDI.SysDataSpaces DS_Desired ON T.Storage_Desired = DS_Desired.name
                INNER JOIN DDI.SysDestinationDataSpaces DDS_Desired ON DDS_Desired.database_id = DS_Desired.database_id
                    AND DDS_Desired.partition_scheme_id = DS_Desired.data_space_id
                    AND P.PartitionNumber = DDS_Desired.destination_id
                INNER JOIN DDI.SysDataSpaces UFG_Desired ON DDS_Desired.database_id = UFG_Desired.database_id
                    AND DDS_Desired.data_space_id = UFG_Desired.data_space_id
        WHERE IntendToPartition = 1
        UNION ALL
        SELECT	T.DatabaseName
                ,T.SchemaName
				,T.TableName
				,0 AS DateDiffs
				,T.TableName + '_NewPartitionedTableFromPrep' AS PrepTableName
				,T.TableName + '_NewPartitionedTableFromPrep' AS NewPartitionedPrepTableName
				,T.PartitionFunctionName
				,'9999-12-31' AS NextBoundaryValue
				,'0001-01-01' AS BoundaryValue
				,DDI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'CREATETABLE', 1, NULL, NULL) AS ColumnListWithTypes
				,DDI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'INSERT', 1, NULL, NULL) AS ColumnListNoTypes
				,DDI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'UPDATE', 1, 'PT', 'O') AS UpdateColumnList
    			,T.PartitionColumn
    			,T.PKColumnList
				,T.PKColumnListJoinClause
				,T.Storage_Desired
				,T.StorageType_Desired
				,0 AS PartitionNumber
                ,NULL AS PrepTableFilegroup
				,1 AS IsNewPartitionedPrepTable
        FROM DDI.Tables T
        WHERE IntendToPartition = 1) AllTables
    CROSS JOIN (SELECT * FROM DDI.DDISettings WHERE SettingName = 'UTEBCP Filepath') SS




GO
