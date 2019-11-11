IF OBJECT_ID('[DDI].[spQueue_BCPTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spQueue_BCPTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spQueue_BCPTables]
	@SchemaName NVARCHAR(128),
	@TableName NVARCHAR(128),
	@BatchId UNIQUEIDENTIFIER


AS

/*
select newid()

	EXEC DDI.[spQueue_BCPTables]
		@SchemaName = 'dbo',
		@TableName = 'Pays',
		@BatchId = '63F397D3-824B-47C2-A8CF-CED62565D2A2'

		call from a job at off hours
		wait at low priority
		maxdop = 1
*/
SET NOCOUNT ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
SET QUOTED_IDENTIFIER ON

BEGIN TRY
	DECLARE @CurrentSchemaName							NVARCHAR(128),
			@CurrentTableName							NVARCHAR(128),
			@CurrentParentIndexName						NVARCHAR(128),
			@CurrentPartitionColumn						NVARCHAR(128),
			@PrepTableName								NVARCHAR(128),
			@IndexName									NVARCHAR(128),
			@CreatePrepTableSQL							NVARCHAR(MAX) = '',
			@CreateDataSynchTriggerSQL					NVARCHAR(MAX) = '',
			@CreateFinalDataSynchTableSQL				NVARCHAR(MAX) = '',
			@CreateFinalDataSynchTriggerSQL				NVARCHAR(MAX) = '',
			@TurnOnDataSynchSQL							NVARCHAR(MAX) = '',
			@TurnOffDataSynchSQL						NVARCHAR(MAX) = '',
			@BCPCmd										NVARCHAR(MAX) = '',
			@CreateIndexStatement						NVARCHAR(MAX) = '',
			@CreateConstraintStatement					NVARCHAR(MAX) = '',
			@NewStorage									NVARCHAR(128),
			@NewStorageType								NVARCHAR(128),
			@IsNewPartitionedPrepTable					BIT ,
			@CheckConstraintSQL							NVARCHAR(MAX) = '',
			@PartitionDataValidationSQL					NVARCHAR(MAX) = '',
			@FinalRepartitioningValidationSQL			NVARCHAR(MAX) = '',
			@RenameNewPartitionedPrepTableSQL			NVARCHAR(MAX) = '',
			@RenameExistingTableIndexSQL				NVARCHAR(MAX) = '',
			@RenameNewPartitionedPrepTableIndexSQL		NVARCHAR(MAX) = '',
			@RenameExistingTableSQL						NVARCHAR(MAX) = '',
			@RenameExistingTableConstraintSQL			NVARCHAR(MAX) = '',
			@RenameNewPartitionedPrepTableConstraintSQL	NVARCHAR(MAX) = '',
			@DropDataSynchTableSQL						NVARCHAR(MAX) = '',
			@DropDataSynchTriggerSQL					NVARCHAR(MAX) = '',
			@DropParentOldTableFKs						NVARCHAR(MAX) = '',
			@DropRefOldTableFKs							NVARCHAR(MAX) = '',
			@AddBackParentTableFKs						NVARCHAR(MAX) = '',
			@AddBackRefTableFKs							NVARCHAR(MAX) = '',
            @SwitchPartitionsSQL						NVARCHAR(MAX) = '',
			@DropTableSQL								NVARCHAR(MAX) = '',
			@NewPartitionedPrepTableName				SYSNAME,
			@UnPartitionedPrepTableName					SYSNAME,
			@TableChildOperationId						SMALLINT,
			@IndexSizeInMB								INT,
			@SynchDeletesSQL							NVARCHAR(MAX) = '',
			@SynchInsertsSQL							NVARCHAR(MAX) = '',
			@SynchUpdatesSQL							NVARCHAR(MAX) = '',
			@CRLF										CHAR(2) = CHAR(13) + CHAR(10),
			@TransactionId								UNIQUEIDENTIFIER = NULL,
            @DeletePartitionStateMetadataSQL            NVARCHAR(500) = '',
			@PriorErrorValidationSQL					NVARCHAR(MAX) = '
IF EXISTS(	SELECT ''True''
			FROM DDI.RefreshIndexStructuresLog 
			WHERE BatchId = ''' + CAST(@BatchId AS VARCHAR(40)) + '''
				AND TableName LIKE ''%' + @TableName + '%''
				AND ErrorText IS NOT NULL ) /*ONLY PROCEED IF NOTHING HAS FAILED IN THIS BATCH.*/
BEGIN
	RAISERROR(''At least 1 step failed in the BCP process.  Aborting partition switch and rename.'', 16, 1)  
END'

	DECLARE @EnableCmdShellSQL					NVARCHAR(MAX) = '
EXEC sp_configure ''allow updates'', 0
RECONFIGURE
EXEC sp_configure ''show advanced options'', 1
RECONFIGURE
EXEC sp_configure ''xp_cmdshell'', 1
RECONFIGURE
',
			@DisableCmdShellSQL					NVARCHAR(MAX) = '
EXEC sp_configure ''allow updates'', 0
RECONFIGURE
EXEC sp_configure ''show advanced options'', 1
RECONFIGURE
EXEC sp_configure ''xp_cmdshell'', 0
RECONFIGURE
'

	IF OBJECT_ID('tempdb..#Indexes') IS NOT NULL
    BEGIN
		DROP TABLE #Indexes
	END
    
	CREATE TABLE #Indexes (
		SchemaName SYSNAME,
		ParentTableName SYSNAME,
		IndexName SYSNAME,
		ParentIndexName SYSNAME,
		CreateIndexStatement NVARCHAR(MAX),
		RenameExistingTableIndexSQL NVARCHAR(MAX),
		RenameNewPartitionedPrepTableIndexSQL NVARCHAR(MAX),
		RowNum BIGINT,
		PrepTableName SYSNAME,
		IndexSizeInMB INT
		CONSTRAINT PK_Indexes
			PRIMARY KEY CLUSTERED (SchemaName, PrepTableName, IndexName))


	INSERT INTO #Indexes ( SchemaName ,ParentTableName ,IndexName , ParentIndexName, CreateIndexStatement ,RenameExistingTableIndexSQL ,RenameNewPartitionedPrepTableIndexSQL ,RowNum ,PrepTableName, IndexSizeInMB )		
	SELECT	FNIDX.SchemaName,
				FNIDX.ParentTableName,
				FNIDX.IndexName, 
				FNIDX.ParentIndexName,
				FNIDX.CreateIndexStatement,
				FNIDX.RenameExistingTableIndexSQL,
				FNIDX.RenameNewPartitionedPrepTableIndexSQL,
				FNIDX.RowNum,
				FNIDX.PrepTableName,
				FNIDX.IndexSizeMB
	FROM  DDI.fnDataDrivenIndexes_GetPrepTableIndexesSQL() FNIDX
	WHERE FNIDX.SchemaName = @SchemaName
		AND FNIDX.ParentTableName = @TableName
								
	DECLARE PrepTable_Cur CURSOR LOCAL FAST_FORWARD FOR
		SELECT	TTP.SchemaName, 
					TTP.TableName,
					TTP.PartitionColumn,
					FN.PrepTableName,
					FN.CreatePrepTableSQL,
					TTP.CreateDataSynchTriggerSQL,
					TTP.CreateFinalDataSynchTableSQL,
					TTP.CreateFinalDataSynchTriggerSQL,
					FN.TurnOnDataSynchSQL,
					TTP.TurnOffDataSynchSQL,
					FN.BCPSQL,
					FN.NewStorage,
					FN.NewStorageType,
					FN.IsNewPartitionedPrepTable,
					FN.NewPartitionedPrepTableName,
					FN.CheckConstraintSQL,
					FN.RenameNewPartitionedPrepTableSQL,
					FN.RenameExistingTableSQL,
					TTP.DropDataSynchTriggerSQL,
					TTP.DropDataSynchTableSQL,
					FN.SynchDeletesPrepTableSQL,
					FN.SynchInsertsPrepTableSQL,
					FN.SynchUpdatesPrepTableSQL,
					FN.FinalRepartitioningValidationSQL,
                    TTP.DeletePartitionStateMetadataSQL
			FROM DDI.vwTables TTP
				INNER JOIN DDI.fnDataDrivenIndexes_GetPrepTableSQL() FN ON FN.SchemaName = TTP.SchemaName
					AND FN.TableName = TTP.TableName
			WHERE TTP.UseBCPStrategy = 1
				AND FN.PrepTableName IS NOT NULL
				AND TTP.IsStorageChanging = 1
				AND TTP.SchemaName = @SchemaName
				AND TTP.TableName = @TableName
			ORDER BY FN.IsNewPartitionedPrepTable, FN.PartitionNumber
	
	OPEN PrepTable_Cur

	FETCH NEXT FROM PrepTable_Cur INTO @CurrentSchemaName, @CurrentTableName, @CurrentPartitionColumn, @PrepTableName, @CreatePrepTableSQL, @CreateDataSynchTriggerSQL, @CreateFinalDataSynchTableSQL, @CreateFinalDataSynchTriggerSQL, @TurnOnDataSynchSQL, @TurnOffDataSynchSQL, @BCPCmd, @NewStorage, @NewStorageType, @IsNewPartitionedPrepTable, @NewPartitionedPrepTableName, @CheckConstraintSQL, @RenameNewPartitionedPrepTableSQL, @RenameExistingTableSQL, @DropDataSynchTriggerSQL, @DropDataSynchTableSQL, @SynchDeletesSQL, @SynchInsertsSQL, @SynchUpdatesSQL, @FinalRepartitioningValidationSQL, @DeletePartitionStateMetadataSQL

	IF @@FETCH_STATUS NOT IN (-1, -2)
	BEGIN
		EXEC DDI.spRefreshIndexesQueueInsert
			@CurrentSchemaName				= @CurrentSchemaName ,
			@CurrentTableName				= @PrepTableName, 
			@CurrentIndexName				= 'N/A',
			@CurrentPartitionNumber			= 0,
			@IndexSizeInMB					= 0,
			@CurrentParentSchemaName		= @CurrentSchemaName,
			@CurrentParentTableName			= @CurrentTableName,
			@CurrentParentIndexName			= 'N/A',
			@IndexOperation					= 'Create Data Synch Trigger', 
			@IsOnlineOperation				= 1,
			@SQLStatement					= @CreateDataSynchTriggerSQL,
			@TransactionId					= @TransactionId,
			@BatchId						= @BatchId,
			@ExitTableLoopOnError			= 1
	END 

	WHILE @@FETCH_STATUS <> -1
	BEGIN
		IF @@FETCH_STATUS <> -2
		BEGIN
			EXEC DDI.spRefreshIndexesQueueInsert
				@CurrentSchemaName				= @CurrentSchemaName ,
                @CurrentTableName				= @PrepTableName, 
                @CurrentIndexName				= 'N/A',
				@CurrentPartitionNumber			= 1,
				@IndexSizeInMB					= 0,
				@CurrentParentSchemaName		= @CurrentSchemaName,
				@CurrentParentTableName			= @CurrentTableName,
				@CurrentParentIndexName			= 'N/A',
				@IndexOperation					= 'Prep Table SQL', 
				@IsOnlineOperation				= 1,
                @SQLStatement					= @CreatePrepTableSQL,
				@TransactionId					= @TransactionId,
				@BatchId						= @BatchId,
				@ExitTableLoopOnError			= 1

			IF @IsNewPartitionedPrepTable = 0
			BEGIN
				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName,
					@CurrentTableName				= @PrepTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 0,
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName, 
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Turn On DataSynch',
					@IsOnlineOperation				= 1,
					@TableChildOperationId			= 0,
					@SQLStatement					= @TurnOnDataSynchSQL, 
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName,
					@CurrentTableName				= @PrepTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 0,
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName, 
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Enable CmdShell',
					@IsOnlineOperation				= 1,
					@TableChildOperationId			= 0,
					@SQLStatement					= @EnableCmdShellSQL, 
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

            	EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @PrepTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 1,
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Loading Data', 
					@IsOnlineOperation				= 1,
					@SQLStatement					= @BCPCmd,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @PrepTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 1,
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Check Constraint SQL',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @CheckConstraintSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1
			END
			            
			--create all indexes
			DECLARE CreateAllIndexes_Cur CURSOR LOCAL FAST_FORWARD FOR
				SELECT	ParentIndexName,
						IndexName, 
						CreateIndexStatement,
						RowNum,
						IndexSizeInMB
				FROM  #Indexes
				WHERE PrepTableName = @PrepTableName

			OPEN CreateAllIndexes_Cur

			FETCH NEXT FROM CreateAllIndexes_Cur INTO @CurrentParentIndexName, @IndexName, @CreateIndexStatement, @TableChildOperationId, @IndexSizeInMB

			WHILE @@FETCH_STATUS <> -1
			BEGIN
				IF @@FETCH_STATUS <> -2
				BEGIN
					EXEC DDI.spRefreshIndexesQueueInsert
						@CurrentSchemaName				= @CurrentSchemaName ,
						@CurrentTableName				= @PrepTableName, 
						@CurrentIndexName				= @IndexName, 
						@CurrentPartitionNumber			= 1,
						@IndexSizeInMB					= @IndexSizeInMB,
						@CurrentParentSchemaName		= @CurrentSchemaName,
						@CurrentParentTableName			= @CurrentTableName,
						@CurrentParentIndexName			= @CurrentParentIndexName,
						@IndexOperation					= 'Create Index',
						@IsOnlineOperation				= 1,
						@SQLStatement					= @CreateIndexStatement,
						@TableChildOperationId			= @TableChildOperationId,
						@TransactionId					= @TransactionId,
						@BatchId						= @BatchId,
						@ExitTableLoopOnError			= 1
				END

				FETCH NEXT FROM CreateAllIndexes_Cur INTO @CurrentParentIndexName, @IndexName, @CreateIndexStatement, @TableChildOperationId, @IndexSizeInMB
			END

			CLOSE CreateAllIndexes_Cur
			DEALLOCATE CreateAllIndexes_Cur

			--create all Constraints
			DECLARE CreateAllConstraints_Cur CURSOR LOCAL FAST_FORWARD FOR
				SELECT	FNIDX.CreateConstraintStatement, RowNum
				FROM  DDI.fnDataDrivenIndexes_GetPrepTableConstraintsSQL() FNIDX
				WHERE FNIDX.SchemaName = @CurrentSchemaName
					AND FNIDX.ParentTableName = @CurrentTableName
					AND FNIDX.PrepTableName = @PrepTableName

			OPEN CreateAllConstraints_Cur

			FETCH NEXT FROM CreateAllConstraints_Cur INTO @CreateConstraintStatement, @TableChildOperationId

			WHILE @@FETCH_STATUS <> -1
			BEGIN
				IF @@FETCH_STATUS <> -2
				BEGIN
					EXEC DDI.spRefreshIndexesQueueInsert
						@CurrentSchemaName				= @CurrentSchemaName ,
						@CurrentTableName				= @PrepTableName, 
						@CurrentIndexName				= 'N/A',
						@CurrentPartitionNumber			= 0,
						@IndexSizeInMB					= 0, 
						@CurrentParentSchemaName		= @CurrentSchemaName,
						@CurrentParentTableName			= @CurrentTableName,
						@CurrentParentIndexName			= 'N/A',
						@IndexOperation					= 'Create Constraint',
						@IsOnlineOperation				= 1,
						@SQLStatement					= @CreateConstraintStatement,
						@TableChildOperationId			= @TableChildOperationId,
						@TransactionId					= @TransactionId,
						@BatchId						= @BatchId,
						@ExitTableLoopOnError			= 1
				END

				FETCH NEXT FROM CreateAllConstraints_Cur INTO @CreateConstraintStatement, @TableChildOperationId
			END

			CLOSE CreateAllConstraints_Cur
			DEALLOCATE CreateAllConstraints_Cur

			IF @IsNewPartitionedPrepTable = 1
            BEGIN
				--MAKE SURE NOTHING HAS ERRORED OUT UP UNTIL THIS POINT BEFORE CONTINUING....
				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @SchemaName ,
					@CurrentTableName				= @TableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 0,
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @SchemaName,
					@CurrentParentTableName			= @TableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Prior Error Validation SQL',
					@IsOnlineOperation				= 1,
					@TableChildOperationId			= 0,
					@SQLStatement					= @PriorErrorValidationSQL,
					@TransactionId					= NULL,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1 
					
				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @PrepTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 0,
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Create Final Data Synch Table', 
					@IsOnlineOperation				= 1,
					@SQLStatement					= @CreateFinalDataSynchTableSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @PrepTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 0,
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Create Final Data Synch Trigger', 
					@IsOnlineOperation				= 1,
					@SQLStatement					= @CreateFinalDataSynchTriggerSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 0,
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Turn Off DataSynch',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @TurnOffDataSynchSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

				DECLARE Partitions_Cur CURSOR LOCAL FAST_FORWARD FOR
					SELECT	NewPartitionedPrepTableName,
							UnPartitionedPrepTableName,
							PartitionDataValidationSQL,
							PartitionSwitchSQL,
							DropTableSQL,
							PartitionNumber
					FROM DDI.fnDataDrivenIndexes_GetPartitionSQL()
					WHERE SchemaName = @CurrentSchemaName
						AND ParentTableName = @CurrentTableName
					ORDER BY PartitionNumber ASC
				OPEN Partitions_Cur

				FETCH NEXT FROM Partitions_Cur INTO @NewPartitionedPrepTableName, @UnPartitionedPrepTableName, @PartitionDataValidationSQL, @SwitchPartitionsSQL, @DropTableSQL, @TableChildOperationId

				WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @@FETCH_STATUS <> -2
					BEGIN
						EXEC DDI.spRefreshIndexesQueueInsert
							@CurrentSchemaName				= @CurrentSchemaName ,
							@CurrentTableName				= @NewPartitionedPrepTableName, 
							@CurrentIndexName				= 'N/A', 
							@CurrentPartitionNumber			= @TableChildOperationId,
							@IndexSizeInMB					= 0,
							@CurrentParentSchemaName		= @CurrentSchemaName,
							@CurrentParentTableName			= @CurrentTableName,
							@CurrentParentIndexName			= 'N/A',
							@IndexOperation					= 'Partition Data Validation SQL',
							@IsOnlineOperation				= 1,
							@TableChildOperationId			= @TableChildOperationId,
							@SQLStatement					= @PartitionDataValidationSQL,
							@TransactionId					= @TransactionId,
							@BatchId						= @BatchId,
							@ExitTableLoopOnError			= 1                    
					END

					FETCH NEXT FROM Partitions_Cur INTO @NewPartitionedPrepTableName, @UnPartitionedPrepTableName, @PartitionDataValidationSQL, @SwitchPartitionsSQL, @DropTableSQL, @TableChildOperationId
				END

				CLOSE Partitions_Cur

				OPEN Partitions_Cur

				FETCH NEXT FROM Partitions_Cur INTO @NewPartitionedPrepTableName, @UnPartitionedPrepTableName, @PartitionDataValidationSQL, @SwitchPartitionsSQL, @DropTableSQL, @TableChildOperationId

				--do partition switches, in a transaction
				SET @TransactionId = NEWID()

				IF @NewPartitionedPrepTableName IS NOT NULL
                BEGIN
                	EXEC DDI.spRefreshIndexesQueueInsert
						@CurrentSchemaName				= @CurrentSchemaName ,
						@CurrentTableName				= @NewPartitionedPrepTableName, 
						@CurrentIndexName				= 'N/A', 
						@CurrentPartitionNumber			= 0, 
						@IndexSizeInMB					= 0,
						@CurrentParentSchemaName		= @CurrentSchemaName,
						@CurrentParentTableName			= @CurrentTableName,
						@CurrentParentIndexName			= 'N/A',
						@IndexOperation					= 'Begin Tran',
						@IsOnlineOperation				= 1,
						@TableChildOperationId				= 0,
						@SQLStatement					= 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE 
BEGIN TRAN',
						@TransactionId					= @TransactionId,
						@BatchId						= @BatchId,
						@ExitTableLoopOnError			= 1
				END
                
				WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @@FETCH_STATUS <> -2
					BEGIN
						EXEC DDI.spRefreshIndexesQueueInsert
							@CurrentSchemaName				= @CurrentSchemaName ,
							@CurrentTableName				= @NewPartitionedPrepTableName, 
							@CurrentIndexName				= 'N/A',
							@CurrentPartitionNumber			= @TableChildOperationId,  
							@IndexSizeInMB					= 0,
							@CurrentParentSchemaName		= @CurrentSchemaName,
							@CurrentParentTableName			= @CurrentTableName,
							@CurrentParentIndexName			= 'N/A',
							@IndexOperation					= 'Switch Partitions SQL',
							@IsOnlineOperation				= 1,
							@TableChildOperationId			= @TableChildOperationId,
							@SQLStatement					= @SwitchPartitionsSQL,
							@TransactionId					= @TransactionId,
							@BatchId						= @BatchId,
							@ExitTableLoopOnError			= 1

						EXEC DDI.spRefreshIndexesQueueInsert
							@CurrentSchemaName				= @CurrentSchemaName ,
							@CurrentTableName				= @UnPartitionedPrepTableName, 
							@CurrentIndexName				= 'N/A', 
							@CurrentPartitionNumber			= 0, 
							@IndexSizeInMB					= 0,
							@CurrentParentSchemaName		= @CurrentSchemaName,
							@CurrentParentTableName			= @CurrentTableName,
							@CurrentParentIndexName			= 'N/A',
							@IndexOperation					= 'Drop Table SQL',
							@IsOnlineOperation				= 1,
							@TableChildOperationId			= @TableChildOperationId,
							@SQLStatement					= @DropTableSQL,
							@TransactionId					= @TransactionId,
							@BatchId						= @BatchId,
							@ExitTableLoopOnError			= 1
					END

					FETCH NEXT FROM Partitions_Cur INTO @NewPartitionedPrepTableName, @UnPartitionedPrepTableName, @PartitionDataValidationSQL, @SwitchPartitionsSQL, @DropTableSQL, @TableChildOperationId
				END

				CLOSE Partitions_Cur
				DEALLOCATE Partitions_Cur

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @NewPartitionedPrepTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Commit Tran',
					@IsOnlineOperation				= 1,
					@TableChildOperationId				= 0,
					@SQLStatement					= 'COMMIT TRAN',
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

				SET @TransactionId = NULL 

				--validate if all has gone well:  do both tables exist, with the right structure, and are their rowcounts within a certain % of each other?
				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @NewPartitionedPrepTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'FinalValidation',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @FinalRepartitioningValidationSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

				--rename tables, in a transaction
				SET @TransactionId = NEWID()

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @NewPartitionedPrepTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Begin Tran',
					@IsOnlineOperation				= 1,
					@TableChildOperationId				= 1,
					@SQLStatement					= 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN',
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

				--Rename all indexes  
                DECLARE RenameAllIndexes_Cur CURSOR LOCAL FAST_FORWARD FOR
					SELECT	ParentIndexName,
							IndexName, 
							RenameExistingTableIndexSQL,
							RenameNewPartitionedPrepTableIndexSQL,
							RowNum
					FROM  #Indexes
					WHERE PrepTableName = @PrepTableName

				OPEN RenameAllIndexes_Cur

				FETCH NEXT FROM RenameAllIndexes_Cur INTO @CurrentParentIndexName, @IndexName, @RenameExistingTableIndexSQL, @RenameNewPartitionedPrepTableIndexSQL, @TableChildOperationId

				WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @@FETCH_STATUS <> -2
					BEGIN
						IF NULLIF(LTRIM(RTRIM(@RenameExistingTableIndexSQL)), '') IS NOT NULL --MISSING INDEXES WON'T EXIST IN THE 'EXISTING' TABLE.
                        BEGIN
							EXEC DDI.spRefreshIndexesQueueInsert
								@CurrentSchemaName				= @CurrentSchemaName ,
								@CurrentTableName				= @CurrentTableName, 
								@CurrentIndexName				= @IndexName, 
								@CurrentPartitionNumber			= 0,  
								@IndexSizeInMB					= 0,
								@CurrentParentSchemaName		= @CurrentSchemaName,
								@CurrentParentTableName			= @CurrentTableName,
								@CurrentParentIndexName			= @CurrentParentIndexName,
								@IndexOperation					= 'Rename Existing Table Index',
								@IsOnlineOperation				= 1,
								@TableChildOperationId			= @TableChildOperationId,
								@SQLStatement					= @RenameExistingTableIndexSQL,
								@TransactionId					= @TransactionId,
								@BatchId						= @BatchId,
								@ExitTableLoopOnError			= 1
						END

						EXEC DDI.spRefreshIndexesQueueInsert
							@CurrentSchemaName				= @CurrentSchemaName ,
							@CurrentTableName				= @PrepTableName, 
							@CurrentIndexName				= @IndexName, 
							@CurrentPartitionNumber			= 0, 
							@IndexSizeInMB					= 0,
							@CurrentParentSchemaName		= @CurrentSchemaName,
							@CurrentParentTableName			= @CurrentTableName,
							@CurrentParentIndexName			= @CurrentParentIndexName,
							@IndexOperation					= 'Rename New Partitioned Prep Table Index',
							@IsOnlineOperation				= 1,
							@TableChildOperationId			= @TableChildOperationId,
							@SQLStatement					= @RenameNewPartitionedPrepTableIndexSQL,
							@TransactionId					= @TransactionId,
							@BatchId						= @BatchId,
							@ExitTableLoopOnError			= 1
					END

					FETCH NEXT FROM RenameAllIndexes_Cur INTO @CurrentParentIndexName, @IndexName, @RenameExistingTableIndexSQL, @RenameNewPartitionedPrepTableIndexSQL, @TableChildOperationId
				END

				CLOSE RenameAllIndexes_Cur
				DEALLOCATE RenameAllIndexes_Cur

				--Rename all Constraints  
				DECLARE RenameAllConstraints_Cur CURSOR LOCAL FAST_FORWARD for
					SELECT	FNC.RenameExistingTableConstraintSQL,
							FNC.RenameNewPartitionedPrepTableConstraintSQL,
							FNC.RowNum
					FROM  DDI.fnDataDrivenIndexes_GetPrepTableConstraintsSQL() FNC
					WHERE FNC.SchemaName = @CurrentSchemaName
						AND FNC.ParentTableName = @CurrentTableName
						AND FNC.PrepTableName = @PrepTableName

				OPEN RenameAllConstraints_Cur

				FETCH NEXT FROM RenameAllConstraints_Cur INTO @RenameExistingTableConstraintSQL, @RenameNewPartitionedPrepTableConstraintSQL, @TableChildOperationId

				WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @@FETCH_STATUS <> -2
					BEGIN
						EXEC DDI.spRefreshIndexesQueueInsert
							@CurrentSchemaName				= @CurrentSchemaName ,
							@CurrentTableName				= @CurrentTableName, 
							@CurrentIndexName				= 'N/A', 
							@CurrentPartitionNumber			= 1, 
							@IndexSizeInMB					= 0,
							@CurrentParentSchemaName		= @CurrentSchemaName,
							@CurrentParentTableName			= @CurrentTableName,
							@CurrentParentIndexName			= 'N/A',
							@IndexOperation					= 'Rename Existing Table Constraint',
							@IsOnlineOperation				= 1,
							@TableChildOperationId			= @TableChildOperationId,
							@SQLStatement					= @RenameExistingTableConstraintSQL,
							@TransactionId					= @TransactionId,
							@BatchId						= @BatchId,
							@ExitTableLoopOnError			= 1

						EXEC DDI.spRefreshIndexesQueueInsert
							@CurrentSchemaName				= @CurrentSchemaName ,
							@CurrentTableName				= @PrepTableName, 
							@CurrentIndexName				= 'N/A', 
							@CurrentPartitionNumber			= 0, 
							@IndexSizeInMB					= 0,
							@CurrentParentSchemaName		= @CurrentSchemaName,
							@CurrentParentTableName			= @CurrentTableName,
							@CurrentParentIndexName			= 'N/A',
							@IndexOperation					= 'Rename New Partitioned Prep Table Constraint',
							@IsOnlineOperation				= 1,
							@TableChildOperationId			= @TableChildOperationId,
							@SQLStatement					= @RenameNewPartitionedPrepTableConstraintSQL,
							@TransactionId					= @TransactionId,
							@BatchId						= @BatchId,
							@ExitTableLoopOnError			= 1
					END

					FETCH NEXT FROM RenameAllConstraints_Cur INTO @RenameExistingTableConstraintSQL, @RenameNewPartitionedPrepTableConstraintSQL, @TableChildOperationId
				END

				CLOSE RenameAllConstraints_Cur
				DEALLOCATE RenameAllConstraints_Cur

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 1, 
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Rename Existing Table',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @RenameExistingTableSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @NewPartitionedPrepTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Rename New Partitioned Prep Table',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @RenameNewPartitionedPrepTableSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1
                
				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0, 
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Commit Tran',
					@IsOnlineOperation				= 1,
					@TableChildOperationId			= 1,
					@SQLStatement					= 'COMMIT TRAN',
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

				SET @TransactionId = NULL 
				--data synch
				--AT THIS POINT, WE HAVE ALREADY RENAMED, SO NO MORE ERRORS SHOULD EXIT THE LOOP.

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 0,  
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Synch Deletes',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @SynchDeletesSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 0

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0, 
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Synch Inserts',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @SynchInsertsSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 0

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0, 
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Synch Updates',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @SynchUpdatesSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 0

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0, 
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Drop Data Synch Trigger',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @DropDataSynchTriggerSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 0

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0, 
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Drop Data Synch Table',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @DropDataSynchTableSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 0

				SET @DropParentOldTableFKs = '
EXEC DDI.spForeignKeysDrop
	@ParentSchemaName = ''' + @CurrentSchemaName + ''',
	@ParentTableName = ''' + @CurrentTableName + ''''
				
				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0, 
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Drop Parent Old Table FKs',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @DropParentOldTableFKs,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 0

				SET @DropRefOldTableFKs = '
EXEC DDI.spForeignKeysDrop
	@ReferencedSchemaName = ''' + @CurrentSchemaName + ''',
	@ReferencedTableName = ''' + @CurrentTableName + ''''

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Drop Ref Old Table FKs',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @DropRefOldTableFKs,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 0

				SET @AddBackParentTableFKs = '
EXEC DDI.spForeignKeysAdd
	@ParentSchemaName = ''' + @CurrentSchemaName + ''',
	@ParentTableName = ''' + @CurrentTableName + ''''
				
				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A', 
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Add back Parent Table FKs',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @AddBackParentTableFKs,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 0

				SET @AddBackRefTableFKs = '
EXEC DDI.spForeignKeysAdd
	@ReferencedSchemaName = ''' + @CurrentSchemaName + ''',
	@ReferencedTableName = ''' + @CurrentTableName + ''''

				EXEC DDI.spRefreshIndexesQueueInsert
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @CurrentTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 0, 
					@IndexSizeInMB					= 0, 
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Add back Ref Table FKs',
					@IsOnlineOperation				= 1,
					@SQLStatement					= @AddBackRefTableFKs,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 0

                EXEC DDI.spRefreshIndexesQueueInsert
		            @CurrentSchemaName				= @SchemaName,
		            @CurrentTableName				= @TableName, 
		            @CurrentIndexName				= 'N/A',
		            @CurrentPartitionNumber			= 0,  
		            @IndexSizeInMB					= 0,
		            @CurrentParentSchemaName		= @SchemaName,
		            @CurrentParentTableName			= @TableName, 
		            @CurrentParentIndexName			= 'N/A',
		            @IndexOperation					= 'Delete PartitionState Metadata',
		            @IsOnlineOperation				= 1,
		            @TableChildOperationId			= 0,
		            @SQLStatement					= @DeletePartitionStateMetadataSQL, 
		            @TransactionId					= @TransactionId,
		            @BatchId						= @BatchId,
		            @ExitTableLoopOnError			= 0
			END --if @IsNewPartitionedTable = 1
		END --IF @@FETCH_STATUS <> -2
		FETCH NEXT FROM PrepTable_Cur INTO @CurrentSchemaName, @CurrentTableName, @CurrentPartitionColumn, @PrepTableName, @CreatePrepTableSQL, @CreateDataSynchTriggerSQL, @CreateFinalDataSynchTableSQL, @CreateFinalDataSynchTriggerSQL, @TurnOnDataSynchSQL, @TurnOffDataSynchSQL, @BCPCmd, @NewStorage, @NewStorageType, @IsNewPartitionedPrepTable, @NewPartitionedPrepTableName, @CheckConstraintSQL, @RenameNewPartitionedPrepTableSQL, @RenameExistingTableSQL, @DropDataSynchTriggerSQL, @DropDataSynchTableSQL, @SynchDeletesSQL, @SynchInsertsSQL, @SynchUpdatesSQL, @FinalRepartitioningValidationSQL, @DeletePartitionStateMetadataSQL
	END  --IF @@FETCH_STATUS <> -1

	CLOSE PrepTable_Cur
	DEALLOCATE PrepTable_Cur

END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRAN;

	/*CLOSE CURSORS IF THEY ARE STILL OPEN*/
	IF (SELECT CURSOR_STATUS('local','PrepTable_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','PrepTable_Cur')) > -1
		BEGIN
			CLOSE PrepTable_Cur
		END

		DEALLOCATE PrepTable_Cur
	END;

	IF (SELECT CURSOR_STATUS('local','CreateAllIndexes_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','CreateAllIndexes_Cur')) > -1
		BEGIN
			CLOSE CreateAllIndexes_Cur
		END

		DEALLOCATE CreateAllIndexes_Cur
	END;

	IF (SELECT CURSOR_STATUS('local','CreateAllConstraints_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','CreateAllConstraints_Cur')) > -1
		BEGIN
			CLOSE CreateAllConstraints_Cur
		END

		DEALLOCATE CreateAllConstraints_Cur
	END;
	
	IF (SELECT CURSOR_STATUS('local','Partitions_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','Partitions_Cur')) > -1
		BEGIN
			CLOSE SwitchPartitions_Cur
		END

		DEALLOCATE SwitchPartitions_Cur
	END;

	IF (SELECT CURSOR_STATUS('local','RenameAllIndexes_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','RenameAllIndexes_Cur')) > -1
		BEGIN
			CLOSE RenameAllIndexes_Cur
		END

		DEALLOCATE RenameAllIndexes_Cur
	END;

	IF (SELECT CURSOR_STATUS('local','RenameAllConstraints_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','RenameAllConstraints_Cur')) > -1
		BEGIN
			CLOSE RenameAllConstraints_Cur
		END

		DEALLOCATE RenameAllConstraints_Cur
	END;

	THROW;
END CATCH

GO
