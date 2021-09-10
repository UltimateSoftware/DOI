-- <Migration ID="18ff79cb-7bbd-43b4-866b-f185b3f7e1db" />

IF OBJECT_ID('[DOI].[spQueue]') IS NOT NULL
	DROP PROCEDURE [DOI].[spQueue];

GO

CREATE   PROCEDURE [DOI].[spQueue]
    @DatabaseName SYSNAME = NULL,
    @SchemaName SYSNAME = NULL,
    @TableName SYSNAME = NULL,
	@IncludeMaintenance BIT = 0,
	@BatchIdOUT UNIQUEIDENTIFIER OUTPUT 

AS

/*
    declare @BatchId uniqueidentifier

	EXEC DOI.spQueue 
		@DatabaseName = 'DOIUnitTests',
        @BatchIdOUT = @BatchId
*/

BEGIN TRY
	SET @BatchIdOUT = NEWID()

    EXEC DOI.spRefreshMetadata_Run_All
		@DatabaseName = @DatabaseName,
		@IncludeMaintenance = @IncludeMaintenance

	--TRACK INDEXES NOT IN METADATA...DO THIS LATER
	EXEC DOI.spQueue_IndexesNotInMetadata
		@DatabaseName = @DatabaseName

	EXEC DOI.spQueue_ConstraintsNotInMetadata
		@DatabaseName = @DatabaseName

	DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10)

	DECLARE @CurrentDatabaseName					NVARCHAR(128),
			@CurrentSchemaName						NVARCHAR(128),
			@CurrentTableName						NVARCHAR(128),
			@CurrentIndexName						NVARCHAR(128),
            @CurrentStatisticsName                  NVARCHAR(128),
			@CurrentPartitionNumber					SMALLINT,
            @FreeDataSpaceValidationSQL             VARCHAR(MAX) = '',
            @FreeLogSpaceValidationSQL              VARCHAR(MAX) = '',
            @FreeTempDBSpaceValidationSQL           VARCHAR(MAX) = '',
            @GetApplicationLockSQL					NVARCHAR(300),
            @ReleaseApplicationLockSQL				NVARCHAR(300),
			@CurrentSQLToExecute					VARCHAR(MAX) = '',
            @StatisticsUpdateType					VARCHAR(MAX) = '',
            @OriginalStatisticsUpdateType           VARCHAR(MAX) = '',
            @StatisticsSQL                          VARCHAR(MAX) = '',
            @DropStatisticsSQL                      VARCHAR(MAX) = '',
			@IsBCPTable								BIT,
			@IsStorageChanging						BIT,
			@WhichUniqueConstraintIsBeingDropped	VARCHAR(5),
			@HasMissingIndexes						BIT,
			@IndexUpdateType						VARCHAR(20),
			@OriginalIndexUpdateType				VARCHAR(20),
			@TransactionId							UNIQUEIDENTIFIER = NULL,
			@IndexSizeInMB							INT,
			@IndexOperation							VARCHAR(70)

    DROP TABLE IF EXISTS #TablesWithPendingConstraintsTable

    CREATE TABLE #TablesWithPendingConstraintsTable  (	DatabaseName SYSNAME, 
														SchemaName SYSNAME, 
														TableName SYSNAME
                                                        PRIMARY KEY NONCLUSTERED (SchemaName, TableName))

	INSERT INTO #TablesWithPendingConstraintsTable ( DatabaseName, SchemaName, TableName )
	SELECT	X.DatabaseName,
			X.SchemaName, 
			X.TableName
	FROM DOI.Tables T
		INNER JOIN (SELECT DatabaseName, SchemaName, TableName
					FROM DOI.CheckConstraintsNotInMetadata 			
					UNION
					SELECT DatabaseName, SchemaName, TableName
					FROM DOI.DefaultConstraintsNotInMetadata
					UNION
					SELECT DatabaseName, SchemaName, TableName
					FROM DOI.IndexesNotInMetadata
					WHERE Ignore = 0) X
			ON X.DatabaseName = T.DatabaseName
				AND X.SchemaName = T.SchemaName
				AND X.TableName = T.TableName
	WHERE T.ReadyToQueue = 1
		AND T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END
 
	DECLARE Databases_Queued_Cur CURSOR LOCAL FAST_FORWARD FOR
	SELECT DatabaseName
	FROM DOI.Databases
	WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END

	OPEN Databases_Queued_Cur

	FETCH NEXT FROM Databases_Queued_Cur INTO @CurrentDatabaseName

	WHILE @@FETCH_STATUS <> -1
	BEGIN
		IF @@FETCH_STATUS <> -2
		BEGIN
	        DECLARE Tables_Queued_Cur CURSOR LOCAL FAST_FORWARD FOR
		        SELECT	FN.DatabaseName,
				        FN.SchemaName, 
				        FN.TableName, 
				        FN.WhichUniqueConstraintIsBeingDropped,
				        FN.AreIndexesMissing,
				        FN.IntendToPartition,
				        FN.IsStorageChanging,
                        FN.FreeDataSpaceCheckSQL,
                        FN.FreeLogSpaceCheckSQL,
                        FN.FreeTempDBSpaceCheckSQL
		        FROM DOI.vwTables FN
		        WHERE (FN.AreIndexesBeingUpdated = 1 
				        OR FN.AreIndexesMissing = 1 
				        OR FN.AreIndexesFragmented = 1
				        OR FN.IsStorageChanging = 1
                        OR FN.AreStatisticsChanging = 1) --any indexes to add or update?
                    AND FN.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN FN.DatabaseName ELSE @DatabaseName END
                    AND FN.SchemaName = CASE WHEN @SchemaName IS NULL THEN FN.SchemaName ELSE @SchemaName END
                    AND FN.TableName = CASE WHEN @TableName IS NULL THEN FN.TableName ELSE @TableName END
                    AND ReadyToQueue = 1
			        AND NOT EXISTS (SELECT 'True' 
							        FROM #TablesWithPendingConstraintsTable TV 
							        WHERE TV.SchemaName = FN.SchemaName 
								        AND TV.TableName = FN.TableName)
    
	        OPEN Tables_Queued_Cur

	        FETCH NEXT FROM Tables_Queued_Cur INTO @CurrentDatabaseName, @CurrentSchemaName, @CurrentTableName, @WhichUniqueConstraintIsBeingDropped, @HasMissingIndexes, @IsBCPTable, @IsStorageChanging, @FreeDataSpaceValidationSQL, @FreeLogSpaceValidationSQL, @FreeTempDBSpaceValidationSQL

	        WHILE @@FETCH_STATUS <> -1
	        BEGIN
		        IF @@FETCH_STATUS <> -2
		        BEGIN
                    BEGIN TRY
			            SELECT  @GetApplicationLockSQL	    = '
EXEC DOI.spRun_GetApplicationLock
    @DatabaseName = ''' + @CurrentDatabaseName + ''',
    @BatchId = ''' + CAST(@BatchIdOUT AS VARCHAR(40)) + '''',
			                    @ReleaseApplicationLockSQL	= '
EXEC DOI.spRun_ReleaseApplicationLock
    @DatabaseName = ''' + @CurrentDatabaseName + ''',
    @BatchId = ''' + CAST(@BatchIdOUT AS VARCHAR(40)) + ''''

		                --APPLICATION LOCK, SO OTHER PROCESSES CAN SEE IF THIS IS RUNNING...
		                EXEC DOI.spQueue_Insert
			                @CurrentDatabaseName			= @CurrentDatabaseName ,
			                @CurrentSchemaName				= '1', 
			                @CurrentTableName				= '1', 
			                @CurrentIndexName				= '1', 
			                @CurrentPartitionNumber			= 0, 
			                @IndexSizeInMB					= 0,
			                @CurrentParentSchemaName		= '1', 
			                @CurrentParentTableName			= '1', 
			                @CurrentParentIndexName			= '1',
			                @IndexOperation					= 'Get Application Lock',
			                @TableChildOperationId			= 0,
			                @SQLStatement					= @GetApplicationLockSQL,
			                @TransactionId					= NULL,
			                @BatchId						= @BatchIdOUT,
			                @ExitTableLoopOnError			= 1
                
                		IF EXISTS (	SELECT 'True' 
							        FROM #TablesWithPendingConstraintsTable 
							        WHERE DatabaseName = @CurrentDatabaseName
								        AND SchemaName = @CurrentSchemaName 
								        AND TableName = @CurrentTableName)
				        BEGIN
					        DECLARE @ErrorMessage VARCHAR(MAX) = @CurrentDatabaseName + '.' + @CurrentSchemaName + '.' + @CurrentTableName + ' has pending constraint or index changes and will NOT be queued for refreshing of Index Structures.'
					        RAISERROR(@ErrorMessage, 10, 1)

					        EXEC DOI.spRun_LogInsert 
						        @CurrentDatabaseName	= @CurrentDatabaseName ,
						        @CurrentSchemaName		= @CurrentSchemaName ,   
						        @CurrentTableName		= @CurrentTableName ,    
						        @CurrentIndexName		= N'N/A' , 
						        @CurrentPartitionNumber	= 0, 
						        @IndexSizeInMB			= 0,   
						        @SQLStatement			= @ErrorMessage ,
						        @IndexOperation			= 'PendingConstraintValidation' ,  
						        @RowCount				= 0 ,     
						        @TableChildOperationId	= 0 , 
						        @RunStatus				= 'Error' , 
						        @TransactionId			= NULL ,      
						        @BatchId				= @BatchIdOUT ,    
						        @SeqNo					= 0,        
						        @ErrorText				= @ErrorMessage ,            
						        @ExitTableLoopOnError	= 0  
				        END

				        --GET THE INDEX SIZE, THE LOCATION OF THE INDEX, AND CHECK THE FREE DISK SPACE ON THAT DRIVE.
				        EXEC DOI.spQueue_Insert
					        @CurrentDatabaseName			= @CurrentDatabaseName ,
					        @CurrentSchemaName				= @CurrentSchemaName ,
					        @CurrentTableName				= @CurrentTableName, 
					        @CurrentIndexName				= 'N/A', 
					        @CurrentPartitionNumber			= 0, 
					        @IndexSizeInMB					= 0,
					        @CurrentParentSchemaName		= @CurrentSchemaName ,
					        @CurrentParentTableName			= @CurrentTableName, 
					        @CurrentParentIndexName			= 'N/A',
					        @IndexOperation					= 'Free Data Space Validation',
					        @TableChildOperationId			= 0,
					        @SQLStatement					= @FreeDataSpaceValidationSQL,
					        @TransactionId					= NULL,
					        @BatchId						= @BatchIdOUT,
					        @ExitTableLoopOnError			= 0

				        EXEC DOI.spQueue_Insert
					        @CurrentDatabaseName			= @CurrentDatabaseName ,
					        @CurrentSchemaName				= @CurrentSchemaName ,
					        @CurrentTableName				= @CurrentTableName, 
					        @CurrentIndexName				= 'N/A', 
					        @CurrentPartitionNumber			= 0, 
					        @IndexSizeInMB					= 0,
					        @CurrentParentSchemaName		= @CurrentSchemaName ,
					        @CurrentParentTableName			= @CurrentTableName, 
					        @CurrentParentIndexName			= 'N/A',
					        @IndexOperation					= 'Free Log Space Validation',
					        @TableChildOperationId			= 0,
					        @SQLStatement					= @FreeLogSpaceValidationSQL,
					        @TransactionId					= NULL,
					        @BatchId						= @BatchIdOUT,
					        @ExitTableLoopOnError			= 0

				        EXEC DOI.spQueue_Insert
					        @CurrentDatabaseName			= @CurrentDatabaseName ,
					        @CurrentSchemaName				= @CurrentSchemaName ,
					        @CurrentTableName				= @CurrentTableName, 
					        @CurrentIndexName				= 'N/A', 
					        @CurrentPartitionNumber			= 0, 
					        @IndexSizeInMB					= 0,
					        @CurrentParentSchemaName		= @CurrentSchemaName ,
					        @CurrentParentTableName			= @CurrentTableName, 
					        @CurrentParentIndexName			= 'N/A',
					        @IndexOperation					= 'Free TempDB Space Validation',
					        @TableChildOperationId			= 0,
					        @SQLStatement					= @FreeTempDBSpaceValidationSQL,
					        @TransactionId					= NULL,
					        @BatchId						= @BatchIdOUT,
					        @ExitTableLoopOnError			= 0

				        IF (@IsBCPTable = 1 AND @IsStorageChanging = 1 ) --make 'PartitionTableSwap' its own IndexUpdateType, and maybe put all the logic of the BCP SP into a view like vwIndexesSQLToRun?
				        BEGIN
					        EXEC DOI.spRun_RefreshPartitionState

					        IF NOT EXISTS(	SELECT 'True' 
									        FROM DOI.Run_PartitionState 
									        WHERE DatabaseName = @CurrentDatabaseName
										        AND SchemaName = @CurrentSchemaName
										        AND ParentTableName = @CurrentTableName)
					        BEGIN
						        SET @ErrorMessage = 'The ' + @CurrentDatabaseName + '.' + @CurrentSchemaName + '.' + @CurrentTableName + ' has no PartitionState Metadata.  Execute spDataDrivenIndexes_RefreshPartitionState for this table.'
						        RAISERROR(@ErrorMessage, 16, 1)

						        EXEC DOI.spRun_LogInsert 
							        @CurrentDatabaseName	= @CurrentDatabaseName ,
							        @CurrentDatabaseName	= @CurrentDatabaseName ,
							        @CurrentSchemaName		= @CurrentSchemaName ,   
							        @CurrentTableName		= @CurrentTableName ,    
							        @CurrentIndexName		= N'N/A' , 
							        @CurrentPartitionNumber	= 0, 
							        @IndexSizeInMB			= 0,   
							        @SQLStatement			= @ErrorMessage ,
							        @IndexOperation			= 'Partition State Metadata Validation' , 
							        @RowCount				= 0 ,     
							        @TableChildOperationId	= 0 , 
							        @RunStatus				= 'Error' ,            
							        @TransactionId			= NULL ,      
							        @BatchId				= @BatchIdOUT ,    
							        @SeqNo					= 0,        
							        @ErrorText				= @ErrorMessage ,            
							        @ExitTableLoopOnError	= 0  
					        END	

					        EXEC DOI.spQueue_BCPTables 
						        @DatabaseName	        = @CurrentDatabaseName ,
						        @SchemaName				= @CurrentSchemaName,
						        @TableName				= @CurrentTableName,
						        @BatchId				= @BatchIdOUT
				        END
						ELSE --if we are doing BCP strategy, then do nothing else on the table.  ONCE 'PartitionSwap' becomes its own IndexUpdateType, this check will no longer be necessary.
        EXEC DOI.spForeignKeysDrop	
				        BEGIN 
					        DECLARE UpdateAllIndexes_Cur CURSOR LOCAL FAST_FORWARD FOR
						        SELECT	I.IndexName, 
								        I.PartitionNumber,
								        I.IndexUpdateType,
								        I.OriginalIndexUpdateType,
								        I.CurrentSQLToExecute,
								        I.IndexSizeMB_Actual,
										I.IndexOperation
						        FROM DOI.vwIndexesSQLToRun I
						        WHERE I.DatabaseName = @CurrentDatabaseName
							        AND I.SchemaName = @CurrentSchemaName
							        AND I.TableName = @CurrentTableName
						        ORDER BY I.RowNum
						
					        OPEN UpdateAllIndexes_Cur
					
					        FETCH NEXT FROM UpdateAllIndexes_Cur INTO @CurrentIndexName, @CurrentPartitionNumber, @IndexUpdateType, @OriginalIndexUpdateType, @CurrentSQLToExecute, @IndexSizeInMB, @IndexOperation
					
					        WHILE @@FETCH_STATUS <> -1
					        BEGIN
						        IF @@FETCH_STATUS <> -2
						        BEGIN
							        EXEC DOI.spQueue_Insert
								        @CurrentDatabaseName			= @CurrentDatabaseName ,
								        @CurrentSchemaName				= @CurrentSchemaName ,
								        @CurrentTableName				= @CurrentTableName, 
								        @CurrentIndexName				= @CurrentIndexName, 
								        @CurrentPartitionNumber			= @CurrentPartitionNumber, 
								        @IndexSizeInMB					= @IndexSizeInMB,
								        @CurrentParentSchemaName		= @CurrentSchemaName ,
								        @CurrentParentTableName			= @CurrentTableName, 
								        @CurrentParentIndexName			= @CurrentIndexName,
								        @IndexOperation					= @IndexOperation,
								        @SQLStatement					= @CurrentSQLToExecute, 
								        @TransactionId					= @TransactionId,
								        @BatchId						= @BatchIdOUT,
								        @ExitTableLoopOnError			= 0
						        END --@@fetch_status <> -2, UpdateAllIndexes_Cur

						        FETCH NEXT FROM UpdateAllIndexes_Cur INTO @CurrentIndexName, @CurrentPartitionNumber, @IndexUpdateType, @OriginalIndexUpdateType, @CurrentSQLToExecute, @IndexSizeInMB, @IndexOperation
					        END --fetch_status <> -1, UpdateAllIndexes_Cur
            
					        CLOSE UpdateAllIndexes_Cur
					        DEALLOCATE UpdateAllIndexes_Cur

                            --STATISTICS UPDATES
                            --rename any stats
                            EXEC DOI.spQueue_RenameStatistics
                
                            DECLARE CreateOrUpdateStatistics_Cur CURSOR LOCAL FAST_FORWARD FOR 
                                SELECT  StatisticsName, 
                                        CASE
                                            WHEN StatisticsUpdateType IN ('Create Statistics', 'DropRecreate Statistics')
                                            THEN CreateStatisticsSQL
                                            WHEN StatisticsUpdateType = 'Update Statistics'
                                            THEN UpdateStatisticsSQL
                                        END , 
                                        StatisticsUpdateType AS OriginalStatisticsUpdateType,
                                        CASE
                                            WHEN StatisticsUpdateType = 'DropRecreate Statistics'
                                            THEN 'Create Statistics'
                                            ELSE StatisticsUpdateType
                                        END AS StatisticsUpdateType,
                                        DropStatisticsSQL
                                FROM DOI.vwStatistics
                                WHERE DatabaseName = @CurrentDatabaseName
							        AND SchemaName = @CurrentSchemaName
                                    AND TableName = @CurrentTableName
                                    AND StatisticsUpdateType <> 'None'
                                    AND ReadyToQueue = 1
                
				            OPEN CreateOrUpdateStatistics_Cur

				            FETCH NEXT FROM CreateOrUpdateStatistics_Cur INTO @CurrentStatisticsName, @StatisticsSQL, @OriginalStatisticsUpdateType, @StatisticsUpdateType, @DropStatisticsSQL
				            WHILE @@FETCH_STATUS <> -1
				            BEGIN
					            IF @@FETCH_STATUS <> -2
					            BEGIN
                        	        IF @OriginalStatisticsUpdateType = 'DropRecreate Statistics' --CHANGE THIS TO CREATE DUPLICATE STATS AND THEN DROP OLD ONE.
							        BEGIN
								        EXEC DOI.spQueue_Insert
										    @CurrentDatabaseName			= @CurrentDatabaseName ,
									        @CurrentSchemaName				= @CurrentSchemaName ,
									        @CurrentTableName				= @CurrentTableName, 
									        @CurrentIndexName				= @CurrentStatisticsName, 
									        @CurrentPartitionNumber			= 0, 
									        @IndexSizeInMB					= 0,
									        @CurrentParentSchemaName		= @CurrentSchemaName ,
									        @CurrentParentTableName			= @CurrentTableName, 
									        @CurrentParentIndexName			= @CurrentStatisticsName,
									        @IndexOperation					= 'Drop Statistics',
									        @SQLStatement					= @DropStatisticsSQL, 
									        @TransactionId					= @TransactionId,
									        @BatchId						= @BatchIdOUT,
									        @ExitTableLoopOnError			= 0
							        END
                        
						            EXEC DOI.spQueue_Insert
								        @CurrentDatabaseName			= @CurrentDatabaseName ,
							            @CurrentSchemaName				= @CurrentSchemaName ,
							            @CurrentTableName				= @CurrentTableName, 
							            @CurrentIndexName				= @CurrentStatisticsName, 
							            @CurrentPartitionNumber			= 0, 
							            @IndexSizeInMB					= 0,
							            @CurrentParentSchemaName		= @CurrentSchemaName ,
							            @CurrentParentTableName			= @CurrentTableName, 
							            @CurrentParentIndexName			= @CurrentStatisticsName,
							            @IndexOperation					= @StatisticsUpdateType,
							            @SQLStatement					= @StatisticsSQL, 
							            @TransactionId					= @TransactionId,
							            @BatchId						= @BatchIdOUT,
							            @ExitTableLoopOnError			= 0                        
                                END --@@fetch_status <> -2, CreateOrUpdateStatistics_Cur
                    
                                FETCH NEXT FROM CreateOrUpdateStatistics_Cur INTO @CurrentStatisticsName, @StatisticsSQL, @OriginalStatisticsUpdateType, @StatisticsUpdateType, @DropStatisticsSQL
                            END--@@fetch_status <> -1, CreateOrUpdateStatistics_Cur

                            CLOSE CreateOrUpdateStatistics_Cur
                            DEALLOCATE CreateOrUpdateStatistics_Cur
				        END  --if we are doing BCP strategy, then do nothing else on the table.       

			        EXEC DOI.spQueue_Insert
				        @CurrentDatabaseName			= @CurrentDatabaseName ,
				        @CurrentSchemaName				= @CurrentSchemaName ,
				        @CurrentTableName				= @CurrentTableName, 
				        @CurrentIndexName				= 'N/A',  
				        @CurrentPartitionNumber			= 0, 
				        @IndexSizeInMB					= 0,
				        @CurrentParentSchemaName		= @CurrentSchemaName ,
				        @CurrentParentTableName			= @CurrentTableName, 
				        @CurrentParentIndexName			= 'N/A',
				        @IndexOperation					= 'Release Application Lock',
				        @TableChildOperationId			= 0,
				        @SQLStatement					= @ReleaseApplicationLockSQL, 
				        @TransactionId					= @TransactionId,
				        @BatchId						= @BatchIdOUT,
				        @ExitTableLoopOnError			= 0

			        --IF NOTHING OF SUBSTANCE WAS INSERTED, DELETE THE FEW USELESS MAINTENANCE TASKS THAT WERE INSERTED.
			        IF EXISTS (	SELECT 'True' 
						        FROM DOI.Queue 
						        WHERE DatabaseName = @CurrentDatabaseName
							        AND ParentTableName = @CurrentTableName
							        AND IndexOperation IN ('Free TempDB Space Validation', 'Free Log Space Validation', 'Free Data Space Validation', 'Disable CmdShell', 'Get Application Lock', 'Release Application Lock'))
				        AND NOT EXISTS (SELECT 'True' 
								        FROM DOI.Queue 
								        WHERE DatabaseName = @CurrentDatabaseName
									        AND ParentTableName = @CurrentTableName
									        AND IndexOperation NOT IN ('Free TempDB Space Validation', 'Free Log Space Validation', 'Free Data Space Validation', 'Disable CmdShell', 'Get Application Lock', 'Release Application Lock'))
			        BEGIN
				        DELETE FROM DOI.Queue 
				        WHERE DatabaseName = @CurrentDatabaseName
					        AND ParentTableName = @CurrentTableName
					        AND IndexOperation IN ('Free TempDB Space Validation', 'Free Log Space Validation', 'Free Data Space Validation', 'Disable CmdShell', 'Get Application Lock', 'Release Application Lock')
			        END
				
			        END TRY
			        BEGIN CATCH
				        IF @@TRANCOUNT > 0 ROLLBACK TRAN 
				        --CLOSE CURSORS IF OPEN
				        IF (SELECT CURSOR_STATUS('local','PrepTables_Cur')) >= -1
				        BEGIN
					        IF (SELECT CURSOR_STATUS('local','PrepTables_Cur')) > -1
					        BEGIN
						        CLOSE PrepTables_Cur
					        END

					        DEALLOCATE PrepTables_Cur
				        END

				        IF (SELECT CURSOR_STATUS('local','DropIndexes_Cur')) >= -1
				        BEGIN
					        IF (SELECT CURSOR_STATUS('local','DropIndexes_Cur')) > -1
					        BEGIN
						        CLOSE DropIndexes_Cur
					        END

					        DEALLOCATE DropIndexes_Cur
				        END

				        IF (SELECT CURSOR_STATUS('local','UpdateAllIndexes_Cur')) >= -1
				        BEGIN
					        IF (SELECT CURSOR_STATUS('local','UpdateAllIndexes_Cur')) > -1
					        BEGIN
						        CLOSE UpdateAllIndexes_Cur
					        END

					        DEALLOCATE UpdateAllIndexes_Cur
				        END;

				        IF (SELECT CURSOR_STATUS('local','CreateOrUpdateStatistics_Cur')) >= -1
				        BEGIN
					        IF (SELECT CURSOR_STATUS('local','CreateOrUpdateStatistics_Cur')) > -1
					        BEGIN
						        CLOSE CreateOrUpdateStatistics_Cur
					        END

					        DEALLOCATE CreateOrUpdateStatistics_Cur
				        END;

				        THROW;
			        END CATCH

		        END --@@fetch_status <> -2, Tables cursor

		        FETCH NEXT FROM Tables_Queued_Cur INTO @CurrentDatabaseName, @CurrentSchemaName, @CurrentTableName, @WhichUniqueConstraintIsBeingDropped, @HasMissingIndexes, @IsBCPTable, @IsStorageChanging, @FreeDataSpaceValidationSQL, @FreeLogSpaceValidationSQL, @FreeTempDBSpaceValidationSQL
	        END --@@fetch_status <> -1, Tables cursor
			CLOSE Tables_Queued_Cur
			DEALLOCATE Tables_Queued_Cur
		END --@@fetch_status <> -2, Databases cursor
		
		FETCH NEXT FROM Databases_Queued_Cur INTO @CurrentDatabaseName
	END --@@fetch_status <> -1, Databases cursor
	CLOSE Databases_Queued_Cur
	DEALLOCATE Databases_Queued_Cur
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRAN 
	--CLOSE CURSORS IF OPEN
	IF (SELECT CURSOR_STATUS('local','Tables_Queued_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','Tables_Queued_Cur')) > -1
		BEGIN
			CLOSE Tables_Queued_Cur
		END

		DEALLOCATE Tables_Queued_Cur
	END;

	IF (SELECT CURSOR_STATUS('local','Databases_Queued_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','Databases_Queued_Cur')) > -1
		BEGIN
			CLOSE Databases_Queued_Cur
		END

		DEALLOCATE Databases_Queued_Cur
	END;

	THROW;
END CATCH


--CLOSE CURSORS IF OPEN
IF (SELECT CURSOR_STATUS('local','Tables_Queued_Cur')) >= -1
BEGIN
	IF (SELECT CURSOR_STATUS('local','Tables_Queued_Cur')) > -1
	BEGIN
		CLOSE Tables_Queued_Cur
	END

	DEALLOCATE Tables_Queued_Cur
END

IF (SELECT CURSOR_STATUS('local','Databases_Queued_Cur')) >= -1
BEGIN
	IF (SELECT CURSOR_STATUS('local','Databases_Queued_Cur')) > -1
	BEGIN
		CLOSE Databases_Queued_Cur
	END

	DEALLOCATE Databases_Queued_Cur
END

RETURN

GO