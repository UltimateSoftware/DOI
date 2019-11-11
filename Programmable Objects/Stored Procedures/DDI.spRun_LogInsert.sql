IF OBJECT_ID('[DDI].[spRun_LogInsert]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRun_LogInsert];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRun_LogInsert]
			@CurrentDatabaseName	NVARCHAR(128),
			@CurrentSchemaName		NVARCHAR(128),
			@CurrentTableName		NVARCHAR(128) ,
			@CurrentIndexName		NVARCHAR(128) ,
			@CurrentPartitionNumber	SMALLINT,
			@IndexSizeInMB			INT,
			@SQLStatement			VARCHAR(MAX),
			@IndexOperation			VARCHAR(50),
			@IsOnlineOperation		BIT,
			@RowCount				INT,
			@TableChildOperationId	SMALLINT,
			@RunStatus				VARCHAR(20),
			@TransactionId			UNIQUEIDENTIFIER,
			@BatchId				UNIQUEIDENTIFIER,
			@ErrorText				VARCHAR(4000) = NULL,
			@SeqNo					INT,
			@ExitTableLoopOnError	BIT 
AS

/*
	DECLARE @Now datetime2 = sysdatetime()

	exec DDI.spRunLogInsert
		@CurrentDatabaseName = 'test',
		@CurrentSchemaName = 'test',
		@CurrentTableName = 'test',
		@CurrentIndexName = 'test',
		@CurrentDateTime = @Now output,
		@SQLStatement = 'bla',
		@ErrorText = NULL

	select @Now
*/

BEGIN TRY 
	IF @IndexSizeInMB IS NULL
	BEGIN
		SET @IndexSizeInMB = 0
	END
    
	INSERT INTO DDI.Log ( DatabaseName, SchemaName ,TableName ,IndexName, IndexSizeInMB, LoginName, UserName, LogDateTime, SQLStatement, IndexOperation, IsOnlineOperation, [RowCount], TableChildOperationId, RunStatus, ErrorText, TransactionId, BatchId, SeqNo, ExitTableLoopOnError)
	VALUES ( @CurrentDatabaseName, @CurrentSchemaName, @CurrentTableName, @CurrentIndexName, @IndexSizeInMB, SUSER_NAME(), USER_NAME(), SYSDATETIME(), @SQLStatement, @IndexOperation, @IsOnlineOperation, @RowCount, @TableChildOperationId, @RunStatus, @ErrorText, @TransactionId, @BatchId, @SeqNo, @ExitTableLoopOnError)
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRAN;
	THROW;
END CATCH 
GO
