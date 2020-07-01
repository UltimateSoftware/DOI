IF OBJECT_ID('[DOI].[spRun_ReleaseApplicationLock]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRun_ReleaseApplicationLock];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRun_ReleaseApplicationLock]
    @DatabaseName NVARCHAR(128),
    @BatchId UNIQUEIDENTIFIER,
    @IsOnlineOperation BIT,
    @Debug BIT = 0
AS

/*
	EXEC DOI.spRun_GetApplicationLock
        @DatabaseName = 'PaymentReporting',
        @LockTimeout = 1000,
        @BatchId = '0483BDE0-118F-4865-9811-B0406C951161',
        @IsOnlineOperation = 1
        
    EXEC DOI.spRun_ReleaseApplicationLock
        @DatabaseName = 'PaymentReporting',
        @BatchId = '0483BDE0-118F-4865-9811-B0406C951161',
        @IsOnlineOperation = 1
*/
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRY
    BEGIN TRAN
        DECLARE @TransactionId UNIQUEIDENTIFIER = NEWID(),
                @ErrorMessage VARCHAR(500) = 'Unable to release Application Lock.',
                @CheckForLockSQL NVARCHAR(1000) = '',
                @ParamList NVARCHAR(100) = '',
                @ReleaseAppLockSQL NVARCHAR(1000) = '',
                @ParamList2 NVARCHAR(100) = '',
                @SPIDMessage VARCHAR(10) = '',
                @SPID INT,
                @RC INT,
                @SQLStatement VARCHAR(500) = '
EXEC DOI.spRun_ReleaseApplicationLock
    @BatchId = ''' + CAST(@BatchId AS NVARCHAR(40)) + ''',
    @IsOnlineOperation = ' + CAST(@IsOnlineOperation AS NVARCHAR(1))

        SET @SPID = @@SPID

        --WE DON'T WANT TO USE APPLOCK_TEST() HERE BECAUSE IT ALLOWS MULTIPLE LOCK GETS AND WE ONLY WANT TO ALLOW 1.
        SET @CheckForLockSQL = N'
        SELECT @SPIDMessageOUT += ''SPID '' + CAST(request_session_id AS VARCHAR(5))
		FROM   ' + @DatabaseName + '.sys.dm_tran_locks
		WHERE  resource_type = ''APPLICATION''
			AND request_mode = ''X''
			AND request_status = ''GRANT''
            AND request_owner_type = ''SESSION''
			AND resource_description LIKE ''%:\[DOI\]:%'' ESCAPE ''\'''

        SET @ParamList = N'@SPIDMessageOUT NVARCHAR(10) OUTPUT'

        IF @Debug = 1
        BEGIN
            EXEC DOI.spPrintOutLongSQL 
                @SQLInput = @CheckForLockSQL ,
                @VariableName = N'@CheckForLockSQL'
        END
        ELSE
        BEGIN
            EXEC sys.sp_executesql
                @CheckForLockSQL,
                @ParamList,
                @SPIDMessageOUT = @SPIDMessage OUTPUT
        END


        SET @SPIDMessage = CASE WHEN @SPIDMessage = '' THEN 'no one' ELSE @SPIDMessage END
        
        IF @SPIDMessage <> 'SPID ' + CAST(@SPID AS VARCHAR(5))
        BEGIN
            SET @ErrorMessage += '  There is no lock to release for this SPID (' + CAST(@SPID AS VARCHAR(5)) + ').  The lock is currently being held by ' + @SPIDMessage + '.'
            RAISERROR(@ErrorMessage, 16, 1)
        END

        SET @ReleaseAppLockSQL = '
	    EXEC @RC_OUT = ' + @DatabaseName + '.sys.sp_releaseapplock 
		    @DbPrincipal= ''dbo'',
		    @Resource	= ''DOI'', 
		    @LockOwner	= ''Session'''

        SET @ParamList = N'@RC_OUT INT OUTPUT'

        IF @Debug = 1
        BEGIN
            EXEC DOI.spPrintOutLongSQL 
                @SQLInput = @ReleaseAppLockSQL ,
                @VariableName = N'@ReleaseAppLockSQL'
        END
        ELSE
        BEGIN
            EXEC sys.sp_executesql
                @ReleaseAppLockSQL,
                @ParamList,
                @RC_OUT = @RC OUTPUT

	        IF @RC < 0
	        BEGIN
		        RAISERROR(@ErrorMessage, 16, 1)
	        END
            ELSE
            BEGIN
                SET @ErrorMessage = 'Application Lock successfully released for this SPID (' + CAST(@SPID AS VARCHAR(5)) + ').'
                RAISERROR(@ErrorMessage, 10, 1)
            END

            EXEC DOI.spRun_LogInsert
                @CurrentDatabaseName    = @DatabaseName,
                @CurrentSchemaName      = N'N/A' ,    
                @CurrentTableName       = N'N/A' ,     
                @CurrentIndexName       = N'N/A' ,     
                @CurrentPartitionNumber = 0 , 
                @IndexSizeInMB          = 0 ,          
                @SQLStatement           = @SQLStatement,          
                @IndexOperation         = 'Release Application Lock' ,        
                @IsOnlineOperation      = @IsOnlineOperation ,   
                @RowCount               = 0 ,               
                @TableChildOperationId  = 0 ,  
                @RunStatus              = 'Info' ,
                @TransactionId          = @TransactionId ,       
                @BatchId                = @BatchId ,             
                @InfoMessage            = @ErrorMessage,             
                @SeqNo                  = 0 ,                  
                @ExitTableLoopOnError   = 1
        END
    COMMIT TRAN
END TRY

BEGIN CATCH
    DECLARE @ActualErrorMessage VARCHAR(1000)
    SET @ActualErrorMessage = ERROR_MESSAGE()
    SET @ErrorMessage += '-' + @ActualErrorMessage
    IF @@TRANCOUNT > 0 ROLLBACK TRAN
    EXEC DOI.spRun_LogInsert
        @CurrentDatabaseName    = @DatabaseName,
        @CurrentSchemaName      = N'N/A' ,    
        @CurrentTableName       = N'N/A' ,     
        @CurrentIndexName       = N'N/A' ,     
        @CurrentPartitionNumber = 0 , 
        @IndexSizeInMB          = 0 ,          
        @SQLStatement           = @SQLStatement,          
        @IndexOperation         = 'Release Application Lock' ,        
        @IsOnlineOperation      = @IsOnlineOperation ,   
        @RowCount               = 0 ,               
        @TableChildOperationId  = 0 ,  
        @RunStatus              = 'Error' ,             
        @TransactionId          = @TransactionId ,       
        @BatchId                = @BatchId ,             
        @ErrorText              = @ErrorMessage,             
        @SeqNo                  = 0 ,                  
        @ExitTableLoopOnError   = 1
    
    RAISERROR(@ErrorMessage, 10, 1)
END CATCH

GO
