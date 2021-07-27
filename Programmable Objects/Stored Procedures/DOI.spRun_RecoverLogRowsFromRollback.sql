
GO

--<Migration ID="67c39ea0-3068-53c9-bc4d-08b8fa12e012" TransactionHandling="Custom" />
IF OBJECT_ID('[DOI].[spRun_RecoverLogRowsFromRollback]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRun_RecoverLogRowsFromRollback];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [DOI].[spRun_RecoverLogRowsFromRollback]
	@Log DOI.LogTT READONLY
	
--WITH NATIVE_COMPILATION, SCHEMABINDING
AS
/*
	EXEC DOI.spRun_RecoverLogRowsFromRollback
		@TransactionId = 'A4FBE249-2478-482A-886E-5B03964DBBD8'
*/
--NOW THAT WE HAVE ROLLED BACK, INSERT THE MISSING LOG ROWS FROM THE TABLE VAR.  THEY SHOULD STILL BE THERE DESPITE THE ROLLBACK.
--BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
	SET IDENTITY_INSERT DOI.Log ON

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

	SET IDENTITY_INSERT DOI.Log OFF
--END
GO
