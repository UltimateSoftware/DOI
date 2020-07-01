IF OBJECT_ID('[DOI].[vwTables_PrepTables]') IS NOT NULL
	DROP VIEW [DOI].[vwTables_PrepTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




















CREATE     VIEW [DOI].[vwTables_PrepTables]

/*
	select top 10 CreateViewForBCPSQL
	from DOI.vwTables_PrepTables
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
        '
IF OBJECT_ID(''' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ''') IS NOT NULL
BEGIN
	DROP TABLE ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.PrepTableName + '
END

IF OBJECT_ID(''' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ''') IS NULL
BEGIN
	CREATE TABLE ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' (' + CHAR(13) + CHAR(10) + AllTables.ColumnListWithTypes + ') ON ' + CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '[' + AllTables.Storage_Desired + '](' + AllTables.PartitionColumn + ')' ELSE '[' + AllTables.PrepTableFilegroup + ']' END + '
END' AS CreatePrepTableSQL,
--CREATE VIEW FOR BCP QUERY BECAUSE SQL STRING IS TOO LONG FOR XP_CMDSHELL.
CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '' ELSE 
'CREATE OR ALTER VIEW dbo.vwCurrentBCPQuery AS 
SELECT * 
FROM ' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.' + AllTables.TableName + ' T 
WHERE ' + CASE WHEN AllTables.BoundaryValue = '0001-01-01' THEN '' ELSE AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue, 120) + '''' + ' AND ' END + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''' AND NOT EXISTS (SELECT 1 FROM ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' PT WHERE ' + AllTables.PKColumnListJoinClause + ')'
END AS CreateViewForBCPSQL,
CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '' ELSE 
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
END AS BCPSQL,
CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '' ELSE 
'
IF OBJECT_ID(''' + AllTables.DatabaseName + '.' + AllTables.SchemaName + '.Chk_' + AllTables.PrepTableName + ''') IS NULL
BEGIN
	ALTER TABLE ' + AllTables.SchemaName + '.' + AllTables.PrepTableName + ' WITH CHECK ADD
		CONSTRAINT Chk_' + AllTables.PrepTableName + '
			CHECK (' + AllTables.PartitionColumn + ' IS NOT NULL 
					AND ' + AllTables.PartitionColumn + ' >= ''' + CONVERT(VARCHAR(30), AllTables.BoundaryValue , 120) + '''  
					AND ' + AllTables.PartitionColumn + ' < ''' + CONVERT(VARCHAR(50), ISNULL(AllTables.NextBoundaryValue, '9999-12-31'), 120) + ''')
END' END AS CheckConstraintSQL,
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
FROM DOI.fnActualIndexStructuresForTable(''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''', ''_NewPartitionedTableFromPrep'', ''' + AllTables.PartitionColumn + ''')

SELECT *
FROM DOI.fnActualIndexStructuresForTable(''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''', ''_NewPartitionedTableFromPrep'', ''' + AllTables.PartitionColumn + ''')
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
FROM DOI.fnActualConstraintsForTable((''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''', ''_NewPartitionedTableFromPrep'', '' '')
--order by ConstraintName	
except
SELECT *
FROM DOI.fnActualConstraintsForTable((''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''', ''_NewPartitionedTableFromPrep'', ''_OLD'')
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

CASE WHEN AllTables.IsNewPartitionedPrepTable = 0 THEN '' ELSE '
IF (SELECT * FROM dbo.fnCompareTableStructures(''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''',''' + AllTables.SchemaName + ''',''' + AllTables.NewPartitionedPrepTableName + ''', ''_NewPartitionedTableFromPrep'',''' + AllTables.PartitionColumn + ''')) > 0
BEGIN
    DECLARE @ErrorMessage VARCHAR(MAX) = ''Schemas from the 2 tables do not match!!''

    SELECT @ErrorMessage += CHAR(13) + CHAR(10) + ''***'' + IndexName + space(1) + SchemaDifferences + ''***'' + CHAR(13) + CHAR(10)
    FROM dbo.fnCompareTableStructuresDetails(''' + AllTables.SchemaName + ''',''' + AllTables.TableName + ''',''' + AllTables.SchemaName + ''',''' + AllTables.NewPartitionedPrepTableName + ''', ''_NewPartitionedTableFromPrep'',''' + AllTables.PartitionColumn + ''')

	RAISERROR(@ErrorMessage, 16, 1)
END

IF NOT EXISTS(	 SELECT * 
		  	     FROM sys.schemas s 
				    INNER JOIN sys.tables t ON s.schema_id = t.schema_id 
			     WHERE s.name = ''' + AllTables.SchemaName + ''' 
				    AND t.name = ''' + AllTables.NewPartitionedPrepTableName + ''') 
BEGIN
	RAISERROR(''NewPartitionedPrepTable does not exist!!'', 16, 1)
END

IF NOT EXISTS(	 SELECT * 
		  	     FROM sys.schemas s 
		  		    INNER JOIN sys.tables t ON s.schema_id = t.schema_id 
			     WHERE s.name = ''' + AllTables.SchemaName + ''' 
				    AND t.name = ''' + AllTables.TableName + ''')
BEGIN
	RAISERROR(''Live table does not exist!!'', 16, 1)
END

IF EXISTS(  SELECT *
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
'SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + AllTables.SchemaName + '.' + AllTables.TableName + ''',
	@newname = ''' + AllTables.TableName + '_OLD'',
	@objtype = ''OBJECT''' 
END AS RenameExistingTableSQL,

CASE WHEN AllTables.IsNewPartitionedPrepTable = 1 THEN '' ELSE 
'UPDATE DOI.DOI.Run_PartitionState
SET DataSynchState = 1
WHERE SchemaName = ''' + AllTables.SchemaName + '''
	AND PrepTableName = ''' + AllTables.PrepTableName + '''
	AND PartitionFromValue = ''' + CAST(AllTables.BoundaryValue AS VARCHAR(20)) + '''
'
END AS TurnOnDataSynchSQL,

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
				,DOI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'CREATETABLE', 1, NULL, NULL) AS ColumnListWithTypes
				,DOI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'INSERT', 1, NULL, NULL) AS ColumnListNoTypes
				,DOI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'UPDATE', 1, 'PT', 'T') AS UpdateColumnList
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
            CROSS APPLY (   SELECT *, T.TableName + P.PrepTableNameSuffix AS PrepTableName, 0 AS IsNewPartitionedPrepTable
                            FROM DOI.vwPartitionFunctionPartitions P 
                            WHERE T.Storage_Desired = PartitionSchemeName) P
                INNER JOIN DOI.SysDataSpaces DS_Desired ON T.Storage_Desired = DS_Desired.name
                INNER JOIN DOI.SysDestinationDataSpaces DDS_Desired ON DDS_Desired.database_id = DS_Desired.database_id
                    AND DDS_Desired.partition_scheme_id = DS_Desired.data_space_id
                    AND P.PartitionNumber = DDS_Desired.destination_id
                INNER JOIN DOI.SysDataSpaces UFG_Desired ON DDS_Desired.database_id = UFG_Desired.database_id
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
				,DOI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'CREATETABLE', 1, NULL, NULL) AS ColumnListWithTypes
				,DOI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'INSERT', 1, NULL, NULL) AS ColumnListNoTypes
				,DOI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'UPDATE', 1, 'PT', 'T') AS UpdateColumnList
    			,T.PartitionColumn
    			,T.PKColumnList
				,T.PKColumnListJoinClause
				,T.Storage_Desired
				,T.StorageType_Desired
				,0 AS PartitionNumber
                ,NULL AS PrepTableFilegroup
				,1 AS IsNewPartitionedPrepTable
        FROM DOI.Tables T
        WHERE IntendToPartition = 1) AllTables
    CROSS JOIN (SELECT * FROM DOI.DOISettings WHERE SettingName = 'UTEBCP Filepath') SS




















GO