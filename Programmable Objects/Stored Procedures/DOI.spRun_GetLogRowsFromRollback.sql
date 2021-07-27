IF OBJECT_ID('[DOI].[spRun_GetLogRowsFromRollback]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRun_GetLogRowsFromRollback];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRun_GetLogRowsFromRollback]
	@TransactionId UNIQUEIDENTIFIER

AS
/*
	EXEC Utility.spRefreshIndexStructures_GetLogRowsFromRollback
		@TransactionId = 'A4FBE249-2478-482A-886E-5B03964DBBD8'
*/

--ANY LOG ENTRIES DURING THE TRANSACTION ARE GOING TO BE LOST, SO PUT THEM INTO TABLE VAR TO GET AROUND THIS...
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
		
FROM   DOI.Log WITH (NOLOCK)
WHERE  TransactionId = @TransactionId;


GO