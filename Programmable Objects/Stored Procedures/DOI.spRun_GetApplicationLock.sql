
GO

IF OBJECT_ID('[DOI].[spRun_GetApplicationLock]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRun_GetApplicationLock];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRun_GetApplicationLock]
    @DatabaseName NVARCHAR(128),
    @LockTimeout INT = 15000,
    @BatchId UNIQUEIDENTIFIER,
    @IsOnlineOperation BIT,
    @Debug BIT = 0

AS

/*
	EXEC DOI.spRun_GetApplicationLock
        @DatabaseName = 'PaymentReporting',
        @LockTimeout = 1000,
        @BatchId = '0483BDE0-118F-4865-9811-B0406C951161',
        @IsOnlineOperation = 1,
        @Debug = 1

        EXEC PaymentReporting.sys.sp_releaseapplock 
	        @DbPrincipal	= 'dbo',
	        @Resource		= 'DOI', 
	        @LockOwner		= 'Session' 

    EXEC Utility.spRefreshIndexStructures_ReleaseApplicationLock 
        @BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73', 
        @IsOnlineOperation = 1

SELECT APPLOCK_TEST('dbo', 'RefreshIndexStructures', 'Exclusive', 'Session')

    SELECT * FROM UTILITY.REFRESHINDEXSTRUCTURESLOG ORDER BY LOGDATETIME DESC
*/
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRY
    BEGIN TRAN
        DECLARE @TransactionId UNIQUEIDENTIFIER = NEWID(),
                @ErrorMessage NVARCHAR(2000) = 'Could not obtain the Application lock.',
                @CheckForLockSQL NVARCHAR(1000) = '',
                @ParamList NVARCHAR(100) = '',
                @GetAppLockSQL NVARCHAR(1000) = '',
                @ParamList2 NVARCHAR(100) = '',
                @SPID INT,
                @RC INT,
                @SQLStatement VARCHAR(500) = '
EXEC DOI.spRun_GetApplicationLock 
    @BatchId = ''' + CAST(@BatchId AS NVARCHAR(40)) + ''',
    @IsOnlineOperation = ' + CAST(@IsOnlineOperation AS NVARCHAR(1))

        SET @SPID = @@SPID

        --WE DON'T WANT TO USE APPLOCK_TEST() HERE BECAUSE IT ALLOWS MULTIPLE LOCK GETS AND WE ONLY WANT TO ALLOW 1.
        SET @CheckForLockSQL = N'
        SELECT @ErrorMessageOUT += ''  Lock has already been granted to '' + 
            CASE 
                WHEN request_session_id = ' + CAST(@SPID AS NVARCHAR(5)) + '
                THEN + ''this SPID (' + CAST(@SPID AS NVARCHAR(5)) + ').'' 
                ELSE ''SPID '' + CAST(request_session_id AS VARCHAR(5)) 
            END
		FROM   ' + @DatabaseName + '.sys.dm_tran_locks
		WHERE  resource_type = ''APPLICATION''
			AND request_mode = ''X''
			AND request_status = ''GRANT''
            AND request_owner_type = ''SESSION''
			AND resource_description LIKE ''%:\[DOI\]:%'' ESCAPE ''\'''

        SET @ParamList = N'@ErrorMessageOUT NVARCHAR(100) OUTPUT, @LockTimeout INT'

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
                @ErrorMessageOUT = @ErrorMessage OUTPUT,
                @LockTimeout = @LockTimeout

            IF @ErrorMessage <> 'Could not obtain the Application lock.'
            BEGIN
                RAISERROR(@ErrorMessage, 16, 1)
            END
        END
                
        SET @GetAppLockSQL = '
        EXEC @RC_OUT = ' + @DatabaseName + '.sys.sp_getapplock 
	        @DbPrincipal	= ''dbo'',
	        @Resource		= ''DOI'', 
	        @LockMode		= ''Exclusive'', 
	        @LockOwner		= ''Session'', 
	        @LockTimeout	= @LockTimeout'

        SET @ParamList = N'@RC_OUT INT OUTPUT, @LockTimeout INT'

        IF @Debug = 1
        BEGIN
            EXEC DOI.spPrintOutLongSQL 
                @SQLInput = @GetAppLockSQL ,
                @VariableName = N'@GetAppLockSQL'
        END
        ELSE
        BEGIN
            EXEC sys.sp_executesql
                @GetAppLockSQL,
                @ParamList,
                @RC_OUT = @RC OUTPUT,
                @LockTimeout = @LockTimeout

            IF @RC < 0 
            BEGIN
                SELECT  @ErrorMessage +=    CASE @RC
                                                WHEN -1 THEN 'The lock request timed out.'
                                                WHEN -2 THEN 'The lock request was canceled.'
                                                WHEN -3 THEN 'The lock request was chosen as a deadlock victim.'
                                                WHEN -999 THEN 'Parameter validation or other call error.'
                                                ELSE ''
                                            END
	            RAISERROR(@ErrorMessage, 16, 1)
            END
            ELSE
            BEGIN
                SET @ErrorMessage = 'Application Lock successfully obtained for this SPID (' + CAST(@SPID AS VARCHAR(5)) + ').'
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
                @IndexOperation         = 'Get Application Lock' ,        
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
        @IndexOperation         = 'Get Application Lock' ,        
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
