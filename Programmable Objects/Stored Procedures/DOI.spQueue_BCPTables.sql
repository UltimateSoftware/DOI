-- <Migration ID="89f1a962-345e-44f3-96ac-fd745dd9f8c0" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

GO

IF OBJECT_ID('[DOI].[spQueue_BCPTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spQueue_BCPTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spQueue_BCPTables]
    @DatabaseName NVARCHAR(128),
	@SchemaName NVARCHAR(128),
	@TableName NVARCHAR(128),
	@BatchId UNIQUEIDENTIFIER


AS

/*
select newid()

	EXEC DOI.[spQueue_BCPTables]
        @DatabaseName = 'PaymentReporting',
		@SchemaName = 'dbo',
		@TableName = 'Pays',
		@BatchId = '63F397D3-824B-47C2-A8CF-CED62565D2A2'
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

    EXEC DOI.spRefreshMetadata_Run_All
		@DatabaseName = @DatabaseName

	DECLARE @CurrentDatabaseName						NVARCHAR(128),
			@CurrentSchemaName							NVARCHAR(128),
			@CurrentTableName							NVARCHAR(128),
			@CurrentParentIndexName						NVARCHAR(128),
			@CurrentPartitionColumn						NVARCHAR(128),
            @CurrentStatisticsName                      NVARCHAR(128),
			@CurrentTriggerName							NVARCHAR(128),
			@PrepTableName								NVARCHAR(128),
			@IndexName									NVARCHAR(128),
			@CreatePrepTableSQL							NVARCHAR(MAX) = '',
			@CreateDataSynchTriggerSQL					NVARCHAR(MAX) = '',
			@CreateFinalDataSynchTableSQL				NVARCHAR(MAX) = '',
			@CreateFinalDataSynchTriggerSQL				NVARCHAR(MAX) = '',
			@TurnOnDataSynchSQL							NVARCHAR(MAX) = '',
			@TurnOffDataSynchSQL						NVARCHAR(MAX) = '',
            @CreateBCPViewSQL                           NVARCHAR(MAX) = '',
			@BCPCmd										NVARCHAR(MAX) = '',
			@CreateIndexStatement						NVARCHAR(MAX) = '',
			@CreateConstraintStatement					NVARCHAR(MAX) = '',
			@NewStorage									NVARCHAR(128),
			@NewStorageType								NVARCHAR(128),
			@IsNewPartitionedPrepTable					BIT ,
			@CheckConstraintSQL							NVARCHAR(MAX) = '',
			@PartitionDataValidationSQL					NVARCHAR(MAX) = '',
			@FinalRepartitioningValidationSQL			NVARCHAR(MAX) = '',
			@PostPartitioningDataValidationSQL			NVARCHAR(MAX) = '',
			@RenameNewPartitionedPrepTableSQL			NVARCHAR(MAX) = '',
			@RenameExistingTableIndexSQL				NVARCHAR(MAX) = '',
			@RenameNewPartitionedPrepTableIndexSQL		NVARCHAR(MAX) = '',
			@RenameExistingTableSQL						NVARCHAR(MAX) = '',
			@RenameExistingTableConstraintSQL			NVARCHAR(MAX) = '',
   			@RenameExistingTableStatisticsSQL    		NVARCHAR(MAX) = '',
            @CreateMissingTableStatisticsSQL            NVARCHAR(MAX) = '',
			@RenameNewPartitionedPrepTableConstraintSQL	NVARCHAR(MAX) = '',
			@DropDataSynchTableSQL						NVARCHAR(MAX) = '',
			@DropDataSynchTriggerSQL					NVARCHAR(MAX) = '',
			@DropParentOldTableFKs						NVARCHAR(MAX) = '',
			@DropRefOldTableFKs							NVARCHAR(MAX) = '',
			@AddBackParentTableFKs						NVARCHAR(MAX) = '',
			@AddBackRefTableFKs							NVARCHAR(MAX) = '',
            @SwitchPartitionsSQL						NVARCHAR(MAX) = '',
			@DropTableSQL								NVARCHAR(MAX) = '',
			@DropTriggerSQL								NVARCHAR(MAX) = '',
			@CreateTriggerSQL							NVARCHAR(MAX) = '',
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
			FROM DOI.DOI.Log 
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
        DatabaseName                            SYSNAME,
		SchemaName                              SYSNAME,
		ParentTableName                         SYSNAME,
		IndexName                               SYSNAME,
		ParentIndexName                         SYSNAME,
		CreateIndexStatement                    NVARCHAR(MAX),
		RenameExistingTableIndexSQL             NVARCHAR(MAX),
		RenameNewPartitionedPrepTableIndexSQL   NVARCHAR(MAX),
		RowNum                                  BIGINT,
		PrepTableName                           SYSNAME,
		IndexSizeInMB                           INT
		PRIMARY KEY CLUSTERED (DatabaseName, SchemaName, PrepTableName, IndexName)) 
        --this clust index is too large a row size.  if it's a problem, change columns to varchar?


	INSERT INTO #Indexes ( DatabaseName, SchemaName ,ParentTableName ,IndexName , ParentIndexName, CreateIndexStatement ,RenameExistingTableIndexSQL ,RenameNewPartitionedPrepTableIndexSQL ,RowNum ,PrepTableName, IndexSizeInMB )		
	SELECT	PTI.DatabaseName,
            PTI.SchemaName,
			PTI.ParentTableName,
			PTI.PrepTableIndexName, 
			PTI.ParentIndexName,
			PTI.PrepTableIndexCreateSQL,
			PTI.RenameExistingTableIndexSQL,
			PTI.RenameNewPartitionedPrepTableIndexSQL,
			PTI.RowNum,
			PTI.PrepTableName,
			PTI.IndexSizeMB_Actual
	FROM  DOI.vwPartitioning_Tables_PrepTables_Indexes PTI
	WHERE PTI.DatabaseName = @DatabaseName
		AND PTI.SchemaName = @SchemaName
		AND PTI.ParentTableName = @TableName
								
	DECLARE PrepTable_Cur CURSOR LOCAL FAST_FORWARD FOR
		SELECT	PT.DatabaseName,
                PT.SchemaName, 
				PT.TableName,
				PT.PartitionColumn,
				PT.PrepTableName,
				PT.CreatePrepTableSQL,
				NPT.CreateDataSynchTriggerSQL,
				NPT.CreateFinalDataSynchTableSQL,
				NPT.CreateFinalDataSynchTriggerSQL,
				PT.TurnOnDataSynchSQL,
				PT.TurnOffDataSynchSQL,
                PT.CreateViewForBCPSQL,
				PT.BCPSQL,
				PT.Storage_Desired,
				PT.StorageType_Desired,
				PT.IsNewPartitionedPrepTable,
				PT.NewPartitionedPrepTableName,
				PT.CheckConstraintSQL,
				NPT.RenameNewPartitionedPrepTableSQL,
				NPT.RenameExistingTableSQL,
				NPT.DropDataSynchTriggerSQL,
				NPT.DropDataSynchTableSQL,
				NPT.SynchDeletesPrepTableSQL,
				NPT.SynchInsertsPrepTableSQL,
				NPT.SynchUpdatesPrepTableSQL,
				NPT.FinalRepartitioningValidationSQL,
                NPT.DeletePartitionStateMetadataSQL,
				PT.PostDataValidationMissingEventsSQL + '' + PT.PostDataValidationCompareByPartitionSQL
		FROM DOI.vwTables TTP
			INNER JOIN DOI.vwPartitioning_Tables_PrepTables PT ON PT.DatabaseName = TTP.DatabaseName
				AND PT.SchemaName = TTP.SchemaName
				AND PT.TableName = TTP.TableName
			INNER JOIN DOI.vwPartitioning_Tables_NewPartitionedTable NPT ON TTP.DatabaseName = NPT.DatabaseName
				AND TTP.SchemaName = NPT.SchemaName
				AND TTP.TableName = NPT.TableName
		WHERE TTP.IntendToPartition = 1
			AND PT.PrepTableName IS NOT NULL
			AND TTP.IsStorageChanging = 1
			AND TTP.DatabaseName = @DatabaseName
			AND TTP.SchemaName = @SchemaName
			AND TTP.TableName = @TableName
		ORDER BY PT.IsNewPartitionedPrepTable, PT.PartitionNumber
	
	OPEN PrepTable_Cur

	FETCH NEXT FROM PrepTable_Cur INTO @CurrentDatabaseName, @CurrentSchemaName, @CurrentTableName, @CurrentPartitionColumn, @PrepTableName, @CreatePrepTableSQL, @CreateDataSynchTriggerSQL, @CreateFinalDataSynchTableSQL, @CreateFinalDataSynchTriggerSQL, @TurnOnDataSynchSQL, @TurnOffDataSynchSQL, @CreateBCPViewSQL, @BCPCmd, @NewStorage, @NewStorageType, @IsNewPartitionedPrepTable, @NewPartitionedPrepTableName, @CheckConstraintSQL, @RenameNewPartitionedPrepTableSQL, @RenameExistingTableSQL, @DropDataSynchTriggerSQL, @DropDataSynchTableSQL, @SynchDeletesSQL, @SynchInsertsSQL, @SynchUpdatesSQL, @FinalRepartitioningValidationSQL, @DeletePartitionStateMetadataSQL, @PostPartitioningDataValidationSQL

	IF @@FETCH_STATUS NOT IN (-1, -2)
	BEGIN
		EXEC DOI.spQueue_Insert
            @CurrentDatabaseName            = @CurrentDatabaseName,
			@CurrentSchemaName				= @CurrentSchemaName,
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
			EXEC DOI.spQueue_Insert
                @CurrentDatabaseName            = @CurrentDatabaseName,
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
				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

            	EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
					@CurrentSchemaName				= @CurrentSchemaName ,
					@CurrentTableName				= @PrepTableName, 
					@CurrentIndexName				= 'N/A',
					@CurrentPartitionNumber			= 1,
					@IndexSizeInMB					= 0,
					@CurrentParentSchemaName		= @CurrentSchemaName,
					@CurrentParentTableName			= @CurrentTableName,
					@CurrentParentIndexName			= 'N/A',
					@IndexOperation					= 'Create BCP View', 
					@IsOnlineOperation				= 1,
					@SQLStatement					= @CreateBCPViewSQL,
					@TransactionId					= @TransactionId,
					@BatchId						= @BatchId,
					@ExitTableLoopOnError			= 1

            	EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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
					EXEC DOI.spQueue_Insert
                        @CurrentDatabaseName            = @CurrentDatabaseName,
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
				SELECT	PTC.CreateConstraintStatement, RowNum
				FROM  DOI.vwPartitioning_Tables_PrepTables_Constraints PTC
				WHERE PTC.DatabaseName = @CurrentDatabaseName
					AND PTC.SchemaName = @CurrentSchemaName
					AND PTC.ParentTableName = @CurrentTableName
					AND PTC.PrepTableName = @PrepTableName

			OPEN CreateAllConstraints_Cur

			FETCH NEXT FROM CreateAllConstraints_Cur INTO @CreateConstraintStatement, @TableChildOperationId

			WHILE @@FETCH_STATUS <> -1
			BEGIN
				IF @@FETCH_STATUS <> -2
				BEGIN
					EXEC DOI.spQueue_Insert
                        @CurrentDatabaseName            = @CurrentDatabaseName,
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
				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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
					
				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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
					FROM DOI.vwPartitioning_Tables_PrepTables_Partitions
					WHERE DatabaseName = @CurrentDatabaseName
						AND SchemaName = @CurrentSchemaName
						AND ParentTableName = @CurrentTableName
					ORDER BY PartitionNumber ASC
				OPEN Partitions_Cur

				FETCH NEXT FROM Partitions_Cur INTO @NewPartitionedPrepTableName, @UnPartitionedPrepTableName, @PartitionDataValidationSQL, @SwitchPartitionsSQL, @DropTableSQL, @TableChildOperationId

				WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @@FETCH_STATUS <> -2
					BEGIN
						EXEC DOI.spQueue_Insert
                            @CurrentDatabaseName            = @CurrentDatabaseName,
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

					--we are no longer doing the 2 validations PostDataValidationMissingEventsSQL and PostDataValidationCompareByPartitionSQL...why?

					FETCH NEXT FROM Partitions_Cur INTO @NewPartitionedPrepTableName, @UnPartitionedPrepTableName, @PartitionDataValidationSQL, @SwitchPartitionsSQL, @DropTableSQL, @TableChildOperationId
				END

				CLOSE Partitions_Cur

				OPEN Partitions_Cur

				FETCH NEXT FROM Partitions_Cur INTO @NewPartitionedPrepTableName, @UnPartitionedPrepTableName, @PartitionDataValidationSQL, @SwitchPartitionsSQL, @DropTableSQL, @TableChildOperationId

				--do partition switches, in a transaction
				SET @TransactionId = NEWID()

				IF @NewPartitionedPrepTableName IS NOT NULL
                BEGIN
                	EXEC DOI.spQueue_Insert
                        @CurrentDatabaseName            = @CurrentDatabaseName,
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
						EXEC DOI.spQueue_Insert
                            @CurrentDatabaseName            = @CurrentDatabaseName,
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

						EXEC DOI.spQueue_Insert
                            @CurrentDatabaseName            = @CurrentDatabaseName,
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

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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
				--EXEC DOI.spQueue_Insert
    --                @CurrentDatabaseName            = @CurrentDatabaseName,
				--	@CurrentSchemaName				= @CurrentSchemaName ,
				--	@CurrentTableName				= @NewPartitionedPrepTableName, 
				--	@CurrentIndexName				= 'N/A', 
				--	@CurrentPartitionNumber			= 0, 
				--	@IndexSizeInMB					= 0,
				--	@CurrentParentSchemaName		= @CurrentSchemaName,
				--	@CurrentParentTableName			= @CurrentTableName,
				--	@CurrentParentIndexName			= 'N/A',
				--	@IndexOperation					= 'FinalValidation',
				--	@IsOnlineOperation				= 1,
				--	@SQLStatement					= @FinalRepartitioningValidationSQL,
				--	@TransactionId					= @TransactionId,
				--	@BatchId						= @BatchId,
				--	@ExitTableLoopOnError			= 1
				--THIS IS COMMENTED OUT FOR NOW...DETERMINE WHETHER OR NOT WE WILL PUT BACK..  WE CAN PROBABLY PUT BACK A RELAXED VERSION OF THIS WHICH ALLOWS NEW STRUCTURE ELEMENTS
				--BUT DOES NOT ALLOW DELETED ELEMENTS...SOMETHING LIKE THAT?

				--rename tables, in a transaction
				SET @TransactionId = NEWID()

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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
							EXEC DOI.spQueue_Insert
                                @CurrentDatabaseName            = @CurrentDatabaseName,
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

						EXEC DOI.spQueue_Insert
                            @CurrentDatabaseName            = @CurrentDatabaseName,
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
					SELECT	PTC.RenameExistingTableConstraintSQL,
							PTC.RenameNewPartitionedPrepTableConstraintSQL,
							PTC.RowNum
					FROM  DOI.vwPartitioning_Tables_PrepTables_Constraints PTC
					WHERE PTC.DatabaseName = @DatabaseName
						AND PTC.SchemaName = @CurrentSchemaName
						AND PTC.ParentTableName = @CurrentTableName
						AND PTC.PrepTableName = @PrepTableName

				OPEN RenameAllConstraints_Cur

				FETCH NEXT FROM RenameAllConstraints_Cur INTO @RenameExistingTableConstraintSQL, @RenameNewPartitionedPrepTableConstraintSQL, @TableChildOperationId

				WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @@FETCH_STATUS <> -2
					BEGIN
						EXEC DOI.spQueue_Insert
                            @CurrentDatabaseName            = @CurrentDatabaseName,
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

						EXEC DOI.spQueue_Insert
                            @CurrentDatabaseName            = @CurrentDatabaseName,
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

                --rename statistics from _OLD table
				DECLARE RenameAllStatistics_Cur CURSOR LOCAL FAST_FORWARD for
					SELECT	S.StatisticsName,
                            S.RenameExistingTableStatisticsSQL,
							S.RowNum
					FROM  DOI.vwPartitioning_Tables_PrepTables_Statistics S
					WHERE S.DatabaseName = @CurrentDatabaseName
						AND S.SchemaName = @CurrentSchemaName
						AND S.ParentTableName = @CurrentTableName

				OPEN RenameAllStatistics_Cur

				FETCH NEXT FROM RenameAllStatistics_Cur INTO @CurrentStatisticsName, @RenameExistingTableStatisticsSQL, @TableChildOperationId

				WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @@FETCH_STATUS <> -2
					BEGIN
						EXEC DOI.spQueue_Insert
                            @CurrentDatabaseName            = @CurrentDatabaseName,
							@CurrentSchemaName				= @CurrentSchemaName ,
							@CurrentTableName				= @CurrentTableName, 
							@CurrentIndexName				= @CurrentStatisticsName, 
							@CurrentPartitionNumber			= 1, 
							@IndexSizeInMB					= 0,
							@CurrentParentSchemaName		= @CurrentSchemaName,
							@CurrentParentTableName			= @CurrentTableName,
							@CurrentParentIndexName			= 'N/A',
							@IndexOperation					= 'Rename Existing Statistic',
							@IsOnlineOperation				= 1,
							@TableChildOperationId			= @TableChildOperationId,
							@SQLStatement					= @RenameExistingTableStatisticsSQL,
							@TransactionId					= @TransactionId,
							@BatchId						= @BatchId,
							@ExitTableLoopOnError			= 1
					END

					FETCH NEXT FROM RenameAllStatistics_Cur INTO @CurrentStatisticsName, @RenameExistingTableStatisticsSQL, @TableChildOperationId
				END

				CLOSE RenameAllStatistics_Cur
				DEALLOCATE RenameAllStatistics_Cur

				--before existing table rename, drop all triggers on it.
				DECLARE DropAllTriggers_Cur CURSOR LOCAL FAST_FORWARD for
					SELECT	TR.TriggerName,
                            TR.DropTriggerSQL,
							TR.RowNum
					FROM  DOI.vwPartitioning_Tables_NewPartitionedTable_Triggers TR
					WHERE TR.DatabaseName = @CurrentDatabaseName
						AND TR.SchemaName = @CurrentSchemaName
						AND TR.TableName = @CurrentTableName

				OPEN DropAllTriggers_Cur

				FETCH NEXT FROM DropAllTriggers_Cur INTO @CurrentTriggerName, @DropTriggerSQL, @TableChildOperationId

				WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @@FETCH_STATUS <> -2
					BEGIN
						EXEC DOI.spQueue_Insert
                            @CurrentDatabaseName            = @CurrentDatabaseName,
							@CurrentSchemaName				= @CurrentSchemaName ,
							@CurrentTableName				= @CurrentTableName, 
							@CurrentIndexName				= 'N/A', 
							@CurrentPartitionNumber			= 1, 
							@IndexSizeInMB					= 0,
							@CurrentParentSchemaName		= @CurrentSchemaName,
							@CurrentParentTableName			= @CurrentTableName,
							@CurrentParentIndexName			= 'N/A',
							@IndexOperation					= 'Drop Trigger',
							@IsOnlineOperation				= 1,
							@TableChildOperationId			= @TableChildOperationId,
							@SQLStatement					= @DropTriggerSQL,
							@TransactionId					= @TransactionId,
							@BatchId						= @BatchId,
							@ExitTableLoopOnError			= 1
					END

					FETCH NEXT FROM DropAllTriggers_Cur INTO @CurrentTriggerName, @DropTriggerSQL, @TableChildOperationId
				END

				CLOSE DropAllTriggers_Cur
				DEALLOCATE DropAllTriggers_Cur

                --rename tables

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

				--after new table rename, create all triggers on it
                DECLARE RecreateAllTriggers_Cur CURSOR LOCAL FAST_FORWARD for
					SELECT	TR.TriggerName,
                            TR.CreateTriggerSQL,
							TR.RowNum
					FROM  DOI.vwPartitioning_Tables_NewPartitionedTable_Triggers TR
					WHERE TR.DatabaseName = @CurrentDatabaseName
						AND TR.SchemaName = @CurrentSchemaName
						AND TR.TableName = @CurrentTableName

				OPEN RecreateAllTriggers_Cur

				FETCH NEXT FROM RecreateAllTriggers_Cur INTO @CurrentTriggerName, @CreateTriggerSQL, @TableChildOperationId

				WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @@FETCH_STATUS <> -2
					BEGIN
						EXEC DOI.spQueue_Insert
                            @CurrentDatabaseName            = @CurrentDatabaseName,
							@CurrentSchemaName				= @CurrentSchemaName ,
							@CurrentTableName				= @CurrentTableName, 
							@CurrentIndexName				= 'N/A', 
							@CurrentPartitionNumber			= 1, 
							@IndexSizeInMB					= 0,
							@CurrentParentSchemaName		= @CurrentSchemaName,
							@CurrentParentTableName			= @CurrentTableName,
							@CurrentParentIndexName			= 'N/A',
							@IndexOperation					= 'Create Trigger',
							@IsOnlineOperation				= 1,
							@TableChildOperationId			= @TableChildOperationId,
							@SQLStatement					= @CreateTriggerSQL,
							@TransactionId					= @TransactionId,
							@BatchId						= @BatchId,
							@ExitTableLoopOnError			= 1
					END

					FETCH NEXT FROM RecreateAllTriggers_Cur INTO @CurrentTriggerName, @CreateTriggerSQL, @TableChildOperationId
				END

				CLOSE RecreateAllTriggers_Cur
				DEALLOCATE RecreateAllTriggers_Cur

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

				--data synch
				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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
					
				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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
				--AT THIS POINT, WE HAVE ALREADY RENAMED, SO NO MORE ERRORS SHOULD EXIT THE LOOP.

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

                --rename all statistics, before we check for any missing....
                EXEC DOI.spQueue_RenameStatistics 
					@DatabaseName = @CurrentDatabaseName,
                    @SchemaName = @CurrentSchemaName,
                    @TableName = @CurrentTableName

                --create any missing stats on the newly renamed table
				DECLARE CreateMissingStatistics_Cur CURSOR LOCAL FAST_FORWARD for
					SELECT	s.StatisticsName,
                            s.CreateStatisticsSQL,
                            ROW_NUMBER() OVER(ORDER BY S.StatisticsName) AS RowNum
					FROM  DOI.vwStatistics S
					WHERE s.DatabaseName = @CurrentDatabaseName
						AND s.SchemaName = @CurrentSchemaName
						AND s.TableName = @CurrentTableName

				OPEN CreateMissingStatistics_Cur

				FETCH NEXT FROM CreateMissingStatistics_Cur INTO @CurrentStatisticsName, @CreateMissingTableStatisticsSQL, @TableChildOperationId

				WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @@FETCH_STATUS <> -2
					BEGIN
						EXEC DOI.spQueue_Insert
                            @CurrentDatabaseName            = @CurrentDatabaseName,
							@CurrentSchemaName				= @CurrentSchemaName ,
							@CurrentTableName				= @CurrentTableName, 
							@CurrentIndexName				= @CurrentStatisticsName, 
							@CurrentPartitionNumber			= 1, 
							@IndexSizeInMB					= 0,
							@CurrentParentSchemaName		= @CurrentSchemaName,
							@CurrentParentTableName			= @CurrentTableName,
							@CurrentParentIndexName			= 'N/A',
							@IndexOperation					= 'Create Missing Table Statistic',
							@IsOnlineOperation				= 1,
							@TableChildOperationId			= @TableChildOperationId,
							@SQLStatement					= @CreateMissingTableStatisticsSQL,
							@TransactionId					= @TransactionId,
							@BatchId						= @BatchId,
							@ExitTableLoopOnError			= 1
					END

					FETCH NEXT FROM CreateMissingStatistics_Cur INTO @CurrentStatisticsName, @CreateMissingTableStatisticsSQL, @TableChildOperationId
				END

				CLOSE CreateMissingStatistics_Cur
				DEALLOCATE CreateMissingStatistics_Cur

				SET @DropParentOldTableFKs = '
EXEC DOI.DOI.spForeignKeysDrop
	@DatabaseName = ''' + @DatabaseName + ''',
	@ParentSchemaName = ''' + @CurrentSchemaName + ''',
	@ParentTableName = ''' + @CurrentTableName + ''''
				
				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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
EXEC DOI.DOI.spForeignKeysDrop
	@DatabaseName = ''' + @DatabaseName + ''',
	@ReferencedSchemaName = ''' + @CurrentSchemaName + ''',
	@ReferencedTableName = ''' + @CurrentTableName + ''''

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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
EXEC DOI.DOI.spForeignKeysAdd
	@DatabaseName = ''' + @DatabaseName + ''',
	@ParentSchemaName = ''' + @CurrentSchemaName + ''',
	@ParentTableName = ''' + @CurrentTableName + ''''
				
				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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
EXEC DOI.DOI.spForeignKeysAdd
	@DatabaseName = ''' + @DatabaseName + ''',
	@ReferencedSchemaName = ''' + @CurrentSchemaName + ''',
	@ReferencedTableName = ''' + @CurrentTableName + ''''

				EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

                EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
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

				
                EXEC DOI.spQueue_Insert
                    @CurrentDatabaseName            = @CurrentDatabaseName,
		            @CurrentSchemaName				= @SchemaName,
		            @CurrentTableName				= @TableName, 
		            @CurrentIndexName				= 'N/A',
		            @CurrentPartitionNumber			= 0,  
		            @IndexSizeInMB					= 0,
		            @CurrentParentSchemaName		= @SchemaName,
		            @CurrentParentTableName			= @TableName, 
		            @CurrentParentIndexName			= 'N/A',
		            @IndexOperation					= 'Post Partitioning Data Validation',
		            @IsOnlineOperation				= 1,
		            @TableChildOperationId			= 0,
		            @SQLStatement					= @PostPartitioningDataValidationSQL, 
		            @TransactionId					= @TransactionId,
		            @BatchId						= @BatchId,
		            @ExitTableLoopOnError			= 0
			END --if @IsNewPartitionedTable = 1
		END --IF @@FETCH_STATUS <> -2
		FETCH NEXT FROM PrepTable_Cur INTO @CurrentDatabaseName, @CurrentSchemaName, @CurrentTableName, @CurrentPartitionColumn, @PrepTableName, @CreatePrepTableSQL, @CreateDataSynchTriggerSQL, @CreateFinalDataSynchTableSQL, @CreateFinalDataSynchTriggerSQL, @TurnOnDataSynchSQL, @TurnOffDataSynchSQL, @CreateBCPViewSQL, @BCPCmd, @NewStorage, @NewStorageType, @IsNewPartitionedPrepTable, @NewPartitionedPrepTableName, @CheckConstraintSQL, @RenameNewPartitionedPrepTableSQL, @RenameExistingTableSQL, @DropDataSynchTriggerSQL, @DropDataSynchTableSQL, @SynchDeletesSQL, @SynchInsertsSQL, @SynchUpdatesSQL, @FinalRepartitioningValidationSQL, @DeletePartitionStateMetadataSQL, @PostPartitioningDataValidationSQL
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
    IF (SELECT CURSOR_STATUS('local','RenameAllStatistics_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','RenameAllStatistics_Cur')) > -1
		BEGIN
			CLOSE RenameAllStatistics_Cur
		END

		DEALLOCATE RenameAllStatistics_Cur
	END;

	IF (SELECT CURSOR_STATUS('local','CreateMissingStatistics_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','CreateMissingStatistics_Cur')) > -1
		BEGIN
			CLOSE CreateMissingStatistics_Cur
		END

		DEALLOCATE CreateMissingStatistics_Cur
	END;
    IF (SELECT CURSOR_STATUS('local','DropAllTriggers_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','DropAllTriggers_Cur')) > -1
		BEGIN
			CLOSE DropAllTriggers_Cur
		END

		DEALLOCATE DropAllTriggers_Cur
	END;

	IF (SELECT CURSOR_STATUS('local','RecreateAllTriggers_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','RecreateAllTriggers_Cur')) > -1
		BEGIN
			CLOSE RecreateAllTriggers_Cur
		END

		DEALLOCATE RecreateAllTriggers_Cur
	END;    
	THROW;
END CATCH

GO