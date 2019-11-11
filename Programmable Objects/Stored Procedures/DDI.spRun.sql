IF OBJECT_ID('[DDI].[spRun]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRun];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRun]
	@OnlineOperations BIT,
	@SchemaName NVARCHAR(128) = NULL,
	@TableName NVARCHAR(128)  = NULL,
	@BatchId UNIQUEIDENTIFIER = NULL,
	@Debug BIT = 0

AS

/*
	EXEC DDI.spRun
		@SchemaName = 'dbo',
		@TableName = 'Liabilities'

DESIGN PRINCIPLES:
1. Do one table at a time.  That way, if we have to kill the job because we're out of time then we can leave it in a consistent state.
2. If a clustered index is going to be updated, drop all the NC indexes first so they don't get rebuilt twice.  
3. Otherwise, drop & recreate indexes one at a time so you don't do any indexes that don't need updates
4. Do the bigger indexes first, then work your way down the list.
5. 
*/
SET NOCOUNT ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
SET QUOTED_IDENTIFIER ON
SET DEADLOCK_PRIORITY 10 --the highest priority

DECLARE @ApplicationRunningThisProcess NVARCHAR(128) = (SELECT program_name
														FROM SYS.dm_exec_sessions 
														WHERE session_id = @@SPID)--,

IF @ApplicationRunningThisProcess <> 'Microsoft SQL Server Management Studio - Query' --SSMS IS REALLY SLOW WITH THE BELOW OPTIONS ON.
BEGIN
	SET STATISTICS PROFILE ON
	SET STATISTICS XML ON
END
ELSE
BEGIN
	SET STATISTICS PROFILE OFF
	SET STATISTICS XML OFF
END

BEGIN TRY
	DECLARE @RGWorkloadGroupName SYSNAME,
			@RGResourcePoolName SYSNAME,
			@LoginName SYSNAME,
			@ProgramName SYSNAME,
			@RGSettings VARCHAR(1000),
			@ExitTableLoopOnError BIT

	SELECT  @ProgramName = [program_name],
			@LoginName = SDES.login_name,
			@RGWorkloadGroupName = SDRGWG.[Name],
			@RGResourcePoolName = DRGRP.[name]
	FROM sys.dm_exec_sessions SDES 
		INNER JOIN sys.dm_resource_governor_workload_groups SDRGWG ON SDES.group_id = SDRGWG.group_id
		INNER JOIN sys.dm_resource_governor_resource_pools DRGRP ON SDRGWG.pool_id = DRGRP.pool_id
	WHERE SDES.session_id = @@SPID

	SET @RGSettings = '
	Resource Governor Settings:  
		Resource Pool Name:  ' + @RGResourcePoolName + ', 
		Workload Group Name:  ' + @RGWorkloadGroupName + ', 
		Login Name:  ' + @LoginName + ',
		Program Name:  ' + @ProgramName + '.'

	DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10)

	DECLARE @CurrentDatabaseName			NVARCHAR(128),
			@CurrentSchemaName				NVARCHAR(128),
			@CurrentTableName				NVARCHAR(128) ,
			@CurrentIndexName				NVARCHAR(128) ,
			@CurrentPartitionNumber			SMALLINT ,
			@CurrentParentSchemaName		NVARCHAR(128) ,
			@CurrentParentTableName			NVARCHAR(128) ,
			@CurrentDateTime				DATETIME2,
			@SwitchAGToAsyncSQL				VARCHAR(MAX) = '',
			@SwitchAGBackToSyncSQL			VARCHAR(MAX) = '',
			@RC								INT,
			@ErrorMessage					NVARCHAR(4000),
			@CurrentSQLStatement			NVARCHAR(MAX) = '',
			@CurrentSeqNo					SMALLINT = 0,
			@CurrentIndexOperation			VARCHAR(50),
			@CurrentTableChildOperationId	SMALLINT,
			@RunStatus						VARCHAR(20),
			@TransactionId					UNIQUEIDENTIFIER = NULL,
			@IndexSizeInMB					INT,
			@RetryCount						TINYINT = 0,
			@ExitRetryLoopOnError				BIT = 0,
			@RowCount						INT = 0,
			@ParamList						NVARCHAR(500) = '@RowCountOUT INT OUTPUT'

	SELECT @SwitchAGToAsyncSQL += 'ALTER AVAILABILITY GROUP [' + AGS.name + '] MODIFY REPLICA ON ''' + replica_server_name + ''' WITH (AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT)' + char(13) + char(10)
	FROM sys.availability_groups AGS 
		INNER JOIN sys.availability_replicas AR ON AR.group_id = AGS.group_id 
		INNER JOIN sys.availability_databases_cluster ADC ON AR.group_id = ADC.group_id
	WHERE @@SERVERNAME <> replica_server_name

	SELECT @SwitchAGBackToSyncSQL += 'ALTER AVAILABILITY GROUP [' + AGS.name + '] MODIFY REPLICA ON ''' + replica_server_name + ''' WITH (AVAILABILITY_MODE = SYNCHRONOUS_COMMIT)' + char(13) + char(10)
	FROM sys.availability_groups AGS 
		INNER JOIN sys.availability_replicas AR ON AR.group_id = AGS.group_id 
		INNER JOIN sys.availability_databases_cluster ADC ON AR.group_id = ADC.group_id
	WHERE @@SERVERNAME <> replica_server_name

    /************************************** TABLE LOOP (BEGIN) ********************************************/
	DECLARE Tables_Run_Cur CURSOR GLOBAL DYNAMIC FOR
		SELECT	DatabaseName,
                SchemaName, 
				TableName,
				ParentSchemaName,
				ParentTableName,
				SeqNo,
				FN.TransactionId,
				IndexName,
				FN.PartitionNumber,
				SQLStatement,
				FN.RunStatus,
				FN.IndexOperation,
				FN.TableChildOperationId,
				FN.BatchId,
				FN.ExitTableLoopOnError,
				FN.IndexSizeInMB
		FROM DDI.Queue FN
		WHERE FN.IsOnlineOperation = @OnlineOperations
			AND FN.ParentSchemaName = CASE WHEN @SchemaName IS NULL THEN FN.ParentSchemaName ELSE @SchemaName END 
			AND FN.ParentTableName = CASE WHEN @TableName IS NULL THEN FN.ParentTableName ELSE @TableName END 
			AND FN.BatchId = CASE WHEN @BatchId IS NULL THEN FN.BatchId ELSE @BatchId END 
		ORDER BY FN.ParentSchemaName ASC, FN.ParentTableName ASC, FN.SeqNo ASC
					
	OPEN Tables_Run_Cur

	FETCH NEXT FROM Tables_Run_Cur INTO @CurrentDatabaseName, @CurrentSchemaName, @CurrentTableName, @CurrentParentSchemaName, @CurrentParentTableName, @CurrentSeqNo, @TransactionId, @CurrentIndexName, @CurrentPartitionNumber, @CurrentSQLStatement, @RunStatus, @CurrentIndexOperation, @CurrentTableChildOperationId, @BatchId, @ExitTableLoopOnError, @IndexSizeInMB

	IF (@CurrentSchemaName + '.' + @CurrentTableName) IS NOT NULL
	BEGIN 
		EXEC DDI.spRun_LogInsert
            @CurrentDatabaseName        = @CurrentDatabaseName 
			,@CurrentSchemaName			= 'N/A'  
			,@CurrentTableName			= 'N/A'
			,@CurrentIndexName			= 'N/A'
			,@CurrentPartitionNumber	= 0
			,@IndexSizeInMB				= 0
			,@SQLStatement				= @RGSettings
			,@IndexOperation			= 'Resource Governor Settings'
			,@IsOnlineOperation			= @OnlineOperations
			,@RowCount					= 0
			,@TransactionId				= NULL 
			,@TableChildOperationId		= 0
			,@BatchId					= @BatchId
			,@SeqNo						= 0
			,@ExitTableLoopOnError		= 0
			,@RunStatus					= 'Start'
	END
    
	IF (@ProgramName LIKE N'SQLAgent - TSQL JobStep%' AND @RGWorkloadGroupName <> 'IndexMaintenanceGroup')
        OR ((SELECT is_enabled FROM sys.resource_governor_configuration) = 0)
	BEGIN
		SET @ExitTableLoopOnError = 1
		RAISERROR('Resource Governor is not turned on.  Aborting.', 16, 1)	
	END

	WHILE @@FETCH_STATUS <> -1
	BEGIN
		IF @@FETCH_STATUS <> -2
		BEGIN
			SET @ExitRetryLoopOnError = 0
            SET @ErrorMessage = NULL 

            /************************** RETRY LOOP (BEGIN) ****************************************************/
			WHILE @RetryCount <= 3 AND @ExitRetryLoopOnError = 0
			BEGIN
				BEGIN TRY
					IF @Debug = 1
					BEGIN
						SELECT	@CurrentDatabaseName,
                                @CurrentSchemaName, 
								@CurrentTableName, 
								@CurrentParentSchemaName, 
								@CurrentParentTableName, 
								@CurrentSeqNo, 
								@TransactionId, 
								@CurrentIndexName, 
								@CurrentSQLStatement, 
								@RunStatus, 
								@CurrentIndexOperation, 
								@CurrentTableChildOperationId, 
								@BatchId, 
								@ExitTableLoopOnError,
								@IndexSizeInMB
					END
					ELSE
					BEGIN 
						SET @CurrentDateTime = SYSDATETIME()

						--LOG START
						EXEC DDI.spRun_LogInsert 
                            @CurrentDatabaseName    = @CurrentDatabaseName
							,@CurrentSchemaName		= @CurrentSchemaName  
							,@CurrentTableName		= @CurrentTableName   
							,@CurrentIndexName		= @CurrentIndexName 
							,@CurrentPartitionNumber= @CurrentPartitionNumber
							,@IndexSizeInMB			= @IndexSizeInMB
							,@SQLStatement			= @CurrentSQLStatement
							,@IndexOperation		= @CurrentIndexOperation
							,@IsOnlineOperation		= @OnlineOperations
							,@RowCount				= @RowCount
							,@TransactionId			= @TransactionId 
							,@TableChildOperationId	= @CurrentTableChildOperationId
							,@BatchId				= @BatchId
							,@SeqNo					= @CurrentSeqNo
							,@ExitTableLoopOnError	= @ExitTableLoopOnError
							,@RunStatus				= 'Start'

						--UPDATE TO IN-PROGRESS
						UPDATE DDI.Queue
						SET InProgress = 1
						WHERE DatabaseName = @CurrentDatabaseName
                            AND SchemaName = @CurrentSchemaName
							AND TableName = @CurrentTableName
							AND IndexName = @CurrentIndexName
							AND IndexOperation = @CurrentIndexOperation
							AND TableChildOperationId = @CurrentTableChildOperationId

						--RUN SQL, UNLESS IT'S A BEGIN OR COMMIT TRAN.  RUN THOSE OUTSIDE THE DYNAMIC SQL OR THEY CAUSE ERRORS.
						IF @CurrentSQLStatement LIKE '%SERIALIZABLE%BEGIN TRAN%' 
						BEGIN
							SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

							BEGIN TRAN
						END
						ELSE
						IF @CurrentSQLStatement = 'COMMIT TRAN' 
						BEGIN
							COMMIT TRAN
						END
						ELSE
						IF @CurrentIndexOperation IN ('Synch Deletes', 'Synch Inserts', 'Synch Updates',  'Loading Data')
						BEGIN
							EXEC sys.sp_executesql 
								@CurrentSQLStatement, 
								@ParamList, 
								@RowCountOUT = @RowCount OUTPUT 
								
							--extract rowcount parameter and store it in variable, for use in logging.
						END
                        ELSE 
						BEGIN						
							EXEC (@CurrentSQLStatement)
						END

						--LOG FINISH
						EXEC DDI.spRun_LogInsert 
                            @CurrentDatabaseName    = @CurrentDatabaseName
							,@CurrentSchemaName		= @CurrentSchemaName  
							,@CurrentTableName		= @CurrentTableName   
							,@CurrentIndexName		= @CurrentIndexName  
							,@CurrentPartitionNumber= @CurrentPartitionNumber
							,@IndexSizeInMB			= @IndexSizeInMB
							,@SQLStatement			= @CurrentSQLStatement
							,@IndexOperation		= @CurrentIndexOperation
							,@IsOnlineOperation		= @OnlineOperations 
							,@RowCount				= @RowCount
							,@TransactionId			= @TransactionId 
							,@TableChildOperationId	= @CurrentTableChildOperationId
							,@BatchId				= @BatchId
							,@SeqNo					= @CurrentSeqNo
							,@ExitTableLoopOnError	= @ExitTableLoopOnError
							,@RunStatus				= 'Finish'

						SET @RowCount = 0

						--DELETE FROM QUEUE
						DELETE DDI.Queue
						WHERE DatabaseName = @CurrentDatabaseName
                            AND SchemaName = @CurrentSchemaName   
							AND TableName = @CurrentTableName   
							AND IndexName = @CurrentIndexName 
							AND IndexOperation = @CurrentIndexOperation
							AND TableChildOperationId = @CurrentTableChildOperationId

					END 

					SET @ExitRetryLoopOnError = 1 --EXIT THE RETRY LOOP IF SUCCESSFUL.
				END TRY
				BEGIN CATCH
                    SET @ErrorMessage = ERROR_MESSAGE()

					IF ERROR_NUMBER() IN (  1204, -- SqlOutOfLocks
											1205, -- SqlDeadlockVictim
											1222 -- SqlLockRequestTimeout
											)
						AND @RetryCount < 3
					BEGIN
						SET @CurrentIndexName = ISNULL(@CurrentIndexName, '')

						EXEC DDI.spRun_LogInsert 
                            @CurrentDatabaseName    = @CurrentDatabaseName,
							@CurrentSchemaName		= @CurrentSchemaName , 
							@CurrentTableName		= @CurrentTableName ,  
							@CurrentIndexName		= @CurrentIndexName , 
							@CurrentPartitionNumber = @CurrentPartitionNumber, 
							@IndexSizeInMB			= @IndexSizeInMB ,
							@IndexOperation			= @CurrentIndexOperation,
							@IsOnlineOperation		= @OnlineOperations ,
							@RowCount				= @RowCount,
							@SQLStatement			= @CurrentSQLStatement ,
							@ErrorText				= @ErrorMessage,
							@TransactionId			= @TransactionId,
							@TableChildOperationId	= 0,
							@BatchId				= @BatchId,
							@SeqNo					= @CurrentSeqNo,
							@RunStatus				= 'Error - Retrying...',
							@ExitTableLoopOnError	= @ExitTableLoopOnError

						SET @RetryCount = @RetryCount + 1  

						WAITFOR DELAY '00:00:02'  
					END 
					ELSE IF @ErrorMessage LIKE 'NOT ENOUGH FREE SPACE%'
                    BEGIN
                        SET @CurrentIndexName = ISNULL(@CurrentIndexName, '')

						EXEC DDI.spRun_LogInsert 
                            @CurrentDatabaseName    = @CurrentDatabaseName,
							@CurrentSchemaName		= @CurrentSchemaName , 
							@CurrentTableName		= @CurrentTableName ,  
							@CurrentIndexName		= @CurrentIndexName , 
							@CurrentPartitionNumber = @CurrentPartitionNumber, 
							@IndexSizeInMB			= @IndexSizeInMB ,
							@IndexOperation			= @CurrentIndexOperation,
							@IsOnlineOperation		= @OnlineOperations ,
							@RowCount				= @RowCount,
							@SQLStatement			= @CurrentSQLStatement ,
							@ErrorText				= @ErrorMessage,
							@TransactionId			= @TransactionId,
							@TableChildOperationId	= 0,
							@BatchId				= @BatchId,
							@SeqNo					= @CurrentSeqNo,
							@RunStatus				= 'Error - Skipping...',
							@ExitTableLoopOnError	= @ExitTableLoopOnError

	                    DELETE Q
	                    FROM DDI.Queue Q
	                    WHERE Q.DatabaseName = @CurrentDatabaseName
                            AND Q.ParentSchemaName = @CurrentParentSchemaName
		                    AND Q.ParentTableName = @CurrentParentTableName

                        SET @ExitRetryLoopOnError = 1
                    END
                    ELSE
					BEGIN
						RAISERROR(@ErrorMessage, 16, 1)
					END
				END CATCH
			END
            /************************** RETRY LOOP (END) ****************************************************/

			FETCH NEXT FROM Tables_Run_Cur INTO @CurrentDatabaseName, @CurrentSchemaName, @CurrentTableName, @CurrentParentSchemaName, @CurrentParentTableName, @CurrentSeqNo, @TransactionId, @CurrentIndexName, @CurrentPartitionNumber, @CurrentSQLStatement, @RunStatus, @CurrentIndexOperation, @CurrentTableChildOperationId, @BatchId, @ExitTableLoopOnError, @IndexSizeInMB

		END --@@fetch_status <> -2
		
	END --@@fetch_status <> -1

	CLOSE Tables_Run_Cur
	DEALLOCATE Tables_Run_Cur
    /************************************** TABLE LOOP (END) ********************************************/
END TRY

BEGIN CATCH
	IF NULLIF(LTRIM(RTRIM(@ErrorMessage)), '') IS NULL
	BEGIN
        SET @ErrorMessage = ERROR_MESSAGE()
	END;

	IF @@TRANCOUNT > 0 
	BEGIN
		--BACKUP THE LOG ROWS SO WE DON'T LOSE THEM IN THE ROLLBACK.
		DECLARE @Log AS LogTT;

		WITH LastLoggedRow
		AS (SELECT   TOP 1 *
			FROM     DDI.Log
			ORDER BY LogDateTime DESC )

		UPDATE LastLoggedRow
		SET    LastLoggedRow.ErrorText = @ErrorMessage
		WHERE LastLoggedRow.TransactionId = @TransactionId;

		INSERT INTO @Log (  DatabaseName,
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
							IsOnlineOperation ,
							[RowCount] ,
							TableChildOperationId ,
							RunStatus ,
							ErrorText ,
							TransactionId ,
							BatchId ,
							SeqNo ,
							ExitTableLoopOnError) 
		EXEC DDI.spRun_GetLogRowsFromRollback
			@TransactionId = @TransactionId


		--AFTER SAVING THE LOG TRANSACTIONS, GO AHEAD AND ROLLBACK:
		ROLLBACK TRAN;

		EXEC DDI.spRun_RecoverLogRowsFromRollback
			@Log = @Log
	END

	--CLEAR THE QUEUE FOR THIS TABLE SO THAT WE ARE FORCED TO REBUILD IT FROM SCRATCH FOR THE NEXT RUN.
	DELETE Q
	FROM DDI.Queue Q
	WHERE Q.DatabaseName = @CurrentDatabaseName
        AND Q.ParentSchemaName = @CurrentParentSchemaName
		AND Q.ParentTableName = @CurrentParentTableName

	SET @CurrentDateTime = SYSDATETIME()
	SET @CurrentSchemaName = ISNULL(@CurrentSchemaName, 'N/A')
	SET @CurrentTableName = ISNULL(@CurrentTableName, 'N/A')
	SET @CurrentIndexName = ISNULL(@CurrentIndexName, 'N/A')
	SET @CurrentIndexOperation = ISNULL(@CurrentIndexOperation, 'N/A')
	SET @BatchId = ISNULL(@BatchId, '00000000-0000-0000-0000-000000000000')
	SET @CurrentPartitionNumber = ISNULL(@CurrentPartitionNumber, 0)
	SET @IndexSizeInMB = ISNULL(@IndexSizeInMB, 0)
	SET @RowCount = ISNULL(@RowCount, 0)
	SET @CurrentSeqNo = ISNULL(@CurrentSeqNo, 0)
	SET @ExitTableLoopOnError = ISNULL(@ExitTableLoopOnError, 0)

	EXEC DDI.spRun_LogInsert 
        @CurrentDatabaseName    = @CurrentDatabaseName,
		@CurrentSchemaName		= @CurrentSchemaName , 
		@CurrentTableName		= @CurrentTableName ,  
		@CurrentIndexName		= @CurrentIndexName , 
		@CurrentPartitionNumber = @CurrentPartitionNumber ,
		@IndexSizeInMB			= @IndexSizeInMB ,
		@IndexOperation			= @CurrentIndexOperation,
		@IsOnlineOperation		= @OnlineOperations ,
		@RowCount				= @RowCount,
		@SQLStatement			= @CurrentSQLStatement ,
		@ErrorText				= @ErrorMessage,
		@TransactionId			= @TransactionId,
		@TableChildOperationId	= 0,
		@BatchId				= @BatchId,
		@SeqNo					= @CurrentSeqNo,
		@RunStatus				= 'Error',
		@ExitTableLoopOnError	= @ExitTableLoopOnError

	EXEC DDI.spRun_ReleaseApplicationLock

	EXEC DDI.spRun_DropObjects
        @CurrentDatabaseName    = @CurrentDatabaseName,
		@CurrentSchemaName		= @CurrentSchemaName,
		@CurrentTableName		= @CurrentTableName,
		@CurrentParentTableName = @CurrentParentTableName,
		@CurrentSeqNo			= @CurrentSeqNo,
		@ExitTableLoopOnError	= 1,
		@BatchId				= @BatchId,
		@DeleteTables			= 0

	--CLOSE CURSORS IF OPEN
	IF (SELECT CURSOR_STATUS('global','Tables_Run_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('global','Tables_Run_Cur')) > -1
		BEGIN
			CLOSE Tables_Run_Cur
		END

		DEALLOCATE Tables_Run_Cur
	END

	IF @ExitTableLoopOnError = 1
	BEGIN;
		THROW;
	END
END CATCH

--CLOSE CURSORS IF OPEN
IF (SELECT CURSOR_STATUS('global','Tables_Run_Cur')) >= -1
BEGIN
	IF (SELECT CURSOR_STATUS('global','Tables_Run_Cur')) > -1
	BEGIN
		CLOSE Tables_Run_Cur
	END

	DEALLOCATE Tables_Run_Cur
END

GO
