IF OBJECT_ID('[DDI].[vwIndexes]') IS NOT NULL
	DROP VIEW [DDI].[vwIndexes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   VIEW [DDI].[vwIndexes]
AS

/*
    SELECT * FROM DDI.vwIndexes
*/

SELECT	AllIdx.* 
        ,CASE
            WHEN AllIdx.IndexUpdateType IN ('CreateMissing', 'AlterRebuild')
                    OR (AllIdx.IndexUpdateType = 'DropRecreate' AND AllIdx.IsClustered_Desired = 1)
            THEN 1
			ELSE 0
         END AS NeedsSpaceOnTempDBDrive
		,CASE 
			WHEN AllIdx.IndexUpdateType IN ('AlterSet', 'AlterReorganize', 'AlterReorganize-PartitionLevel')
				OR (AllIdx.IndexUpdateType IN ('AlterRebuild', 'AlterRebuild-PartitionLevel') 
					AND (AllIdx.IndexType = 'RowStore' AND AllIdx.IndexHasLOBColumns = 0))
			THEN 1
			WHEN AllIdx.IndexUpdateType IN ('DropRecreate')
				OR (AllIdx.IndexUpdateType IN ('AlterRebuild', 'AlterRebuild-PartitionLevel') 
					AND ((AllIdx.IndexType = 'RowStore' AND AllIdx.IndexHasLOBColumns = 1)
							OR (AllIdx.IndexType = 'ColumnStore')))
			THEN 0
			ELSE 0
        END AS IsOnlineOperation
		--KEEP THE ORDER OF THE CASE STATEMENTS BELOW IN ALPHABETICAL ORDER!!!
		,STUFF(CASE WHEN AllIdx.IsAllowPageLocksChanging			= 1						THEN	', AllowPageLocks'								ELSE '' END
				+ CASE WHEN AllIdx.IsAllowRowLocksChanging			= 1						THEN	', AllowRowLocks'									ELSE '' END
				+ CASE WHEN AllIdx.IsClusteredChanging				= 1						THEN	', Clustered'									ELSE '' END
				+ CASE WHEN AllIdx.IsDataCompressionDelayChanging	= 1						THEN	', CompressionDelay'							ELSE '' END
				+ CASE WHEN AllIdx.IsDataCompressionChanging		= 1						THEN	', DataCompression'								ELSE '' END
				+ CASE WHEN AllIdx.IsFillfactorChanging				= 1						THEN	', FillFactor'									ELSE '' END
				+ CASE WHEN AllIdx.IsFilterChanging					= 1						THEN	', Filter'										ELSE '' END
				+ CASE WHEN AllIdx.FragmentationType				IN ('Heavy', 'Light')	THEN	', Fragmentation:  ' + AllIdx.FragmentationType	ELSE '' END 
				+ CASE WHEN AllIdx.IsIgnoreDupKeyChanging			= 1						THEN	', IgnoreDupKey'								ELSE '' END
				+ CASE WHEN AllIdx.IsIncludedColumnListChanging		= 1						THEN	', IncludedColumnList'							ELSE '' END
				+ CASE WHEN AllIdx.IsPrimaryKeyChanging				= 1						THEN	', IsPrimaryKey'								ELSE '' END
				+ CASE WHEN AllIdx.IsKeyColumnListChanging			= 1						THEN	', KeyColumnList'								ELSE '' END
				+ CASE WHEN AllIdx.IsPadIndexChanging				= 1						THEN	', PadIndex'									ELSE '' END
				+ CASE WHEN AllIdx.IsPartitioningChanging			= 1						THEN	', Partitioning'								ELSE '' END
				+ CASE WHEN AllIdx.IsStatisticsNoRecomputeChanging	= 1						THEN	', StatisticsNoRecompute'						ELSE '' END
				+ CASE WHEN AllIdx.IsStatisticsIncrementalChanging	= 1						THEN	', StatisticsIncremental'						ELSE '' END
				+ CASE WHEN AllIdx.IsUniquenessChanging				= 1						THEN	', Uniqueness'									ELSE '' END, 1, 2, SPACE(0)) AS ListOfChanges
FROM (	SELECT	 IRS.*
				,CASE
					WHEN IRS.IsIndexMissingFromSQLServer = 1
					THEN 'CreateMissing'
					WHEN IRS.IsIndexMissingFromSQLServer = 0
						AND IRS.AreDropRecreateOptionsChanging = 1
					THEN 'DropRecreate'
					WHEN (IRS.IsIndexMissingFromSQLServer = 0
						AND IRS.NeedsPartitionLevelOperations = 0 
						AND IRS.AreDropRecreateOptionsChanging = 0 )
							AND ((IRS.FragmentationType = 'Heavy' OR IRS.AreRebuildOnlyOptionsChanging = 1)
								OR (IRS.FragmentationType = 'Light' AND IRS.AreSetOptionsChanging = 1))
					THEN 'AlterRebuild'	
					WHEN (IRS.IsIndexMissingFromSQLServer = 0
						AND IRS.NeedsPartitionLevelOperations = 1 
						AND IRS.AreDropRecreateOptionsChanging = 0 )
							AND (IRS.FragmentationType = 'Heavy' OR IRS.IsDataCompressionChanging = 1)
					THEN 'AlterRebuild-PartitionLevel'
					WHEN IRS.IsIndexMissingFromSQLServer = 0
						AND IRS.FragmentationType = 'None'
						AND IRS.AreSetOptionsChanging = 1
						AND IRS.NeedsPartitionLevelOperations = 0 
						AND IRS.AreDropRecreateOptionsChanging = 0 
						AND IRS.AreRebuildOnlyOptionsChanging = 0
					THEN 'AlterSet'
					WHEN (IRS.IsIndexMissingFromSQLServer = 0
						AND IRS.AreDropRecreateOptionsChanging = 0 
						AND IRS.AreRebuildOptionsChanging = 0
						AND IRS.FragmentationType = 'Light'
						AND IRS.AreSetOptionsChanging = 0)
					THEN	CASE IRS.NeedsPartitionLevelOperations
								WHEN 0 THEN 'AlterReorganize'
								WHEN 1 THEN 'AlterReorganize-PartitionLevel'
							END
					ELSE 'None'
				END AS IndexUpdateType 
				
				,CASE 
					WHEN ISNULL(IRS.IsPrimaryKey_Actual, IRS.IsPrimaryKey_Desired) = 1 OR ISNULL(IRS.IsUniqueConstraint_Actual, IRS.IsUniqueConstraint_Desired) = 1 
					THEN 'ALTER TABLE ' + IRS.SchemaName + '.' + IRS.TableName + ' DROP CONSTRAINT IF EXISTS ' + IRS.IndexName
					ELSE 'DROP INDEX IF EXISTS '+ IRS.SchemaName + '.' + IRS.TableName + '.' + IRS.IndexName
				END AS DropStatement
				,
'IF NOT EXISTS (SELECT ''True'' FROM sys.indexes i INNER JOIN sys.tables t ON i.object_id = t.object_id INNER JOIN sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''' + IRS.SchemaName + ''' AND t.name = ''' + IRS.TableName + ''' AND i.name = ''' + IRS.IndexName + ''')
BEGIN' + 	CASE 
				WHEN (IRS.IsPrimaryKey_Desired = 1 OR IRS.IsUniqueConstraint_Desired = 1)
				THEN '
ALTER TABLE ' + IRS.SchemaName + '.' + IRS.TableName + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
'	ADD CONSTRAINT ' + IRS.IndexName + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
'		' + CASE WHEN IRS.IsPrimaryKey_Desired = 1 THEN 'PRIMARY KEY ' WHEN IRS.IsUniqueConstraint_Desired = 1 THEN ' UNIQUE ' ELSE '' END + CASE WHEN IRS.IsClustered_Desired = 0 THEN ' NON' ELSE ' ' END + 'CLUSTERED (' + IRS.KeyColumnList_Desired + ') ' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
'				WITH (	
						PAD_INDEX = ' + CASE WHEN IRS.OptionPadIndex_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						FILLFACTOR = ' + CAST(CASE WHEN IRS.Fillfactor_Desired = 0 THEN 100 ELSE IRS.Fillfactor_Desired END AS VARCHAR(3)) + ',
						IGNORE_DUP_KEY = ' + CASE WHEN IRS.OptionIgnoreDupKey_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						STATISTICS_NORECOMPUTE = ' + CASE WHEN IRS.OptionStatisticsNoRecompute_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						STATISTICS_INCREMENTAL = ' + CASE WHEN IRS.OptionStatisticsIncremental_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						ALLOW_ROW_LOCKS = ' + CASE WHEN IRS.OptionAllowRowLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						ALLOW_PAGE_LOCKS = ' + CASE WHEN IRS.OptionAllowPageLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
						DATA_COMPRESSION = ' + IRS.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + CHAR(9) +
'			ON ' +	CASE 
						WHEN IRS.IntendToPartition = 1
						THEN ISNULL(IRS.Storage_Desired, '[' + IRS.Storage_Actual + ']')
						ELSE '[' + ISNULL(IRS.Storage_Desired, IRS.Storage_Actual) + ']'
					END +	CASE 
								WHEN IRS.StorageType_Desired = 'PARTITION_SCHEME'
								THEN '(' + IRS.PartitionColumn_Desired + ')' 
								ELSE '' 
							END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9)
					ELSE '
CREATE' +	CASE IRS.IsUnique_Desired WHEN 1 THEN ' UNIQUE ' ELSE ' ' END + CASE WHEN IRS.IsClustered_Desired = 0 THEN ' NON' ELSE ' ' END + 'CLUSTERED INDEX ' + IRS.IndexName + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										'	ON ' + IRS.SchemaName + '.' + IRS.TableName + '(' + IRS.KeyColumnList_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										CASE 
											WHEN IRS.IncludedColumnList_Desired IS NULL 
											THEN '' 
											ELSE '		INCLUDE(' + IRS.IncludedColumnList_Desired + ')'
										END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										CASE
											WHEN IRS.IsFiltered_Desired = 0
											THEN ''
											ELSE '		WHERE ' + IRS.FilterPredicate_Desired
										END + CHAR(13) + CHAR(10) +
										'					WITH (	
							PAD_INDEX = ' + CASE WHEN IRS.OptionPadIndex_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
							FILLFACTOR = ' + CAST(CASE WHEN IRS.Fillfactor_Desired = 0 THEN 100 ELSE IRS.Fillfactor_Desired END AS VARCHAR(3)) + ',
							SORT_IN_TEMPDB = ON,
							IGNORE_DUP_KEY = ' + CASE WHEN IRS.OptionIgnoreDupKey_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
							STATISTICS_NORECOMPUTE = ' + CASE WHEN IRS.OptionStatisticsNoRecompute_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
							STATISTICS_INCREMENTAL = ' + CASE WHEN IRS.OptionStatisticsIncremental_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
							DROP_EXISTING = OFF,
							ONLINE = OFF,
							ALLOW_ROW_LOCKS = ' + CASE WHEN IRS.OptionAllowRowLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
							ALLOW_PAGE_LOCKS = ' + CASE WHEN IRS.OptionAllowPageLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
							MAXDOP = 0,
							DATA_COMPRESSION = ' + IRS.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										'		ON ' +	CASE 
															WHEN IRS.IntendToPartition = 1
															THEN ISNULL(IRS.Storage_Desired, '[' + IRS.Storage_Actual + ']')
															ELSE '[' + ISNULL(IRS.Storage_Desired, IRS.Storage_Actual) + ']'
														END +	CASE 
																	WHEN IRS.StorageType_Desired = 'PARTITION_SCHEME'
																	THEN '(' + IRS.PartitionColumn_Desired + ')' 
																	ELSE '' 
																END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9)
		END + 
'END' AS CreateStatement
				,'
ALTER INDEX ' + IRS.IndexName + ' ON ' + IRS.SchemaName + '.' + IRS.TableName + CHAR(13) + CHAR(10) + 
'	SET (	IGNORE_DUP_KEY = ' + CASE WHEN IRS.OptionIgnoreDupKey_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
			STATISTICS_NORECOMPUTE = ' + CASE WHEN IRS.OptionStatisticsNoRecompute_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
			ALLOW_ROW_LOCKS = ' + CASE WHEN IRS.OptionAllowRowLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
			ALLOW_PAGE_LOCKS = ' + CASE WHEN IRS.OptionAllowPageLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) 
AS AlterSetStatement
				,	CASE 
						WHEN ISNULL(IRS.NeedsPartitionLevelOperations, 0) = 0
						THEN '
ALTER INDEX ' + IRS.IndexName + ' ON ' + IRS.SchemaName + '.' + IRS.TableName + CHAR(13) + CHAR(10) + 
'	REBUILD PARTITION = ALL' + CHAR(13) + CHAR(10) + 
'		WITH (	
				PAD_INDEX = ' + CASE WHEN IRS.OptionPadIndex_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
				FILLFACTOR = ' + CAST(CASE WHEN IRS.Fillfactor_Desired = 0 THEN 100 ELSE IRS.Fillfactor_Desired END AS VARCHAR(3)) + ',
				SORT_IN_TEMPDB = ON' + 
				CASE WHEN IRS.IsPrimaryKey_Desired = 1 THEN '' ELSE ',
				IGNORE_DUP_KEY = ' + CASE WHEN IRS.OptionIgnoreDupKey_Desired = 1 THEN 'ON' ELSE 'OFF' END END + ',
				STATISTICS_NORECOMPUTE = ' + CASE WHEN IRS.OptionStatisticsNoRecompute_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
				STATISTICS_INCREMENTAL = ' + CASE WHEN IRS.OptionStatisticsIncremental_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
				ONLINE = ' + CASE WHEN IndexHasLOBColumns = 1 THEN 'OFF' ELSE ' ON(WAIT_AT_LOW_PRIORITY (MAX_DURATION = 0 MINUTES, ABORT_AFTER_WAIT = NONE))' END + ',
				ALLOW_ROW_LOCKS = ' + CASE WHEN IRS.OptionAllowRowLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
				ALLOW_PAGE_LOCKS = ' + CASE WHEN IRS.OptionAllowPageLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
				MAXDOP = 0,
				DATA_COMPRESSION = ' + IRS.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) 
						ELSE 'Needs Partition Level Statements'
END AS AlterRebuildStatement
				,	CASE
						WHEN ISNULL(IRS.NeedsPartitionLevelOperations, 0) = 0
						THEN '
ALTER INDEX ' + IRS.IndexName + ' ON ' + IRS.SchemaName + '.' + IRS.TableName + CHAR(13) + CHAR(10) + 
'	REORGANIZE PARTITION = ALL' + CHAR(13) + CHAR(10) + 
'		WITH (	LOB_COMPACTION = ON)' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) 
						ELSE 'Needs Partition Level Statements'
END AS AlterReorganizeStatement,
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + IRS.SchemaName + '.' + IRS.TableName + '.' + IRS.IndexName + ''',
	@newname = ''' + REPLACE(IRS.IndexName, IRS.TableName, IRS.TableName + '_OLD') + ''',
	@objtype = ''INDEX''' AS RenameIndexSQL,
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + IRS.SchemaName + '.' + IRS.TableName + '.' + REPLACE(IRS.IndexName, IRS.TableName, IRS.TableName + '_OLD') + ''',
	@newname = ''' + IRS.IndexName + ''',
	@objtype = ''INDEX''' AS RevertRenameIndexSQL,
CASE WHEN IsPrimaryKey_Desired = 0 THEN '' ELSE 
'IF NOT EXISTS (SELECT ''True'' FROM sys.indexes i INNER JOIN sys.tables t ON i.object_id = t.object_id INNER JOIN sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''' + IRS.SchemaName + ''' AND t.name = ''' + IRS.TableName + ''' AND i.name = ''' + IRS.IndexName + ''')
BEGIN
	CREATE UNIQUE ' + CASE WHEN IRS.IsClustered_Desired = 0 THEN ' NON' ELSE ' ' END + 'CLUSTERED INDEX ' + IRS.IndexName + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
											'	ON ' + IRS.SchemaName + '.' + IRS.TableName + '(' + IRS.KeyColumnList_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
											CASE 
												WHEN IRS.IncludedColumnList_Desired IS NULL 
												THEN '' 
												ELSE '		INCLUDE(' + IRS.IncludedColumnList_Desired + ')'
											END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
											CASE
												WHEN IRS.IsFiltered_Desired = 0
												THEN ''
												ELSE '		WHERE ' + IRS.FilterPredicate_Desired
											END + CHAR(13) + CHAR(10) +
											'					WITH (	
								PAD_INDEX = ' + CASE WHEN IRS.OptionPadIndex_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								FILLFACTOR = ' + CAST(CASE WHEN IRS.Fillfactor_Desired = 0 THEN 100 ELSE IRS.Fillfactor_Desired END AS VARCHAR(3)) + ',
								SORT_IN_TEMPDB = ON,
								IGNORE_DUP_KEY = ' + CASE WHEN IRS.OptionIgnoreDupKey_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								STATISTICS_NORECOMPUTE = ' + CASE WHEN IRS.OptionStatisticsNoRecompute_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								STATISTICS_INCREMENTAL = ' + CASE WHEN IRS.OptionStatisticsIncremental_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								DROP_EXISTING = OFF,
								ONLINE = OFF,
								ALLOW_ROW_LOCKS = ' + CASE WHEN IRS.OptionAllowRowLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								ALLOW_PAGE_LOCKS = ' + CASE WHEN IRS.OptionAllowPageLocks_Desired = 1 THEN 'ON' ELSE 'OFF' END + ',
								MAXDOP = 0,
								DATA_COMPRESSION = ' + IRS.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
											'		ON ' +	CASE 
																WHEN IRS.IntendToPartition = 1
																THEN ISNULL(IRS.Storage_Desired, '[' + IRS.Storage_Actual + ']')
																ELSE '[' + ISNULL(IRS.Storage_Desired, IRS.Storage_Actual) + ']'
															END +	CASE 
																		WHEN IRS.StorageType_Desired = 'PARTITION_SCHEME'
																		THEN '(' + IRS.PartitionColumn_Desired + ')' 
																		ELSE '' 
																	END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + 
'END'
END AS CreatePKAsUniqueIndexSQL,
CASE WHEN IsPrimaryKey_Desired = 0 THEN '' ELSE 
'DROP INDEX IF EXISTS '+ IRS.SchemaName + '.' + IRS.TableName + '.' + IRS.IndexName 
END AS DropPKAsUniqueIndexSQL
		--select count(*)
		FROM DDI.fnIndexesRowStore() IRS
		UNION ALL
		SELECT	 ICS.*
				,CASE
					WHEN ICS.IsIndexMissingFromSQLServer = 1
					THEN 'CreateMissing'
					WHEN ICS.IsIndexMissingFromSQLServer = 0
						AND ICS.AreDropRecreateOptionsChanging = 1
					THEN 'DropRecreate'
					WHEN (ICS.IsIndexMissingFromSQLServer = 0
						AND ICS.NeedsPartitionLevelOperations = 0 
						AND ICS.AreDropRecreateOptionsChanging = 0 )
							AND ((ICS.FragmentationType = 'Heavy' OR ICS.AreRebuildOnlyOptionsChanging = 1)
								OR (ICS.FragmentationType = 'Light' AND ICS.AreSetOptionsChanging = 1))
					THEN 'AlterRebuild'	
					WHEN (ICS.IsIndexMissingFromSQLServer = 0
						AND ICS.NeedsPartitionLevelOperations = 1 
						AND ICS.AreDropRecreateOptionsChanging = 0 )
							AND (ICS.FragmentationType = 'Heavy' OR ICS.IsDataCompressionChanging = 1)
					THEN 'AlterRebuild-PartitionLevel'
					WHEN (ICS.IsIndexMissingFromSQLServer = 0
						AND ICS.NeedsPartitionLevelOperations = 0 
						AND ICS.AreDropRecreateOptionsChanging = 0 
						AND ICS.AreRebuildOptionsChanging = 0
						AND ICS.FragmentationType = 'None')
						AND ICS.AreSetOptionsChanging = 1
					THEN 'AlterSet'
					WHEN (ICS.IsIndexMissingFromSQLServer = 0
						AND ICS.AreDropRecreateOptionsChanging = 0 
						AND ICS.AreRebuildOptionsChanging = 0
						AND ICS.FragmentationType = 'Light'
						AND ICS.AreSetOptionsChanging = 0)
					THEN	CASE ICS.NeedsPartitionLevelOperations
								WHEN 0 THEN 'AlterReorganize'
								WHEN 1 THEN 'AlterReorganize-PartitionLevel'
							END
					ELSE 'None'
				END AS IndexUpdateType 
				,'
DROP INDEX IF EXISTS '+ ICS.SchemaName + '.' + ICS.TableName + '.' + ICS.IndexName AS DropStatement
				,
'IF NOT EXISTS (SELECT ''True'' FROM sys.indexes i INNER JOIN sys.tables t ON i.object_id = t.object_id INNER JOIN sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''' + ICS.SchemaName + ''' AND t.name = ''' + ICS.TableName + ''' AND i.name = ''' + ICS.IndexName + ''')
BEGIN
	CREATE' + CASE WHEN ICS.IsClustered_Desired = 0 THEN ' NON' ELSE ' ' END + 'CLUSTERED COLUMNSTORE INDEX ' + ICS.IndexName + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										'	ON ' + ICS.SchemaName + '.' + ICS.TableName + CASE WHEN ICS.IsClustered_Desired = 1 THEN '' ELSE '(' + ICS.KeyColumnList_Desired + ')' END + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										CASE
											WHEN ICS.IsFiltered_Desired = 0
											THEN ''
											ELSE '			WHERE ' + ICS.FilterPredicate_Desired
										END + CHAR(13) + CHAR(10) +
										'				WITH (	
						DROP_EXISTING = OFF,
						COMPRESSION_DELAY = ' + CAST(ICS.OptionDataCompressionDelay_Desired AS VARCHAR(20)) + ',
						MAXDOP = 0,
						DATA_COMPRESSION = ' + ICS.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
										'		ON ' +	CASE 
															WHEN ICS.IntendToPartition = 1 
															THEN ISNULL(ICS.Storage_Desired, '[' + ICS.Storage_Actual + ']')
															ELSE '[' + ISNULL(ICS.Storage_Desired, ICS.Storage_Actual) + ']'
														END +	CASE 
																	WHEN ICS.StorageType_Desired = 'PARTITION_SCHEME'
																	THEN '(' + ICS.PartitionColumn_Desired + ')' 
																	ELSE '' 
																END + CHAR(13) + CHAR(10) + '
END' AS CreateStatement
				,'
ALTER INDEX ' + ICS.IndexName + ' ON ' + ICS.SchemaName + '.' + ICS.TableName + CHAR(13) + CHAR(10) + 
'	SET (COMPRESSION_DELAY = ' + ICS.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) 
AS AlterSetStatement
				,'
ALTER INDEX ' + ICS.IndexName + ' ON ' + ICS.SchemaName + '.' + ICS.TableName + CHAR(13) + CHAR(10) + 
'	REBUILD PARTITION = ALL' + CHAR(13) + CHAR(10) + 
'		WITH (	DATA_COMPRESSION = ' + ICS.OptionDataCompression_Desired + ')' + CHAR(13) + CHAR(10) + CHAR(10) --COMPRESSION_DELAY errors out...not available yet?
AS AlterRebuildStatement
				,'
ALTER INDEX ' + ICS.IndexName + ' ON ' + ICS.SchemaName + '.' + ICS.TableName + CHAR(13) + CHAR(10) + 
'	REORGANIZE PARTITION = ALL' + CHAR(13) + CHAR(10) + 
'		WITH (COMPRESS_ALL_ROW_GROUPS = OFF)' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) 
AS AlterReorganizeStatement,
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + ICS.SchemaName + '.' + ICS.TableName + '.' + ICS.IndexName + ''',
	@newname = ''' + REPLACE(ICS.IndexName, ICS.TableName, ICS.TableName + '_OLD') + ''',
	@objtype = ''INDEX''' AS RenameIndexSQL,
'
SET DEADLOCK_PRIORITY 10
EXEC sp_rename
	@objname = ''' + ICS.SchemaName + '.' + ICS.TableName + '.' + REPLACE(ICS.IndexName, ICS.TableName, ICS.TableName + '_OLD') + ''',
	@newname = ''' + ICS.IndexName + ''',
	@objtype = ''INDEX''' AS RevertRenameIndexSQL,
'' AS CreatePKAsUniqueIndexSQL,
'' AS DropPKAsUniqueIndexSQL
		--select count(*)
		FROM DDI.fnIndexesColumnStore() AS ICS ) AS AllIdx



GO
