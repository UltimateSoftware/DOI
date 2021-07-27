-- <Migration ID="93e7be6c-baa1-43c0-b1bb-87d048cfd2d9" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!
IF OBJECT_ID('[DOI].[spQueue_InsertSQLCommand]') IS NOT NULL
	DROP PROCEDURE [DOI].[spQueue_InsertSQLCommand];

GO

/****** Object:  StoredProcedure [DOI].[spDDI_RefreshIndexStructures_InsertSQLCommand]    Script Date: 3/17/2021 11:55:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [DOI].[spQueue_InsertSQLCommand]
    @DatabaseName SYSNAME,
    @ParentTableName SYSNAME,
    @ParentSchemaName SYSNAME,
    @SeqNoJustAfterSQLCommand INT,
    @SQLCommand VARCHAR(MAX)
AS

/*
truncate table Utility.RefreshIndexStructuresQueue
DECLARE @BatchId UNIQUEIDENTIFIER

EXEC Utility.spRefreshIndexStructures_Queue
    @IsBeingRunDuringADeployment = 0,
    @BatchIdOUT = @BatchId

select * from Utility.RefreshIndexStructuresQueue

    EXEC Utility.spDDI_RefreshIndexStructures_InsertDelay
        @ParentTableName = 'TaxAgency_Audit',
        @ParentSchemaName = 'dbo',
        @SeqNoJustAfterDelay = 5,
        @LengthOfDelay = '00:01'

        select cast(getdate() as time)
        
*/

DECLARE @BatchId UNIQUEIDENTIFIER,
        @TransactionId UNIQUEIDENTIFIER,
        @TableName SYSNAME,
        @SchemaName SYSNAME

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRY
    BEGIN TRANSACTION

        SELECT  @SchemaName = SchemaName,
                @TableName = TableName,
                @BatchId = BatchId,
                @TransactionId = TransactionId
        FROM DOI.Queue WITH (TABLOCKX)
        WHERE SeqNo = @SeqNoJustAfterSQLCommand

        UPDATE DOI.Queue
        SET SeqNo = SeqNo + 1
        WHERE DatabaseName = @DatabaseName
            AND ParentSchemaName = @ParentSchemaName
            AND ParentTableName = @ParentTableName
            AND SeqNo >= @SeqNoJustAfterSQLCommand

		IF @@ROWCOUNT = 0 
		BEGIN;
			THROW 50000, 'Table was not found.', 1;
		END

        INSERT INTO DOI.Queue ( DatabaseName, SchemaName ,TableName ,IndexName , PartitionNumber, IndexSizeInMB, ParentSchemaName, ParentTableName, ParentIndexName, IndexOperation, TableChildOperationId, SQLStatement , SeqNo, RunStatus, TransactionId, BatchId, ExitTableLoopOnError)
        VALUES ( @DatabaseName, @SchemaName, @TableName, 'N/A' , 0, 0, @ParentSchemaName, @ParentTableName, 'N/A', 'Manual SQL Command', 0, @SQLCommand, @SeqNoJustAfterSQLCommand, 'Running', @TransactionId, @BatchId, 0)

    COMMIT TRANSACTION
END TRY

BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH
GO