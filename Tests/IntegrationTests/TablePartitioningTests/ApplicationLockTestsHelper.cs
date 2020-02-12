using NUnit.Framework;
using Reporting.TestHelpers;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.TablePartitioning
{
    public class ApplicationLockTestsHelper
    {
        public static string GetApplicationLockSql()
        {
            return @"
                EXEC Utility.spRefreshIndexStructures_GetApplicationLock
                    @BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73',
                    @IsOnlineOperation = 1,
                    @LockTimeout = 1000";
        }
        public static string ReleaseApplicationLockSql()
        {
            return @"
                EXEC Utility.spRefreshIndexStructures_ReleaseApplicationLock
                    @BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73',
                    @IsOnlineOperation = 1";
        }

        public static string IsAppLockGrantedInSysDmTranLocks()
        {
            return @"
                    SELECT ISNULL(( SELECT 1
			                        FROM   sys.dm_tran_locks
			                        WHERE  resource_type = 'APPLICATION'
				                        AND request_mode = 'X'
				                        AND request_status = 'GRANT'
                                        AND request_owner_type = 'SESSION'
				                        AND resource_description LIKE '%:\[RefreshIndexStructures\]:%' ESCAPE '\'
                                        AND request_reference_count = 1), 0)";
        }

        public static string VerifyThatAppLockGetWasLogged()
        {
            return @"
                    SELECT ISNULL(( SELECT TOP 1 1
                                    FROM Utility.RefreshIndexStructuresLog
                                    WHERE IndexOperation = 'Get Application Lock'
                                        AND RunStatus = 'Info'
                                        AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'), 0)";
        }
        public static string VerifyThatAppLockReleaseWasLogged()
        {
            return @"
                    SELECT ISNULL(( SELECT TOP 1 1
                                    FROM Utility.RefreshIndexStructuresLog
                                    WHERE IndexOperation = 'Release Application Lock'
                                        AND RunStatus = 'Info'
                                        AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'), 0)";
        }

        public static string IsAppLockGrantableInAppLock_Test()
        {
            return 
                @"SELECT APPLOCK_TEST('dbo', 'RefreshIndexStructures', 'Exclusive', 'Session')";
        }
        public static string DoesLogHaveErrors()
        {
            return @"
                    SELECT ISNULL(( SELECT 1
                                    FROM Utility.RefreshIndexStructuresLog
                                    WHERE RunStatus = 'Error'
                                        AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'), 0)";
        }

        public static string RunAppLockStatementsThroughQueue(int isOnlineOperation)
        {
            return $@"
            DECLARE @GetApplicationLockSQL      NVARCHAR(300) = '
                            EXEC Utility.spRefreshIndexStructures_GetApplicationLock
                                @BatchId = ''4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'',
                                @IsOnlineOperation = {isOnlineOperation},
                                @LockTimeout = 1000',

        			@ReleaseApplicationLockSQL	NVARCHAR(300) = '
                            EXEC Utility.spRefreshIndexStructures_ReleaseApplicationLock
                                @BatchId = ''4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'',
                                @IsOnlineOperation = {isOnlineOperation}'

            EXEC Utility.spRefreshIndexStructuresQueueInsert
                @CurrentSchemaName = 'N/A',
                @CurrentTableName = 'N/A', 
                @CurrentIndexName = 'N/A', 
                @CurrentPartitionNumber = 0, 
                @IndexSizeInMB = 0,
                @CurrentParentSchemaName = 'N/A',
                @CurrentParentTableName = 'N/A', 
                @CurrentParentIndexName = 'N/A',
                @IndexOperation = 'Get Application Lock',
                @IsOnlineOperation = {isOnlineOperation}, 
                @TableChildOperationId = 0,
                @SQLStatement = @GetApplicationLockSQL,
                @TransactionId = NULL,
                @BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73',
                @ExitTableLoopOnError = 1

            EXEC Utility.spRefreshIndexStructuresQueueInsert
                @CurrentSchemaName = 'N/A',
                @CurrentTableName = 'N/A', 
                @CurrentIndexName = 'N/A', 
                @CurrentPartitionNumber = 0, 
                @IndexSizeInMB = 0,
                @CurrentParentSchemaName = 'N/A',
                @CurrentParentTableName = 'N/A', 
                @CurrentParentIndexName = 'N/A',
                @IndexOperation = 'Release Application Lock',
                @IsOnlineOperation = {isOnlineOperation}, 
                @TableChildOperationId = 0,
                @SQLStatement = @ReleaseApplicationLockSQL,
                @TransactionId = NULL,
                @BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73',
                @ExitTableLoopOnError = 1";
        }

        public static string RunAppLockStatementsThroughQueueWithError(int isOnlineOperation)
        {
            return $@"
            DECLARE @GetApplicationLockSQL      NVARCHAR(300) = '
                            EXEC Utility.spRefreshIndexStructures_ReleaseApplicationLock
                                @BatchId = ''4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'',
                                @IsOnlineOperation = {isOnlineOperation}'

            EXEC Utility.spRefreshIndexStructuresQueueInsert
                @CurrentSchemaName = 'N/A',
                @CurrentTableName = 'N/A', 
                @CurrentIndexName = 'N/A', 
                @CurrentPartitionNumber = 0, 
                @IndexSizeInMB = 0,
                @CurrentParentSchemaName = 'N/A',
                @CurrentParentTableName = 'N/A', 
                @CurrentParentIndexName = 'N/A',
                @IndexOperation = 'Release Application Lock',
                @IsOnlineOperation = {isOnlineOperation}, 
                @TableChildOperationId = 0,
                @SQLStatement = @GetApplicationLockSQL,
                @TransactionId = NULL,
                @BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73',
                @ExitTableLoopOnError = 1";
        }

        public static string KillSessionHoldingAppLock()
        {
            return @"  
                DECLARE @SQL VARCHAR(100) = ''

                SELECT @SQL += 'KILL ' + CAST(request_session_id AS VARCHAR(5))
                FROM   sys.dm_tran_locks
                WHERE  resource_type = 'APPLICATION'
	                AND request_mode = 'X'
	                AND request_status = 'GRANT'
	                AND resource_description LIKE '%:\[RefreshIndexStructures\]:%' ESCAPE '\'

                EXEC(@SQL)";
        }

        public static void AssertAppLockOperation(string operationType, bool shouldSucceed, int isAppLockGrantableInAppLock_Test_Expected, int isAppLockGrantableInAppLock_Test_Actual, int isAppLockGrantedInSysDmTranLocks_Expected, string message_Expected, string message_Actual, int spid)
        {
            string whichMessageToUse = shouldSucceed ? "Info" : "Error";
            string whichColumnToSelect = shouldSucceed ? "InfoMessage" : "ErrorText";

            var isAppLockGrantedInSysDmTranLocks_Actual = new SqlHelper().ExecuteScalar<int>(IsAppLockGrantedInSysDmTranLocks());

            //Assert if lock is grant-able in APPLOCK_TEST
            Assert.AreEqual(isAppLockGrantableInAppLock_Test_Expected, isAppLockGrantableInAppLock_Test_Actual);

            //Assert that lock was taken
            Assert.AreEqual(isAppLockGrantedInSysDmTranLocks_Expected, isAppLockGrantedInSysDmTranLocks_Actual);

            //Assert message
            StringAssert.Contains(message_Expected, message_Actual);

            //Assert if message was logged
            var wasAppLockOperationLogged = new SqlHelper().ExecuteScalar<int>($@"
                                                                        SELECT ISNULL((SELECT TOP 1 1
                                                                        FROM Utility.RefreshIndexStructuresLog
                                                                        WHERE IndexOperation = '{operationType} Application Lock'
                                                                            AND RunStatus = '{whichMessageToUse}'
                                                                            AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'
                                                                            AND {whichColumnToSelect} LIKE '%{message_Expected}%'), 0)");
            Assert.AreEqual(1, wasAppLockOperationLogged);
        }
    }
}
