-- <Migration ID="39dd4fb0-685b-450a-ab56-2f939541670b" />
IF OBJECT_ID('[DOI].[vwExchangeTableNonPartitioned_Tables_NewTable]') IS NOT NULL
	DROP VIEW [DOI].[vwExchangeTableNonPartitioned_Tables_NewTable];

GO

CREATE     VIEW [DOI].[vwExchangeTableNonPartitioned_Tables_NewTable]

/*
	select top 10 CreateViewForBCPSQL
	from DOI.[vwExchangeTableNonPartitioned_Tables_NewTable]
    where tablename = 'BAI2BANKTRANSACTIONS'
 */ 
AS

SELECT  AllTables.DatabaseName,
        AllTables.SchemaName,
        AllTables.TableName,
        AllTables.NewTableName,
		AllTables.NewTableNameSuffix,
        AllTables.PKColumnList,
        AllTables.PKColumnListJoinClause_Desired,
        AllTables.UpdateColumnList,
        AllTables.Storage_Desired,
        AllTables.StorageType_Desired,
        AllTables.NewTableFilegroup,'
DROP TABLE IF EXISTS ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch

IF OBJECT_ID(''' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch'') IS NULL
BEGIN
	CREATE TABLE ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch (' + CHAR(13) + CHAR(10) + AllTables.ColumnListWithTypes + CHAR(13) + CHAR(10) + ' DMLType CHAR(1) NOT NULL) ON [' + AllTables.Storage_Desired + ']' + '
END
'		AS CreateDataSynchTableSQL,
		'
CREATE OR ALTER TRIGGER ' + AllTables.SchemaName + '.tr' + AllTables.TableName + '_DataSynch
ON ' + AllTables.SchemaName + '.' + AllTables.TableName + '
AFTER INSERT, UPDATE, DELETE
AS

INSERT INTO ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch (' + AllTables.ColumnListNoTypes + ', DMLType)
SELECT ' + AllTables.ColumnListNoTypes + ', ''I''
FROM inserted T
WHERE NOT EXISTS(SELECT ''True'' FROM deleted PT WHERE ' + AllTables.PKColumnListJoinClause_Desired + ')

INSERT INTO ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch (' + AllTables.ColumnListNoTypes + ', DMLType)
SELECT ' + AllTables.ColumnListNoTypes + ', ''U''
FROM inserted T
WHERE EXISTS (SELECT * FROM deleted PT WHERE ' + AllTables.PKColumnListJoinClause_Desired + ')

INSERT INTO ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch (' + AllTables.ColumnListNoTypes + ', DMLType)
SELECT ' + AllTables.ColumnListNoTypes + ', ''D''
FROM deleted T
WHERE NOT EXISTS(SELECT ''True'' FROM inserted PT WHERE ' + AllTables.PKColumnListJoinClause_Desired + ')'
AS CreateDataSynchTriggerSQL,
'
USE ' + AllTables.DatabaseName + '
IF EXISTS(SELECT * FROM sys.triggers tr WHERE tr.name = ''tr' + AllTables.TableName + '_DataSynch'' AND OBJECT_NAME(parent_id) = ''' + AllTables.TableName + '_OLD'')
BEGIN
	DROP TRIGGER tr' + AllTables.TableName + '_DataSynch
END' 
AS DropDataSynchTriggerSQL,
		'
IF OBJECT_ID(''' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch'') IS NOT NULL
	AND OBJECT_ID(''' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ''') IS NOT NULL
BEGIN
	IF (SELECT SUM(Counts)
		FROM (
				SELECT ''Inserts Left'' AS Type, COUNT(*) AS Counts
				FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch PT
				WHERE PT.DMLType = ''I''
					AND NOT EXISTS (SELECT ''True'' 
									FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' T
									WHERE ' + AllTables.PKColumnListJoinClause_Desired + ')
				UNION ALL
				SELECT ''Updates Left'' AS Type, COUNT(*)
				FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch PT
				WHERE PT.DMLType = ''U''
					AND EXISTS (SELECT ''True'' 
								FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' T
								WHERE ' + AllTables.PKColumnListJoinClause_Desired + '
									AND T.' + AllTables.UpdateTimeStampColumn + ' < PT.' + AllTables.UpdateTimeStampColumn + ')
				UNION ALL
				SELECT ''Deletes Left'' AS Type, COUNT(*)
				FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch PT
				WHERE PT.DMLType = ''D''
					AND EXISTS (SELECT ''True'' 
								FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' T
								WHERE ' + AllTables.PKColumnListJoinClause_Desired + '))c) = 0
	BEGIN
		DROP TABLE ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch
	END
	ELSE
	BEGIN
		RAISERROR(''Not all data was synched to the new table.  ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch Table was not dropped'', 10, 1)
	END
END
ELSE
BEGIN
	RAISERROR(''Not all necessary tables have been created.'' , 16 , 1);
END'
AS DropDataSynchTableSQL,
'
INSERT INTO ' + AllTables.DatabaseName + '.' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '
SELECT ' + AllTables.ColumnListNoTypes + '
FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch T
WHERE T.DMLType = ''I''
	AND NOT EXISTS (SELECT ''True'' 
					FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK)
					WHERE ' + AllTables.PKColumnListJoinClause_Desired + ')

SET @RowCountOUT = @@ROWCOUNT

IF EXISTS(	SELECT ''True''
			FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch T
			WHERE T.DMLType = ''I''
				AND NOT EXISTS (SELECT ''True'' 
								FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK) 
								WHERE ' + AllTables.PKColumnListJoinClause_Desired + '))
BEGIN
	RAISERROR(''Not all INSERTs were synched to the new table for ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '.'', 10, 1)
END' 
AS SynchInsertsNewTableSQL,
'
UPDATE PT
SET ' + AllTables.UpdateColumnList + '
FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch T
	INNER JOIN ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK) ON ' + AllTables.PKColumnListJoinClause_Desired + '
	INNER JOIN (SELECT ' + AllTables.PKColumnList + ', MAX(' + AllTables.UpdateTimeStampColumn + ') AS ' + AllTables.UpdateTimeStampColumn + '
				FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch
				WHERE  DMLType = ''U''
				GROUP BY ' + AllTables.PKColumnList + ') O2
		ON ' + REPLACE(AllTables.PKColumnListJoinClause_Desired, 'PT.', 'O2.') + '
			AND O2.' + AllTables.UpdateTimeStampColumn + ' = T.' + AllTables.UpdateTimeStampColumn + '
WHERE T.DMLType = ''U''
	AND T.' + AllTables.UpdateTimeStampColumn + ' > PT.' + AllTables.UpdateTimeStampColumn + '

SET @RowCountOUT = @@ROWCOUNT

IF EXISTS(	SELECT ''True'' 
			FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch T
				INNER JOIN ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK) ON ' + AllTables.PKColumnListJoinClause_Desired + '
				INNER JOIN (SELECT ' + AllTables.PKColumnList + ', MAX(' + AllTables.UpdateTimeStampColumn + ') AS ' + AllTables.UpdateTimeStampColumn + ' 
							FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch
							WHERE  DMLType = ''U''
							GROUP BY ' + AllTables.PKColumnList + ') O2
					ON ' + REPLACE(AllTables.PKColumnListJoinClause_Desired, 'PT.', 'O2.') + '
						AND O2.' + AllTables.UpdateTimeStampColumn + ' = T.' + AllTables.UpdateTimeStampColumn + '
			WHERE T.DMLType = ''U''
				AND T.' + AllTables.UpdateTimeStampColumn + ' > PT.' + AllTables.UpdateTimeStampColumn + ')
BEGIN
	RAISERROR(''Not all UPDATEs were synched to the new table for ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '.'', 10, 1)
END' 
AS SynchUpdatesNewTableSQL,
'
DELETE PT
FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK)
WHERE EXISTS (	SELECT ''True'' 
				FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch T
				WHERE T.DMLType = ''D'' 
					AND ' + AllTables.PKColumnListJoinClause_Desired + ')

SET @RowCountOUT = @@ROWCOUNT

IF EXISTS(	SELECT ''True''
			FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch T
			WHERE T.DMLType = ''D''
				AND EXISTS (SELECT ''True'' 
							FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' PT WITH (TABLOCKX, XLOCK) 
							WHERE ' + AllTables.PKColumnListJoinClause_Desired + '))
BEGIN
	RAISERROR(''Not all DELETEs were synched to the new table for ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '.'', 10, 1)
END' 
AS SynchDeletesNewTableSQL,
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + AllTables.SchemaName + '.' + AllTables.NewTableName + ''',
	@newname = ''' + AllTables.TableName + ''',
	@objtype = ''OBJECT''' 
AS RenameNewTableSQL,
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + AllTables.SchemaName + '.' + AllTables.TableName + ''',
	@newname = ''' + AllTables.TableName + '_OLD'',
	@objtype = ''OBJECT''' 
AS RenameExistingTableSQL,
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + AllTables.SchemaName + '.' + AllTables.TableName + ''',
	@newname = ''' + AllTables.NewTableName + ''',
	@objtype = ''OBJECT''' 
AS RevertRenameNewTableSQL, --need to add USE statement above to change DB context?

'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + AllTables.SchemaName + '.' + AllTables.TableName + '_OLD'',
	@newname = ''' + AllTables.TableName + ''',
	@objtype = ''OBJECT''' 
AS RevertRenameExistingTableSQL, --need to add USE statement above to change DB context?
'
SELECT *
FROM (
		SELECT ''Inserts Left'' AS Type, COUNT(*) AS Counts
		FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch PT WITH (NOLOCK)
		WHERE PT.DMLType = ''I''
			AND NOT EXISTS (SELECT ''True'' 
							FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' T WITH (NOLOCK)
							WHERE ' + AllTables.PKColumnListJoinClause_Desired + ')
		UNION ALL
		SELECT ''Updates Left'' AS Type, COUNT(*)
		FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch PT WITH (NOLOCK)
		WHERE PT.DMLType = ''U''
			AND EXISTS (SELECT ''True'' 
						FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' T WITH (NOLOCK)
						WHERE ' + AllTables.PKColumnListJoinClause_Desired + '
							AND O.' + AllTables.UpdateTimeStampColumn + ' = PT.' + AllTables.UpdateTimeStampColumn + ')
		UNION ALL
		SELECT ''Deletes Left'' AS Type, COUNT(*)
		FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + '_DataSynch PT WITH (NOLOCK)
		WHERE PT.DMLType = ''D''
			AND EXISTS (SELECT ''True'' 
						FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' T WITH (NOLOCK)
						WHERE ' + AllTables.PKColumnListJoinClause_Desired + '))c
' AS DataSynchProgressSQL,
'
IF (SELECT * FROM dbo.fnCompareTableStructures(''' + AllTables.DatabaseName + ''',''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''',''' + AllTables.SchemaName + ''',''' + AllTables.NewTableName + ''', ''_New'')) > 0
BEGIN
    DECLARE @ErrorMessage VARCHAR(MAX) = ''Schemas from the 2 tables do not match!!''

    SELECT @ErrorMessage += CHAR(13) + CHAR(10) + ''***'' + IndexName + space(1) + SchemaDifferences + ''***'' + CHAR(13) + CHAR(10)
    FROM dbo.fnCompareTableStructuresDetails(''' + AllTables.DatabaseName + ''',''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''',''' + AllTables.SchemaName + ''',''' + AllTables.NewTableName + ''', ''_New'')

	RAISERROR(@ErrorMessage, 16, 1)
END

IF NOT EXISTS(	 SELECT * 
		  	     FROM DOI.SysSchemas s 
				    INNER JOIN DOI.SysTables t ON s.schema_id = t.schema_id 
			     WHERE d.name = ''' + AllTables.DatabaseName + '''
					AND s.name = ''' + AllTables.SchemaName + ''' 
				    AND t.name = ''' + AllTables.NewTableName + ''') 
BEGIN
	RAISERROR(''NewTable does not exist!!'', 16, 1)
END

IF NOT EXISTS(	 SELECT * 
		  	     FROM DOI.SysSchemas s 
				    INNER JOIN DOI.SysTables t ON s.schema_id = t.schema_id 
			     WHERE d.name = ''' + AllTables.DatabaseName + '''
					AND s.name = ''' + AllTables.SchemaName + ''' 
				    AND t.name = ''' + AllTables.TableName + ''')
BEGIN
	RAISERROR(''Live table does not exist!!'', 16, 1)
END

IF EXISTS(  SELECT *
		    FROM DOI.SysTables t 
		    WHERE name <> ''' + AllTables.NewTableName + ''' 
		        AND name LIKE ''%' + AllTables.TableName + '%New%'')
BEGIN
	RAISERROR(''Some New tables still exist!!'', 16, 1)
END

DECLARE @RowCount_NewTable int = (SELECT SUM(ROWS)
									  FROM DOI.SysPartitions 
									  WHERE object_id = OBJECT_ID(''' + AllTables.DatabaseName + ''',''' + AllTables.SchemaName + '.' + AllTables.NewTableName + ''') 
										 AND index_id in (0,1))

DECLARE @RowCount_OldTable int = (SELECT SUM(ROWS) 
								  FROM DOI.SysPartitions 
								  WHERE object_id = OBJECT_ID(''' + AllTables.DatabaseName + ''',''' + AllTables.SchemaName + '.' + AllTables.TableName + ''') 
									 AND index_id in (0,1))

DECLARE @MaximumAllowedRowsDifference DECIMAL(18,4) =  (	SELECT SUM(ROWS) * 0.1 
															FROM sys.partitions 
															WHERE object_id = OBJECT_ID(''' + AllTables.DatabaseName + ''',''' + AllTables.SchemaName + '.' + AllTables.TableName + ''') 
																AND index_id in (0,1))

IF ABS( @RowCount_NewTable - @RowCount_OldTable ) > @MaximumAllowedRowsDifference 
BEGIN
	RAISERROR(''RowCounts from 2 tables are too far apart!!'', 16, 1)
END'
AS FinalValidationSQL,
'
DROP TABLE IF EXISTS ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.NewTableName + '

IF OBJECT_ID(''' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.NewTableName + ''') IS NULL
BEGIN
	CREATE TABLE ' + AllTables.SchemaName + '.' + AllTables.NewTableName + ' (' + CHAR(13) + CHAR(10) + AllTables.ColumnListWithTypes + ') ON [' + AllTables.NewTableFilegroup + ']
END' AS CreateNewTableSQL,
--CREATE VIEW FOR BCP QUERY BECAUSE SQL STRING IS TOO LONG FOR XP_CMDSHELL.
'CREATE OR ALTER VIEW dbo.vwCurrentBCPQuery AS 
SELECT * 
FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' T 
WHERE NOT EXISTS (SELECT 1 FROM ' + AllTables.SchemaName + '.' + AllTables.NewTableName + ' PT WHERE ' + AllTables.PKColumnListJoinClause_Desired + ')'
AS CreateViewForBCPSQL,
'
DECLARE @RowCountOUT INT

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

    DECLARE @bcpString VARCHAR(8000) = ''' + SS.SettingValue + 'utebcp.exe -queryout="SELECT * FROM dbo.vwCurrentBCPQuery" -destinationtable="' + AllTables.SchemaName + '.' + AllTables.NewTableName + '" -database=' + AllTables.DatabaseName + ' -batch=1000000''
	
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
CREATE OR ALTER FUNCTION [dbo].[fnActualIndexesForTable](
	@DatabaseName SYSNAME,
	@SchemaName SYSNAME,
	@TableName SYSNAME,
	@NameStringReplace SYSNAME = NULL)
RETURNS TABLE
AS RETURN
(

/*
SELECT * 
FROM DOI.fnActualIndexesForTable(''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''', ''_New'')

SELECT *
FROM DOI.fnActualIndexesForTable(''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''', ''_New'')
*/
SELECT 
    d.name AS DatabaseName
    ,s.name AS SchemaName
    ,REPLACE(t.name, @NameStringReplace, SPACE(0)) AS TableName
	,REPLACE(i.name, @NameStringReplace, SPACE(0)) AS IndexName
	--,i.type
	,i.type_desc
	,i.is_unique
	,i.ignore_dup_key
	,i.is_primary_key
	,i.is_unique_constraint
	,i.is_disabled
	,i.is_hypothetical
	,i.has_filter
	,i.filter_definition
    ,i.key_column_list AS IndexKeys
    ,i.included_column_list AS IncludedColumns 
FROM DOI.SysIndexes i
	INNER JOIN DOI.SysDatabases d ON i.database_id = d.database_id
	INNER JOIN DOI.SysTables t ON t.database_id = d.database_id
		AND t.object_id = i.object_id
	INNER JOIN DOI.SysSchemas s ON s.database_id = d.database_id
		AND s.schema_id = t.schema_id
WHERE d.name = @DatabaseName
	AND s.name = @SchemaName
	AND t.name = @TableName)
' AS FinalValidation_CreateActualIndexesForTableFunctionSQL,
'
CREATE OR ALTER FUNCTION [dbo].[fnActualConstraintsForTable](
	@DatabaseName SYSNAME,
	@SchemaName SYSNAME,
	@TableName SYSNAME,
	@NameStringReplace SYSNAME = NULL)
RETURNS TABLE
AS RETURN
(

/*
SELECT * 
FROM DOI.fnActualConstraintsForTable((''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''', ''_New'', '' '')
--order by ConstraintName	
except
SELECT *
FROM DOI.fnActualConstraintsForTable((''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''', ''_New'', ''_OLD'')
order by ConstraintName	
*/

SELECT	REPLACE(cc.name, @NameStringReplace, SPACE(0)) AS ConstraintName, 
		cc.type_desc, 
		c.name AS ColumnName, 
		cc.definition
FROM DOI.SysCheckConstraints cc
	INNER JOIN DOI.SysDatabases d ON cc.database_id = d.database_id
	INNER JOIN DOI.SysTables t ON t.database_id = d.database_id
		AND t.object_id = i.object_id
	INNER JOIN DOI.SysColumns c ON c.database_id = d.database_id
		AND c.object_id = t.object_id
		AND c.column_id = cc.parent_column_id
	INNER JOIN DOI.SysSchemas s ON s.database_id = d.database_id
		AND s.schema_id = t.schema_id
WHERE d.name = @DatabaseName
	AND s.name = @SchemaName
	AND t.name = @TableName
UNION ALL
SELECT	REPLACE(dc.name, @NameStringReplace, SPACE(0)) AS ConstraintName, 
		dc.type_desc, 
		c.name AS ColumnName, 
		dc.definition
FROM DOI.SysDefaultConstraints dc
	INNER JOIN DOI.SysDatabases d ON dc.database_id = d.database_id
	INNER JOIN DOI.SysTables t ON t.database_id = d.database_id
		AND t.object_id = i.object_id
	INNER JOIN DOI.SysColumns c ON c.database_id = d.database_id
		AND c.object_id = t.object_id
		AND c.column_id = dc.parent_column_id
	INNER JOIN DOI.SysSchemas s ON s.database_id = d.database_id
		AND s.schema_id = t.schema_id
WHERE d.name = @DatabaseName
	AND s.name = @SchemaName
	AND t.name = @TableName)
' AS FinalValidation_CreateActualConstraintsForTableFunctionSQL,
'
CREATE OR ALTER FUNCTION [dbo].[fnCompareTableStructuresDetails](
    @DatabaseName SYSNAME,
	@SchemaName1 SYSNAME,
	@TableName1 SYSNAME,
	@SchemaName2 SYSNAME,
	@TableName2 SYSNAME,
	@DiffBetTableNames SYSNAME,
	@PartitionColumnToReplaceInPK SYSNAME)
RETURNS TABLE

AS

/*
    select * from dbo.fnCompareTableStructuresDetails(
    ''PaymentReporting'',
    ''dbo'',
    ''Bai2BankTransactions'',
    ''dbo'',
    ''Bai2BankTransactions_New'',
    ''_New'',
    ''TransactionSysUtcDt'')
*/
RETURN (
        SELECT *
        FROM (  SELECT  AT.DatabaseName,
                        ISNULL(AT.TableName, NUT.TableName) AS TableName,
                        ISNULL(AT.IndexName, NUT.IndexName) AS IndexName,
                        CASE 
                            WHEN ISNULL(AT.type_desc, '''') <> ISNULL(NUT.type_desc, '''') 
                            THEN ''TypeDiff:  Actual Table:  '' + ISNULL(AT.type_desc, '''') + ''// New Table:  '' + ISNULL(NUT.type_desc, '''') 
                            ELSE ''''
                        END + 
                        CASE 
                            WHEN ISNULL(CAST(AT.is_unique AS CHAR(1)), '''') <> ISNULL(CAST(NUT.is_unique AS CHAR(1)), '''') 
                            THEN ''IsUniqueDiff:  Actual Table:  '' + ISNULL(CAST(AT.is_unique AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NUT.is_unique AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.ignore_dup_key AS CHAR(1)), '''') <> ISNULL(CAST(NUT.ignore_dup_key AS CHAR(1)), '''') 
                            THEN ''OptionIgnoreDupKeyDiff:  Actual Table:  '' + ISNULL(CAST(AT.ignore_dup_key AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NUT.ignore_dup_key AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_primary_key AS CHAR(1)), '''') <> ISNULL(CAST(NUT.is_primary_key AS CHAR(1)), '''') 
                            THEN ''IsPrimaryKeyDiff:  Actual Table:  '' + ISNULL(CAST(AT.is_primary_key AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NUT.is_primary_key AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_unique_constraint AS CHAR(1)), '''') <> ISNULL(CAST(NUT.is_unique_constraint AS CHAR(1)), '''') 
                            THEN ''IsUniqueConstraintDiff:  Actual Table:  '' + ISNULL(CAST(AT.is_unique_constraint AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NUT.is_unique_constraint AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_disabled AS CHAR(1)), '''') <> ISNULL(CAST(NUT.is_disabled AS CHAR(1)), '''') 
                            THEN ''IsDisableDOIff:  Actual Table:  '' + ISNULL(CAST(AT.is_disabled AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NUT.is_disabled AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_hypothetical AS CHAR(1)), '''') <> ISNULL(CAST(NUT.is_hypothetical AS CHAR(1)), '''') 
                            THEN ''IsHypotheticalDiff:  Actual Table:  '' + ISNULL(CAST(AT.is_hypothetical AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NUT.is_hypothetical AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.has_filter AS CHAR(1)), '''') <> ISNULL(CAST(NUT.has_filter AS CHAR(1)), '''') 
                            THEN ''IsFiltereDOIff:  Actual Table:  '' + ISNULL(CAST(AT.has_filter AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NUT.has_filter AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(AT.filter_definition, '''') <> ISNULL(NUT.filter_definition, '''') 
                            THEN ''FilterPredicateDiff:  Actual Table:  '' + ISNULL(AT.filter_definition, '''') + ''// New Table:  '' + ISNULL(NUT.filter_definition, '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(AT.IndexKeys, '''') <> ISNULL(NUT.IndexKeys, '''') 
                            THEN ''KeyColumnListDiff:  Actual Table:  '' + ISNULL(AT.IndexKeys, '''') + ''// New Table:  '' + ISNULL(NUT.IndexKeys, '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(AT.IncludedColumns, '''') <> ISNULL(NUT.IncludedColumns, '''') 
                            THEN ''IncludedColumnListDiff:  Actual Table:  '' + ISNULL(AT.IncludedColumns, '''') + ''// New Table:  '' + ISNULL(NUT.IncludedColumns, '''') 
                            ELSE ''''
                        END COLLATE DATABASE_DEFAULT AS SchemaDifferences
                FROM dbo.fnActualIndexesForTable(@DatabaseName,@SchemaName1,@TableName1, @DiffBetTableNames, @PartitionColumnToReplaceInPK) AT
                    FULL OUTER JOIN dbo.fnActualIndexesForTable(@DatabaseName,@SchemaName2,@TableName2, @DiffBetTableNames, @PartitionColumnToReplaceInPK) NUT
                        ON AT.DatabaseName = NUT.DatabaseName
							AND AT.TableName = NUT.TableName
                            AND AT.IndexName = NUT.IndexName) x
        WHERE EXISTS (  SELECT *
                        FROM (
                                SELECT * 
                                FROM dbo.fnActualIndexesForTable(@DatabaseName,@SchemaName1,@TableName1, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
                                WHERE TableName = @TableName1
                                EXCEPT
                                SELECT *
                                FROM dbo.fnActualIndexesForTable(@DatabaseName,@SchemaName2,@TableName2, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
                                WHERE TableName = @TableName1)Diff
                        WHERE Diff.DatabaseName = x.DatabaseName
							AND Diff.TableName = x.TableName
                            AND Diff.IndexName = x.IndexName))
' AS FinalValidation_CreateCompareTableStructuresDetailsFunctionSQL,
'
CREATE OR ALTER FUNCTION [dbo].[fnCompareTableStructures](
    @DatabaseName SYSNAME,
	@SchemaName1 SYSNAME,
	@TableName1 SYSNAME,
	@SchemaName2 SYSNAME,
	@TableName2 SYSNAME,
	@DiffBetTableNames SYSNAME,
	@PartitionColumnToReplaceInPK SYSNAME)
RETURNS TABLE
AS RETURN
(

/*

SELECT * FROM dbo.fnCompareTableStructures(
    ''PaymentReporting'',
    ''dbo'',
    ''Liabilities'',
    ''dbo'',
    ''Liabilities_New'',
    ''_New'',
    ''PayDate'')	
*/


SELECT 
(SELECT	COUNT(*) AS Counts
FROM (	SELECT * 
		FROM sys.dm_exec_describe_first_result_set (N''SELECT * FROM '' + @SchemaName1 + ''.'' + @TableName1 , NULL, 0) 
		WHERE name NOT IN (''DMLType'')) Live 
	FULL OUTER JOIN (	SELECT * 
						FROM sys.dm_exec_describe_first_result_set (N''SELECT * FROM '' + @SchemaName2 + ''.'' + @TableName2, NULL, 0) 
						WHERE name NOT IN (''DMLType'')) New 
		ON Live.name = New.name 
WHERE (Live.is_nullable <> New.is_nullable
		OR live.system_type_name <> New.system_type_name
		OR live.is_identity_column <> New.is_identity_column
		OR Live.max_length <> New.max_length
		OR Live.precision <> New.precision
		OR Live.collation_name <> New.collation_name
		OR Live.scale <> New.scale
		OR Live.is_part_of_unique_key <> New.is_part_of_unique_key
		OR Live.name IS NULL
		OR New.name IS NULL))
+ --indexes
(SELECT COUNT(*)
FROM (
		SELECT * 
		FROM dbo.fnActualIndexStructuresForTable(@DatabaseName,@SchemaName1,@TableName1, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
		WHERE NOT EXISTS (  SELECT ''True''
                            FROM DOI.IndexesNotInMetadata INIM 
                            WHERE DatabaseName = INIM.DatabaseName
                                AND SchemaName = INIM.SchemaName
                                AND TableName = INIM.TableName
                                AND INIM.IndexName = IndexName)
		EXCEPT
		SELECT *
		FROM dbo.fnActualIndexStructuresForTable(@DatabaseName,@SchemaName2,@TableName2, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
		WHERE NOT EXISTS (  SELECT ''True'' 
                            FROM DOI.IndexesNotInMetadata INIM 
                            WHERE DatabaseName = INIM.DatabaseName
                                AND SchemaName = INIM.SchemaName
                                AND TableName = INIM.TableName
                                AND INIM.IndexName = IndexName))x)
+ --constraints
(SELECT COUNT(*)
FROM (
		SELECT * 
		FROM dbo.fnActualConstraintsForTable(@DatabaseName,@SchemaName1,@TableName1, @DiffBetTableNames)
		EXCEPT
		SELECT *
		FROM dbo.fnActualConstraintsForTable(@DatabaseName,@SchemaName2,@TableName2, @DiffBetTableNames))x) AS Counts
)
' AS FinalValidation_CreateCompareTableStructuresFunctionSQL,
'
EXEC sp_configure ''allow updates'', 0
RECONFIGURE
EXEC sp_configure ''show advanced options'', 1
RECONFIGURE
EXEC sp_configure ''xp_cmdshell'', 1
RECONFIGURE
' AS EnableCmdShellSQL,
'
EXEC sp_configure ''allow updates'', 0
RECONFIGURE
EXEC sp_configure ''show advanced options'', 1
RECONFIGURE
EXEC sp_configure ''xp_cmdshell'', 0
RECONFIGURE
' AS DisableCmdShellSQL,
'
EXEC DOI.spRun_GetApplicationLock
    @DatabaseName = ''' + AllTables.DatabaseName + ''',
    @BatchId = ''00000000-0000-0000-0000-000000000000''
' AS GetApplicationLockSQL,
'
EXEC DOI.spRun_ReleaseApplicationLock
    @DatabaseName = ''' + AllTables.DatabaseName + ''',
    @BatchId = ''00000000-0000-0000-0000-000000000000''
' AS ReleaseApplicationLockSQL,
        '
DECLARE @ErrorMessage NVARCHAR(500),
        @DataSpaceNeeded BIGINT,
        @DataSpaceAvailable BIGINT,
        @DriveLetter CHAR(1)  

SELECT @DataSpaceAvailable = available_MB, 
        @DataSpaceNeeded = FSI.SpaceNeededOnDrive,
        @DriveLetter = FS.DriveLetter
FROM DOI.vwFreeSpaceOnDisk FS
    INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + AllTables.DatabaseName + ''', ''' + AllTables.SchemaName + ''', ''' + AllTables.TableName + ''', ''data'') FSI ON FSI.DriveLetter = FS.DriveLetter
WHERE DBName = ''' + AllTables.DatabaseName + '''
    AND FS.FileType = ''DATA''
    AND EXISTS(	SELECT ''True''
				FROM DOI.Queue Q 
				WHERE Q.DatabaseName = FSI.DatabaseName
					AND Q.ParentSchemaName = FSI.SchemaName
					AND Q.ParentTableName = FSI.TableName)

IF @DataSpaceAvailable <= @DataSpaceNeeded
BEGIN
    SET @ErrorMessage = ''NOT ENOUGH FREE SPACE ON DATA DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@DataSpaceNeeded AS NVARCHAR(50)) + ''MB AND ONLY HAVE '' + CAST(@DataSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 16, 1)
END
ELSE 
BEGIN
    SET @ErrorMessage = ''THERE IS ENOUGH FREE SPACE ON DATA DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@DataSpaceNeeded AS NVARCHAR(50)) + ''MB AND HAVE '' + CAST(@DataSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 10, 1)
END' AS FreeDataSpaceCheckSQL,

        '
DECLARE @ErrorMessage NVARCHAR(500),
        @LogSpaceNeeded BIGINT,
        @LogSpaceAvailable BIGINT,
        @DriveLetter CHAR(1)  

SELECT @LogSpaceAvailable = available_MB, 
        @LogSpaceNeeded = FSI.SpaceNeededOnDrive,
        @DriveLetter = FS.DriveLetter
FROM DOI.vwFreeSpaceOnDisk FS
    INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + AllTables.DatabaseName + ''', ''' + AllTables.SchemaName + ''', ''' + AllTables.TableName + ''', ''log'') FSI ON FSI.DriveLetter = FS.DriveLetter
WHERE DBName = ''' + AllTables.DatabaseName + '''
    AND FS.FileType = ''LOG''
    AND EXISTS(	SELECT ''True''
				FROM DOI.Queue Q 
				WHERE Q.ParentSchemaName = FSI.SchemaName
					AND Q.ParentTableName = FSI.TableName)

IF @LogSpaceAvailable <= @LogSpaceNeeded
BEGIN
    SET @ErrorMessage = ''NOT ENOUGH FREE SPACE ON LOG DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@LogSpaceNeeded AS NVARCHAR(50)) + ''MB AND ONLY HAVE '' + CAST(@LogSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 16, 1)
END
ELSE 
BEGIN
    SET @ErrorMessage = ''THERE IS ENOUGH FREE SPACE ON LOG DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@LogSpaceNeeded AS NVARCHAR(50)) + ''MB AND HAVE '' + CAST(@LogSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 10, 1)
END
' AS FreeLogSpaceCheckSQL,

        '
DECLARE @ErrorMessage NVARCHAR(500),
        @TempDBSpaceNeeded BIGINT,
        @TempDBSpaceAvailable BIGINT,
        @DriveLetter CHAR(1)  

SELECT @TempDBSpaceAvailable = available_MB, 
        @TempDBSpaceNeeded = FSI.SpaceNeededOnDrive,
        @DriveLetter = FS.DriveLetter
FROM DOI.vwFreeSpaceOnDisk FS
    INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + AllTables.DatabaseName + ''', ''' + AllTables.SchemaName + ''', ''' + AllTables.TableName + ''', ''TempDB'') FSI ON FSI.DriveLetter = FS.DriveLetter
WHERE DBName = ''TempDB''
    AND FS.FileType = ''DATA''
    AND EXISTS(	SELECT ''True''
				FROM DOI.Queue Q 
				WHERE Q.ParentSchemaName = FSI.SchemaName
					AND Q.ParentTableName = FSI.TableName)

IF @TempDBSpaceAvailable <= @TempDBSpaceNeeded
BEGIN
    SET @ErrorMessage = ''NOT ENOUGH FREE SPACE ON TEMPDB DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@TempDBSpaceNeeded AS NVARCHAR(50)) + ''MB AND ONLY HAVE '' + CAST(@TempDBSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 16, 1)
END
ELSE 
BEGIN
    SET @ErrorMessage = ''THERE IS ENOUGH FREE SPACE ON TEMPDB DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@TempDBSpaceNeeded AS NVARCHAR(50)) + ''MB AND HAVE '' + CAST(@TempDBSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 10, 1)
END
' AS FreeTempDBSpaceCheckSQL
FROM (  SELECT	T.DatabaseName
                ,T.SchemaName
				,T.TableName
				,T.TableName + '_New' AS NewTableName
				,'_New' AS NewTableNameSuffix
				,T.ColumnListWithTypes
				,T.ColumnListNoTypes
				,T.UpdateColumnList
    			,T.PKColumnList
				,T.PKColumnListJoinClause_Desired
				,T.Storage_Desired
				,T.StorageType_Desired
                ,T.Storage_Desired AS NewTableFilegroup
				,T.IntendToPartition
				,T.UpdateTimeStampColumn
        FROM DOI.Tables T
        WHERE IntendToPartition = 0) AllTables
    CROSS JOIN (SELECT * FROM DOI.DOISettings WHERE SettingName = 'UTEBCP Filepath') SS

GO