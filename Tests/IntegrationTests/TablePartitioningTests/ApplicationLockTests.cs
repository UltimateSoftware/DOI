using System;
using System.Data.SqlClient;
using DDI.Tests.Integration;
using DDI.Tests.Integration.Tests.TablePartitioning;
using NUnit.Framework;


namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.TablePartitioning
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    [Parallelizable(ParallelScope.None)]
    public class ApplicationLockTests : SqlIndexJobBaseTest
    {
        /*
         * 
         * 1. happy path (get lock, release lock).  operations should work and be logged.
         * 2. get lock on lock already exists. should log error.
         * 3. release lock when it doesn't exist. should log error.
         * 4. 2 threads doing happy path, at the same time...and staggered.
         * 5. 1 thread on disconnect?
         * 6. try the APPLOCK_TEST() function?  this is what the DDL trigger uses.
         * 7. try running job so that it's killed by business hours check.
         */
        private SqlConnection connection;

        private string connectionInfoMessage;

        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(ApplicationLockTestsHelper.KillSessionHoldingAppLock());
            connection = new SqlConnection(sqlHelper.GetConnectionString());
            connectionInfoMessage = String.Empty;

            connection.InfoMessage += (s, e) =>
            {
                connectionInfoMessage += e.Message;
            };
            connection.Open();
            sqlHelper.Execute("TRUNCATE TABLE Utility.RefreshIndexStructuresLog");
            sqlHelper.Execute("TRUNCATE TABLE Utility.RefreshIndexStructuresQueue");
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(ApplicationLockTestsHelper.KillSessionHoldingAppLock());
            if (connection != null)
            {
                connection.Close();
                connection.Dispose();
            }
            sqlHelper.Execute("TRUNCATE TABLE Utility.RefreshIndexStructuresLog");
            sqlHelper.Execute("TRUNCATE TABLE Utility.RefreshIndexStructuresQueue");
            sqlHelper.Execute("EXEC Utility.spRefreshMetadata_BusinessHoursSchedule");
        }

        [Test]
        public void HappyPath()
        {
            using (connection)
            {
                var spId = sqlHelper.ExecuteScalar<int>(connection, "SELECT CAST(@@SPID AS INT)");

                CheckForGrantableLock();
                GetLock(connection, spId, true, 1, 0, $"Application Lock successfully obtained for this SPID ({spId}).");
                ReleaseLock(spId, true, 0, 1, $"Application Lock successfully released for this SPID ({spId}).");
            }
        }

        [Test]
        public void Get2ndLockSameSession()
        {
            var spId = sqlHelper.ExecuteScalar<int>(connection, "SELECT CAST(@@SPID AS INT)");

            CheckForGrantableLock();
            //Get 1st lock
            GetLock(connection, spId, true, 1, 0, $"Application Lock successfully obtained for this SPID ({spId}).");
            //Get 2nd lock, with the same session
            GetLock(connection, spId, false, 1, 0, $"Could not obtain the Application lock.  Lock has already been granted to this SPID ({spId}).");
            //Release Lock.  a Single Lock Release should get rid of the lock
            ReleaseLock(spId, true, 0, 1, $"Application Lock successfully released for this SPID ({spId}).");
            //Release lock a 2nd time
            ReleaseLock(spId, false, 0, 1, $"Unable to release Application Lock.  There is no lock to release for this SPID ({spId}).  The lock is currently being held by no one.");
        }

        [Test]
        public void Get2ndLockDiffSession()
        {
            var spid = sqlHelper.ExecuteScalar<int>(connection, "SELECT CAST(@@SPID AS INT)");

            CheckForGrantableLock();
            //Get 1st lock
            GetLock(connection, spid, true, 1, 0, $"Application Lock successfully obtained for this SPID ({spid}).");
            //Get 2nd lock, with a different session
            GetLock(spid, false, 1, 0, $"Could not obtain the Application lock.  Lock has already been granted to SPID {spid}");
            //Release Lock.  a Single Lock Release should get rid of the lock
            ReleaseLock(spid, true, 0, 1, $"Application Lock successfully released for this SPID ({spid}).");
            //Release lock a 2nd time
            ReleaseLock(spid, false, 0, 1, $"Unable to release Application Lock.  There is no lock to release for this SPID ({spid}).  The lock is currently being held by no one.");
        }

        [Test]
        public void KillLockWithoutGettingLockFirst()
        {
            var spid = sqlHelper.ExecuteScalar<int>(connection, "SELECT CAST(@@SPID AS INT)");

            CheckForGrantableLock();

            //Release application lock
            ReleaseLock(spid, false, 0, 1, $"Unable to release Application Lock.  There is no lock to release for this SPID ({spid}).  The lock is currently being held by no one.");
        }

        [Test]
        public void RunApplicationLocksThroughQueue()
        {
            //Populate Queue
            sqlHelper.Execute(ApplicationLockTestsHelper.RunAppLockStatementsThroughQueue(1));
            
            //Run Queue
            sqlHelper.Execute("EXEC Utility.spRefreshIndexStructures_Run @OnlineOperations = 1");

            //Assertions
            //Start, info, and finish messages for Get
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>(@"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE IndexOperation = 'Get Application Lock' AND RunStatus = 'Start' AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'"));
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>(@"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE IndexOperation = 'Get Application Lock' AND RunStatus = 'Info' AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'"));
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>(@"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE IndexOperation = 'Get Application Lock' AND RunStatus = 'Finish' AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'"));
            //Start, info, and finish messages for Release
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>(@"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE IndexOperation = 'Release Application Lock' AND RunStatus = 'Start' AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'"));
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>(@"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE IndexOperation = 'Release Application Lock' AND RunStatus = 'Info' AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'"));
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>(@"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE IndexOperation = 'Release Application Lock' AND RunStatus = 'Finish' AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'"));
            //No error messages
            Assert.AreEqual(0, sqlHelper.ExecuteScalar<int>(@"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE IndexOperation = 'Release Application Lock' AND RunStatus = 'Error' AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'"));
        }

        [Test]
        public void RunApplicationLocksThroughQueueWithError()
        {
            var spid = sqlHelper.ExecuteScalar<int>(connection, "SELECT CAST(@@SPID AS INT)");

            //Populate Queue
            sqlHelper.Execute(connection, ApplicationLockTestsHelper.RunAppLockStatementsThroughQueueWithError(1));

            //Run Queue
            sqlHelper.Execute(connection, "EXEC Utility.spRefreshIndexStructures_Run @OnlineOperations = 1");

            //Assertions
            //Start, info, and finish messages for Release
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>(@"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE IndexOperation = 'Release Application Lock' AND RunStatus = 'Start' AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'"));
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>($@"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE IndexOperation = 'Release Application Lock' AND RunStatus = 'Error' AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73' AND ErrorText LIKE '%Unable to release Application Lock.  There is no lock to release for this SPID ({spid}).  The lock is currently being held by no one.%'"));
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>(@"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE IndexOperation = 'Release Application Lock' AND RunStatus = 'Finish' AND BatchId = '4B14EAD7-7C02-4F0D-9ADB-B7F49EAEFD73'"));
        }

        [Test]
        public void KilledByBusinessHoursCheckBeforeRun()
        {
            //Make sure Business Hours are set so that it will fail and kill the job.
            sqlHelper.Execute("UPDATE Utility.BusinessHoursSchedule SET IsBusinessHours = 1");

            //Populate Queue
            sqlHelper.Execute(ApplicationLockTestsHelper.RunAppLockStatementsThroughQueue(0));

            //Run Queue
            sqlHelper.Execute("EXEC Utility.spRefreshIndexStructures_Run @OnlineOperations = 0");

            //Assert
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>("SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE RunStatus = 'Error' AND ErrorText = 'Stopping Offline DDI, before run started.  Business hours are here.'"));
        }

        [Test]
        public void KilledByBusinessHoursCheckDuringRun()
        {
            //Make sure Business Hours are set so that it will start the run.
            sqlHelper.Execute("UPDATE Utility.BusinessHoursSchedule SET IsBusinessHours = 0");

            //Populate Queue
            sqlHelper.Execute(ApplicationLockTestsHelper.RunAppLockStatementsThroughQueue(0));

            //insert command in queue to update business hours
            sqlHelper.Execute(@"EXEC Utility.spDDI_RefreshIndexStructures_InsertSQLCommand
                                    @ParentTableName = 'N/A',
                                    @ParentSchemaName = 'N/A',
                                    @SeqNoJustAfterSQLCommand = 2,
                                    @SQLCommand = 'UPDATE Utility.BusinessHoursSchedule SET IsBusinessHours = 1'");

            //Run Queue
            sqlHelper.Execute("EXEC Utility.spRefreshIndexStructures_Run @OnlineOperations = 0");

            //Assert
            Assert.AreEqual(1, sqlHelper.ExecuteScalar<int>("SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE RunStatus = 'Error' AND ErrorText = 'Stopping Offline DDI, after run started.  Business hours are here.'"));
        }

        private void ReleaseLock(int spId, bool shouldSucceed, byte isAppLockGrantedInSysDmTranLocksExpected, byte isAppLockGrantableInAppLockTestExpected, string messageExpected)
        {
            //Release Lock
            var operationType = "Release";

            this.connectionInfoMessage = "";
            sqlHelper.Execute(connection, ApplicationLockTestsHelper.ReleaseApplicationLockSql());

            //Assert
            var messageActual = this.connectionInfoMessage;
            var isAppLockGrantableInAppLockTestActual = sqlHelper.ExecuteScalar<int>(ApplicationLockTestsHelper.IsAppLockGrantableInAppLock_Test());
            ApplicationLockTestsHelper.AssertAppLockOperation(
                operationType,
                shouldSucceed,
                isAppLockGrantableInAppLockTestExpected,
                isAppLockGrantableInAppLockTestActual,
                isAppLockGrantedInSysDmTranLocksExpected,
                messageExpected,
                messageActual,
                spId);
        }
        private void GetLock(SqlConnection connection, int spId, bool shouldSucceed, byte isAppLockGrantedInSysDmTranLocksExpected, byte isAppLockGrantableInAppLockTestExpected, string messageExpected)
        {
            //Get Lock
            var operationType = "Get";

            this.connectionInfoMessage = "";
            sqlHelper.Execute(connection, ApplicationLockTestsHelper.GetApplicationLockSql());

            //Assert
            var messageActual = this.connectionInfoMessage;
            var isAppLockGrantableInAppLockTestActual =
                sqlHelper.ExecuteScalar<int>(ApplicationLockTestsHelper.IsAppLockGrantableInAppLock_Test());
            ApplicationLockTestsHelper.AssertAppLockOperation(
                operationType,
                shouldSucceed,
                isAppLockGrantableInAppLockTestExpected,
                isAppLockGrantableInAppLockTestActual,
                isAppLockGrantedInSysDmTranLocksExpected,
                messageExpected,
                messageActual,
                spId);
        }
        private void GetLock(int spId, bool shouldSucceed, byte isAppLockGrantedInSysDmTranLocksExpected, byte isAppLockGrantableInAppLockTestExpected, string messageExpected)
        {
            //Get Lock
            var operationType = "Get";

            string infoMessage = sqlHelper.ExecuteGetInfoMessageOnly(ApplicationLockTestsHelper.GetApplicationLockSql());

            //Assert
            var messageActual = infoMessage;
            var isAppLockGrantableInAppLockTestActual =
                sqlHelper.ExecuteScalar<int>(ApplicationLockTestsHelper.IsAppLockGrantableInAppLock_Test());
            ApplicationLockTestsHelper.AssertAppLockOperation(
                operationType,
                shouldSucceed,
                isAppLockGrantableInAppLockTestExpected,
                isAppLockGrantableInAppLockTestActual,
                isAppLockGrantedInSysDmTranLocksExpected,
                messageExpected,
                messageActual,
                spId);
        }
        private void CheckForGrantableLock()
        {
            //Lock should be grant-able
            var isAppLockGrantableInAppLockTest =
                sqlHelper.ExecuteScalar<int>(connection, ApplicationLockTestsHelper.IsAppLockGrantableInAppLock_Test());
            Assert.AreEqual(1, isAppLockGrantableInAppLockTest);
        }
    }
}
