IF OBJECT_ID('[DDI].[vwTables_PrepTables_Indexes]') IS NOT NULL
	DROP VIEW [DDI].[vwTables_PrepTables_Indexes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   VIEW [DDI].[vwTables_PrepTables_Indexes]

AS

/*
	SELECT	*
	FROM  DDI.vwTables_PrepTables_Indexes
	WHERE preptableindexname = 'CDX_Bai2BankTransactions_NewPartitionedTableFromPrep'

select * from utility.vwindexes where tablename = 'JournalEntries'
select * from ddi.vwtables_preptables where tablename = 'journalentries'
select * from paymentreporting.utility.fndatadrivenindexes_getpreptablesql()

kill 56

*/ 

SELECT  PT.DatabaseName, 
        PT.SchemaName, 
        PT.TableName AS ParentTableName,
        I.IndexName AS ParentIndexName,
        I.IsIndexMissingFromSQLServer,
        PT.PrepTableName,
        REPLACE(I.IndexName, I.TableName, PT.PrepTableName) AS PrepTableIndexName,
        PT.IsNewPartitionedPrepTable,
        I.Storage_Actual,
        I.StorageType_Actual,
        I.Storage_Desired,
        I.StorageType_Desired,
        PT.PrepTableFilegroup,
        I.IndexSizeMB_Actual,
		ROW_NUMBER() OVER(PARTITION BY PT.DatabaseName, PT.SchemaName, PT.TableName ORDER BY PT.IsNewPartitionedPrepTable, PT.PrepTableName) AS RowNum,
		CASE PT.IsNewPartitionedPrepTable 
			WHEN 0 
			THEN	REPLACE(REPLACE(REPLACE(REPLACE(I.CreateStatement, I.TableName, PT.PrepTableName), 
									'ON ' + ISNULL(I.Storage_Desired, I.Storage_Actual),	'ON ' + PT.PrepTableFilegroup), 
									'(' + ISNULL(I.PartitionColumn_Desired, '') + ')', SPACE(0)) , 
							'STATISTICS_INCREMENTAL = ON', 'STATISTICS_INCREMENTAL = OFF') 
			WHEN 1
			THEN	REPLACE(I.CreateStatement, I.TableName, PT.PrepTableName) 
		END COLLATE SQL_Latin1_General_CP1_CI_AS AS PrepTableIndexCreateSQL,
        I.CreateStatement AS OrigCreateSQL,
		CASE PT.IsNewPartitionedPrepTable
			WHEN 0
			THEN ''
			ELSE CASE 
					WHEN I.IsIndexMissingFromSQLServer = 1 
					THEN '' 
					ELSE I.RenameIndexSQL
					END 
		END AS RenameExistingTableIndexSQL,
		CASE PT.IsNewPartitionedPrepTable
			WHEN 0
			THEN ''
			ELSE '
IF EXISTS(	SELECT ''True'' 
			FROM sys.indexes i 
				INNER JOIN sys.tables t ON t.object_id = i.object_id 
				INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
			WHERE s.name = ''' + PT.SchemaName + ''' 
				AND t.name = ''' + PT.TableName + '''
				AND i.name = ''' + REPLACE(I.IndexName, PT.TableName, PT.TableName + '_OLD') + ''')
BEGIN
	' + I.RevertRenameIndexSQL + '
END'
		END AS RevertRenameExistingTableIndexSQL,

		CASE PT.IsNewPartitionedPrepTable
			WHEN 0
			THEN ''
			ELSE '
SET DEADLOCK_PRIORITY 10
EXEC sp_rename 
	@objname = ''' + PT.SchemaName + '.' + PT.PrepTableName + '.' + REPLACE(I.IndexName, PT.TableName, PT.PrepTableName) + ''', 
	@newname = ''' + I.IndexName + ''', 
	@objtype = ''INDEX''' 
		END AS RenameNewPartitionedPrepTableIndexSQL,

		CASE PT.IsNewPartitionedPrepTable
			WHEN 0
			THEN ''
			ELSE '
IF EXISTS(	SELECT ''True'' 
			FROM sys.indexes i 
				INNER JOIN sys.tables t ON t.object_id = i.object_id 
				INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
			WHERE s.name = ''' + PT.SchemaName + ''' 
				AND t.name = ''' + PT.PrepTableName + '''
				AND i.name = ''' + I.IndexName + ''')
BEGIN
	SET DEADLOCK_PRIORITY 10
	EXEC sp_rename 
		@objname = ''' + PT.SchemaName + '.' + PT.PrepTableName + '.' + I.IndexName + ''', 
		@newname = ''' + REPLACE(I.IndexName, PT.TableName, PT.PrepTableName) + ''', 
		@objtype = ''INDEX''
END' 
		END AS RevertRenameNewPartitionedPrepTableIndexSQL
FROM DDI.vwTables_PrepTables PT
    INNER JOIN DDI.vwIndexes I ON I.DatabaseName = PT.DatabaseName
        AND I.SchemaName = PT.SchemaName
        AND I.TableName = PT.TableName






GO
