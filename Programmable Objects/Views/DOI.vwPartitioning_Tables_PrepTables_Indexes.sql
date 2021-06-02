
GO

IF OBJECT_ID('[DOI].[vwPartitioning_Tables_PrepTables_Indexes]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitioning_Tables_PrepTables_Indexes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE   VIEW [DOI].[vwPartitioning_Tables_PrepTables_Indexes]

AS

/*
	SELECT	PrepTableIndexCreateSQL
	FROM  DOI.vwPartitioning_Tables_PrepTables_Indexes
	WHERE preptableindexname = 'CDX_Bai2BankTransactions_NewPartitionedTableFromPrep'
*/ 

SELECT  PT.DatabaseName, 
        PT.SchemaName, 
        PT.TableName AS ParentTableName,
        I.IndexName AS ParentIndexName,
        I.IsIndexMissingFromSQLServer,
        PT.PrepTableName,
        REPLACE(I.IndexName, I.TableName, PT.PrepTableName) AS PrepTableIndexName,
		PartitionFunctionName,
		BoundaryValue,
		NextBoundaryValue,
        PT.IsNewPartitionedPrepTable,
        I.Storage_Actual,
        I.StorageType_Actual,
        I.Storage_Desired,
        I.StorageType_Desired,
        PT.PrepTableFilegroup,
        I.IndexSizeMB_Actual,
		I.IndexType,
		I.IsClustered_Actual,
		ROW_NUMBER() OVER(PARTITION BY PT.DatabaseName, PT.SchemaName, PT.TableName ORDER BY PT.IsNewPartitionedPrepTable, PT.BoundaryValue) AS RowNum,
        CASE 
            WHEN IndexType = 'RowStore'
            THEN '
IF NOT EXISTS (SELECT ''True'' FROM sys.indexes i INNER JOIN sys.tables t ON i.object_id = t.object_id INNER JOIN sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''' + I.SchemaName + ''' AND t.name = ''' + PT.PrepTableName + ''' AND i.name = ''' + REPLACE(I.IndexName, I.TableName, PT.PrepTableName) + ''')
BEGIN' + 	CASE 
				WHEN (I.IsPrimaryKey_Desired = 1 OR I.IsUniqueConstraint_Desired = 1)
				THEN '
ALTER TABLE ' + I.SchemaName + '.' + PT.PrepTableName + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
'	ADD CONSTRAINT ' + REPLACE(I.IndexName, I.TableName, PT.PrepTableName) + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
'		' + CASE WHEN I.IsPrimaryKey_Desired = 1 THEN 'PRIMARY KEY ' WHEN I.IsUniqueConstraint_Desired = 1 THEN ' UNIQUE ' ELSE '' END + CASE WHEN I.IsClustered_Desired = 0 THEN ' NON' ELSE ' ' END + 'CLUSTERED (' + I.KeyColumnList_Desired + ') ' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
'				WITH (	
						PAD_INDEX = ' + CASE WHEN I.OptionPadIndex_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						FILLFACTOR = ' + CAST(CASE WHEN I.[Fillfactor_Desired] = 0 THEN 100 ELSE I.[Fillfactor_Desired] END AS VARCHAR(3)) + ',
						IGNORE_DUP_KEY = ' + CASE WHEN I.OptionIgnoreDupKey_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						STATISTICS_NORECOMPUTE = ' + CASE WHEN I.OptionStatisticsNoRecompute_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						STATISTICS_INCREMENTAL = ' +    CASE
                                                            WHEN PT.IsNewPartitionedPrepTable = 0
                                                            THEN 'OFF'
                                                            ELSE    CASE 
                                                                        WHEN I.OptionStatisticsIncremental_Desired = 1 
                                                                        THEN 'ON' 
                                                                        ELSE 'OFF' 
                                                                    END
                                                        END + ',
						ALLOW_ROW_LOCKS = ' + CASE WHEN I.OptionAllowRowLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						ALLOW_PAGE_LOCKS = ' + CASE WHEN I.OptionAllowPageLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						DATA_COMPRESSION = ' + I.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + CHAR(9) +
'			ON [' +	CASE 
                        WHEN PT.IsNewPartitionedPrepTable = 0
                        THEN PT.PrepTableFilegroup
                        ELSE PT.Storage_Desired
                    END + ']' +
					        CASE 
								WHEN PT.IsNewPartitionedPrepTable = 0
                                THEN ''
                                ELSE '(' + I.PartitionColumn_Desired + ')'  
							END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9)
					ELSE '
	CREATE' +	CASE I.IsUnique_Desired WHEN 1 THEN ' UNIQUE ' ELSE ' ' END + CASE WHEN I.IsClustered_Desired = 0 THEN ' NON' ELSE ' ' END + 'CLUSTERED INDEX ' + REPLACE(I.IndexName, I.TableName, PT.PrepTableName) + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
											'	ON ' + I.SchemaName + '.' + PT.PrepTableName + '(' + I.KeyColumnList_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
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
								STATISTICS_INCREMENTAL = ' +    CASE
                                                                    WHEN PT.IsNewPartitionedPrepTable = 0
                                                                    THEN 'OFF'
                                                                    ELSE    CASE 
                                                                                WHEN I.OptionStatisticsIncremental_Desired = 1 
                                                                                THEN 'ON' 
                                                                                ELSE 'OFF' 
                                                                            END
                                                                END + ',
								DROP_EXISTING = OFF,
								ONLINE = OFF,
								ALLOW_ROW_LOCKS = ' + CASE WHEN I.OptionAllowRowLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								ALLOW_PAGE_LOCKS = ' + CASE WHEN I.OptionAllowPageLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								MAXDOP = 0,
								DATA_COMPRESSION = ' + I.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
											'		ON [' + CASE 
                                                                WHEN PT.IsNewPartitionedPrepTable = 0
                                                                THEN PT.PrepTableFilegroup
                                                                ELSE PT.Storage_Desired
                                                            END + ']'
															+	CASE 
																	WHEN PT.IsNewPartitionedPrepTable = 0
	    															THEN ''
	    															ELSE '(' + I.PartitionColumn_Desired + ')'  
																END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9)
			END + 
'END'
                WHEN indexType = 'ColumnStore'
                THEN '
IF NOT EXISTS (SELECT ''True'' FROM sys.indexes i INNER JOIN sys.tables t ON i.object_id = t.object_id INNER JOIN sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''' + I.SchemaName + ''' AND t.name = ''' + PT.PrepTableName + ''' AND i.name = ''' + REPLACE(I.IndexName, I.TableName, PT.PrepTableName) + ''')
BEGIN
	CREATE' + CASE WHEN I.IsClustered_Desired = 0 THEN ' NON' ELSE ' ' END + 'CLUSTERED COLUMNSTORE INDEX ' + REPLACE(I.IndexName, I.TableName, PT.PrepTableName) + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										'	ON ' + I.SchemaName + '.' + PT.PrepTableName + CASE WHEN I.IsClustered_Desired = 1 THEN '' ELSE '(' + I.IncludedColumnList_Desired + ')' END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
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
										'		ON [' + CASE 
                                                            WHEN PT.IsNewPartitionedPrepTable = 0
                                                            THEN PT.PrepTableFilegroup
                                                            ELSE PT.Storage_Desired
                                                        END + ']'
														+	CASE 
																WHEN PT.IsNewPartitionedPrepTable = 0
																THEN ''
																ELSE '(' + I.PartitionColumn_Desired + ')'  
															END + CHAR(13) + CHAR(10) + '
END'
        END AS PrepTableIndexCreateSQL,
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
FROM DOI.vwPartitioning_Tables_PrepTables PT
    INNER JOIN DOI.vwIndexes I ON I.DatabaseName = PT.DatabaseName
        AND I.SchemaName = PT.SchemaName
        AND I.TableName = PT.TableName


GO
