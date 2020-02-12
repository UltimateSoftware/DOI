using System;
using DDI.Tests.Integration.Models;
using DDI.TestHelpers;
using NUnit.Framework;

namespace DDI.Tests.Integration
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class ErrorHandlingTests : SqlIndexJobBaseTest
    {
        /*

         * 1. Space failures in one table, continue to all other tables anyway.  all index types and index update type scenarios.  Error should be logged.  DONE.
         * 2. Error retry errors.  Should retry until successful.  Should retry a max of 3 times and then raise error.
         * 3. Resource Governor not turned on should generate error and exit loop. DONE.
         * 4. ExitTableLoopOnError tests?  Do we need these?
         * 5. Log rows should be preserved on transaction rollback.  DONE.
         * 6. Prep tables and objects should be dropped on failure.

         */
        protected const string TempTableName = "TempA";
        protected DataDrivenIndexTestHelper dataDrivenIndexTestHelper;
        protected TempARepository tempARepository;

        [SetUp]
        public virtual void Setup()
        {
            this.TearDown();
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_Setup.sql")), 120);
            this.dataDrivenIndexTestHelper = new DataDrivenIndexTestHelper(this.sqlHelper);
            this.tempARepository = new TempARepository(this.sqlHelper);

            this.dataDrivenIndexTestHelper.CreateIndex("PK_TempA");
            this.dataDrivenIndexTestHelper.CreateIndex("PK_TempB");
            this.dataDrivenIndexTestHelper.CreateIndex("CCI_TempB_Report");
            this.dataDrivenIndexTestHelper.CreateIndex("CDX_TempA");
            this.dataDrivenIndexTestHelper.CreateIndex("NCCI_TempA_Report");
            this.dataDrivenIndexTestHelper.CreateIndex("NIDX_TempA_Report");
            this.dataDrivenIndexTestHelper.CreateIndex("NIDX_TempA_Report2");
            this.dataDrivenIndexTestHelper.CreateForeignKeys();
        }

        [TearDown]
        public virtual void TearDown()
        {
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_TearDown.sql")), 120);
            this.sqlHelper.Execute($"UPDATE dbo.SystemSettings SET SettingValue = '1' WHERE SettingName LIKE 'FreeSpaceCheckerTestMultiplier%'");
            this.sqlHelper.Execute("ALTER RESOURCE GOVERNOR RECONFIGURE");
        }

        [TestCase("log", TestName = "Free Log Space Error does not stop process.")]
        [TestCase("data", TestName = "Free Data Space Error does not stop process.")]
        [TestCase("TempDB", TestName = "Free TempDB Space Error does not stop process.")]
        public void SpaceFailuresTests(string fileType)
        {
            /*
             * 1. Set up first table to fail due to space errors.
             * 2. Run 2nd table
             * 3. Assert to make sure error from first table was logged and that 2nd table operations went through.
             *
             */

            // setup the space error table.
            this.sqlHelper.Execute(@"
            CREATE TABLE dbo.AAA_SpaceError(
                SpaceErrorId INT IDENTITY(1,1) NOT NULL, 
	            BogusColumn INT NOT NULL 
		            CONSTRAINT Def_AAA_SpaceError_BogusColumn 
			            DEFAULT 0, 
            	SenselessText CHAR(255) NOT NULL,
            	SenselessText2 VARCHAR(MAX) NOT NULL 
	
	            CONSTRAINT PK_AAA_SpaceError PRIMARY KEY CLUSTERED (SpaceErrorId,BogusColumn))

            CREATE INDEX IDX_AAA_SpaceError_SenselessTextOnlineRebuild ON dbo.AAA_SpaceError(SenselessText)
            CREATE INDEX IDX_AAA_SpaceError_SenselessTextOfflineRebuild ON dbo.AAA_SpaceError(SenselessText) INCLUDE (SenselessText2)");

            this.sqlHelper.Execute(@"
            INSERT INTO [Utility].[Tables]
                    ([SchemaName]	,[TableName]	,[PartitionColumn]	,[NewStorage]	,[UseBCPStrategy]	,[IntendToPartition]	,[EnableRunPartitioning]	,[ReadyToQueue])
            VALUES  ('dbo'			,'AAA_SpaceError'	, NULL				,'PRIMARY'		,0					,0						,0							,1)");

            this.sqlHelper.Execute(@"
            INSERT INTO Utility.IndexesRowStore(SchemaName, TableName, IndexName, IsUnique, IsPrimaryKey, IsUniqueConstraint, IsClustered, KeyColumnList, IncludedColumnList, IsFiltered, FilterPredicate, [Fillfactor], OptionPadIndex, OptionStatisticsNoRecompute, OptionStatisticsIncremental, OptionIgnoreDupKey, OptionResumable, OptionMaxDuration, OptionAllowRowLocks, OptionAllowPageLocks, OptionDataCompression, NewStorage, PartitionColumn)
            VALUES(N'dbo', N'AAA_SpaceError', N'PK_AAA_SpaceError', 1, 1, 0, 1, N'SpaceErrorId ASC, BogusColumn ASC', NULL, 0, NULL, 0, 1, 0, 0, 0, DEFAULT, 0, 1, 1, 'PAGE', 'PRIMARY', NULL)
                ,(N'dbo', N'AAA_SpaceError', N'IDX_AAA_SpaceError_SenselessTextOnlineRebuild', 0, 0, 0, 0, N'SenselessText ASC', NULL, 0, NULL, 0, 1, 0, 0, 0, DEFAULT, 0, 1, 1, 'PAGE', 'PRIMARY', NULL)
                ,(N'dbo', N'AAA_SpaceError', N'IDX_AAA_SpaceError_SenselessTextOfflineRebuild', 0, 0, 0, 0, N'SenselessText ASC', N'SenselessText2', 0, NULL, 0, 1, 0, 0, 0, DEFAULT, 0, 1, 1, 'PAGE', 'PRIMARY', NULL)");

            this.sqlHelper.Execute(@"
            INSERT INTO Utility.DefaultConstraints(SchemaName, TableName, ColumnName, DefaultDefinition)
            VALUES(N'dbo', N'AAA_SpaceError', N'BogusColumn', N'((0))')");

            var indexRow = new IndexView()
            {
                SchemaName = "dbo",
                TableName = "TempA",
                IndexName = "CDX_TempA",
                IndexUpdateType = "None",
                IndexType = "RowStore",
                IsAllowPageLocksChanging = false,
                IsAllowRowLocksChanging = false,
                AreDropRecreateOptionsChanging = false,
                AreRebuildOptionsChanging = false,
                AreReorgOptionsChanging = false,
                AreSetOptionsChanging = false,
                IsIndexMissing = false,
                IsClustered = true,
                DropStatement = "DROP INDEX IF EXISTS dbo.TempA.CDX_TempA",
                CreateStatement = "IF NOT EXISTS (SELECT 'True' FROM sys.indexes i INNER JOIN sys.tables t ON i.object_id = t.object_id INNER JOIN sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = 'dbo' AND t.name = 'TempA' AND i.name = 'CDX_TempA')  BEGIN   CREATE  CLUSTERED INDEX CDX_TempA     ON dbo.TempA(TempAId ASC,TransactionUtcDt ASC)               WITH (           PAD_INDEX = ON,          FILLFACTOR = 90,          SORT_IN_TEMPDB = ON,          IGNORE_DUP_KEY = OFF,          STATISTICS_NORECOMPUTE = OFF,          STATISTICS_INCREMENTAL = OFF,          DROP_EXISTING = OFF,          ONLINE = OFF,          ALLOW_ROW_LOCKS = ON,          ALLOW_PAGE_LOCKS = ON,          MAXDOP = 0,          DATA_COMPRESSION = NONE)      ON [PRIMARY]    END",
                AlterSetStatement = "ALTER INDEX CDX_TempA ON dbo.TempA   SET ( IGNORE_DUP_KEY = OFF,     STATISTICS_NORECOMPUTE = OFF,     ALLOW_ROW_LOCKS = ON,     ALLOW_PAGE_LOCKS = ON)",
                AlterRebuildStatement = "ALTER INDEX CDX_TempA ON dbo.TempA   REBUILD PARTITION = ALL    WITH (       PAD_INDEX = ON,      FILLFACTOR = 90,      SORT_IN_TEMPDB = OFF,      IGNORE_DUP_KEY = OFF,      STATISTICS_NORECOMPUTE = OFF,      STATISTICS_INCREMENTAL = OFF,      ONLINE =  ON(WAIT_AT_LOW_PRIORITY (MAX_DURATION = 0 MINUTES, ABORT_AFTER_WAIT = NONE)),      ALLOW_ROW_LOCKS = ON,      ALLOW_PAGE_LOCKS = ON,      MAXDOP = 0,      DATA_COMPRESSION = NONE)",
                AlterReorganizeStatement = "ALTER INDEX CDX_TempA ON dbo.TempA   REORGANIZE PARTITION = ALL    WITH ( LOB_COMPACTION = ON)",
                RenameIndexSQL = "  SET DEADLOCK_PRIORITY 10  EXEC sp_rename   @objname = 'dbo.TempA.CDX_TempA',   @newname = 'CDX_TempA_OLD',   @objtype = 'INDEX'",
                RevertRenameIndexSQL = "  SET DEADLOCK_PRIORITY 10  EXEC sp_rename   @objname = 'dbo.TempA.CDX_TempA_OLD',   @newname = 'CDX_TempA',   @objtype = 'INDEX'"
            };

            // set up the changes in the other table(s)
            var tableName = "TempA";
            var indexName = "CDX_TempA";
            this.sqlHelper.Execute($"UPDATE IRS SET OptionPadIndex = CASE WHEN OptionPadIndex = 0 THEN 1 ELSE 0 END FROM Utility.IndexesRowStore IRS WHERE SchemaName = 'dbo' AND TableName = '{tableName}' AND IndexName = '{indexName}'");
            indexRow.AreRebuildOptionsChanging = true;
            indexRow.IndexUpdateType = "AlterRebuild";

            // add data to fail on space issue
            this.sqlHelper.Execute("INSERT INTO dbo.AAA_SpaceError(SenselessText, SenselessText2) SELECT TOP 5000 CONVERT(char(255), NEWID()), CONVERT(char(255), NEWID()) FROM sys.objects a CROSS JOIN sys.objects b");

            // set multiplier setting to always guarantee a space failure.
            string dbName = fileType == "TempDB" ? "tempdb" : "PaymentReporting";
            string vwFreeSpaceOnDiskFileType = fileType == "log" ? "log" : "data";
            var dbMetadataReader = this.sqlHelper.ExecuteReader($@"SELECT * FROM Utility.vwFreeSpaceOnDisk WHERE DBName = '{dbName}' AND FileType = '{vwFreeSpaceOnDiskFileType}'");

            var driveLetterWhereIndexesAreStored = string.Empty;
            var freeSpaceOnDisk = 0;
            while (dbMetadataReader.Read())
            {
                driveLetterWhereIndexesAreStored = Convert.ToString(dbMetadataReader["DriveLetter"]);
                freeSpaceOnDisk = Convert.ToInt32(dbMetadataReader["available_MB"]);
            }

            int indexSize = this.sqlHelper.ExecuteScalar<int>($"SELECT IndexSizeMB FROM Utility.vwIndexes WHERE IndexName = 'IDX_AAA_SpaceError_SenselessTextOnlineRebuild'");
            int multiplierSetting = (freeSpaceOnDisk / indexSize) + 1;
            this.sqlHelper.Execute($"UPDATE dbo.SystemSettings SET SettingValue = '{multiplierSetting}' WHERE SettingName = 'FreeSpaceCheckerTestMultiplierFor{fileType}Files'");

            var indexChangesReader = this.sqlHelper.ExecuteReader($@"
                SELECT  IndexUpdateType, 
                        IsAllowPageLocksChanging, 
                        IsAllowRowLocksChanging, 
                        AreDropRecreateOptionsChanging, 
                        AreRebuildOptionsChanging, 
                        AreReorgOptionsChanging, 
                        AreSetOptionsChanging, 
                        IndexType, 
                        IsClustered 
                FROM Utility.vwIndexes 
                WHERE SchemaName = 'dbo' 
                    AND TableName = '{tableName}' 
                    AND IndexName = '{indexName}'");

            // assert current values, BEFORE actually making the change.
            while (indexChangesReader.Read())
            {
                Assert.AreEqual(indexRow.IndexUpdateType, Convert.ToString(indexChangesReader["IndexUpdateType"]));
                Assert.AreEqual(indexRow.IsAllowPageLocksChanging, Convert.ToBoolean(indexChangesReader["IsAllowPageLocksChanging"]));
                Assert.AreEqual(indexRow.IsAllowRowLocksChanging, Convert.ToBoolean(indexChangesReader["IsAllowRowLocksChanging"]));
                Assert.AreEqual(indexRow.AreDropRecreateOptionsChanging, Convert.ToBoolean(indexChangesReader["AreDropRecreateOptionsChanging"]));
                Assert.AreEqual(indexRow.AreRebuildOptionsChanging, Convert.ToBoolean(indexChangesReader["AreRebuildOptionsChanging"]));
                Assert.AreEqual(indexRow.AreReorgOptionsChanging, Convert.ToBoolean(indexChangesReader["AreReorgOptionsChanging"]));
                Assert.AreEqual(indexRow.AreSetOptionsChanging, Convert.ToBoolean(indexChangesReader["AreSetOptionsChanging"]));
                Assert.AreEqual(indexRow.IndexType, Convert.ToString(indexChangesReader["IndexType"]));
                Assert.AreEqual(indexRow.IsClustered, Convert.ToBoolean(indexChangesReader["IsClustered"]));
            }

            // Act - Execute the index engine
            this.dataDrivenIndexTestHelper.ExecuteSPQueue(true);
            this.dataDrivenIndexTestHelper.ExecuteSPRun(true);

            // Assert - Check that index for AAA_SpaceError failed due to insufficient space error
            var errorLogReader = this.sqlHelper.ExecuteReader($@"
                SELECT RunStatus, ErrorText 
                FROM Utility.RefreshIndexStructuresLog 
                WHERE SchemaName = 'dbo' 
                    AND TableName = 'AAA_SpaceError' 
                    AND IndexOperation = 'Free {fileType} Space Validation' 
                    AND RunStatus <> 'Start'");
            if (!errorLogReader.HasRows)
            {
                Assert.Fail("Out of space error not found!");
            }

            while (errorLogReader.Read())
            {
                // check that the space error occurred, and that it was skipped.
                Assert.AreEqual("Error - Skipping...", Convert.ToString(errorLogReader["RunStatus"]));
                StringAssert.Contains($"NOT ENOUGH FREE SPACE ON {fileType.ToUpper()} DRIVE {driveLetterWhereIndexesAreStored}:", Convert.ToString(errorLogReader["ErrorText"]));
            }

            // check that the other table's changes were made
            indexRow.IndexUpdateType = "None";
            indexRow.AreRebuildOptionsChanging = false;

            indexChangesReader = this.sqlHelper.ExecuteReader($@"
            SELECT  IndexUpdateType, 
                    IsAllowPageLocksChanging, 
                    IsAllowRowLocksChanging, 
                    AreDropRecreateOptionsChanging, 
                    AreRebuildOptionsChanging, 
                    AreReorgOptionsChanging, 
                    AreSetOptionsChanging, 
                    IndexType, 
                    IsClustered 
            FROM Utility.vwIndexes 
            WHERE SchemaName = 'dbo' 
                AND TableName = '{tableName}' 
                AND IndexName = '{indexName}'");

            while (indexChangesReader.Read())
            {
                Assert.AreEqual(indexRow.IndexUpdateType, Convert.ToString(indexChangesReader["IndexUpdateType"]));
                Assert.AreEqual(indexRow.IsAllowPageLocksChanging, Convert.ToBoolean(indexChangesReader["IsAllowPageLocksChanging"]));
                Assert.AreEqual(indexRow.IsAllowRowLocksChanging, Convert.ToBoolean(indexChangesReader["IsAllowRowLocksChanging"]));
                Assert.AreEqual(indexRow.AreDropRecreateOptionsChanging, Convert.ToBoolean(indexChangesReader["AreDropRecreateOptionsChanging"]));
                Assert.AreEqual(indexRow.AreRebuildOptionsChanging, Convert.ToBoolean(indexChangesReader["AreRebuildOptionsChanging"]));
                Assert.AreEqual(indexRow.AreReorgOptionsChanging, Convert.ToBoolean(indexChangesReader["AreReorgOptionsChanging"]));
                Assert.AreEqual(indexRow.AreSetOptionsChanging, Convert.ToBoolean(indexChangesReader["AreSetOptionsChanging"]));
                Assert.AreEqual(indexRow.IndexType, Convert.ToString(indexChangesReader["IndexType"]));
                Assert.AreEqual(indexRow.IsClustered, Convert.ToBoolean(indexChangesReader["IsClustered"]));
            }
        }

        [Test]
        public void ResourceGovernorNotTurnedOnTest()
        {
            // 1.turn off Resource Gov.
            this.sqlHelper.Execute("ALTER RESOURCE GOVERNOR DISABLE;");

            // 2. Make index change.
            this.sqlHelper.Execute($"UPDATE IRS SET OptionPadIndex = CASE WHEN OptionPadIndex = 0 THEN 1 ELSE 0 END FROM Utility.IndexesRowStore IRS WHERE SchemaName = 'dbo' AND TableName = 'TempA' AND IndexName = 'CDX_TempA'");

            // 3. Run queue and Run SPs.
            this.dataDrivenIndexTestHelper.ExecuteSPQueue(true);
            try
            {
                dataDrivenIndexTestHelper.ExecuteSPRun(true);
            }
            catch (Exception e)
            {
                Assert.AreEqual("Online job is trying to run with Resource Governor off.  Aborting.  Need to turn on Resource Governor.", e.Message);
            }

            // 4.Check for Resource Gov error and NO OTHER ACTIVITY in the log table.
            var logErrorCount = this.sqlHelper.ExecuteScalar<int>("SELECT ErrorText FROM Utility.RefreshIndexStructuresLog WHERE ErrorText = 'Resource Governor is not turned on.  Aborting';");
        }

        [Test]
        public void LogRowsPreservedOnRollbackTest()
        {
            // 1. Make a DropRecreate change to an index.
            this.sqlHelper.Execute($"UPDATE IRS SET IsClustered = 0 FROM Utility.IndexesRowStore IRS WHERE SchemaName = 'dbo' AND TableName = 'TempA' AND IndexName = 'CDX_TempA'");

            // 2. Run Queue SP.
            this.sqlHelper.Execute($"TRUNCATE TABLE Utility.RefreshIndexStructuresQueue");
            this.sqlHelper.Execute($"TRUNCATE TABLE Utility.RefreshIndexStructuresLog");
            this.dataDrivenIndexTestHelper.ExecuteSPQueue(false);
            var transactionId = this.sqlHelper.ExecuteScalar<Guid>($"SELECT TOP 1 TransactionId FROM Utility.RefreshIndexStructuresQueue WHERE TableName = '{TempTableName}' AND TransactionId IS NOT NULL");
            var batchId = this.sqlHelper.ExecuteScalar<Guid>($"SELECT TOP 1 BatchId FROM Utility.RefreshIndexStructuresQueue WHERE TableName = '{TempTableName}'");
            var seqNo = this.sqlHelper.ExecuteScalar<int>($"SELECT TOP 1 SeqNo FROM Utility.RefreshIndexStructuresQueue WHERE TableName = '{TempTableName}' AND IndexName = 'CDX_TempA' AND IndexOperation = 'Drop Index'");

            // 3. Introduce an error into the Queue while the transaction is open.
            this.sqlHelper.ExecuteScalar<int>($"UPDATE Q SET SeqNo = SeqNo + 1 FROM Utility.RefreshIndexStructuresQueue Q WHERE SeqNo > {seqNo}");
            this.sqlHelper.Execute($@"
                INSERT INTO Utility.RefreshIndexStructuresQueue ( SchemaName ,TableName ,IndexName ,PartitionNumber ,IndexSizeInMB ,ParentSchemaName ,ParentTableName ,ParentIndexName ,IndexOperation ,IsOnlineOperation ,TableChildOperationId ,SQLStatement ,SeqNo ,DateTimeInserted ,InProgress ,RunStatus ,ErrorMessage ,TransactionId ,BatchId ,ExitTableLoopOnError )
                VALUES(N'dbo', N'{TempTableName}', N'CDX_TempA', 0, 0, N'dbo', N'{TempTableName}', N'CDX_TempA', 'Stop Processing', 0, 0, 'SELECT 1/0', {seqNo + 1}, SYSDATETIME(), 0, 'Start', '', '{transactionId}', '{batchId}', 0)");

            // 4. Run the Run SP.
            dataDrivenIndexTestHelper.ExecuteSPRun(false, "dbo", "TempA");

            // 5. Check that the Logged rows are still in the Log table.
            var countOfLogRows = this.sqlHelper.ExecuteScalar<int>($"SELECT COUNT(*) FROM Utility.RefreshIndexStructuresLog WHERE ErrorText = 'Divide by zero error encountered.'");
            Assert.AreEqual(1, countOfLogRows);
        }
    }
}
