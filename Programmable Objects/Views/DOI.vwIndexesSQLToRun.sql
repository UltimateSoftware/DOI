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

/*
	replace all these unions with a PIVOT?
*/

SELECT I.DatabaseName, I.SchemaName, I.TableName, I.IndexName, IUTO.* 
FROM DOI.vwIndexes I
    INNER JOIN DOI.IndexUpdateTypeOperations IUTO ON IUTO.IndexUpdateType = I.IndexUpdateType
ORDER BY I.DatabaseName, I.SchemaName, I.TableName, IUTO.SeqNo

SELECT *
FROM (	
/*		--ExchangeTablePartitioned
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A' AS IndexName, 'ExchangeTablePartitioned' AS OriginalIndexUpdateType, 'ExchangeTablePartitioned' AS IndexUpdateType, 1 AS RowNum, 'ExchangeTablePartitioned_CreateDataSynchTrigger' AS IndexOperation, PT.CreateDataSynchTriggerSQL AS CurrentSQLToExecute, 0 AS PartitionNumber, 0 AS INdexSizeMB_Actual
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 2, 'ExchangeTablePartitioned_CreatePrepTable', PT.CreatePrepTableSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 3, 'ExchangeTablePartitioned_TurnOnDataSynch', PT.TurnOnDataSynchSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 4, 'ExchangeTablePartitioned_EnableCmdShell', PT.EnableCmdShellSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 5, 'ExchangeTablePartitioned_CreateViewForBCP', PT.CreateViewForBCPSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 6, 'ExchangeTablePartitioned_LoadData', PT.BCPSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 7, 'ExchangeTablePartitioned_CreatePrepTableDataLoadConstraints', PT.CheckConstraintSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT I.DatabaseName, I.SchemaName, I.ParentTableName, I.PrepTableIndexName, 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 8, 'ExchangeTablePartitioned_CreatePrepTableIndexes', I.PrepTableIndexCreateSQL, 0, I.IndexSizeMB_Actual
		FROM DOI.vwPartitioning_Tables_PrepTables_Indexes I
		WHERE EXISTS (	SELECT 'True'
						FROM DOI.vwIndexes I2
						WHERE I.DatabaseName = I2.DatabaseName
							AND I.SchemaName = I2.SchemaName
							AND I.ParentTableName = I2.TableName
							AND I2.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PTC.DatabaseName, PTC.SchemaName, PTC.ParentTableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 9, 'ExchangeTablePartitioned_CreatePrepTableConstraints', PTC.CreateConstraintStatement, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables_Constraints PTC
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTC.DatabaseName 
							AND I.TableName = PTC.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 10, 'ExchangeTablePartitioned_PriorErrorValidation', PT.PriorErrorValidationSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 11, 'ExchangeTablePartitioned_CreateDataSynchTable', PT.CreateFinalDataSynchTableSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 12, 'ExchangeTablePartitioned_CreateDataSynchTrigger', PT.CreateFinalDataSynchTriggerSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 13, 'ExchangeTablePartitioned_TurnOffDataSynch', PT.TurnOffDataSynchSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.ParentTableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 14, 'ExchangeTablePartitioned_PartitionDataValidation', PT.PartitionDataValidationSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables_Partitions PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 15, 'ExchangeTablePartitioned_BeginTran', 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN', 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.ParentTableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 16, 'ExchangeTablePartitioned_PartitionSwitch', PT.PartitionSwitchSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables_Partitions PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.ParentTableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 17, 'DropTable SQL', PT.DropTableSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables_Partitions PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 18, 'Commit Tran', 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'COMMIT TRAN', 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION all
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 19, 'Begin Tran', 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN', 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT I.DatabaseName, I.SchemaName, I.ParentTableName, I.PrepTableIndexName, 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 20, 'ExchangeTablePartitioned_RenameExistingTableIndex', I.RenameExistingTableIndexSQL, 0, I.IndexSizeMB_Actual
		FROM DOI.vwPartitioning_Tables_PrepTables_Indexes I
		WHERE EXISTS (	SELECT 'True'
						FROM DOI.vwIndexes I2
						WHERE I.DatabaseName = I2.DatabaseName
							AND I.SchemaName = I2.SchemaName
							AND I.ParentTableName = I2.TableName
							AND I2.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT I.DatabaseName, I.SchemaName, I.ParentTableName, I.PrepTableIndexName, 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 21, 'ExchangeTablePartitioned_RenameNewPartitionedPrepTableIndex', I.RenameNewPartitionedPrepTableIndexSQL, 0, I.IndexSizeMB_Actual
		FROM DOI.vwPartitioning_Tables_PrepTables_Indexes I
		WHERE EXISTS (	SELECT 'True'
						FROM DOI.vwIndexes I2
						WHERE I.DatabaseName = I2.DatabaseName
							AND I.SchemaName = I2.SchemaName
							AND I.ParentTableName = I2.TableName
							AND I2.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PTC.DatabaseName, PTC.SchemaName, PTC.ParentTableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 22, 'ExchangeTablePartitioned_RenameExistingTableConstraints', PTC.RenameExistingTableConstraintSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables_Constraints PTC
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTC.DatabaseName 
							AND I.TableName = PTC.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PTC.DatabaseName, PTC.SchemaName, PTC.ParentTableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 23, 'ExchangeTablePartitioned_RenameNewTableConstraints', PTC.RenameNewPartitionedPrepTableConstraintSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables_Constraints PTC
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTC.DatabaseName 
							AND I.TableName = PTC.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PTS.DatabaseName, PTS.SchemaName, PTS.ParentTableName, PTS.StatisticsName, 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 24, 'ExchangeTablePartitioned_RenameExistingTableStatistic', PTS.RenameExistingTableStatisticsSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables_Statistics PTS
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTS.DatabaseName 
							AND I.TableName = PTS.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PTT.DatabaseName, PTT.SchemaName, PTT.TableName, PTT.TriggerName, 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 25, 'ExchangeTablePartitioned_DropTrigger', PTT.DropTriggerSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable_Triggers PTT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTT.DatabaseName 
							AND I.TableName = PTT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 26, 'ExchangeTablePartitioned_RenameExistingTable', PT.RenameExistingTableSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 27, 'ExchangeTablePartitioned_RenameNewTable', PT.RenameNewPartitionedPrepTableSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PTT.DatabaseName, PTT.SchemaName, PTT.TableName, PTT.TriggerName, 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 28, 'ExchangeTablePartitioned_CreateTrigger', PTT.CreateTriggerSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable_Triggers PTT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTT.DatabaseName 
							AND I.TableName = PTT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 29, 'ExchangeTablePartitioned_DropDataSynchTrigger', PT.DropDataSynchTriggerSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 30, 'ExchangeTablePartitioned_SynchDeletes', PT.SynchDeletesPrepTableSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 31, 'ExchangeTablePartitioned_SynchInserts', PT.SynchInsertsPrepTableSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL 
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 32, 'ExchangeTablePartitioned_SynchUpdates', PT.SynchUpdatesPrepTableSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL 
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 33, 'Commit Tran', 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'COMMIT TRAN', 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 34, 'ExchangeTablePartitioned_DropDataSynchTable', PT.DropDataSynchTableSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))							
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 35, 'ExchangeTablePartitioned_DropParentOldTableFKs', PT.DropParentOldTableFKSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))							
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 36, 'ExchangeTablePartitioned_DropRefOldTableFKs', PT.DropRefOldTableFKSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))							
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 37, 'ExchangeTablePartitioned_AddBackParentOldTableFKs', PT.AddBackParentTableFKSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))							
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 38, 'ExchangeTablePartitioned_AddBackRefOldTableFKs', PT.AddBackRefTableFKSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))							
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 39, 'ExchangeTablePartitioned_DeletePartitionStateMetadata', PT.DeletePartitionStateMetadataSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_NewPartitionedTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))							
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 40, 'ExchangeTablePartitioned_PostPartitioningDataValidation', PT.PostDataValidationMissingEventsSQL + '' + PT.PostDataValidationCompareByPartitionSQL, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))							
		/***************at this point, we call spQueue_RenameStatistics...find out what this does and how to put it in here..*/					
			
		UNION ALL
		SELECT PTS.DatabaseName, PTS.SchemaName, PTS.ParentTableName, PTS.StatisticsName, 'ExchangeTablePartitioned', 'ExchangeTablePartitioned', 41, 'ExchangeTablePartitioned_CreateMissingStatistic', PTS.CreateStatisticsStatement, 0, 0
		FROM DOI.vwPartitioning_Tables_PrepTables_Statistics PTS
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTS.DatabaseName 
							AND I.TableName = PTS.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTablePartitioned'))
		--ExchangeTableNonPartitioned (for updates to clustered and isPrimaryKey properties only)
		UNION ALL*/
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A' AS IndexName, 'ExchangeTableNonPartitioned' AS OriginalIndexUpdateType, 'ExchangeTableNonPartitioned' AS IndexUpdateType, 1 AS RowNum, 'ExchangeTableNonPartitioned_CreateNewTable' AS IndexOperation, PT.CreateNewTableSQL AS CurrentSQLToExecute, 0 AS PartitionNumber, 0 AS IndexSizeMB_Actual
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTC.DatabaseName, PTC.SchemaName, PTC.ParentTableName, PTC.NewTableConstraintName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 2, 'ExchangeTableNonPartitioned_CreateNewTableConstraints', PTC.CreateConstraintStatement, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable_Constraints PTC
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTC.DatabaseName 
							AND I.TableName = PTC.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 3, 'ExchangeTableNonPartitioned_CreateDataSynchTable', PT.CreateDataSynchTableSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 4, 'ExchangeTableNonPartitioned_CreateDataSynchTrigger', PT.CreateDataSynchTriggerSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 5, 'ExchangeTableNonPartitioned_CreateViewForBCP', PT.CreateViewForBCPSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 6, 'ExchangeTableNonPartitioned_LoadData', PT.BCPSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT I.DatabaseName, I.SchemaName, I.ParentTableName, I.NewTableIndexName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 7, 'ExchangeTableNonPartitioned_CreateNewTableIndexes', I.NewTableIndexCreateSQL, 0, I.IndexSizeMB_Actual
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable_Indexes I
		WHERE EXISTS (	SELECT 'True'
						FROM DOI.vwIndexes I2
						WHERE I.DatabaseName = I2.DatabaseName
							AND I.SchemaName = I2.SchemaName
							AND I.ParentTableName = I2.TableName
							AND I2.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTS.DatabaseName, PTS.SchemaName, PTS.ParentTableName, PTS.NewTableStatisticsName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 8, 'ExchangeTableNonPartitioned_CreateNewTableStatistics', PTS.CreateStatisticsStatement, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable_Statistics PTS
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTS.DatabaseName 
							AND I.TableName = PTS.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 9, 'ExchangeTableNonPartitioned_BeginTran', 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN', 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTI.DatabaseName, PTI.SchemaName, PTI.ParentTableName, PTI.NewTableIndexName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 10, 'ExchangeTableNonPartitioned_RenameExistingIndex', PTI.RenameExistingTableIndexSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable_Indexes PTI
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTI.DatabaseName 
							AND I.TableName = PTI.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTI.DatabaseName, PTI.SchemaName, PTI.ParentTableName, PTI.NewTableIndexName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 11, 'ExchangeTableNonPartitioned_RenameNewTableIndex', PTI.RenameNewTableIndexSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable_Indexes PTI
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTI.DatabaseName 
							AND I.TableName = PTI.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTS.DatabaseName, PTS.SchemaName, PTS.ParentTableName, PTS.NewTableStatisticsName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 12, 'ExchangeTableNonPartitioned_RenameExistingTableStatistic', PTS.RenameExistingTableStatisticsSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable_Statistics PTS
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTS.DatabaseName 
							AND I.TableName = PTS.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTS.DatabaseName, PTS.SchemaName, PTS.ParentTableName, PTS.NewTableStatisticsName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 13, 'ExchangeTableNonPartitioned_RenameNewTableStatistic', PTS.RenameNewTableStatisticsSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable_Statistics PTS
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTS.DatabaseName 
							AND I.TableName = PTS.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTC.DatabaseName, PTC.SchemaName, PTC.ParentTableName, PTC.NewTableConstraintName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 14, 'ExchangeTableNonPartitioned_RenameExistingTableConstraint', PTC.RenameExistingTableConstraintSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable_Constraints PTC
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTC.DatabaseName 
							AND I.TableName = PTC.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PTC.DatabaseName, PTC.SchemaName, PTC.ParentTableName, PTC.NewTableConstraintName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 15, 'ExchangeTableNonPartitioned_RenameNewTableConstraint', PTC.RenameNewTableConstraintSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable_Constraints PTC
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PTC.DatabaseName 
							AND I.TableName = PTC.ParentTableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT NTT.DatabaseName, NTT.SchemaName, NTT.TableName, NTT.TriggerName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 16, 'ExchangeTableNonPartitioned_DropTrigger', NTT.DropTriggerSQL, 0, 0
		FROM DOI.[vwExchangeTableNonPartitioned_Tables_NewTable_Triggers] NTT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = NTT.DatabaseName 
							AND I.TableName = NTT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 17, 'ExchangeTableNonPartitioned_RenameExistingTable', PT.RenameExistingTableSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 18, 'ExchangeTableNonPartitioned_RenameNewTable', PT.RenameNewTableSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT NTT.DatabaseName, NTT.SchemaName, NTT.TableName, NTT.TriggerName, 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 19, 'ExchangeTableNonPartitioned_CreateTrigger', NTT.CreateTriggerSQL, 0, 0
		FROM DOI.[vwExchangeTableNonPartitioned_Tables_NewTable_Triggers] NTT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = NTT.DatabaseName 
							AND I.TableName = NTT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 20, 'ExchangeTableNonPartitioned_CommitTran', 'COMMIT TRAN', 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL  --we need the data synch here!!
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 21, 'ExchangeTableNonPartitioned_DropDataSynchTrigger', PT.DropDataSynchTriggerSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
		WHERE EXISTS (  SELECT 'True' 
						FROM DOI.vwIndexes I 
						WHERE i.DatabaseName = PT.DatabaseName 
							AND I.TableName = PT.TableName 
							AND I.IndexUpdateType IN ('ExchangeTableNonPartitioned'))
		UNION ALL
		SELECT PT.DatabaseName, PT.SchemaName, PT.TableName, 'N/A', 'ExchangeTableNonPartitioned', 'ExchangeTableNonPartitioned', 22, 'ExchangeTableNonPartitioned_DropDataSynchTable', PT.DropDataSynchTableSQL, 0, 0
		FROM DOI.vwExchangeTableNonPartitioned_Tables_NewTable PT
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