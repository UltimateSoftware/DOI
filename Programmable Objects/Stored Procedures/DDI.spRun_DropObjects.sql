IF OBJECT_ID('[DDI].[spRun_DropObjects]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRun_DropObjects];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRun_DropObjects]
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
	EXEC DDI.spRun_DropObjects
		@SchemaName = 'dbo',
		@TableName = 'Liabilities'

*/
--DROP DATA SYNCH TRIGGER, BUT WE NEED TO FIND OUT WHICH TABLE HAS THE TRIGGER....
BEGIN TRY
	DECLARE @TriggerName SYSNAME = (SELECT tr.name
									FROM DDI.SysTriggers tr
										INNER JOIN DDI.SysTables t ON tr.parent_id = t.object_id
									WHERE t.name IN (@CurrentParentTableName, @CurrentParentTableName + '_OLD')
										AND tr.name LIKE '%|DataSynch' ESCAPE '|')

	DECLARE @DropDataSynchTriggerSQL NVARCHAR(MAX) = 'DROP TRIGGER ' + @TriggerName

	EXEC DDI.spRun_LogInsert 
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

	EXEC DDI.spRun_LogInsert 
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

	IF @DeleteTables = 1
	BEGIN
		DECLARE @DropPrepAndDataSynchTablesSQL NVARCHAR(MAX) = ''
		SELECT @DropPrepAndDataSynchTablesSQL += 'DROP TABLE ' + s.name + '.' + t.name + CHAR(13) + CHAR(10)
		FROM DDI.SysTables t
			INNER JOIN DDI.SysSchemas s ON s.schema_id = t.schema_id
		WHERE t.name LIKE '%' + @CurrentParentTableName + '|_DataSynch' ESCAPE '|'
			OR t.name LIKE '%' + @CurrentParentTableName + '|_%prep' ESCAPE '|'

		EXEC DDI.spRun_LogInsert 
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

		EXEC DDI.spRun_LogInsert
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
