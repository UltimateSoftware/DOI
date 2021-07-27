-- <Migration ID="0c57c425-db95-51a3-88a0-fe5bb26e4d58" TransactionHandling="Custom" />

GO

IF OBJECT_ID('[DOI].[spQueue_Insert]') IS NOT NULL
	DROP PROCEDURE [DOI].[spQueue_Insert];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create   PROCEDURE [DOI].[spQueue_Insert]
			@CurrentDatabaseName			NVARCHAR(128),
			@CurrentSchemaName				NVARCHAR(128),
			@CurrentTableName				NVARCHAR(128),
			@CurrentIndexName				NVARCHAR(128),
			@CurrentPartitionNumber			SMALLINT,
			@IndexSizeInMB					INT,
			@CurrentParentSchemaName		NVARCHAR(128),
			@CurrentParentTableName 		NVARCHAR(128),
			@CurrentParentIndexName			NVARCHAR(128),
			@IndexOperation					VARCHAR(50),
			@TableChildOperationId			SMALLINT = 0,
			@SQLStatement					VARCHAR(MAX),
			@TransactionId					UNIQUEIDENTIFIER,
			@BatchId						UNIQUEIDENTIFIER,
			@ExitTableLoopOnError			BIT 

--WITH NATIVE_COMPILATION, SCHEMABINDING 

AS
--BEGIN ATOMIC WITH  ( TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
    BEGIN TRY 
	    DECLARE @SeqNo SMALLINT = ISNULL((	SELECT MAX(SeqNo)
										    FROM DOI.Queue WITH(NOLOCK)
										    WHERE DatabaseName = @CurrentDatabaseName
												AND ParentSchemaName = @CurrentParentSchemaName
											    AND ParentTableName = @CurrentParentTableName), 0) + 1 

    	DELETE 
		FROM DOI.Queue 
		WHERE DatabaseName = @CurrentDatabaseName
			AND SchemaName = @CurrentSchemaName 
			AND TableName = @CurrentTableName 
			AND IndexName = @CurrentIndexName
			AND PartitionNumber = @CurrentPartitionNumber
			AND IndexOperation = @IndexOperation
			AND TableChildOperationId = @TableChildOperationId

	    INSERT INTO DOI.Queue ( DatabaseName, SchemaName ,TableName ,IndexName , PartitionNumber, IndexSizeInMB, ParentSchemaName, ParentTableName, ParentIndexName, IndexOperation, TableChildOperationId, SQLStatement , SeqNo, /*RunAutomaticallyOnDeployment, RunAutomaticallyOnSQLJob,*/ RunStatus, TransactionId, BatchId, ExitTableLoopOnError)
	    VALUES ( @CurrentDatabaseName, @CurrentSchemaName, @CurrentTableName, @CurrentIndexName , @CurrentPartitionNumber, @IndexSizeInMB, @CurrentParentSchemaName, @CurrentParentTableName, @CurrentParentIndexName, @IndexOperation, @TableChildOperationId, @SQLStatement, @SeqNo, /*@RunAutomaticallyOnDeployment, @RunAutomaticallyOnSQLJob,*/ 'Running', @TransactionId, @BatchId, @ExitTableLoopOnError)
    END TRY

    BEGIN CATCH
--	    IF @@TRANCOUNT > 0 ROLLBACK TRAN

	    SELECT	@CurrentDatabaseName, 
			    @CurrentSchemaName, 
			    @CurrentTableName, 
			    @CurrentIndexName, 
			    @CurrentPartitionNumber,
			    @IndexSizeInMB,
			    @CurrentParentSchemaName, 
			    @CurrentParentTableName, 
			    @CurrentParentIndexName,
			    @IndexOperation, 
			    @TableChildOperationId,
			    @TransactionId,
			    ERROR_MESSAGE()
	    THROW;
    END CATCH 
--END
GO
