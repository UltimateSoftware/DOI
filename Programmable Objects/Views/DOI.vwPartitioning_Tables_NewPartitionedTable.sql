-- <Migration ID="892a75cc-c8b0-4a13-a254-60a7ef8b30ab" />
GO
IF OBJECT_ID('[DOI].[vwPartitioning_Tables_NewPartitionedTable]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitioning_Tables_NewPartitionedTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
	CREATE TABLE ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + CHAR(13) + CHAR(10) + T.ColumnListWithTypes + CHAR(9) + '[DMLType] CHAR(1) NOT NULL) ON [' + T.Storage_Desired + '] (' + T.PartitionColumn + ')
END
'		AS CreateFinalDataSynchTableSQL,
		'
CREATE OR ALTER TRIGGER ' + T.SchemaName + '.tr' + T.TableName + '_DataSynch
ON ' + T.SchemaName + '.' + T.TableName + '
AFTER INSERT, UPDATE, DELETE
AS

INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + T.ColumnListForDataSynchTriggerInsert + ', [DMLType])
SELECT ' + REPLACE(T.ColumnListForDataSynchTriggerSelect, 'PT.', 'ST.') + ', ''I''
FROM inserted T ' + 
CASE 
	WHEN T.TableHasOldBlobColumns = 1 
	THEN '
	INNER JOIN ' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause_Desired, 'PT.', 'ST.') + CHAR(13) + CHAR(10) 
	ELSE '' 
END + '
WHERE NOT EXISTS(SELECT ''True'' FROM deleted PT WHERE ' + T.PKColumnListJoinClause_Desired + ')

INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + T.ColumnListForDataSynchTriggerInsert + ', [DMLType])
SELECT ' + REPLACE(T.ColumnListForDataSynchTriggerSelect, 'PT.', 'ST.') + ', ''U''
FROM inserted T' + 
CASE 
	WHEN T.TableHasOldBlobColumns = 1 
	THEN '
	INNER JOIN ' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause_Desired, 'PT.', 'ST.') + CHAR(13) + CHAR(10) 
	ELSE '' 
END + '
WHERE EXISTS (SELECT * FROM deleted PT WHERE ' + T.PKColumnListJoinClause_Desired + ')

INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + T.ColumnListForDataSynchTriggerInsert + ', [DMLType])
SELECT ' + T.ColumnListForFinalDataSynchTriggerSelectForDelete + ', ''D''
FROM deleted T
WHERE NOT EXISTS(SELECT ''True'' FROM inserted PT WHERE ' + T.PKColumnListJoinClause_Desired + ')
'
AS CreateFinalDataSynchTriggerSQL,

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
EXEC DOI.DOI.spRun_TurnOffIdentityInsert
	@DatabaseName = ''' + T.DatabaseName + ''',
	@SchemaName = ''' + T.SchemaName + ''',
	@TableName = ''' + T.TableName + '''' + 
	
CASE WHEN T.TableHasIdentityColumn = 0 THEN '' ELSE '
SET IDENTITY_INSERT ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' ON 
' END + '

INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '(' + T.ColumnListForDataSynchTriggerInsert + ')
SELECT ' + REPLACE(T.ColumnListForDataSynchTriggerSelect, 'PT.', 'ST.') + '
FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch T ' + 
CASE WHEN T.TableHasOldBlobColumns = 1 THEN '
	INNER JOIN ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'ST.') ELSE '' END + '
WHERE T.DMLType = ''I''
	AND NOT EXISTS (SELECT ''True'' 
					FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' PT WITH (TABLOCKX, XLOCK)
					WHERE ' + T.PKColumnListJoinClause + ')

SET @RowCountOUT = @@ROWCOUNT' + 
	
CASE WHEN T.TableHasIdentityColumn = 0 THEN '' ELSE '
SET IDENTITY_INSERT ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' OFF 
' END + '

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
EXEC DOI.DOI.spRun_TurnOffIdentityInsert
	@DatabaseName = ''' + T.DatabaseName + ''',
	@SchemaName = ''' + T.SchemaName + ''',
	@TableName = ''' + T.TableName + '''

UPDATE PT
SET ' + T.ColumnListForDataSynchTriggerUpdate + '
FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch T' + 
CASE WHEN T.TableHasOldBlobColumns = 1 THEN '
	INNER JOIN ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'ST.') ELSE '' END + '
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
EXEC DOI.DOI.spRun_TurnOffIdentityInsert
	@DatabaseName = ''' + T.DatabaseName + ''',
	@SchemaName = ''' + T.SchemaName + ''',
	@TableName = ''' + T.TableName + '''

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
CREATE OR ALTER FUNCTION [dbo].[fnActualIndexesForTable](
	@SchemaName SYSNAME,
	@TableName SYSNAME,
	@NameStringReplace SYSNAME = NULL,
	@PartitionColumnToReplace SYSNAME = NULL)
RETURNS TABLE
AS RETURN
(

/*
SELECT * 
FROM DOI.fnActualIndexStructuresForTable(''' + T.SchemaName + ''',''' + T.TableName + ''', ''_NewPartitionedTableFromPrep'', ''' + T.PartitionColumn + ''')

SELECT *
FROM DOI.fnActualIndexStructuresForTable(''' + T.SchemaName + ''',''' + T.TableName + ''', ''_NewPartitionedTableFromPrep'', ''' + T.PartitionColumn + ''')
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
FROM sys.indexes i
	INNER JOIN sys.tables t ON t.object_id = i.object_id
	INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = @SchemaName
	AND t.name = @TableName)
' AS FinalRepartitioningValidation_CreateActualIndexesForTableFunctionSQL,
'
CREATE OR ALTER FUNCTION [dbo].[fnActualConstraintsForTable](
	@SchemaName SYSNAME,
	@TableName SYSNAME,
	@NameStringReplace SYSNAME = NULL)
RETURNS TABLE
AS RETURN
(

/*
SELECT * 
FROM DOI.fnActualConstraintsForTable((''' + T.SchemaName + ''',''' + T.TableName + ''', ''_NewPartitionedTableFromPrep'', '' '')
--order by ConstraintName	
except
SELECT *
FROM DOI.fnActualConstraintsForTable((''' + T.SchemaName + ''',''' + T.TableName + ''', ''_NewPartitionedTableFromPrep'', ''_OLD'')
order by ConstraintName	
*/

SELECT	REPLACE(cc.name, @NameStringReplace, SPACE(0)) AS ConstraintName, 
		cc.type_desc, 
		c.name AS ColumnName, 
		cc.definition
FROM DOI.SysCheckConstraints cc
	INNER JOIN sys.tables t ON t.object_id = i.object_id
	INNER JOIN sys.columns c ON c.object_id = t.object_id
		AND c.column_id = cc.parent_column_id
	INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = @SchemaName
	AND t.name = @TableName
UNION ALL
SELECT	REPLACE(dc.name, @NameStringReplace, SPACE(0)) AS ConstraintName, 
		dc.type_desc, 
		c.name AS ColumnName, 
		dc.definition
FROM DOI.SysDefaultConstraints dc
	INNER JOIN sys.tables t ON t.object_id = i.object_id
	INNER JOIN sys.columns c ON c.object_id = t.object_id
		AND c.column_id = cc.parent_column_id
	INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = @SchemaName
	AND t.name = @TableName)
' AS FinalRepartitioningValidation_CreateActualConstraintsForTableFunctionSQL,
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
    ''Bai2BankTransactions_NewPartitionedTableFromPrep'',
    ''_NewPartitionedTableFromPrep'',
    ''TransactionSysUtcDt'')
*/
RETURN (
        SELECT *
        FROM (  SELECT  AT.DatabaseName,
                        ISNULL(AT.TableName, NPT.TableName) AS TableName,
                        ISNULL(AT.IndexName, NPT.IndexName) AS IndexName,
                        CASE 
                            WHEN ISNULL(AT.type_desc, '''') <> ISNULL(NPT.type_desc, '''') 
                            THEN ''TypeDiff:  Actual Table:  '' + ISNULL(AT.type_desc, '''') + ''// New Table:  '' + ISNULL(NPT.type_desc, '''') 
                            ELSE ''''
                        END + 
                        CASE 
                            WHEN ISNULL(CAST(AT.is_unique AS CHAR(1)), '''') <> ISNULL(CAST(NPT.is_unique AS CHAR(1)), '''') 
                            THEN ''IsUniqueDiff:  Actual Table:  '' + ISNULL(CAST(AT.is_unique AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NPT.is_unique AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.ignore_dup_key AS CHAR(1)), '''') <> ISNULL(CAST(NPT.ignore_dup_key AS CHAR(1)), '''') 
                            THEN ''OptionIgnoreDupKeyDiff:  Actual Table:  '' + ISNULL(CAST(AT.ignore_dup_key AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NPT.ignore_dup_key AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_primary_key AS CHAR(1)), '''') <> ISNULL(CAST(NPT.is_primary_key AS CHAR(1)), '''') 
                            THEN ''IsPrimaryKeyDiff:  Actual Table:  '' + ISNULL(CAST(AT.is_primary_key AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NPT.is_primary_key AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_unique_constraint AS CHAR(1)), '''') <> ISNULL(CAST(NPT.is_unique_constraint AS CHAR(1)), '''') 
                            THEN ''IsUniqueConstraintDiff:  Actual Table:  '' + ISNULL(CAST(AT.is_unique_constraint AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NPT.is_unique_constraint AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_disabled AS CHAR(1)), '''') <> ISNULL(CAST(NPT.is_disabled AS CHAR(1)), '''') 
                            THEN ''IsDisableDOIff:  Actual Table:  '' + ISNULL(CAST(AT.is_disabled AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NPT.is_disabled AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_hypothetical AS CHAR(1)), '''') <> ISNULL(CAST(NPT.is_hypothetical AS CHAR(1)), '''') 
                            THEN ''IsHypotheticalDiff:  Actual Table:  '' + ISNULL(CAST(AT.is_hypothetical AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NPT.is_hypothetical AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.has_filter AS CHAR(1)), '''') <> ISNULL(CAST(NPT.has_filter AS CHAR(1)), '''') 
                            THEN ''IsFiltereDOIff:  Actual Table:  '' + ISNULL(CAST(AT.has_filter AS CHAR(1)), '''') + ''// New Table:  '' + ISNULL(CAST(NPT.has_filter AS CHAR(1)), '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(AT.filter_definition, '''') <> ISNULL(NPT.filter_definition, '''') 
                            THEN ''FilterPredicateDiff:  Actual Table:  '' + ISNULL(AT.filter_definition, '''') + ''// New Table:  '' + ISNULL(NPT.filter_definition, '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(AT.IndexKeys, '''') <> ISNULL(NPT.IndexKeys, '''') 
                            THEN ''KeyColumnListDiff:  Actual Table:  '' + ISNULL(AT.IndexKeys, '''') + ''// New Table:  '' + ISNULL(NPT.IndexKeys, '''') 
                            ELSE ''''
                        END +
                        CASE 
                            WHEN ISNULL(AT.IncludedColumns, '''') <> ISNULL(NPT.IncludedColumns, '''') 
                            THEN ''IncludedColumnListDiff:  Actual Table:  '' + ISNULL(AT.IncludedColumns, '''') + ''// New Table:  '' + ISNULL(NPT.IncludedColumns, '''') 
                            ELSE ''''
                        END COLLATE DATABASE_DEFAULT AS SchemaDifferences
                FROM dbo.fnActualIndexesForTable(@SchemaName1,@TableName1, @DiffBetTableNames, @PartitionColumnToReplaceInPK) AT
                    FULL OUTER JOIN dbo.fnActualIndexesForTable(@SchemaName2,@TableName2, @DiffBetTableNames, @PartitionColumnToReplaceInPK) NPT
                        ON AT.TableName = NPT.TableName
                            AND AT.IndexName = NPT.IndexName) x
        WHERE EXISTS (  SELECT *
                        FROM (
                                SELECT * 
                                FROM dbo.fnActualIndexesForTable(@SchemaName1,@TableName1, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
                                WHERE TableName = @TableName1
                                EXCEPT
                                SELECT *
                                FROM dbo.fnActualIndexesForTable(@SchemaName2,@TableName2, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
                                WHERE TableName = @TableName1)Diff
                        WHERE Diff.TableName = x.TableName
                            AND Diff.IndexName = x.IndexName))
' AS FinalRepartitioningValidation_CreateCompareTableStructuresDetailsFunctionSQL,
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
    ''Liabilities_NewPartitionedTableFromPrep'',
    ''_NewPartitionedTableFromPrep'',
    ''PayDate'')	
*/


SELECT 
(SELECT	COUNT(*) AS Counts
FROM (	SELECT * 
		FROM sys.dm_exec_describe_first_result_set (N''SELECT * FROM '' + @SchemaName1 + ''.'' + @TableName1 , NULL, 0) 
		WHERE name NOT IN (''DMLType'')) Live 
	FULL OUTER JOIN (	SELECT * 
						FROM sys.dm_exec_describe_first_result_set (N''SELECT * FROM '' + @SchemaName2 + ''.'' + @TableName2, NULL, 0) 
						WHERE name NOT IN (''DMLType'')) Prep 
		ON Live.name = Prep.name 
WHERE (Live.is_nullable <> Prep.is_nullable
		OR live.system_type_name <> prep.system_type_name
		OR live.is_identity_column <> prep.is_identity_column
		OR Live.max_length <> Prep.max_length
		OR Live.precision <> Prep.precision
		OR Live.collation_name <> Prep.collation_name
		OR Live.scale <> Prep.scale
		OR Live.is_part_of_unique_key <> Prep.is_part_of_unique_key
		OR Live.name IS NULL
		OR Prep.name IS NULL))
+ --indexes
(SELECT COUNT(*)
FROM (
		SELECT * 
		FROM dbo.fnActualIndexStructuresForTable(@SchemaName1,@TableName1, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
		WHERE NOT EXISTS (  SELECT ''True''
                            FROM DOI.IndexesNotInMetadata INIM 
                            WHERE DatabaseName = INIM.DatabaseName
                                AND SchemaName = INIM.SchemaName
                                AND TableName = INIM.TableName
                                AND INIM.IndexName = IndexName)
		EXCEPT
		SELECT *
		FROM dbo.fnActualIndexStructuresForTable(@SchemaName2,@TableName2, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
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
		FROM dbo.fnActualConstraintsForTable(@SchemaName1,@TableName1, @DiffBetTableNames)
		EXCEPT
		SELECT *
		FROM dbo.fnActualConstraintsForTable(@SchemaName2,@TableName2, @DiffBetTableNames))x) AS Counts
)
' AS FinalRepartitioningValidation_CreateCompareTableStructuresFunctionSQL,
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
AS FinalRepartitioningValidationSQL,
'
DECLARE @BatchId UNIQUEIDENTIFIER = (SELECT TOP 1 BatchId FROM DOI.DOI.Log ORDER BY LogDateTime DESC)

IF EXISTS(	SELECT ''True''
			FROM DOI.DOI.Log 
			WHERE BatchId = @BatchId
				AND TableName LIKE ''%' + T.TableName + '%''
				AND ErrorText IS NOT NULL ) /*ONLY PROCEED IF NOTHING HAS FAILED IN THIS BATCH.*/
BEGIN
	RAISERROR(''At least 1 step failed in the BCP process.  Aborting partition switch and rename.'', 16, 1)  
END
' AS PriorErrorValidationSQL,
'
EXEC DOI.DOI.spForeignKeysDrop
	@DatabaseName = ''' + T.DatabaseName + ''',
	@ParentSchemaName = ''' + T.SchemaName + ''',
	@ParentTableName = ''' + T.TableName + '''' AS DropParentOldTableFKSQL,
'
EXEC DOI.DOI.spForeignKeysDrop
	@DatabaseName = ''' + T.DatabaseName + ''',
	@ReferencedSchemaName = ''' + T.SchemaName + ''',
	@ReferencedTableName = ''' + T.TableName + '''' AS DropRefOldTableFKSQL,
'
EXEC DOI.DOI.spForeignKeysAdd
	@DatabaseName = ''' + T.DatabaseName + ''',
	@ParentSchemaName = ''' + T.SchemaName + ''',
	@ParentTableName = ''' + T.TableName + '''' AS AddBackParentTableFKSQL,
'
EXEC DOI.DOI.spForeignKeysAdd
	@DatabaseName = ''' + T.DatabaseName + ''',
	@ReferencedSchemaName = ''' + T.SchemaName + ''',
	@ReferencedTableName = ''' + T.TableName + '''' AS AddBackRefTableFKSQL,
'
EXEC DOI.spRun_GetApplicationLock
    @DatabaseName = ''' + T.DatabaseName + ''',
    @BatchId = ''00000000-0000-0000-0000-000000000000''
' AS GetApplicationLockSQL,
'
EXEC DOI.spRun_ReleaseApplicationLock
    @DatabaseName = ''' + T.DatabaseName + ''',
    @BatchId = ''00000000-0000-0000-0000-000000000000''
' AS ReleaseApplicationLockSQL
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
				,ColumnListWithTypesNoIdentityProperty
				,ColumnListNoTypes
				,ColumnListForDataSynchTriggerInsert
				,ColumnListForDataSynchTriggerUpdate
				,ColumnListForDataSynchTriggerSelect
				,ColumnListForFinalDataSynchTriggerSelectForDelete
				,UpdateColumnList
    			,PartitionColumn
    			,PKColumnList
				,PKColumnListJoinClause
				,PKColumnListJoinClause_Desired
				,Storage_Desired
				,StorageType_Desired
				,0 AS PartitionNumber
                ,SPACE(0) AS PrepTableFilegroup
				,TableHasOldBlobColumns
				,TableHasIdentityColumn
		FROM DOI.Tables
		WHERE IntendToPartition = 1) T
    CROSS APPLY(SELECT STUFF((  SELECT PT.PrepTableTriggerSQLFragment
								FROM DOI.vwPartitioning_Tables_PrepTables PT
								WHERE PT.DatabaseName = T.DatabaseName
									AND PT.SchemaName = T.SchemaName
									AND PT.TableName = T.TableName
								FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)'), 1, 1, '')) DSTrigger(DSTriggerSQL)
GO