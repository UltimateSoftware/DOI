using System;
using System.Threading.Tasks;
using NUnit.Framework;
using TestHelper = DOI.Tests.TestHelpers;

namespace DOI.Tests.IntegrationTests.RunTests.Offline
{
    //[Quarantine("ULTI-420019 Queue no longer running")]
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class OfflineRunTests : DOIBaseTest
    {
        /*
         * 1. happy path.  normal run should:
         *      a. Assert the DDIOfflineJobStatus setting at each stage of the run.
         *          - Before it starts, should = 'Stop'
         *          - After it starts, should = 'IntendToRun'
         *          - Once no SQL commands are running, should = 'Run'
         *          - Once it's done, should = 'Stop'
         * 2. run into business hours should stop and have the error logged.
         *      - if stopped in the middle of a transaction, the transaction should be allowed to complete. (or roll it back?)
         * 2. run while a sql command is still running should not work.
         * 3. if DDI is stopped for any reason, the Status should = 'Stop'.
         */

        protected TestHelper.OfflineRunTestsHelper offlineRunTestsHelper;

        protected const string TempTableName = "TempA";
        protected const string IndexName = "PK_TempA";
        protected const string ColumnStoreIndexName = "NCCI_TempA";

        [SetUp]
        public virtual void Setup()
        {
            this.sqlHelper = new TestHelper.SqlHelper();
            this.dataDrivenIndexTestHelper = new TestHelper.DataDrivenIndexTestHelper(this.sqlHelper);
            this.offlineRunTestsHelper = new TestHelper.OfflineRunTestsHelper();
            this.TearDown();
            sqlHelper.Execute(string.Format(TestHelper.ResourceLoader.Load("IndexesViewTests_Setup.sql")), 120);
            sqlHelper.Execute($@"
            INSERT INTO Utility.IndexesRowStore (SchemaName, TableName, IndexName, IsUnique, IsPrimaryKey, IsUniqueConstraint, IsClustered, KeyColumnList, IncludedColumnList, IsFiltered, FilterPredicate,[Fillfactor], OptionPadIndex, OptionStatisticsNoRecompute, OptionStatisticsIncremental, OptionIgnoreDupKey, OptionResumable, OptionMaxDuration, OptionAllowRowLocks, OptionAllowPageLocks, OptionDataCompression, NewStorage, PartitionColumn)
            VALUES(N'{SchemaName}', N'{TempTableName}', N'{IndexName}', 1, 1, 0, 0, N'TempAId ASC', NULL, 0, NULL, 80, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 'NONE', 'PRIMARY', NULL)");

            sqlHelper.Execute($@"
            INSERT INTO Utility.IndexesColumnStore ( SchemaName ,TableName ,IndexName ,IsClustered ,ColumnList ,IsFiltered ,FilterPredicate ,OptionDataCompression ,OptionCompressionDelay ,NewStorage ,PartitionColumn )
            VALUES (N'{SchemaName}', N'{TempTableName}', N'{ColumnStoreIndexName}',  0 , N'TempAId,TransactionUtcDt,IncludedColumn,TextCol' ,  0 , NULL,   'COLUMNSTORE' ,   0 ,    N'PRIMARY' ,  NULL)");

            sqlHelper.Execute($@"
            IF NOT EXISTS (   SELECT 'True'
                              FROM   sys.indexes i
                                     INNER JOIN sys.tables t ON i.object_id = t.object_id
                                     INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
                              WHERE  s.name = '{SchemaName}'
                                     AND t.name = '{TempTableName}'
                                     AND i.name = '{IndexName}' )
            BEGIN
                ALTER TABLE {SchemaName}.{TempTableName}
                ADD CONSTRAINT {IndexName}
                    PRIMARY KEY NONCLUSTERED ( TempAId ASC )
                    WITH ( PAD_INDEX = ON, FILLFACTOR = 80, IGNORE_DUP_KEY = OFF ,
                           STATISTICS_NORECOMPUTE = OFF ,
                           STATISTICS_INCREMENTAL = OFF, ALLOW_ROW_LOCKS = ON ,
                           ALLOW_PAGE_LOCKS = ON, DATA_COMPRESSION = NONE ) ON [PRIMARY];
            END;");

            sqlHelper.Execute($@"
    IF NOT EXISTS (   SELECT 'True'
                      FROM   sys.indexes i
                             INNER JOIN sys.tables t ON i.object_id = t.object_id
                             INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
                      WHERE  s.name = 'dbo'
                             AND t.name = 'TempA'
                             AND i.name = 'NCCI_TempA' )
    BEGIN
        CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_TempA
            ON dbo.TempA (
            TempAId ,
            TransactionUtcDt ,
            IncludedColumn ,
            TextCol )
            WITH ( DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, MAXDOP = 0 ,
                   DATA_COMPRESSION = COLUMNSTORE )
            ON [PRIMARY];
    END;");

            sqlHelper.Execute("EXEC Utility.spDDI_RefreshMetadata_SystemSettings");
            sqlHelper.Execute("EXEC Utility.spRefreshMetadata_BusinessHoursSchedule");

            sqlHelper.Execute(@"UPDATE dbo.SystemSettings
                                    SET SettingValue = '0'
                                    WHERE SettingName = 'DDIRunsPartitioningOnly'");
        }

        [TearDown]
        public virtual void TearDown()
        {
            sqlHelper.Execute(string.Format(TestHelper.ResourceLoader.Load("IndexesViewTests_TearDown.sql")), 120);
            sqlHelper.Execute("TRUNCATE TABLE Utility.RefreshIndexStructuresQueue");
            sqlHelper.Execute("TRUNCATE TABLE Utility.RefreshIndexStructuresLog");
            sqlHelper.Execute("EXEC Utility.spDDI_RefreshMetadata_SystemSettings");
            sqlHelper.Execute("EXEC Utility.spRefreshMetadata_BusinessHoursSchedule");
        }

        [Test]
        [Ignore("Offline Processing not enabled yet.")]
        public virtual void HappyPath()
        {
            //make some changes...
            sqlHelper.Execute($@"
            UPDATE Utility.IndexesRowStore 
            SET KeyColumnList = 'TempAId ASC,TransactionUtcDt ASC' 
            WHERE SchemaName = '{SchemaName}' 
                AND TableName = '{TempTableName}' 
                AND IndexName = '{IndexName}'");

            sqlHelper.Execute($@"
            UPDATE Utility.IndexesColumnStore 
            SET OptionDataCompression = 'COLUMNSTORE_ARCHIVE' 
            WHERE SchemaName = '{SchemaName}' 
                AND TableName = '{TempTableName}' 
                AND IndexName = '{ColumnStoreIndexName}'");

            //build queue, and assert that it was populated
            dataDrivenIndexTestHelper.ExecuteSPQueue(DatabaseName, SchemaName, TempTableName);
            int actualQueueEntryCount = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountPKOnly();
            Assert.AreEqual(2, actualQueueEntryCount);

            //run queue
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.SetToNonBusinessHoursSql);
            this.dataDrivenIndexTestHelper.ExecuteSPRun(DatabaseName, SchemaName, TempTableName);

            //assert that queue is now empty
            int queueCount = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountSQL();
            Assert.AreEqual(0, queueCount);

            //assert that no errors occurred...
            int errorsCount = offlineRunTestsHelper.GetLogErrorCount(SchemaName, TempTableName);
            Assert.AreEqual(0, errorsCount);

            //assert that the index updates happened...
            int indexesToUpdateCount = offlineRunTestsHelper.IndexesToUpdateInTableCount(SchemaName, TempTableName);
            Assert.AreEqual(0, indexesToUpdateCount);
        }

        [Test]
        [Ignore("Offline Processing not enabled yet.")]
        public void RunIntoBusinessHoursLogsError_StopBeforeQueue()
        {
            // Arrange

            //set schedule to business hours
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.SetToBusinessHoursSql);

            // insert into index metadata
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.IndexInsertSql);

            // populate queue
            this.dataDrivenIndexTestHelper.ExecuteSPQueue(DatabaseName, SchemaName, TempTableName);

            var countOfItemsInQueueBefore = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountPKOnly();
            Assert.AreEqual(2, countOfItemsInQueueBefore);

            // Act

            // run queue in offline mode.  this should do nothing and log an error in RefreshIndexStructuresLog stating that 'Stopping Offline DDI.  Business hours are here.'.
            this.dataDrivenIndexTestHelper.ExecuteSPRun(DatabaseName, SchemaName, TempTableName);

            // Validate

            // assert that the count of items in queue is now empty.
            var countOfItemsInQueueAfter = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountSQL();
            Assert.AreEqual(0, countOfItemsInQueueAfter, "Failure: Expecting Queue to be empty.");

            // assert that the 'Stopping Offline DDI.  Business hours are here.' error is in the Utility.RefreshIndexStructuresLog table.
            var businessHoursErrorCount = offlineRunTestsHelper.BusinessHoursErrorCount(SchemaName, TempTableName, "within");
            Assert.AreEqual(1, businessHoursErrorCount);

            string indexUpdateType = offlineRunTestsHelper.UpdateTypeForIndex(SchemaName, TempTableName, "PK_TempA");
            Assert.AreEqual("DropRecreate", indexUpdateType);
        }

        [Test]
        [Ignore("Offline Processing not enabled yet.")]
        public void RunIntoBusinessHoursLogsError_StopAtBeginningOfQueue()
        {
            // Arrange
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.SetToNonBusinessHoursSql);

            // insert into index metadata
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.IndexInsertSql);

            // populate queue
            this.dataDrivenIndexTestHelper.ExecuteSPQueue(DatabaseName, SchemaName, TempTableName);

            // insert step in the beginning of the queue to cause business hours error.
            this.offlineRunTestsHelper.InsertSqlCommandInQueue(SchemaName, TempTableName, 1, TestHelper.OfflineRunTestsHelper.SetToBusinessHoursSql);

            var countOfItemsInQueueBefore = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountPKOnly();
            Assert.AreEqual(2, countOfItemsInQueueBefore);


            // Act

            // run queue in offline mode.  this should do nothing and log an error in RefreshIndexStructuresLog stating that 'Stopping Offline DDI.  Business hours are here.'.
            this.dataDrivenIndexTestHelper.ExecuteSPRun(DatabaseName, SchemaName, TempTableName);

            // Validate

            // assert that the count of items in queue.
            var countOfItemsInQueueAfter = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountSQL();
            Assert.AreEqual(0, countOfItemsInQueueAfter, "Failure: Expecting Queue to be empty.");

            // assert that the 'Stopping Offline DDI.  Business hours are here.' error is in the Utility.RefreshIndexStructuresLog table.
            var businessHoursErrorCount = offlineRunTestsHelper.BusinessHoursErrorCount(SchemaName, TempTableName, "within");
            Assert.AreEqual(1, businessHoursErrorCount);

            string indexUpdateType = offlineRunTestsHelper.UpdateTypeForIndex(SchemaName, TempTableName, "PK_TempA");
            Assert.AreEqual("DropRecreate", indexUpdateType);
        }

        [Test]
        [Ignore("Offline Processing not enabled yet.")]
        public void RunIntoBusinessHoursLogsError_StopInsideTransaction()
        {
            // Arrange
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.SetToNonBusinessHoursSql);

            // insert into index metadata
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.IndexInsertSql);

            // populate queue
            this.dataDrivenIndexTestHelper.ExecuteSPQueue(DatabaseName, SchemaName, TempTableName);

            // insert step in the beginning of the queue to cause business hours error.
            var queueRowNumber = TestHelper.OfflineRunTestsHelper.GetSeqNoForIndexOperationSql("Create Index");
            this.offlineRunTestsHelper.InsertSqlCommandInQueue(SchemaName, TempTableName, queueRowNumber, TestHelper.OfflineRunTestsHelper.SetToBusinessHoursSql);

            var countOfItemsInQueueBefore = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountPKOnly();
            Assert.AreEqual(2, countOfItemsInQueueBefore);

            // Act

            // run queue in offline mode.  this should do nothing and log an error in RefreshIndexStructuresLog stating that 'Stopping Offline DDI.  Business hours are here.'.
            this.dataDrivenIndexTestHelper.ExecuteSPRun(DatabaseName, SchemaName, TempTableName);

            // Validate

            // assert that the count of items in queue is now empty.
            var countOfItemsInQueueAfter = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountSQL();
            Assert.AreEqual(0, countOfItemsInQueueAfter, "Failure: Expecting Queue to be empty.");

            // assert that the 'Stopping Offline DDI.  Business hours are here.' error is in the Utility.RefreshIndexStructuresLog table.
            var businessHoursErrorCount = offlineRunTestsHelper.BusinessHoursErrorCount(SchemaName, TempTableName, "within");
            Assert.AreEqual(1, businessHoursErrorCount);

            string indexUpdateType = offlineRunTestsHelper.UpdateTypeForIndex(SchemaName, TempTableName, "PK_TempA");
            Assert.AreEqual("DropRecreate", indexUpdateType);
        }

        [Test]
        [Ignore("Offline Processing not enabled yet.")]
        public void RunIntoBusinessHoursLogsError_StopOutsideTransaction()
        {
            // Arrange
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.SetToNonBusinessHoursSql);

            // change index metadata
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.IntroduceNonTransactionalChange);

            // populate queue
            this.dataDrivenIndexTestHelper.ExecuteSPQueue(DatabaseName, SchemaName, TempTableName);

            // insert step in the middle of the queue to cause business hours error.
            var queueRowNumber = TestHelper.OfflineRunTestsHelper.GetSeqNoForIndexOperationSql("Alter Index");
            this.offlineRunTestsHelper.InsertSqlCommandInQueue(SchemaName, TempTableName, queueRowNumber, TestHelper.OfflineRunTestsHelper.SetToBusinessHoursSql);

            //get count of items in queue
            var countOfItemsInQueueBefore = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountNCCIOnly();
            Assert.AreEqual(1, countOfItemsInQueueBefore);

            // Act
            // run queue in offline mode.  this should do nothing and log an error in RefreshIndexStructuresLog stating that 'Stopping Offline DDI.  Business hours are here.'.
            this.dataDrivenIndexTestHelper.ExecuteSPRun(DatabaseName, SchemaName, TempTableName);

            // Validate

            // assert that the count of items in queue is now empty.
            var countOfItemsInQueueAfter = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountSQL();
            Assert.AreEqual(0, countOfItemsInQueueAfter, "Failure: Expecting Queue to be empty.");

            // assert that the 'Stopping Offline DDI.  Business hours are here.' error is in the Utility.RefreshIndexStructuresLog table.
            var businessHoursErrorCount = offlineRunTestsHelper.BusinessHoursErrorCount(SchemaName, TempTableName, "within");
            Assert.AreEqual(1, businessHoursErrorCount);

            string indexUpdateType = offlineRunTestsHelper.UpdateTypeForIndex(SchemaName, TempTableName, "NCCI_TempA");
            Assert.AreEqual("AlterRebuild", indexUpdateType);
        }

        [Test]
        [Ignore("Offline Processing not enabled yet.")]
        public void RunIntoBusinessHoursLogsError_StopAtTheEndOfQueue()
        {
            // Arrange
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.SetToNonBusinessHoursSql);

            // change index metadata
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.IntroduceNonTransactionalChange);

            // populate queue
            this.dataDrivenIndexTestHelper.ExecuteSPQueue(DatabaseName, SchemaName, TempTableName);

            // insert step in the end of the queue to cause business hours error.
            var queueRowNumber = TestHelper.OfflineRunTestsHelper.GetSeqNoForIndexOperationSql("Release Application Lock");
            this.offlineRunTestsHelper.InsertSqlCommandInQueue(SchemaName, TempTableName, queueRowNumber, TestHelper.OfflineRunTestsHelper.SetToBusinessHoursSql);

            //get count of items in queue
            var countOfItemsInQueueBefore = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountNCCIOnly();
            Assert.AreEqual(1, countOfItemsInQueueBefore);

            // Act
            // run queue in offline mode.  this should do nothing and log an error in RefreshIndexStructuresLog stating that 'Stopping Offline DDI.  Business hours are here.'.
            this.dataDrivenIndexTestHelper.ExecuteSPRun(DatabaseName, SchemaName, TempTableName);

            // Validate

            // assert that the count of items in queue is now empty.
            var countOfItemsInQueueAfter = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountSQL();
            Assert.AreEqual(0, countOfItemsInQueueAfter, "Failure: Expecting Queue to be empty.");

            // assert that the 'Stopping Offline DDI.  Business hours are here.' error is in the Utility.RefreshIndexStructuresLog table.
            var businessHoursErrorCount = offlineRunTestsHelper.BusinessHoursErrorCount(SchemaName, TempTableName, "within");
            Assert.AreEqual(1, businessHoursErrorCount);

            string indexUpdateType = offlineRunTestsHelper.UpdateTypeForIndex(SchemaName, TempTableName, "NCCI_TempA");
            Assert.AreEqual("None", indexUpdateType);
        }

        [Test]
        [Ignore("Offline Processing not enabled yet.")]
        public virtual void StoppedRun()
        {
            this.sqlHelper.Execute(TestHelper.OfflineRunTestsHelper.SetToNonBusinessHoursSql);

            //make change to rebuild NCCI...
            sqlHelper.Execute($@"
                UPDATE Utility.IndexesColumnStore 
                SET OptionDataCompression = 'COLUMNSTORE_ARCHIVE' 
                WHERE SchemaName = '{SchemaName}' 
                    AND TableName = '{TempTableName}' 
                    AND IndexName = '{ColumnStoreIndexName}'");

            //populate queue in offline mode
            dataDrivenIndexTestHelper.ExecuteSPQueue(DatabaseName, SchemaName, TempTableName);

            //assert that there are items in the queue
            var offlineQueueCount = TestHelper.OfflineRunTestsHelper.GetOfflineQueueCountSQL();
            Assert.AreNotEqual(0, offlineQueueCount);

            //insert delay of 1 minute into queue
            var alterIndexSeqNo = TestHelper.OfflineRunTestsHelper.GetSeqNoForIndexOperationSql("Alter Index");
            TimeSpan lengthOfdelay = new TimeSpan(0, 0, 1, 0);
            offlineRunTestsHelper.InsertDelayInQueue(SchemaName, TempTableName, alterIndexSeqNo, lengthOfdelay);

            //run queue
            Task result = this.dataDrivenIndexTestHelper.ExecuteSPRunAsync(DatabaseName, SchemaName, TempTableName);

            //wait until the application lock is taken, then stop the DDI run
            Func<bool> getApplicationLock = () => offlineRunTestsHelper.GetApplicationLock();
            TestHelper.WaitHelper.WaitFor(getApplicationLock, 30000);
            sqlHelper.Execute("EXEC Utility.spRefreshIndexStructures_Stop");

            //assert that the KILL command appears in the log.
            var killLogCount = offlineRunTestsHelper.GetKillCommandInLogCount(SchemaName, TempTableName);
            Assert.AreEqual(2, killLogCount);

            //assert that the index update did not take place.
            string indexUpdateType = offlineRunTestsHelper.UpdateTypeForIndex(SchemaName, TempTableName, "NCCI_TempA");
            Assert.AreEqual("AlterRebuild", indexUpdateType);
        }
    }
}