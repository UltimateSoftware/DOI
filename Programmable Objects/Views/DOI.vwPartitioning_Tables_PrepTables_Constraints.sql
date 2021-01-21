
GO

IF OBJECT_ID('[DOI].[vwPartitioning_Tables_PrepTables_Constraints]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitioning_Tables_PrepTables_Constraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE   VIEW [DOI].[vwPartitioning_Tables_PrepTables_Constraints]
AS

/*
	SELECT *
	FROM DOI.[vwPartitioning_Tables_PrepTables_Constraints]
	WHERE ParentTableName = 'Pays' 
		AND preptablename = 'PayTaxes_NewPartitionedTableFromPrep'
*/ 

SELECT	FN.DatabaseName,
        FN.SchemaName,
		FN.TableName AS ParentTableName,
		FN.PrepTableName,
		FN.NewPartitionedPrepTableName,
		FN.PartitionFunctionName,
		FN.BoundaryValue,
		FN.NextBoundaryValue,
		FN.IsNewPartitionedPrepTable,
		REPLACE(C.ConstraintName, FN.TableName, FN.PrepTableName) AS ConstraintName,
		C.ConstraintType,
		C.CreateConstraintStatement,
		C.RenameExistingTableConstraintSQL,
		C.RenameNewPartitionedPrepTableConstraintSQL,
		C.RevertRenameExistingTableConstraintSQL,
		C.RevertRenameNewPartitionedPrepTableConstraintSQL,
		ROW_NUMBER() OVER(PARTITION BY FN.SchemaName, FN.TableName, FN.PrepTableName ORDER BY FN.SchemaName, FN.TableName, FN.PrepTableName) AS RowNum
FROM DOI.vwPartitioning_Tables_PrepTables FN
	CROSS APPLY(SELECT *
				FROM (	SELECT	SchemaName,
								TableName,
								dc.DefaultConstraintName AS ConstraintName,
								'DEFAULT' AS ConstraintType,
								'
IF OBJECT_ID(''' + FN.DatabaseName + '.' + FN.SchemaName + '.' + FN.PrepTableName + ''') IS NOT NULL
	AND OBJECT_ID(''' + FN.DatabaseName + '.' + FN.SchemaName + '.' + REPLACE(dc.DefaultConstraintName, TableName, FN.PrepTableName) + ''') IS NULL
BEGIN
	ALTER TABLE ' + SchemaName + '.' + FN.PrepTableName + ' ADD CONSTRAINT ' + REPLACE(dc.DefaultConstraintName, TableName, FN.PrepTableName) + ' DEFAULT ' + dc.DefaultDefinition + ' FOR ' + ColumnName + '
END' + CHAR(13) + CHAR(10) 
AS CreateConstraintStatement,

CASE WHEN FN.IsNewPartitionedPrepTable = 0 THEN '' ELSE
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename @objname = ''' + FN.SchemaName + '.' + dc.DefaultConstraintName + ''',
				@newname = ''' + REPLACE(dc.DefaultConstraintName, FN.TableName, FN.TableName + '_OLD') + ''',
				@objtype = ''OBJECT''' END 
AS RenameExistingTableConstraintSQL,

CASE WHEN FN.IsNewPartitionedPrepTable = 0 THEN '' ELSE
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(dc.DefaultConstraintName, FN.TableName, FN.PrepTableName) + ''',
				@newname = ''' + REPLACE(dc.DefaultConstraintName, FN.PrepTableName, FN.TableName) + ''',
				@objtype = ''OBJECT''' END 
AS RenameNewPartitionedPrepTableConstraintSQL,

CASE WHEN FN.IsNewPartitionedPrepTable = 0 THEN '' ELSE
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(dc.DefaultConstraintName, FN.TableName, FN.TableName + '_OLD') + ''',
				@newname = ''' + dc.DefaultConstraintName + ''',
				@objtype = ''OBJECT''' END 
AS RevertRenameExistingTableConstraintSQL,

CASE WHEN FN.IsNewPartitionedPrepTable = 0 THEN '' ELSE
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(dc.DefaultConstraintName, FN.PrepTableName, FN.TableName) + ''',
				@newname = ''' + REPLACE(dc.DefaultConstraintName, FN.TableName, FN.PrepTableName) + ''',
				@objtype = ''OBJECT''' END 
AS RevertRenameNewPartitionedPrepTableConstraintSQL

						FROM DOI.DefaultConstraints dc
						UNION ALL
						SELECT	cc.SchemaName,
								cc.TableName,
								cc.CheckConstraintName,
								'CHECK' AS ConstraintType,
								'
IF OBJECT_ID(''' + FN.DatabaseName + '.' + FN.SchemaName + '.' + FN.PrepTableName + ''') IS NOT NULL
	AND OBJECT_ID(''' + FN.DatabaseName + '.' + FN.SchemaName + '.' + REPLACE(cc.CheckConstraintName, cc.TableName, FN.PrepTableName) + ''') IS NULL
BEGIN
	ALTER TABLE ' + cc.SchemaName + '.' + FN.PrepTableName + ' ADD CONSTRAINT ' + REPLACE(cc.CheckConstraintName, cc.TableName, FN.PrepTableName) + ' CHECK ' + cc.CheckDefinition + '
END' + CHAR(13) + CHAR(10) 
AS CreateConstraintStatement,

CASE WHEN FN.IsNewPartitionedPrepTable = 0 THEN '' ELSE
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename @objname = ''' + FN.SchemaName + '.' + cc.CheckConstraintName + ''',
				@newname = ''' + REPLACE(cc.CheckConstraintName, FN.TableName, FN.TableName + '_OLD') + ''',
				@objtype = ''OBJECT''' END 
AS RenameExistingTableConstraintSQL,

CASE WHEN FN.IsNewPartitionedPrepTable = 0 THEN '' ELSE
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename @objname = ''' + REPLACE(cc.CheckConstraintName, FN.TableName, FN.PrepTableName) + ''',
				@newname = ''' + FN.SchemaName + '.' + REPLACE(cc.CheckConstraintName, FN.PrepTableName, FN.TableName) + ''',
				@objtype = ''OBJECT''' END 
AS RenameNewPartitionedPrepTableConstraintSQL,

CASE WHEN FN.IsNewPartitionedPrepTable = 0 THEN '' ELSE
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(cc.CheckConstraintName, FN.TableName, FN.TableName + '_OLD') + ''',
				@newname = ''' + cc.CheckConstraintName + ''',
				@objtype = ''OBJECT''' END 
AS RevertRenameExistingTableConstraintSQL,

CASE WHEN FN.IsNewPartitionedPrepTable = 0 THEN '' ELSE
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(cc.CheckConstraintName, FN.PrepTableName, FN.TableName) + ''',
				@newname = ''' + REPLACE(cc.CheckConstraintName, FN.TableName, FN.PrepTableName) + ''',
				@objtype = ''OBJECT''' END 
AS RevertRenameNewPartitionedPrepTableConstraintSQL

						FROM DOI.CheckConstraints cc) Constraints
				WHERE Constraints.SchemaName = FN.SchemaName
					AND Constraints.TableName = FN.TableName) C







GO
