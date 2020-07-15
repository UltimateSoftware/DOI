USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRun_DropObjects]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRun_DropObjects];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRun_DropObjects]
    @CurrentDatabaseName NVARCHAR(128),
	@CurrentSchemaName NVARCHAR(128),
	@CurrentTableName NVARCHAR(128),
	@CurrentParentTableName NVARCHAR(128),
	@CurrentSeqNo INT,
	@ExitTableLoopOnError BIT ,
	@BatchId UNIQUEIDENTIFIER = NULL,
	@DeleteTables BIT = 0


AS

/*
	EXEC DOI.spRun_DropObjects
        @CurrentDatabaseName = 'PaymentReporting',
		@CurrentSchemaName = 'dbo',
		@CurrentTableName = 'Bai2BankTransactions'
        @CurrentParentTableName = 'Bai2BankTransactions'
*/
--DROP DATA SYNCH TRIGGER, BUT WE NEED TO FIND OUT WHICH TABLE HAS THE TRIGGER....
BEGIN TRY
	DECLARE @TriggerName SYSNAME = (SELECT tr.name
									FROM DOI.SysTriggers tr WITH (SNAPSHOT)
                                        INNER JOIN DOI.SysDatabases d WITH (SNAPSHOT) ON d.database_id = tr.database_id
										INNER JOIN DOI.SysTables t WITH (SNAPSHOT) ON tr.database_id = t.database_id
                                            AND tr.parent_id = t.object_id
									WHERE d.name = @CurrentDatabaseName
                                        AND t.name IN (@CurrentParentTableName, @CurrentParentTableName + '_OLD')
										AND tr.name LIKE '%|DataSynch' ESCAPE '|')

	DECLARE @DropDataSynchTriggerSQL NVARCHAR(MAX) = 'DROP TRIGGER IF EXISTS ' + @TriggerName,
            @DropBCPViewSQL VARCHAR(100) = 'DROP VIEW IF EXISTS dbo.vwCurrentBCPQuery',
            @DropCompareObjectsSQL VARCHAR(500) = '
DROP FUNCTION IF EXISTS dbo.fnCompareTableStructuresDetails;
DROP FUNCTION IF EXISTS dbo.fnCompareTableStructures;
DROP FUNCTION IF EXISTS dbo.fnActualIndexesForTable;
DROP FUNCTION IF EXISTS dbo.fnActualConstraintsForTable;'

	EXEC DOI.spRun_LogInsert 
        @CurrentDatabaseName    = @CurrentDatabaseName,
		@CurrentSchemaName		= 'N/A' , 
		@CurrentTableName		= 'N/A' ,  
		@CurrentIndexName		= 'N/A' ,  
		@CurrentPartitionNumber	= 0, 
		@IndexSizeInMB			= 0 ,
		@IndexOperation			= 'Drop Data Synch Trigger',
		@IsOnlineOperation		= 1 ,
		@RowCount				= 0 ,
		@SQLStatement			= @DropDataSynchTriggerSQL ,
		@ErrorText				= NULL,
		@TransactionId			= NULL,
		@TableChildOperationId	= 0,
		@BatchId				= @BatchId,
		@SeqNo					= @CurrentSeqNo,
		@RunStatus				= 'Start',
		@ExitTableLoopOnError	= @ExitTableLoopOnError

	EXEC(@DropDataSynchTriggerSQL)

	EXEC DOI.spRun_LogInsert 
        @CurrentDatabaseName    = @CurrentDatabaseName,
		@CurrentSchemaName		= 'N/A' , 
		@CurrentTableName		= 'N/A' ,  
		@CurrentIndexName		= 'N/A' , 
		@CurrentPartitionNumber	= 0,  
		@IndexSizeInMB			= 0 ,
		@IndexOperation			= 'Drop Data Synch Trigger',
		@IsOnlineOperation		= 1 ,
		@RowCount				= 0 ,
		@SQLStatement			= @DropDataSynchTriggerSQL ,
		@ErrorText				= NULL,
		@TransactionId			= NULL,
		@TableChildOperationId	= 0,
		@BatchId				= @BatchId,
		@SeqNo					= @CurrentSeqNo,
		@RunStatus				= 'Finish',
		@ExitTableLoopOnError	= @ExitTableLoopOnError

	EXEC DOI.spRun_LogInsert 
        @CurrentDatabaseName    = @CurrentDatabaseName,
		@CurrentSchemaName		= 'N/A' , 
		@CurrentTableName		= 'N/A' ,  
		@CurrentIndexName		= 'N/A' , 
		@CurrentPartitionNumber	= 0,  
		@IndexSizeInMB			= 0 ,
		@IndexOperation			= 'Drop BCP View',
		@IsOnlineOperation		= 1 ,
		@RowCount				= 0 ,
		@SQLStatement			= @DropBCPViewSQL ,
		@ErrorText				= NULL,
		@TransactionId			= NULL,
		@TableChildOperationId	= 0,
		@BatchId				= @BatchId,
		@SeqNo					= @CurrentSeqNo,
		@RunStatus				= 'Finish',
		@ExitTableLoopOnError	= @ExitTableLoopOnError

    EXEC(@DropBCPViewSQL)

    EXEC DOI.spRun_LogInsert 
        @CurrentDatabaseName    = @CurrentDatabaseName,
		@CurrentSchemaName		= 'N/A' , 
		@CurrentTableName		= 'N/A' ,  
		@CurrentIndexName		= 'N/A' , 
		@CurrentPartitionNumber	= 0,  
		@IndexSizeInMB			= 0 ,
		@IndexOperation			= 'Drop Compare Objects',
		@IsOnlineOperation		= 1 ,
		@RowCount				= 0 ,
		@SQLStatement			= @DropCompareObjectsSQL ,
		@ErrorText				= NULL,
		@TransactionId			= NULL,
		@TableChildOperationId	= 0,
		@BatchId				= @BatchId,
		@SeqNo					= @CurrentSeqNo,
		@RunStatus				= 'Finish',
		@ExitTableLoopOnError	= @ExitTableLoopOnError

    EXEC(@DropCompareObjectsSQL)

	IF @DeleteTables = 1
	BEGIN
		DECLARE @DropPrepAndDataSynchTablesSQL NVARCHAR(MAX) = ''
		SELECT @DropPrepAndDataSynchTablesSQL += 'DROP TABLE ' + s.name + '.' + t.name + CHAR(13) + CHAR(10)
		FROM DOI.SysTables t
            INNER JOIN DOI.SysDatabases d ON d.database_id = t.database_id
			INNER JOIN DOI.SysSchemas s ON s.schema_id = t.schema_id
		WHERE d.name = @CurrentDatabaseName
            AND (t.name LIKE '%' + @CurrentParentTableName + '|_DataSynch' ESCAPE '|'
			        OR t.name LIKE '%' + @CurrentParentTableName + '|_%prep' ESCAPE '|')

		EXEC DOI.spRun_LogInsert 
            @CurrentDatabaseName    = @CurrentDatabaseName,
			@CurrentSchemaName		= 'N/A' , 
			@CurrentTableName		= 'N/A' ,  
			@CurrentIndexName		= 'N/A' , 
			@CurrentPartitionNumber	= 0,  
			@IndexSizeInMB			= 0 ,
			@IndexOperation			= 'Clean Up Tables',
			@IsOnlineOperation		= 1 ,
			@RowCount				= 0 ,
			@SQLStatement			= @DropPrepAndDataSynchTablesSQL ,
			@ErrorText				= NULL,
			@TransactionId			= NULL,
			@TableChildOperationId	= 0,
			@BatchId				= @BatchId,
			@SeqNo					= @CurrentSeqNo,
			@RunStatus				= 'Start',
			@ExitTableLoopOnError	= @ExitTableLoopOnError
		
		EXEC(@DropPrepAndDataSynchTablesSQL)

		EXEC DOI.spRun_LogInsert
            @CurrentDatabaseName    = @CurrentDatabaseName, 
			@CurrentSchemaName		= 'N/A' , 
			@CurrentTableName		= 'N/A' ,  
			@CurrentIndexName		= 'N/A' , 
			@CurrentPartitionNumber	= 0,  
			@IndexSizeInMB			= 0 ,
			@IndexOperation			= 'Clean Up Tables',
			@IsOnlineOperation		= 1 ,
			@RowCount				= 0 ,
			@SQLStatement			= @DropPrepAndDataSynchTablesSQL ,
			@ErrorText				= NULL,
			@TransactionId			= NULL,
			@TableChildOperationId	= 0,
			@BatchId				= @BatchId,
			@SeqNo					= @CurrentSeqNo,
			@RunStatus				= 'Finish',
			@ExitTableLoopOnError	= @ExitTableLoopOnError
	END
    
END TRY
BEGIN CATCH
	THROW;
END CATCH

GO
