
GO

IF OBJECT_ID('[DOI].[spQueue]') IS NOT NULL
	DROP PROCEDURE [DOI].[spQueue];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spQueue]
	@OnlineOperations BIT,
	@IsBeingRunDuringADeployment BIT,
    @DatabaseName SYSNAME = NULL,
    @SchemaName SYSNAME = NULL,
    @TableName SYSNAME = NULL,
	@BatchIdOUT UNIQUEIDENTIFIER OUTPUT 

AS

/*
    declare @BatchId uniqueidentifier

	EXEC DOI.spQueue 
		@OnlineOperations = 0,
		@IsBeingRunDuringADeployment = 0,
        @BatchIdOUT = @BatchId

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
	SET @BatchIdOUT = NEWID()

    EXEC DOI.spRefreshMetadata_Run_All
		@DatabaseName = @DatabaseName

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
			@DropSingleIndexSQL						VARCHAR(MAX) = '',
			@CreateSingleIndexSQL					VARCHAR(MAX) = '',
            @StatisticsUpdateType					VARCHAR(MAX) = '',
            @OriginalStatisticsUpdateType           VARCHAR(MAX) = '',
            @IsStatisticsOnlineOperation            BIT,
            @StatisticsSQL                          VARCHAR(MAX) = '',
            @DropStatisticsSQL                      VARCHAR(MAX) = '',
			@IsClusteredIndexBeingDroppedForTable	BIT = 0,
			@IsOnlineOperation						BIT,
			@IsBCPTable								BIT,
			@IsStorageChanging						BIT,
			@WhichUniqueConstraintIsBeingDropped	VARCHAR(5),
			@HasMissingIndexes						BIT,
			@DropRefFKs								VARCHAR(MAX) ,
			@RecreateRefFKSQL						VARCHAR(MAX),
			@IndexUpdateType						VARCHAR(20),
			@OriginalIndexUpdateType				VARCHAR(20),
			@TransactionId							UNIQUEIDENTIFIER = NULL,
			@IndexSizeInMB							INT,
			@NeedsTransaction						BIT

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
 
	WHILE @@FETCH_STATUS <> -1
	BEGIN
		IF @@FETCH_STATUS <> -2
		BEGIN
	        DECLARE Tables_Queued_Cur CURSOR LOCAL FAST_FORWARD FOR
		        SELECT	FN.DatabaseName,
				        FN.SchemaName, 
				        FN.TableName, 
				        FN.IsClusteredIndexBeingDropped,
				        FN.WhichUniqueConstraintIsBeingDropped,
				        FN.AreIndexesMissing,
				        FN.IntendToPartition,
				        FN.IsStorageChanging,
				        FN.NeedsTransaction,
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

	        FETCH NEXT FROM Tables_Queued_Cur INTO @CurrentDatabaseName, @CurrentSchemaName, @CurrentTableName, @IsClusteredIndexBeingDroppedForTable, @WhichUniqueConstraintIsBeingDropped, @HasMissingIndexes, @IsBCPTable, @IsStorageChanging, /*@RunAutomaticallyOnDeployment, @RunAutomaticallyOnSQLJob,*/ @NeedsTransaction, @FreeDataSpaceValidationSQL, @FreeLogSpaceValidationSQL, @FreeTempDBSpaceValidationSQL

	        WHILE @@FETCH_STATUS <> -1
	        BEGIN
		        IF @@FETCH_STATUS <> -2
		        BEGIN
                    BEGIN TRY
			            SELECT  @GetApplicationLockSQL	    = '
EXEC DOI.DOI.spRun_GetApplicationLock
    @DatabaseName = ''' + @CurrentDatabaseName + ''',
    @BatchId = ''' + CAST(@BatchIdOUT AS VARCHAR(40)) + ''',
    @IsOnlineOperation = ' + CAST(@OnlineOperations AS VARCHAR(1)),
			                    @ReleaseApplicationLockSQL	= '
EXEC DOI.DOI.spRun_ReleaseApplicationLock
    @DatabaseName = ''' + @CurrentDatabaseName + ''',
    @BatchId = ''' + CAST(@BatchIdOUT AS VARCHAR(40)) + ''',
    @IsOnlineOperation = ' + CAST(@OnlineOperations AS VARCHAR(1))

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
			                @IsOnlineOperation				= @OnlineOperations, --RUNS FOR BOTH ONLINE AND OFFLINE OPERATIONS
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
						        @IsOnlineOperation		= @OnlineOperations, --RUNS FOR BOTH ONLINE AND OFFLINE OPERATIONS
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
					        @IsOnlineOperation				= @OnlineOperations, --RUNS FOR BOTH ONLINE AND OFFLINE OPERATIONS
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
					        @IsOnlineOperation				= @OnlineOperations, --RUNS FOR BOTH ONLINE AND OFFLINE OPERATIONS
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
					        @IsOnlineOperation				= @OnlineOperations, --RUNS FOR BOTH ONLINE AND OFFLINE OPERATIONS
					        @TableChildOperationId			= 0,
					        @SQLStatement					= @FreeTempDBSpaceValidationSQL,
					        @TransactionId					= NULL,
					        @BatchId						= @BatchIdOUT,
					        @ExitTableLoopOnError			= 0

				        IF (@OnlineOperations = 1)
					        AND (@IsBCPTable = 1 AND @IsStorageChanging = 1 )
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
							        @IsOnlineOperation		= @OnlineOperations, 
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
                
				        IF (@OnlineOperations = 0)
					        AND NOT (@IsBCPTable = 1 AND @IsStorageChanging = 1) --IF WE'RE DOING BCP ON A TABLE THEN DO NOTHING ELSE.
				        BEGIN
							IF (@WhichUniqueConstraintIsBeingDropped <> 'None' OR @IsClusteredIndexBeingDroppedForTable = 1) --DROP REF FKs IF PK OR UQ CONSTRAINTS ARE BEING UPDATED.
					        BEGIN
						        SET @DropRefFKs = '
        EXEC DOI.DOI.spForeignKeysDrop	
	        @DatabaseName = ''' + @CurrentDatabaseName + ''',
	        @ReferencedSchemaName = ''' + @CurrentSchemaName + ''' , 
	        @ReferencedTableName = ''' + @CurrentTableName + ''''

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
							        @IndexOperation					= 'Drop Ref FKs', 
							        @IsOnlineOperation				= @OnlineOperations, 
							        @SQLStatement					= @DropRefFKs,
							        @TransactionId					= @TransactionId,
							        @BatchId						= @BatchIdOUT,
							        @ExitTableLoopOnError			= 1
					        END

					        IF @NeedsTransaction = 1
					        BEGIN
						        SET @TransactionId = NEWID()

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
							        @IndexOperation					= 'Begin Tran',
							        @IsOnlineOperation				= @OnlineOperations, 
							        @SQLStatement					= 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
        BEGIN TRAN', 
							        @TransactionId					= @TransactionId,
							        @BatchId						= @BatchIdOUT,
							        @ExitTableLoopOnError			= 1
					        END

					        IF @IsClusteredIndexBeingDroppedForTable = 1 --DROP ALL NC INDEXES IF CLUSTERED INDEX IS UPDATED
					        BEGIN
						        DECLARE DropIndexes_Cur CURSOR LOCAL FAST_FORWARD FOR 

							        SELECT IndexName, DropStatement, IndexSizeMB_Actual
							        FROM DOI.vwIndexes
							        WHERE DatabaseName = @CurrentDatabaseName
								        AND SchemaName = @CurrentSchemaName
								        AND TableName = @CurrentTableName
								        AND IsClustered_Desired = 0
							        ORDER BY IndexSizeMB_Actual ASC

						        OPEN DropIndexes_Cur

						        FETCH NEXT FROM DropIndexes_Cur INTO @CurrentIndexName, @DropSingleIndexSQL, @IndexSizeInMB
						        WHILE @@FETCH_STATUS <> -1
						        BEGIN
							        IF @@FETCH_STATUS <> -2
							        BEGIN
								        --DROP INDEX
								        EXEC DOI.spQueue_Insert
									        @CurrentDatabaseName			= @CurrentDatabaseName ,
									        @CurrentSchemaName				= @CurrentSchemaName ,
									        @CurrentTableName				= @CurrentTableName, 
									        @CurrentIndexName				= @CurrentIndexName, 
									        @CurrentPartitionNumber			= 0, 
									        @IndexSizeInMB					= 0,
									        @CurrentParentSchemaName		= @CurrentSchemaName ,
									        @CurrentParentTableName			= @CurrentTableName, 
									        @CurrentParentIndexName			= @CurrentIndexName,
									        @IndexOperation					= 'Drop Index',
									        @IsOnlineOperation				= 0 ,
									        @SQLStatement					= @DropSingleIndexSQL,
									        @TransactionId					= @TransactionId,
									        @BatchId						= @BatchIdOUT,
									        @ExitTableLoopOnError			= 0
							        END
							        FETCH NEXT FROM DropIndexes_Cur INTO @CurrentIndexName, @DropSingleIndexSQL, @IndexSizeInMB
						        END
						        CLOSE DropIndexes_Cur
							        DEALLOCATE DropIndexes_Cur
					        END --@IsClusteredIndexUpdated = 1
				        END --@OnlineOperations = 0

				        IF NOT (@IsBCPTable = 1 AND @IsStorageChanging = 1) --if we are doing BCP strategy, then do nothing else on the table.
				        BEGIN 
					        DECLARE UpdateAllIndexes_Cur CURSOR LOCAL FAST_FORWARD FOR
						        SELECT	I.IndexName, 
								        ISNULL(IP.PartitionNumber, 0),
								        I.DropStatement AS DropSingleIndexSQL, 
								        CASE 
									        WHEN (I.IndexUpdateType IN ('DropRecreate', 'CreateMissing')
											        OR @IsClusteredIndexBeingDroppedForTable = 1) 
									        THEN 'Create Index'
									        WHEN I.IndexUpdateType LIKE 'Alter%' 
									        THEN 'Alter Index'
									        WHEN I.IndexUpdateType = 'None' 
									        THEN 'None'
									        ELSE ''
								        END AS IndexUpdateType,
								        I.IndexUpdateType AS OriginalIndexUpdateType,
								        CASE 
									        WHEN (I.IndexUpdateType IN ('DropRecreate', 'CreateMissing')
											        OR @IsClusteredIndexBeingDroppedForTable = 1)
									        THEN I.CreateStatement
									        WHEN I.IndexUpdateType = 'AlterRebuild'
									        THEN I.AlterRebuildStatement
									        WHEN I.IndexUpdateType = 'AlterRebuild-PartitionLevel'
									        THEN IP.AlterRebuildStatement
									        WHEN I.IndexUpdateType = 'AlterSet'
									        THEN I.AlterSetStatement
									        WHEN I.IndexUpdateType = 'AlterReorganize'
									        THEN I.AlterReorganizeStatement
									        WHEN I.IndexUpdateType = 'AlterReorganize-PartitionLevel'
									        THEN IP.AlterReorganizeStatement
									        ELSE 'Error'
								        END AS CreateSingleIndexSQL,
								        I.IndexSizeMB_Actual,
								        I.IsOnlineOperation
						        FROM DOI.vwIndexes I
							        LEFT OUTER JOIN DOI.vwIndexPartitions IP ON IP.SchemaName = I.SchemaName
								        AND IP.TableName = I.TableName
								        AND IP.IndexName = I.IndexName
								        AND IP.PartitionUpdateType <> 'None'
						        WHERE (IndexUpdateType <> 'None' OR @IsClusteredIndexBeingDroppedForTable = 1)
							        AND I.DatabaseName = @CurrentDatabaseName
							        AND I.SchemaName = @CurrentSchemaName
							        AND I.TableName = @CurrentTableName
							        AND (I.IsOnlineOperation = @OnlineOperations OR @IsClusteredIndexBeingDroppedForTable = 1)
						        ORDER BY I.IsClustered_Desired DESC, I.IndexName, ISNULL(IP.PartitionNumber, 0) --do the clustered indexes first, now that all the NC indexes have been dropped.
						
					        OPEN UpdateAllIndexes_Cur
					
					        FETCH NEXT FROM UpdateAllIndexes_Cur INTO @CurrentIndexName, @CurrentPartitionNumber, @DropSingleIndexSQL, @IndexUpdateType, @OriginalIndexUpdateType, @CreateSingleIndexSQL, @IndexSizeInMB, @IsOnlineOperation
					
					        WHILE @@FETCH_STATUS <> -1
					        BEGIN
						        IF @@FETCH_STATUS <> -2
						        BEGIN
							        IF @OnlineOperations = 0
							        BEGIN 
								        --DROP THE INDEX IF IT EXISTS....IT MAY HAVE ALREADY BEEN DROPPED ABOVE IF ITS CLUSTERED INDEX WAS UPDATED.
								        IF ((@OriginalIndexUpdateType = 'DropRecreate' 
										        OR @IsClusteredIndexBeingDroppedForTable = 1  
										        OR @WhichUniqueConstraintIsBeingDropped <> 'None'))
								        BEGIN
									        EXEC DOI.spQueue_Insert
										        @CurrentDatabaseName			= @CurrentDatabaseName ,
										        @CurrentSchemaName				= @CurrentSchemaName ,
										        @CurrentTableName				= @CurrentTableName, 
										        @CurrentIndexName				= @CurrentIndexName, 
										        @CurrentPartitionNumber			= @CurrentPartitionNumber, 
										        @IndexSizeInMB					= 0,
										        @CurrentParentSchemaName		= @CurrentSchemaName ,
										        @CurrentParentTableName			= @CurrentTableName, 
										        @CurrentParentIndexName			= @CurrentIndexName,
										        @IndexOperation					= 'Drop Index',
										        @IsOnlineOperation				= @OnlineOperations ,
										        @SQLStatement					= @DropSingleIndexSQL, 
										        @TransactionId					= @TransactionId,
										        @BatchId						= @BatchIdOUT,
										        @ExitTableLoopOnError			= 0
								        END
							        END
                        
							        --RECREATE OR OTHERWISE UPDATE THE INDEX  
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
								        @IndexOperation					= @IndexUpdateType,
								        @IsOnlineOperation				= @OnlineOperations ,
								        @SQLStatement					= @CreateSingleIndexSQL, 
								        @TransactionId					= @TransactionId,
								        @BatchId						= @BatchIdOUT,
								        @ExitTableLoopOnError			= 0
						        END --@@fetch_status <> -2

						        FETCH NEXT FROM UpdateAllIndexes_Cur INTO @CurrentIndexName, @CurrentPartitionNumber, @DropSingleIndexSQL, @IndexUpdateType, @OriginalIndexUpdateType, @CreateSingleIndexSQL, @IndexSizeInMB, @IsOnlineOperation
					        END --fetch_status <> -1
            
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
                                        IsOnlineOperation,
                                        DropStatisticsSQL
                                FROM DOI.vwStatistics
                                WHERE DatabaseName = @CurrentDatabaseName
							        AND SchemaName = @CurrentSchemaName
                                    AND TableName = @CurrentTableName
                                    AND StatisticsUpdateType <> 'None'
                                    AND IsOnlineOperation = @OnlineOperations
                                    AND ReadyToQueue = 1
                
				            OPEN CreateOrUpdateStatistics_Cur

				            FETCH NEXT FROM CreateOrUpdateStatistics_Cur INTO @CurrentStatisticsName, @StatisticsSQL, @OriginalStatisticsUpdateType, @StatisticsUpdateType, @IsStatisticsOnlineOperation, @DropStatisticsSQL
				            WHILE @@FETCH_STATUS <> -1
				            BEGIN
					            IF @@FETCH_STATUS <> -2
					            BEGIN
                                    IF @OnlineOperations = 0
                                    BEGIN
                        	            IF @OriginalStatisticsUpdateType = 'DropRecreate Statistics'
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
									            @IsOnlineOperation				= @IsStatisticsOnlineOperation ,
									            @SQLStatement					= @DropStatisticsSQL, 
									            @TransactionId					= @TransactionId,
									            @BatchId						= @BatchIdOUT,
									            @ExitTableLoopOnError			= 0
							            END
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
							            @IsOnlineOperation				= @IsStatisticsOnlineOperation ,
							            @SQLStatement					= @StatisticsSQL, 
							            @TransactionId					= @TransactionId,
							            @BatchId						= @BatchIdOUT,
							            @ExitTableLoopOnError			= 0                        
                                END
                    
                                FETCH NEXT FROM CreateOrUpdateStatistics_Cur INTO @CurrentStatisticsName, @StatisticsSQL, @OriginalStatisticsUpdateType, @StatisticsUpdateType, @IsStatisticsOnlineOperation, @DropStatisticsSQL
                            END

                            CLOSE CreateOrUpdateStatistics_Cur
                            DEALLOCATE CreateOrUpdateStatistics_Cur
				        END  --if we are doing BCP strategy, then do nothing else on the table.       
                                
			        IF (@OnlineOperations = 0)
				        AND NOT (@IsBCPTable = 1 AND @IsStorageChanging = 1)
			        BEGIN
				        IF @NeedsTransaction = 1
				        BEGIN 
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
						        @IndexOperation					= 'Commit Tran',
						        @IsOnlineOperation				= @OnlineOperations ,
						        @TableChildOperationId			= 2,
						        @SQLStatement					= 'COMMIT TRAN', 
						        @TransactionId					= @TransactionId,
						        @BatchId						= @BatchIdOUT,
						        @ExitTableLoopOnError			= 0
				        END 
			        END

						IF (@OnlineOperations = 0)
					        AND NOT (@IsBCPTable = 1 AND @IsStorageChanging = 1)
					        AND @IsBeingRunDuringADeployment = 0 --IF THIS IS RUNNING DURING A DEPLOYMENT, LET THE ALWAYSRUN SCRIPT ADD THE FKs BACK.
					        AND (@WhichUniqueConstraintIsBeingDropped <> 'None' OR @IsClusteredIndexBeingDroppedForTable = 1) --RECREATE REF FKs
				        BEGIN
					        SET @RecreateRefFKSQL = '
        EXEC DOI.spForeignKeysAdd	
	        @DatabaseName = ''' + @CurrentDatabaseName + ''',
	        @ReferencedSchemaName = ''' + @CurrentSchemaName + ''' , 
	        @ReferencedTableName = ''' + @CurrentTableName + ''''
			                    
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
						        @IndexOperation					= 'Recreate All FKs',
						        @IsOnlineOperation				= @OnlineOperations ,
						        @SQLStatement					= @RecreateRefFKSQL,  
						        @TransactionId					= @TransactionId,
						        @BatchId						= @BatchIdOUT,
						        @ExitTableLoopOnError			= 0
				        END

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
				        @IsOnlineOperation				= @OnlineOperations ,
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

		        END --@@fetch_status <> -2

		        FETCH NEXT FROM Tables_Queued_Cur INTO @CurrentDatabaseName, @CurrentSchemaName, @CurrentTableName, @IsClusteredIndexBeingDroppedForTable, @WhichUniqueConstraintIsBeingDropped, @HasMissingIndexes, @IsBCPTable, @IsStorageChanging, /*@RunAutomaticallyOnDeployment, @RunAutomaticallyOnSQLJob,*/ @NeedsTransaction, @FreeDataSpaceValidationSQL, @FreeLogSpaceValidationSQL, @FreeTempDBSpaceValidationSQL
	        END --@@fetch_status <> -1
        END
    END 
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
GO
