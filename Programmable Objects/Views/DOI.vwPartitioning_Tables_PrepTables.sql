-- <Migration ID="c01e57fb-0a94-43d4-ae82-ce75a441091b" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!
IF OBJECT_ID('[DOI].[vwPartitioning_Tables_PrepTables]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitioning_Tables_PrepTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     VIEW [DOI].[vwPartitioning_Tables_PrepTables]

/*
	select top 10 CreateViewForBCPSQL
	from DOI.[vwPartitioning_Tables_PrepTables]
    where tablename = 'BAI2BANKTRANSACTIONS'
	order by tablename, partitionnumber

    --to get the PrepTableFilegroup:
SELECT t.TableName, t.Storage_Desired, ds_desired.name, DDS_Desired.data_space_id, UFG_Desired.name
FROM DOI.Tables T
    INNER JOIN DOI.SysDataSpaces DS_Desired ON T.Storage_Desired = DS_Desired.name
    INNER JOIN DOI.SysDestinationDataSpaces DDS_Desired ON DDS_Desired.database_id = DS_Desired.database_id
        AND DDS_Desired.partition_scheme_id = DS_Desired.data_space_id
    INNER JOIN DOI.SysDataSpaces UFG_Desired ON DDS_Desired.database_id = UFG_Desired.database_id
        AND DDS_Desired.data_space_id = UFG_Desired.data_space_id

 */ 
AS

SELECT  AllTables.DatabaseName,
        AllTables.SchemaName,
        AllTables.TableName,
        AllTables.DateDiffs,
        AllTables.PrepTableName,
		AllTables.PrepTableNameSuffix,
		AllTables.NewPartitionedPrepTableName,
        AllTables.PartitionFunctionName,
        AllTables.BoundaryValue, 
        AllTables.NextBoundaryValue,
        AllTables.PartitionColumn,
        AllTables.PKColumnList,
        AllTables.PKColumnListJoinClause,
        AllTables.UpdateColumnList,
        Storage_Desired,
        StorageType_Desired,
        AllTables.PrepTableFilegroup,
        PartitionNumber,
        '
IF OBJECT_ID(''' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ''') IS NOT NULL
BEGIN
	DROP TABLE ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.PrepTableName + '
END

IF OBJECT_ID(''' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ''') IS NULL
BEGIN
	CREATE TABLE ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' (' + CHAR(13) + CHAR(10) + AllTables.ColumnListWithTypes + ') ON [' + AllTables.PrepTableFilegroup + ']
END' AS CreatePrepTableSQL,
--CREATE VIEW FOR BCP QUERY BECAUSE SQL STRING IS TOO LONG FOR XP_CMDSHELL.
'CREATE OR ALTER VIEW dbo.vwCurrentBCPQuery AS 
SELECT * 
FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' T 
WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''' + ' AND ' END + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''' AND NOT EXISTS (SELECT 1 FROM ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' PT WHERE ' + AllTables.PKColumnListJoinClause + ')'
AS CreateViewForBCPSQL,
'
IF NOT EXISTS(  SELECT ''True''
                FROM ' + AllTables.DatabaseName + '.sys.triggers tr
                    INNER JOIN ' + AllTables.DatabaseName + '.sys.tables t ON tr.parent_id = t.object_id
                WHERE tr.name = ''tr' + AllTables.TableName + '_DataSynch'' 
                    AND t.name = ''' + AllTables.TableName + ''')
BEGIN
	RAISERROR (''Data Synch Trigger has not been created!!'', 16, 1)
END
ELSE
BEGIN
	DECLARE @T TABLE (XpCmdShellOutput VARCHAR(1000))

    DECLARE @bcpString VARCHAR(8000) = ''' + SS.SettingValue + 'utebcp.exe -queryout="SELECT * FROM dbo.vwCurrentBCPQuery" -destinationtable="' + AllTables.SchemaName + '.' + AllTables.PrepTableName + '" -database=' + AllTables.DatabaseName + ' -batch=1000000''
	
    INSERT INTO @T ( XpCmdShellOutput )
	EXEC xp_cmdshell @bcpString

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
AS BCPSQL,
'
IF OBJECT_ID(''' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.Chk_' + AllTables.PrepTableName + ''') IS NULL
BEGIN
	ALTER TABLE ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' WITH CHECK ADD
		CONSTRAINT Chk_' + AllTables.PrepTableName + '
			CHECK (' + AllTables.PartitionColumn + ' IS NOT NULL 
					AND ' + AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue , 120) + '''  
					AND ' + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''')
END' AS CheckConstraintSQL,
'
UPDATE DOI.DOI.Run_PartitionState
SET DataSynchState = 1
WHERE SchemaName = ''' + AllTables.SchemaName + '''
	AND PrepTableName = ''' + AllTables.PrepTableName + '''
	AND PartitionFromValue = ''' + CAST(AllTables.BoundaryValue AS VARCHAR(20)) + '''
'
AS TurnOnDataSynchSQL,

'
UPDATE DOI.DOI.Run_PartitionState
SET DataSynchState = 0
WHERE DatabaseName = ''' + AllTables.DatabaseName + '''
	AND SchemaName = ''' + AllTables.SchemaName + '''
	AND ParentTableName = ''' + AllTables.TableName + '''
'
END AS TurnOffDataSynchSQL,

CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '' ELSE 
'
IF EXISTS (	SELECT ''True''
			FROM DOI.DOI.Run_PartitionState WITH (NOLOCK)
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
	INSERT INTO ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + '(' + AllTables.ColumnListForDataSynchTriggerInsert + ')
	SELECT ' + AllTables.ColumnListForDataSynchTriggerSelect + /*FOR TEXT, IMAGE AND NTEXT COLUMNS, WE NEED TO PULL THEM FROM THE PT TABLE.*/'
	FROM inserted T
		INNER JOIN ' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT ON ' + AllTables.PKColumnListJoinClause + ' 
	WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE 'T.' + AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''' + ' AND ' END + 'T.' + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''' 
		AND NOT EXISTS (SELECT ''True''
						FROM deleted PT 
						WHERE ' + AllTables.PKColumnListJoinClause + ')

	UPDATE PT
	SET ' + AllTables.ColumnListForDataSynchTriggerUpdate + '
	FROM ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' PT
		INNER JOIN inserted T ON ' + AllTables.PKColumnListJoinClause + '
		INNER JOIN deleted d ON ' + REPLACE(AllTables.PKColumnListJoinClause, 'PT.', 'd.') + '
		INNER JOIN ' + AllTables.SchemaName + '.' + AllTables.TableName + ' ST ON ' + REPLACE(AllTables.PKColumnListJoinClause, 'PT.', 'ST.') + ' 
	WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE 'T.' +AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''' + ' AND ' END + 'T.' + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''' 

	DELETE PT
	FROM ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' PT
		INNER JOIN deleted T ON ' + AllTables.PKColumnListJoinClause + '
	WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE 'T.' + AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''' + ' AND ' END + 'T.' + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''' 
		AND NOT EXISTS (SELECT ''True''
						FROM inserted i 
						WHERE ' + REPLACE(AllTables.PKColumnListJoinClause, 'PT.', 'i.') + ')
END' AS PrepTableTriggerSQLFragment,

'
SELECT COUNT(*), ''MissingInserts''
FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_OLD T
WHERE NOT EXISTS (	SELECT ''True''
					FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT 
					WHERE ' + AllTables.PKColumnListJoinClause + ')
UNION ALL
SELECT COUNT(*), ''MissingUpdates''
FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT
	INNER JOIN ' + AllTables.SchemaName + '.' + AllTables.TableName + '_OLD T ON ' + AllTables.PKColumnListJoinClause + '
WHERE T.UpdatedUtcDt > PT.UpdatedUtcDt
UNION ALL
SELECT COUNT(*), ''Missing Deletes'' 
FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT
WHERE NOT EXISTS(	SELECT ''True'' 
					FROM ' + AllTables.SchemaName + '.' + AllTables.TableName + '_OLD T
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
				,P.PrepTableNameSuffix
				,T.NewPartitionedPrepTableName
				,T.PartitionFunctionName
				,P.NextBoundaryValue
				,P.BoundaryValue
				,T.ColumnListWithTypes
				,T.ColumnListNoTypes
				,T.UpdateColumnList
				,T.ColumnListForDataSynchTriggerSelect
				,T.ColumnListForDataSynchTriggerUpdate
				,T.ColumnListForDataSynchTriggerInsert
				,T.TableHasOldBlobColumns
				,T.TableHasIdentityColumn
    			,T.PartitionColumn
    			,T.PKColumnList
				,T.PKColumnListJoinClause
				,T.Storage_Desired
				,T.StorageType_Desired
				,P.PartitionNumber
                ,UFG_Desired.name AS PrepTableFilegroup
				,0 AS IsNewPartitionedPrepTable
        --SELECT COUNT(*)
        FROM DOI.Tables T
            CROSS APPLY (   SELECT *, T.TableName + P.PrepTableNameSuffix AS PrepTableName
                            FROM (  SELECT  *,         
                                            CASE 
			                                    WHEN DateDiffs IN (365, 366) 
			                                    THEN CAST(YEAR(CONVERT(DATE, BoundaryValue, 112)) AS VARCHAR(4))-- 'Yearly' 
			                                    WHEN DateDiffs IN (28, 29, 30, 31) 
			                                    THEN CAST(YEAR(CONVERT(DATE, BoundaryValue, 112)) AS VARCHAR(4))
					                                    + CASE WHEN LEN(CAST(MONTH(CONVERT(DATE, BoundaryValue, 112)) AS VARCHAR(2))) < 2 THEN '0' ELSE '' END 
					                                    + CAST(MONTH(CONVERT(DATE, BoundaryValue, 112)) AS VARCHAR(4)) --'Monthly' 
			                                    WHEN DateDiffs = 1
			                                    THEN 'Daily'
			                                    WHEN BoundaryValue < InitialDate--= '0001-01-01'
			                                    THEN 'Historical' 
			                                    WHEN NextBoundaryValue = '9999-12-31'
			                                    THEN 'LastPartition'
			                                    ELSE ''
		                                    END + '_PartitionPrep' AS PrepTableNameSuffix
                                    FROM (  SELECT	PFI.DatabaseName,
				                                    PFI.PartitionFunctionName,
                                                    PFI.PartitionSchemeName,
                                                    PFI.BoundaryInterval,
                                                    PFI.BoundaryValue,
                                                    CAST(LEAD(BoundaryValue, 1, '9999-12-31') OVER (PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS DATE) AS NextBoundaryValue,
                                                    DATEDIFF(DAY, PFI.BoundaryValue, CAST(LEAD(BoundaryValue, 1, '9999-12-31') OVER (PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS DATE)) AS DateDiffs,
                                                    ROW_NUMBER() OVER(PARTITION BY PartitionFunctionName ORDER BY BoundaryValue) AS PartitionNumber,
				                                    PFI.IncludeInPartitionFunction,
                                                    PFI.IncludeInPartitionScheme,
													PFI.InitialDate
                                            --SELECT count(*)
                                            FROM (  SELECT	TOP (1234567890987) *
                                                    FROM (SELECT DISTINCT
		                                                    PFM.*,
		                                                    CASE  
			                                                    WHEN BoundaryInterval = 'Monthly' AND (DATEADD(MONTH, RowNum-1, InitialDate) > PFM.LastBoundaryDate) 
			                                                    THEN PFM.LastBoundaryDate
			                                                    WHEN BoundaryInterval = 'Monthly' AND (DATEADD(MONTH, RowNum-1, InitialDate) <= PFM.LastBoundaryDate) 
			                                                    THEN DATEADD(MONTH, RowNum-1, InitialDate)
			                                                    WHEN BoundaryInterval = 'Yearly' AND (DATEADD(YEAR, RowNum-1, InitialDate) > PFM.LastBoundaryDate)
			                                                    THEN PFM.LastBoundaryDate
			                                                    WHEN BoundaryInterval = 'Yearly' AND (DATEADD(YEAR, RowNum-1, InitialDate) <= PFM.LastBoundaryDate)
			                                                    THEN DATEADD(YEAR, RowNum-1, InitialDate)
		                                                    END AS BoundaryValue,
		                                                    CASE 
			                                                    WHEN BoundaryInterval = 'Monthly' AND (DATEADD(MONTH, RowNum-1, InitialDate) > PFM.LastBoundaryDate) 
			                                                    THEN 'Active'
			                                                    WHEN BoundaryInterval = 'Monthly' AND (DATEADD(MONTH, RowNum-1, InitialDate) <= PFM.LastBoundaryDate) 
			                                                    THEN LEFT(CONVERT(VARCHAR(20), DATEADD(MONTH, RowNum-1, InitialDate), 112), NumOfCharsInSuffix) 
			                                                    WHEN BoundaryInterval = 'Yearly'  AND (DATEADD(YEAR, RowNum-1, InitialDate) > PFM.LastBoundaryDate)
			                                                    THEN 'Active'
			                                                    WHEN BoundaryInterval = 'Yearly'  AND (DATEADD(YEAR, RowNum-1, InitialDate) <= PFM.LastBoundaryDate)
			                                                    THEN LEFT(CONVERT(VARCHAR(20), DATEADD(YEAR, RowNum-1, InitialDate), 112), NumOfCharsInSuffix) 
		                                                    END AS Suffix,
		                                                    CASE 
			                                                    WHEN (PFM.BoundaryInterval = 'Yearly' AND PFM.UsesSlidingWindow = 1 AND (DATEADD(YEAR, RowNum-1, InitialDate) > PFM.LastBoundaryDate))
					                                                    OR (PFM.BoundaryInterval = 'Monthly' AND PFM.UsesSlidingWindow = 1 AND (DATEADD(MONTH, RowNum-1, InitialDate) > PFM.LastBoundaryDate))
			                                                    THEN 1
			                                                    ELSE 0
		                                                    END AS IsSlidingWindowActivePartition,
		                                                    1 AS IncludeInPartitionFunction,
		                                                    1 AS IncludeInPartitionScheme
                                                    --select count(*)
                                                    FROM DOI.PartitionFunctions PFM
	                                                    CROSS APPLY DOI.fnNumberTable(ISNULL(NumOfTotalPartitionFunctionIntervals, 0)) PSN
                                                    UNION ALL
                                                    SELECT	PFM.*,
		                                                    MinInterval.MinValueOfDataType AS BoundaryValue,
		                                                    'Historical' AS Suffix,
		                                                    0 AS IsSlidingWindowActivePartition,
		                                                    0 AS IncludeInPartitionFunction,
		                                                    1 AS IncludeInPartitionScheme
                                                    FROM DOI.PartitionFunctions PFM
	                                                    CROSS APPLY (   SELECT PFM2.MinValueOfDataType 
                                                                        FROM DOI.PartitionFunctions PFM2 
                                                                        WHERE PFM2.PartitionFunctionName = PFM.PartitionFunctionName) MinInterval)V
                                                    ORDER BY PartitionFunctionName, BoundaryValue)PFI)X) P 
                            WHERE T.Storage_Desired = PartitionSchemeName) P
                INNER JOIN DOI.SysDataSpaces DS_Desired ON T.Storage_Desired = DS_Desired.name
                INNER JOIN DOI.SysDestinationDataSpaces DDS_Desired ON DDS_Desired.database_id = DS_Desired.database_id
                    AND DDS_Desired.partition_scheme_id = DS_Desired.data_space_id
                    AND P.PartitionNumber = DDS_Desired.destination_id
                INNER JOIN DOI.SysDataSpaces UFG_Desired ON DDS_Desired.database_id = UFG_Desired.database_id
                    AND DDS_Desired.data_space_id = UFG_Desired.data_space_id
				,T.ColumnListForDataSynchTriggerSelect
				,T.ColumnListForDataSynchTriggerUpdate
				,T.ColumnListForDataSynchTriggerInsert
				,T.TableHasOldBlobColumns
				,T.TableHasIdentityColumn
                ,'PRIMARY' AS PrepTableFilegroup
        WHERE IntendToPartition = 1) AllTables
    CROSS JOIN (SELECT * FROM DOI.DOISettings WHERE SettingName = 'UTEBCP Filepath') SS

GO