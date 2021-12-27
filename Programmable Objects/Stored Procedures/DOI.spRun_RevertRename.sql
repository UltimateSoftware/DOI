-- <Migration ID="c40d94a4-92bc-49f1-b6a6-df206c5848f1" />
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

GO

IF OBJECT_ID('[DOI].[spRun_RevertRename]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRun_RevertRename];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRun_RevertRename]
    @DatabaseName SYSNAME,
	@SchemaName SYSNAME,
	@TableName SYSNAME,
	@Debug		BIT = 0

AS

/*
	EXEC DOI.spRun_RevertRename
		@SchemaName = 'dbo',
		@TableName = 'Pays',
		@Debug = 1
*/

--get all the rename revert SQLs, insert into queue, and then run them.
DECLARE @BatchId UNIQUEIDENTIFIER = NEWID(),
		@TransactionId UNIQUEIDENTIFIER = NEWID(),
		@CurrentObjectName NVARCHAR(128),
		@ObjectType VARCHAR(20),
		@TableChildOperationId INT,
		@SQLStatement NVARCHAR(MAX) = '',
		@IndexOperation NVARCHAR(60),
		@ErrorMessage NVARCHAR(MAX),
		@RowCount INT

BEGIN TRY
    EXEC ('
	IF NOT EXISTS(SELECT ''True'' FROM ' + @DatabaseName + '.sys.tables WHERE name = ''' + @TableName + '_OLD'')
	BEGIN
		RAISERROR(''There is nothing to revert.  Either the Revert has already run, or nothing has been partitioned.'', 16, 1)
	END')
    
	DECLARE Revert_Cur CURSOR LOCAL FAST_FORWARD FOR
		SELECT  X.DatabaseName,
                X.ObjectName,
				X.SQLStatement,
				X.ObjectType,
				ROW_NUMBER() OVER (ORDER BY X.SortId) AS RowNum
		FROM (
				SELECT	DatabaseName,
                        TableName AS ObjectName,
						RevertRenameNewPartitionedPrepTableSQL AS SQLStatement, 
						'Table' AS ObjectType,
						1 AS SortId
				FROM DOI.vwPartitioning_Tables_NewPartitionedTable
				WHERE SchemaName = @SchemaName
					AND TableName = @TableName
				UNION ALL 
				SELECT	DatabaseName,
                        PrepTableIndexName,
						RevertRenameNewPartitionedPrepTableIndexSQL,
						'Index',
						2
				FROM DOI.vwPartitioning_Tables_PrepTables_Indexes
				WHERE SchemaName = @SchemaName
					AND ParentTableName = @TableName
					AND IsNewPartitionedTable = 1
				UNION ALL
				SELECT	DatabaseName,
                        ConstraintName,
						RevertRenameNewPartitionedPrepTableConstraintSQL,
						'Constraint',
						3
				FROM DOI.vwPartitioning_Tables_PrepTables_Constraints
				WHERE SchemaName = @SchemaName
					AND ParentTableName = @TableName
					AND IsNewPartitionedTable = 1
				UNION ALL
				SELECT	DatabaseName,
                        StatisticsName,
						RevertRenameNewPartitionedPrepTableStatisticsSQL,
						'Statistics',
						4
				FROM DOI.vwPartitioning_Tables_PrepTables_Statistics
				WHERE SchemaName = @SchemaName
					AND ParentTableName = @TableName
				UNION ALL
				SELECT	DatabaseName,
                        TriggerName,
						DropTriggerSQL,
						'Drop Trigger',
						5
				FROM DOI.vwPartitioning_Tables_NewPartitionedTable_Triggers
				WHERE SchemaName = @SchemaName
					AND TableName = @TableName
				UNION ALL
				SELECT	DatabaseName,
                        TableName,
						RevertRenameExistingTableSQL,
						'Table',
						6
				FROM DOI.vwPartitioning_Tables_NewPartitionedTable
				WHERE SchemaName = @SchemaName
					AND TableName = @TableName
				UNION ALL
				SELECT	DatabaseName,
                        TriggerName,
						CreateTriggerSQL,
						'Create Trigger',
						7
				FROM DOI.vwPartitioning_Tables_NewPartitionedTable_Triggers
				WHERE SchemaName = @SchemaName
					AND TableName = @TableName
				UNION ALL 
				SELECT	DatabaseName,
                        PrepTableIndexName,
						RevertRenameExistingTableIndexSQL,
						'Index' AS ObjectType,
						8
				FROM DOI.vwPartitioning_Tables_PrepTables_Indexes
				WHERE SchemaName = @SchemaName
					AND ParentTableName = @TableName
					AND IsNewPartitionedTable = 1
				UNION ALL
				SELECT	DatabaseName,
                        ConstraintName,
						RevertRenameExistingTableConstraintSQL,
						'Constraint',
						9
				FROM DOI.vwPartitioning_Tables_PrepTables_Constraints
				WHERE SchemaName = @SchemaName
					AND ParentTableName = @TableName
					AND IsNewPartitionedTable = 1
                UNION ALL
				SELECT	DatabaseName,
                        StatisticsName,
						RevertRenameExistingTableStatisticsSQL,
						'Statistics',
						10
				FROM DOI.vwPartitioning_Tables_PrepTables_Statistics
				WHERE SchemaName = @SchemaName
					AND ParentTableName = @TableName
)x
		ORDER BY x.SortId ASC


	OPEN Revert_Cur

	IF (@SchemaName + '.' + @TableName) IS NOT NULL 
	BEGIN 
		EXEC DOI.spQueue_Insert 
            @CurrentDatabaseName            = @DatabaseName,
			@CurrentSchemaName				= @SchemaName , 
			@CurrentTableName				= @TableName ,  
			@CurrentIndexName				= 'N/A' , 
			@CurrentPartitionNumber			= 0, 
			@IndexSizeInMB					= 0,
			@CurrentParentSchemaName		= @SchemaName ,
			@CurrentParentTableName			= @TableName ,
			@CurrentParentIndexName			= 'N/A' ,
			@IndexOperation					= 'Begin Tran',
			@TableChildOperationId			= 0 ,
			@SQLStatement					= 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN' ,
			--@RunAutomaticallyOnDeployment	= 0 ,
			--@RunAutomaticallyOnSQLJob		= 1 ,
			@TransactionId					= @TransactionId ,
			@BatchId						= @BatchId ,
			@ExitTableLoopOnError			= 1
	END
    
	FETCH NEXT FROM Revert_Cur INTO @DatabaseName, @CurrentObjectName, @SQLStatement, @ObjectType, @TableChildOperationId
		WHILE @@FETCH_STATUS <> -1
		BEGIN
			IF @@FETCH_STATUS <> -2
			BEGIN
				BEGIN TRY
					SET @IndexOperation = @ObjectType + ' Revert Rename'

					EXEC DOI.spQueue_Insert 
                        @CurrentDatabaseName            = @DatabaseName,
						@CurrentSchemaName				= @SchemaName , 
						@CurrentTableName				= @TableName ,  
						@CurrentIndexName				= @CurrentObjectName , 
						@CurrentPartitionNumber			= 0, 
						@IndexSizeInMB					= 0,
						@CurrentParentSchemaName		= @SchemaName ,
						@CurrentParentTableName			= @TableName ,
						@CurrentParentIndexName			= 'N/A' ,
						@IndexOperation					= @IndexOperation,
						@TableChildOperationId			= @TableChildOperationId ,
						@SQLStatement					= @SQLStatement ,
						@TransactionId					= @TransactionId ,
						@BatchId						= @BatchId ,
						@ExitTableLoopOnError			= 1

				END TRY
				BEGIN CATCH
					IF @@TRANCOUNT > 0 
					BEGIN
						--ANY LOG ENTRIES DURING THE TRANSACTION ARE GOING TO BE LOST, SO PUT THEM INTO TABLE VAR TO GET AROUND THIS...
						DECLARE @Log DOI.LogTT

						INSERT INTO @Log (  LogID,
                                            DatabaseName,
                                            SchemaName ,
											TableName ,
											IndexName ,
	                                        PartitionNumber ,
	                                        IndexSizeInMB ,
											LoginName ,
											UserName ,
											LogDateTime ,
											SQLStatement ,
											IndexOperation ,
											[RowCount],
											TableChildOperationId ,
											RunStatus ,
											ErrorText ,
											TransactionId,
											BatchId,
											SeqNo,
											ExitTableLoopOnError )
						SELECT  LogID,
                                DatabaseName,
                                SchemaName ,
								TableName ,
								IndexName ,
	                            PartitionNumber ,
	                            IndexSizeInMB ,
								LoginName ,
								UserName ,
								LogDateTime ,
								SQLStatement ,
								IndexOperation ,
								[RowCount],
								TableChildOperationId ,
								RunStatus ,
								ErrorText ,
								TransactionId ,
								BatchId ,
								SeqNo ,
								ExitTableLoopOnError
						FROM   DOI.Log
						WHERE  TransactionId = @TransactionId;

						WITH LastLoggedRow
						AS (SELECT   TOP 1 *
							FROM     @Log
							ORDER BY LogDateTime DESC )

						UPDATE LastLoggedRow
						SET    LastLoggedRow.ErrorText = ERROR_MESSAGE();

						--AFTER SAVING THE LOG TRANSACTIONS, GO AHEAD AND ROLLBACK:
						ROLLBACK TRAN;
					END

					--NOW THAT WE HAVE ROLLED BACK, INSERT THE MISSING LOG ROWS FROM THE TABLE VAR.  THEY SHOULD STILL BE THERE DESPITE THE ROLLBACK.
					INSERT INTO DOI.Log (   LogID,
                                            DatabaseName,
                                            SchemaName ,
										    TableName ,
										    IndexName ,
	                                        PartitionNumber ,
	                                        IndexSizeInMB ,
										    LoginName ,
										    UserName ,
										    LogDateTime ,
										    SQLStatement ,
										    IndexOperation ,
										    [RowCount] ,
										    TableChildOperationId ,
										    RunStatus ,
										    ErrorText ,
										    TransactionId ,
										    BatchId ,
										    SeqNo ,
										    ExitTableLoopOnError )
					SELECT	LogID,
							DatabaseName,
							SchemaName ,
							TableName ,
							IndexName ,
							PartitionNumber ,
							IndexSizeInMB ,
							LoginName ,
							UserName ,
							LogDateTime ,
							SQLStatement ,
							IndexOperation ,
							[RowCount] ,
							TableChildOperationId ,
							RunStatus ,
							ErrorText ,
							TransactionId ,
							BatchId ,
							SeqNo ,
							ExitTableLoopOnError
					FROM   @Log T
					WHERE  NOT EXISTS ( SELECT 't'
										FROM   DOI.Log L
										WHERE  T.DatabaseName = L.DatabaseName
                                            AND T.SchemaName = L.SchemaName
											AND T.TableName = L.TableName
											AND T.IndexName = L.IndexName
											AND T.IndexOperation = L.IndexOperation
											AND T.RunStatus = L.RunStatus
											AND T.TableChildOperationId = L.TableChildOperationId );

					SET @ErrorMessage = ERROR_MESSAGE()

					UPDATE DOI.Queue
					SET ErrorMessage = @ErrorMessage,
						InProgress = 0
					WHERE DatabaseName = @DatabaseName
                        AND SchemaName = @SchemaName
						AND TableName = @TableName
						AND IndexName = @CurrentObjectName
						AND IndexOperation = @IndexOperation
						AND TableChildOperationId = @TableChildOperationId


					EXEC DOI.spRun_LogInsert 
                        @CurrentDatabaseName    = @DatabaseName,
						@CurrentSchemaName		= @SchemaName , 
						@CurrentTableName		= @TableName ,  
						@CurrentIndexName		= @CurrentObjectName ,
						@CurrentPartitionNumber = 0 ,
						@IndexSizeInMB			= 0,
						@IndexOperation			= @IndexOperation,
						@RowCount				= @RowCount,
						@SQLStatement			= @SQLStatement ,
						@ErrorText				= @ErrorMessage,
						@TransactionId			= @TransactionId,
						@TableChildOperationId	= 0,
						@BatchId				= @BatchId,
						@SeqNo					= 0,
						@RunStatus				= 'Error',
						@ExitTableLoopOnError	= 1;

					THROW;

				END CATCH

			FETCH NEXT FROM Revert_Cur INTO @DatabaseName, @CurrentObjectName, @SQLStatement, @ObjectType, @TableChildOperationId

			END
        
		END
    
		CLOSE Revert_Cur
		DEALLOCATE Revert_Cur

		EXEC DOI.spQueue_Insert 
            @CurrentDatabaseName            = @DatabaseName,
			@CurrentSchemaName				= @SchemaName , 
			@CurrentTableName				= @TableName ,  
			@CurrentIndexName				= 'N/A' ,
			@CurrentPartitionNumber			= 0, 
			@IndexSizeInMB					= 0,
			@CurrentParentSchemaName		= @SchemaName ,
			@CurrentParentTableName			= @TableName ,
			@CurrentParentIndexName			= 'N/A' ,
			@IndexOperation					= 'Commit Tran',
			@IsOnlineOperation				= 1 ,
			@TableChildOperationId			= 0 ,
			@SQLStatement					= 'COMMIT TRAN' ,
			@TransactionId					= @TransactionId ,
			@BatchId						= @BatchId ,
			@ExitTableLoopOnError			= 1

		DECLARE @DropParentOldTableFKs NVARCHAR(MAX),
				@DropRefOldTableFKs NVARCHAR(MAX),
				@AddBackParentTableFKs NVARCHAR(MAX),
				@AddBackRefTableFKs NVARCHAR(MAX)

		SET @DropParentOldTableFKs = '
EXEC DOI.DOI.spForeignKeysDrop
	@DatabaseName = ''' + @DatabaseName + ''',
	@ParentSchemaName = ''' + @SchemaName + ''',
	@ParentTableName = ''' + @TableName + ''''
				
		EXEC DOI.spQueue_Insert
            @CurrentDatabaseName            = @DatabaseName,
			@CurrentSchemaName				= @SchemaName ,
			@CurrentTableName				= @TableName, 
			@CurrentIndexName				= 'N/A', 
			@CurrentPartitionNumber			= 0, 
			@IndexSizeInMB					= 0, 
			@CurrentParentSchemaName		= @SchemaName,
			@CurrentParentTableName			= @TableName,
			@CurrentParentIndexName			= 'N/A',
			@IndexOperation					= 'Drop Parent Old Table FKs',
			@SQLStatement					= @DropParentOldTableFKs,
			@TransactionId					= @TransactionId,
			@BatchId						= @BatchId,
			@ExitTableLoopOnError			= 1

		SET @DropRefOldTableFKs = '
EXEC DOI.DOI.spForeignKeysDrop
	@DatabaseName = ''' + @DatabaseName + ''',
	@ReferencedSchemaName = ''' + @SchemaName + ''',
	@ReferencedTableName = ''' + @TableName + ''''

		EXEC DOI.spQueue_Insert
            @CurrentDatabaseName            = @DatabaseName,
			@CurrentSchemaName				= @SchemaName ,
			@CurrentTableName				= @TableName, 
			@CurrentIndexName				= 'N/A', 
			@CurrentPartitionNumber			= 0, 
			@IndexSizeInMB					= 0,
			@CurrentParentSchemaName		= @SchemaName,
			@CurrentParentTableName			= @TableName,
			@CurrentParentIndexName			= 'N/A',
			@IndexOperation					= 'Drop Ref Old Table FKs',
			@SQLStatement					= @DropRefOldTableFKs,
			@TransactionId					= @TransactionId,
			@BatchId						= @BatchId,
			@ExitTableLoopOnError			= 1

		SET @AddBackParentTableFKs = '
EXEC DOI.DOI.spForeignKeysAdd
	@DatabaseName = ''' + @DatabaseName + ''',
	@ParentSchemaName = ''' + @SchemaName + ''',
	@ParentTableName = ''' + @TableName + ''''
				
		EXEC DOI.spQueue_Insert
            @CurrentDatabaseName            = @DatabaseName,
			@CurrentSchemaName				= @SchemaName ,
			@CurrentTableName				= @TableName, 
			@CurrentIndexName				= 'N/A', 
			@CurrentPartitionNumber			= 0, 
			@IndexSizeInMB					= 0,
			@CurrentParentSchemaName		= @SchemaName,
			@CurrentParentTableName			= @TableName,
			@CurrentParentIndexName			= 'N/A',
			@IndexOperation					= 'Add back Parent Table FKs',
			@SQLStatement					= @AddBackParentTableFKs,
			@TransactionId					= @TransactionId,
			@BatchId						= @BatchId,
			@ExitTableLoopOnError			= 1

		SET @AddBackRefTableFKs = '
EXEC DOI.DOI.spForeignKeysAdd
	@DatabaseName = ''' + @DatabaseName + ''',
	@ReferencedSchemaName = ''' + @SchemaName + ''',
	@ReferencedTableName = ''' + @TableName + ''''

		EXEC DOI.spQueue_Insert
            @CurrentDatabaseName            = @DatabaseName,
			@CurrentSchemaName				= @SchemaName ,
			@CurrentTableName				= @TableName, 
			@CurrentIndexName				= 'N/A',
			@CurrentPartitionNumber			= 0, 
			@IndexSizeInMB					= 0, 
			@CurrentParentSchemaName		= @SchemaName,
			@CurrentParentTableName			= @TableName,
			@CurrentParentIndexName			= 'N/A',
			@IndexOperation					= 'Add back Ref Table FKs',
			@SQLStatement					= @AddBackRefTableFKs,
			@TransactionId					= @TransactionId,
			@BatchId						= @BatchId,
			@ExitTableLoopOnError			= 1

		--RUN REVERT
		EXEC DOI.spRun 
            @DatabaseName   = @DatabaseName,
			@SchemaName		= @SchemaName,
			@TableName		= @TableName,
			@BatchId		= @BatchId,
			@Debug			= @Debug

END TRY
BEGIN CATCH
	--CLOSE CURSORS IF OPEN
	IF (SELECT CURSOR_STATUS('local','Revert_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','Revert_Cur')) > -1
		BEGIN
			CLOSE Revert_Cur
		END

		DEALLOCATE Revert_Cur
	END;

	THROW;
END CATCH

GO