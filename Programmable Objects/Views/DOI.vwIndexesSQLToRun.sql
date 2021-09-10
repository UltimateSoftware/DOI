-- <Migration ID="5048c6a4-4a49-46da-b2fd-8dc1bacfaa78" />
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[DOI].[vwIndexesSQLToRun]') IS NOT NULL
	DROP VIEW [DOI].[vwIndexesSQLToRun];

GO
CREATE   VIEW DOI.[vwIndexesSQLToRun]

AS
SELECT *
FROM (	--ExchangeTableNonPartitioned (for updates to clustered and isPrimaryKey properties only)
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A' AS IndexName, 'ExchangeTableNonPartitioned' AS OriginalIndexUpdateType, 'ExchangeTableNonPartitioned' AS IndexUpdateType, 1 AS RowNum, 'ExchangeTableNonPartitioned_CreatePrepTable' AS IndexOperation, PT.CreatePrepTableSQL AS CurrentSQLToExecute, 0 AS PartitionNumber, 0 AS IndexSizeMB_Actual
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTC.DatabaseName, PTC.SchemaName, PTC.ParentTableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 2, 'ExchangeTableNonPartitioned_CreatePrepTableConstraints', PTC.CreateConstraintStatement, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable_Constraints PTC
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTC.DatabaseName 
							AND I.TableName = PTC.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 3, 'ExchangeTableNonPartitioned_CreateDataSynchTable', PT.CreateFinalDataSynchTableSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 4, 'ExchangeTableNonPartitioned_CreateDataSynchTrigger', PT.CreateFinalDataSynchTriggerSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 5, 'ExchangeTableNonPartitioned_CreateViewForBCP', PT.CreateViewForBCPSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 6, 'ExchangeTableNonPartitioned_LoadData', PT.BCPSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT I.DatabaseName, I.SchemaName, I.ParentTableName, I.PrepTableIndexName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 7, 'ExchangeTableNonPartitioned_CreatePrepTableIndexes', I.PrepTableIndexCreateSQL, 0, I.IndexSizeMB_Actual
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable_Indexes I
		WHERE EXISTS (	SELECT 'True'
						FROM DOI.vwIndexes I2
						WHERE I.DatabaseName = I2.DatabaseName
							AND I.SchemaName = I2.SchemaName
							AND I.ParentTableName = I2.TableName
							AND I2.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTS.DatabaseName, PTS.SchemaName, PTS.ParentTableName, PTS.PrepTableStatisticsName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 8, 'ExchangeTableNonPartitioned_CreatePrepTableStatistics', PTS.CreateStatisticsStatement, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable_Statistics PTS
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTS.DatabaseName 
							AND I.TableName = PTS.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 9, 'ExchangeTableNonPartitioned_BeginTran', 'BEGIN TRAN', 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTI.DatabaseName, PTI.SchemaName, PTI.ParentTableName, PTI.PrepTableIndexName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 10, 'ExchangeTableNonPartitioned_RenameExistingIndex', PTI.RenameExistingTableIndexSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable_Indexes PTI
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTI.DatabaseName 
							AND I.TableName = PTI.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTI.DatabaseName, PTI.SchemaName, PTI.ParentTableName, PTI.PrepTableIndexName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 11, 'ExchangeTableNonPartitioned_RenameNewTableIndex', PTI.RenameNewNonPartitionedPrepTableIndexSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable_Indexes PTI
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTI.DatabaseName 
							AND I.TableName = PTI.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTS.DatabaseName, PTS.SchemaName, PTS.ParentTableName, PTS.PrepTableStatisticsName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 12, 'ExchangeTableNonPartitioned_RenameExistingTableStatistic', PTS.RenameExistingTableStatisticsSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable_Statistics PTS
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTS.DatabaseName 
							AND I.TableName = PTS.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTS.DatabaseName, PTS.SchemaName, PTS.ParentTableName, PTS.PrepTableStatisticsName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 13, 'ExchangeTableNonPartitioned_RenameNewTableStatistic', PTS.RenameNewNonPartitionedPrepTableStatisticsSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable_Statistics PTS
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTS.DatabaseName 
							AND I.TableName = PTS.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTC.DatabaseName, PTC.SchemaName, PTC.ParentTableName, PTC.PrepTableConstraintName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 14, 'ExchangeTableNonPartitioned_RenameExistingTableConstraint', PTC.RenameExistingTableConstraintSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable_Constraints PTC
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTC.DatabaseName 
							AND I.TableName = PTC.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTC.DatabaseName, PTC.SchemaName, PTC.ParentTableName, PTC.PrepTableConstraintName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 15, 'ExchangeTableNonPartitioned_RenameNewTableConstraint', PTC.RenameNewNonPartitionedPrepTableConstraintSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable_Constraints PTC
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTC.DatabaseName 
							AND I.TableName = PTC.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 16, 'ExchangeTableNonPartitioned_RenameExistingTable', PT.RenameExistingTableSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 17, 'ExchangeTableNonPartitioned_RenameNewTable', PT.RenameNewNonPartitionedPrepTableSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 18, 'ExchangeTableNonPartitioned_CommitTran', 'COMMIT TRAN', 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL  --we need the data synch here!!
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 19, 'ExchangeTableNonPartitioned_DropDataSynchTrigger', PT.DropDataSynchTriggerSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 20, 'ExchangeTableNonPartitioned_DropDataSynchTable', PT.DropDataSynchTableSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_PrepTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		--rest of index-level updates
		UNION ALL
		SELECT	I.DatabaseName,
				I.SchemaName, 
				I.TableName, 
				I.IndexName, 
				I.IndexUpdateType AS OriginalIndexUpdateType,
				CASE 
					WHEN I.IndexUpdateType = 'Delete'
					THEN 'Delete'
					WHEN I.IndexUpdateType = 'CreateMissing'
					THEN 'Create Index'
					WHEN I.IndexUpdateType = 'CreateDropExisting'
					THEN 'CreateDropExisting'
					WHEN I.IndexUpdateType LIKE 'Alter%' 
					THEN 'Alter Index'
					WHEN I.IndexUpdateType = 'None' 
					THEN 'None'
					ELSE ''
				END AS IndexUpdateType,
				1 AS RowNum,
				CASE 
					WHEN I.IndexUpdateType = 'Delete'
					THEN 'Delete'
					WHEN I.IndexUpdateType = 'CreateMissing'
					THEN 'Create Index'
					WHEN I.IndexUpdateType = 'CreateDropExisting'
					THEN 'CreateDropExisting'
					WHEN I.IndexUpdateType LIKE 'Alter%' 
					THEN 'Alter Index'
					WHEN I.IndexUpdateType = 'None' 
					THEN 'None'
					ELSE ''
				END AS IndexOperation,
				CASE I.IndexUpdateType
					WHEN 'Delete'
					THEN I.DropStatement
					WHEN 'CreateMissing'
					THEN I.CreateStatement
					WHEN 'CreateDropExisting'
					THEN I.CreateDropExistingStatement
					WHEN 'AlterRebuild'
					THEN	CASE
								WHEN I.IndexType = 'ColumnStore' 
								THEN I.CreateDropExistingStatement
								ELSE	CASE 
											WHEN I.IndexType = 'RowStore' AND I.IndexHasLOBColumns = 1
											THEN I.CreateDropExistingStatement
											ELSE I.AlterRebuildStatement
										END 
							END 
					WHEN 'AlterReorganize'
					THEN I.AlterReorganizeStatement
					WHEN 'AlterSet'
					THEN I.AlterSetStatement
					ELSE ''
				END AS CurrentSQLToExecute,
				0 AS PartitionNumber,
				I.IndexSizeMB_Actual
		FROM DOI.vwIndexes I
		WHERE I.IndexUpdateType NOT IN ('None', 'ExchangeTableNonPartitioned')
			AND NOT EXISTS (SELECT 'True' 
							FROM DOI.vwIndexes I2
							WHERE I.DatabaseName = I2.DatabaseName 
								AND I.TableName = I2.TableName 
								AND I2.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		--partition-level updates
		UNION ALL
		SELECT	IP.DatabaseName,
				IP.SchemaName, 
				IP.TableName, 
				IP.IndexName, 
				IP.PartitionUpdateType,
				IP.PartitionUpdateType,
				1 AS RowNum,
				IP.PartitionUpdateType AS IndexOperation,
				CASE IP.PartitionUpdateType
					WHEN 'AlterRebuild-PartitionLevel'
					THEN IP.AlterRebuildStatement
					WHEN 'AlterReorganize-PartitionLevel'
					THEN IP.AlterReorganizeStatement
					ELSE ''
				END AS CurrentSQLToExecute,
				IP.PartitionNumber,
				IP.TotalIndexPartitionSizeInMB
		FROM DOI.vwIndexPartitions IP 
		WHERE IP.PartitionUpdateType <> 'None') U
GO