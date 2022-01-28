-- <Migration ID="de3c755a-5ae1-444d-ae65-e4426bee7344" />
IF OBJECT_ID('[DOI].[vwExchangeTableNonPartitioned_Tables_NewTable_Indexes]') IS NOT NULL
	DROP VIEW [DOI].[vwExchangeTableNonPartitioned_Tables_NewTable_Indexes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [DOI].[vwExchangeTableNonPartitioned_Tables_NewTable_Indexes]

AS

/*
	SELECT	NewTableIndexCreateSQL
	FROM  DOI.vwExchangeTableNonPartitioned_Tables_NewTable_Indexes
	WHERE NewTableindexname = 'CDX_Bai2BankTransactions_NewTable'
*/ 

SELECT  PT.DatabaseName, 
        PT.SchemaName, 
        PT.TableName AS ParentTableName,
        I.IndexName AS ParentIndexName,
        I.IsIndexMissingFromSQLServer,
        PT.NewTableName,
        REPLACE(I.IndexName, I.TableName, PT.NewTableName) AS NewTableIndexName,
        I.Storage_Actual,
        I.StorageType_Actual,
        I.Storage_Desired,
        I.StorageType_Desired,
        PT.NewTableFilegroup,
        I.IndexSizeMB_Actual,
		I.IndexType,
		I.IsClustered_Actual,
		ROW_NUMBER() OVER(PARTITION BY PT.DatabaseName, PT.SchemaName, PT.TableName ORDER BY PT.DatabaseName, PT.SchemaName, PT.TableName) AS RowNum,
        CASE 
            WHEN IndexType = 'RowStore'
            THEN '
IF NOT EXISTS (SELECT ''True'' FROM ' + PT.DatabaseName + '.sys.indexes i INNER JOIN ' + PT.DatabaseName + '.sys.tables t ON i.object_id = t.object_id INNER JOIN ' + PT.DatabaseName + '.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''' + I.SchemaName + ''' AND t.name = ''' + PT.NewTableName + ''' AND i.name = ''' + REPLACE(I.IndexName, I.TableName, PT.NewTableName) + ''')
BEGIN' + 	CASE 
				WHEN (I.IsPrimaryKey_Desired = 1 OR I.IsUniqueConstraint_Desired = 1)
				THEN '
	ALTER TABLE ' + I.SchemaName + '.' + PT.NewTableName + '
		ADD CONSTRAINT ' + REPLACE(I.IndexName, I.TableName, PT.NewTableName) + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
'		' + CASE WHEN I.IsPrimaryKey_Desired = 1 THEN 'PRIMARY KEY ' WHEN I.IsUniqueConstraint_Desired = 1 THEN ' UNIQUE ' ELSE '' END + CASE WHEN I.IsClustered_Desired = 0 THEN ' NON' ELSE ' ' END + 'CLUSTERED (' + I.KeyColumnList_Desired + ') ' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
'				WITH (	
						PAD_INDEX = ' + CASE WHEN I.OptionPadIndex_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						FILLFACTOR = ' + CAST(CASE WHEN I.[Fillfactor_Desired] = 0 THEN 100 ELSE I.[Fillfactor_Desired] END AS VARCHAR(3)) + ',
						IGNORE_DUP_KEY = ' + CASE WHEN I.OptionIgnoreDupKey_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						STATISTICS_NORECOMPUTE = ' + CASE WHEN I.OptionStatisticsNoRecompute_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						STATISTICS_INCREMENTAL = OFF,
						ALLOW_ROW_LOCKS = ' + CASE WHEN I.OptionAllowRowLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						ALLOW_PAGE_LOCKS = ' + CASE WHEN I.OptionAllowPageLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						DATA_COMPRESSION = ' + I.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + CHAR(9) +
'			ON [' +	PT.NewTableFilegroup + ']'
				ELSE '
	CREATE' +	CASE I.IsUnique_Desired WHEN 1 THEN ' UNIQUE ' ELSE ' ' END + CASE WHEN I.IsClustered_Desired = 0 THEN ' NON' ELSE ' ' END + 'CLUSTERED INDEX ' + REPLACE(I.IndexName, I.TableName, PT.NewTableName) + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
											'	ON ' + I.SchemaName + '.' + PT.NewTableName + '(' + I.KeyColumnList_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
											CASE 
												WHEN I.IncludedColumnList_Desired IS NULL 
												THEN '' 
												ELSE '		INCLUDE(' + I.IncludedColumnList_Desired + ')'
											END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
											CASE
												WHEN I.IsFiltered_Desired = 0
												THEN ''
												ELSE '		WHERE ' + I.FilterPredicate_Desired
											END + CHAR(13) + CHAR(10) +
											'					WITH (	
								PAD_INDEX = ' + CASE WHEN I.OptionPadIndex_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								FILLFACTOR = ' + CAST(CASE WHEN I.[Fillfactor_Desired] = 0 THEN 100 ELSE I.[Fillfactor_Desired] END AS VARCHAR(3)) + ',
								SORT_IN_TEMPDB = ON,
								IGNORE_DUP_KEY = ' + CASE WHEN I.OptionIgnoreDupKey_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								STATISTICS_NORECOMPUTE = ' + CASE WHEN I.OptionStatisticsNoRecompute_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								STATISTICS_INCREMENTAL = OFF,
								DROP_EXISTING = OFF,
								ONLINE = OFF,
								ALLOW_ROW_LOCKS = ' + CASE WHEN I.OptionAllowRowLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								ALLOW_PAGE_LOCKS = ' + CASE WHEN I.OptionAllowPageLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								MAXDOP = 0,
								DATA_COMPRESSION = ' + I.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
											'		ON [' + PT.NewTableFilegroup + ']'
			END + 
'END'
                WHEN indexType = 'ColumnStore'
                THEN '
IF NOT EXISTS (SELECT ''True'' FROM ' + PT.DatabaseName + '.sys.indexes i INNER JOIN ' + PT.DatabaseName + '.sys.tables t ON i.object_id = t.object_id INNER JOIN ' + PT.DatabaseName + '.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''' + I.SchemaName + ''' AND t.name = ''' + PT.NewTableName + ''' AND i.name = ''' + REPLACE(I.IndexName, I.TableName, PT.NewTableName) + ''')
BEGIN
	CREATE' + CASE WHEN I.IsClustered_Desired = 0 THEN ' NON' ELSE ' ' END + 'CLUSTERED COLUMNSTORE INDEX ' + REPLACE(I.IndexName, I.TableName, PT.NewTableName) + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										'	ON ' + I.SchemaName + '.' + PT.NewTableName + CASE WHEN I.IsClustered_Desired = 1 THEN '' ELSE '(' + I.IncludedColumnList_Desired + ')' END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										CASE
											WHEN I.IsFiltered_Desired = 0
											THEN ''
											ELSE '			WHERE ' + I.FilterPredicate_Desired
										END + CHAR(13) + CHAR(10) +
										'				WITH (	
						DROP_EXISTING = OFF,
						COMPRESSION_DELAY = ' + CAST(I.OptionDataCompressionDelay_Desired AS VARCHAR(20)) + ',
						MAXDOP = 0,
						DATA_COMPRESSION = ' + I.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										'		ON [' + PT.NewTableFilegroup + ']
END'
        END AS NewTableIndexCreateSQL,
        I.CreateStatement AS OrigCreateSQL,
		CASE 
			WHEN I.IsIndexMissingFromSQLServer = 1 
			THEN '' 
			ELSE I.RenameIndexSQL
		END AS RenameExistingTableIndexSQL,
'
IF EXISTS(	SELECT ''True'' 
			FROM ' + PT.DatabaseName + '.sys.indexes i 
				INNER JOIN ' + PT.DatabaseName + '.sys.tables t ON t.object_id = i.object_id 
				INNER JOIN ' + PT.DatabaseName + '.sys.schemas s ON t.schema_id = s.schema_id 
			WHERE s.name = ''' + PT.SchemaName + ''' 
				AND t.name = ''' + PT.TableName + '''
				AND i.name = ''' + REPLACE(I.IndexName, PT.TableName, PT.TableName + '_OLD') + ''')
BEGIN
	' + I.RevertRenameIndexSQL + '
END'
		AS RevertRenameExistingTableIndexSQL,

'
SET DEADLOCK_PRIORITY 10
EXEC ' + PT.DatabaseName + '.sys.sp_rename 
	@objname = ''' + PT.SchemaName + '.' + PT.NewTableName + '.' + REPLACE(I.IndexName, PT.TableName, PT.NewTableName) + ''', 
	@newname = ''' + I.IndexName + ''', 
	@objtype = ''INDEX''' 
		AS RenameNewTableIndexSQL,

'
IF EXISTS(	SELECT ''True'' 
			FROM ' + PT.DatabaseName + '.sys.indexes i 
				INNER JOIN ' + PT.DatabaseName + '.sys.tables t ON t.object_id = i.object_id 
				INNER JOIN ' + PT.DatabaseName + '.sys.schemas s ON t.schema_id = s.schema_id 
			WHERE s.name = ''' + PT.SchemaName + ''' 
				AND t.name = ''' + PT.NewTableName + '''
				AND i.name = ''' + I.IndexName + ''')
BEGIN
	SET DEADLOCK_PRIORITY 10
	EXEC ' + PT.DatabaseName + '.sys.sp_rename 
		@objname = ''' + PT.SchemaName + '.' + PT.NewTableName + '.' + I.IndexName + ''', 
		@newname = ''' + REPLACE(I.IndexName, PT.TableName, PT.NewTableName) + ''', 
		@objtype = ''INDEX''
END' 
		AS RevertRenameNewTableIndexSQL
FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
    INNER JOIN DOI.vwIndexes I ON I.DatabaseName = PT.DatabaseName
        AND I.SchemaName = PT.SchemaName
        AND I.TableName = PT.TableName


GO