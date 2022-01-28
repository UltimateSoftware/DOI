
IF OBJECT_ID('[DOI].[vwExchangeTableNonPartitioned_Tables_NewTable_Constraints]') IS NOT NULL
	DROP VIEW [DOI].[vwExchangeTableNonPartitioned_Tables_NewTable_Constraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   VIEW [DOI].[vwExchangeTableNonPartitioned_Tables_NewTable_Constraints]
AS

/*
	SELECT *
	FROM DOI.[vwExchangeTableNonPartitioned_Tables_NewTable_Constraints]
	WHERE ParentTableName = 'Pays' 
		AND NewTablename = 'PayTaxes_NewPartitionedTableFromPrep'
*/ 

SELECT	FN.DatabaseName,
        FN.SchemaName,
		FN.TableName AS ParentTableName,
		FN.NewTableName,
		REPLACE(C.ConstraintName, FN.TableName, FN.NewTableName) AS NewTableConstraintName,
		C.ConstraintType,
		C.CreateConstraintStatement,
		C.RenameExistingTableConstraintSQL,
		C.RenameNewTableConstraintSQL,
		C.RevertRenameExistingTableConstraintSQL,
		C.RevertRenameNewTableConstraintSQL,
		ROW_NUMBER() OVER(PARTITION BY FN.SchemaName, FN.TableName, FN.NewTableName ORDER BY FN.SchemaName, FN.TableName, FN.NewTableName) AS RowNum
FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable FN
	CROSS APPLY(SELECT *
				FROM (	SELECT	SchemaName,
								TableName,
								dc.DefaultConstraintName AS ConstraintName,
								'DEFAULT' AS ConstraintType,
								'
IF OBJECT_ID(''' + FN.DatabaseName + '.' + FN.SchemaName + '.' + FN.NewTableName + ''') IS NOT NULL
	AND OBJECT_ID(''' + FN.DatabaseName + '.' + FN.SchemaName + '.' + REPLACE(dc.DefaultConstraintName, TableName, FN.NewTableName) + ''') IS NULL
BEGIN
	ALTER TABLE ' + SchemaName + '.' + FN.NewTableName + ' ADD CONSTRAINT ' + REPLACE(dc.DefaultConstraintName, TableName, FN.NewTableName) + ' DEFAULT ' + dc.DefaultDefinition + ' FOR ' + ColumnName + '
END' + CHAR(13) + CHAR(10) 
AS CreateConstraintStatement, --need a USE statement at the top of the dynamic sql?

'
SET DEADLOCK_PRIORITY 10
EXEC ' + FN.DatabaseName + '.sys.sp_rename @objname = ''' + FN.SchemaName + '.' + dc.DefaultConstraintName + ''',
				@newname = ''' + REPLACE(dc.DefaultConstraintName, FN.TableName, FN.TableName + '_OLD') + ''',
				@objtype = ''OBJECT'''
AS RenameExistingTableConstraintSQL,

'
SET DEADLOCK_PRIORITY 10
EXEC ' + FN.DatabaseName + '.sys.sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(dc.DefaultConstraintName, FN.TableName, FN.NewTableName) + ''',
				@newname = ''' + REPLACE(dc.DefaultConstraintName, FN.NewTableName, FN.TableName) + ''',
				@objtype = ''OBJECT''' 
AS RenameNewTableConstraintSQL,

'
SET DEADLOCK_PRIORITY 10
EXEC ' + FN.DatabaseName + '.sys.sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(dc.DefaultConstraintName, FN.TableName, FN.TableName + '_OLD') + ''',
				@newname = ''' + dc.DefaultConstraintName + ''',
				@objtype = ''OBJECT''' 
AS RevertRenameExistingTableConstraintSQL,

'
SET DEADLOCK_PRIORITY 10
EXEC ' + FN.DatabaseName + '.sys.sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(dc.DefaultConstraintName, FN.NewTableName, FN.TableName) + ''',
				@newname = ''' + REPLACE(dc.DefaultConstraintName, FN.TableName, FN.NewTableName) + ''',
				@objtype = ''OBJECT''' 
AS RevertRenameNewTableConstraintSQL

						FROM DOI.DefaultConstraints dc
						UNION ALL
						SELECT	cc.SchemaName,
								cc.TableName,
								cc.CheckConstraintName,
								'CHECK' AS ConstraintType,
								'
IF OBJECT_ID(''' + FN.DatabaseName + '.' + FN.SchemaName + '.' + FN.NewTableName + ''') IS NOT NULL
	AND OBJECT_ID(''' + FN.DatabaseName + '.' + FN.SchemaName + '.' + REPLACE(cc.CheckConstraintName, cc.TableName, FN.NewTableName) + ''') IS NULL
BEGIN
	ALTER TABLE ' + cc.SchemaName + '.' + FN.NewTableName + ' ADD CONSTRAINT ' + REPLACE(cc.CheckConstraintName, cc.TableName, FN.NewTableName) + ' CHECK ' + cc.CheckDefinition + '
END' + CHAR(13) + CHAR(10) 
AS CreateConstraintStatement,

'
SET DEADLOCK_PRIORITY 10
EXEC ' + FN.DatabaseName + '.sys.sp_rename @objname = ''' + FN.SchemaName + '.' + cc.CheckConstraintName + ''',
				@newname = ''' + REPLACE(cc.CheckConstraintName, FN.TableName, FN.TableName + '_OLD') + ''',
				@objtype = ''OBJECT'''
AS RenameExistingTableConstraintSQL,

'
SET DEADLOCK_PRIORITY 10
EXEC ' + FN.DatabaseName + '.sys.sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(cc.CheckConstraintName, FN.TableName, FN.NewTableName) + ''',
				@newname = ''' + REPLACE(cc.CheckConstraintName, FN.NewTableName, FN.TableName) + ''',
				@objtype = ''OBJECT'''
AS RenameNewTableConstraintSQL,

'
SET DEADLOCK_PRIORITY 10
EXEC ' + FN.DatabaseName + '.sys.sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(cc.CheckConstraintName, FN.TableName, FN.TableName + '_OLD') + ''',
				@newname = ''' + cc.CheckConstraintName + ''',
				@objtype = ''OBJECT'''
AS RevertRenameExistingTableConstraintSQL,

'
SET DEADLOCK_PRIORITY 10
EXEC ' + FN.DatabaseName + '.sys.sp_rename @objname = ''' + FN.SchemaName + '.' + REPLACE(cc.CheckConstraintName, FN.NewTableName, FN.TableName) + ''',
				@newname = ''' + REPLACE(cc.CheckConstraintName, FN.TableName, FN.NewTableName) + ''',
				@objtype = ''OBJECT'''
AS RevertRenameNewTableConstraintSQL

						FROM DOI.CheckConstraints cc) Constraints
				WHERE Constraints.SchemaName = FN.SchemaName
					AND Constraints.TableName = FN.TableName) C

GO