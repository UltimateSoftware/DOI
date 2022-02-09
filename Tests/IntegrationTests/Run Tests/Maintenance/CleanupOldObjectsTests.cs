using DOI.Tests.TestHelpers;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.RunTests.Maintenance
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class CleanupOldObjectsTests : DOIBaseTest
    {
        [TearDown]
        public void TearDown()
        {
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("CleanupOldObjectsTests_TearDown.sql")), 120);
        }

        [Test]
        [Ignore("Scripting Engine Not Enabled yet.")]
        public void GivenDDIStoreProcCreatedTodayWhenSpRunsToDeleteObjectsOlderThanTheSpecifiedDateThenNothingShouldHappen()
        {
            int minAgeInDays = 10;
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spDDI_RefreshIndexStructures_ManualScript_WasRunOn_Some_Date"));
            bool desDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesDDIStoreProcExist(minAgeInDays));
            Assert.AreEqual(true, desDdiStoreProcExist);

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(10));
            desDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesDDIStoreProcExist(minAgeInDays));

            // Then
            Assert.AreEqual(true, desDdiStoreProcExist, "Since SP is not older than 10 days should not has been deleted");

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(1));
            desDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesDDIStoreProcExist(minAgeInDays));

            // Then
            Assert.AreEqual(true, desDdiStoreProcExist, "Since SP is not older than 1 day should not has been deleted");
        }

        [Test]
        [Ignore("Scripting Engine Not Enabled yet.")]
        public void GivenDDIStoreProcCreatedTodayWhenSpRunsToDeleteObjectsOlderThanTodayThenItShouldBeDropped()
        {
            int minAgeInDays = 0;
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spDDI_RefreshIndexStructures_ManualScript_WasRunOn_Some_Date"));
            bool doesDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesDDIStoreProcExist(minAgeInDays));
            Assert.AreEqual(true, doesDdiStoreProcExist);

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(minAgeInDays));
            doesDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesDDIStoreProcExist(minAgeInDays));

            // Then
            Assert.AreEqual(false, doesDdiStoreProcExist, "Since SP is older than now then it should has been dropped");
        }

        [Test]
        [Ignore("Scripting Engine Not Enabled yet.")]
        public void GivenTwoDDIStoreProcCreatedTodayWhenSpRunsToDeleteObjectsOlderThanTodayThenTheyShouldBeDropped()
        {
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spDDI_RefreshIndexStructures_ManualScript_WasRunOn_Some_Date"));
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spDDI_RefreshIndexStructures_ManualScript_WasRunOn_Some_Other_Date"));
            int dDiStoreProcCount = this.sqlHelper.ExecuteScalar<int>(CleanupOldObjectsSqlStatements.DDIStoreProcCount());
            Assert.AreEqual(2, dDiStoreProcCount);

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(0));
            dDiStoreProcCount = this.sqlHelper.ExecuteScalar<int>(CleanupOldObjectsSqlStatements.DDIStoreProcCount());

            // Then
            Assert.AreEqual(0, dDiStoreProcCount, "Since SPs are older than now then they should has been dropped");
        }

        [Test]
        [Ignore("Scripting Engine Not Enabled yet.")]
        public void GivenNonDDIStoreProcCreatedTodayWhenSpRunsToDeleteObjectsOlderThanTodayThenNothingShouldHappen()
        {
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spNonDDI_RefreshIndexStructuresProcedure"));
            bool doesNonDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesNonDDIStoreProcExist());
            Assert.AreEqual(true, doesNonDdiStoreProcExist);

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(0));
            doesNonDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesNonDDIStoreProcExist());

            // Then
            Assert.AreEqual(true, doesNonDdiStoreProcExist, "Since SP only drops DDI scripting SPs then it should not has been dropped");
        }

        [Test]
        [Ignore("Scripting Engine Not Enabled yet.")]
        public void GivenDDIStoreProcAndANonDDIOneCreatedTodayWhenSpRunsToDeleteObjectsOlderThanTodayThenOnlyTheDDIOneShouldBeDropped()
        {
            int minAgeInDays = 0;
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spDDI_RefreshIndexStructures_ManualScript_WasRunOn_Some_Date"));
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spNonDDI_RefreshIndexStructuresProcedure"));
            bool doesDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesDDIStoreProcExist(minAgeInDays));
            bool doesNonDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesNonDDIStoreProcExist());
            Assert.AreEqual(true, doesDdiStoreProcExist);
            Assert.AreEqual(true, doesNonDdiStoreProcExist);

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(minAgeInDays));
            doesDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesDDIStoreProcExist(minAgeInDays));
            doesNonDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesNonDDIStoreProcExist());

            // Then
            Assert.AreEqual(false, doesDdiStoreProcExist, "Since SP is older than now then it should has been dropped");
            Assert.AreEqual(true, doesNonDdiStoreProcExist, "Since SP only drops DDI scripting SPs then it should not has been dropped");
        }

        [Test]
        [Ignore("Scripting Engine Not Enabled yet.")]
        public void GivenTwoDDIStoreProcsCreatedTodayForOnlineAndOfflineChangesWhenSpRunsToDeleteObjectsOlderThanTodayThenBothShouldBeDropped()
        {
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spDDI_RefreshIndexStructures_ManualScript_Online_WasRunOn_Some_Date"));
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spDDI_RefreshIndexStructures_ManualScript_Offline_WasRunOn_Some_Date"));
            int dDiStoreProcCount = this.sqlHelper.ExecuteScalar<int>(CleanupOldObjectsSqlStatements.DDIStoreProcCount());
            Assert.AreEqual(2, dDiStoreProcCount);

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(0));
            dDiStoreProcCount = this.sqlHelper.ExecuteScalar<int>(CleanupOldObjectsSqlStatements.DDIStoreProcCount());

            // Then
            Assert.AreEqual(0, dDiStoreProcCount, "Since SPs are older than now then they should has been dropped");
        }

        [Test]
        [Ignore("Scripting Engine Not Enabled yet.")]
        public void GivenDDIStoreProcsCreatedTodayLabeledAsErroredOutWhenSpRunsToDeleteObjectsOlderThanTodayThenItShouldNotBeDropped()
        {
            int minAgeInDays = 0;
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spDDI_RefreshIndexStructures_ManualScript_Online_ErroredOutOn_Some_Date"));
            bool doesErroredOutDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesErroredOutDDIStoreProcExist(minAgeInDays));
            Assert.AreEqual(true, doesErroredOutDdiStoreProcExist);

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(minAgeInDays));
            doesErroredOutDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesErroredOutDDIStoreProcExist(minAgeInDays));

            // Then
            Assert.AreEqual(true, doesErroredOutDdiStoreProcExist, "Since SP only drops successful executed Sps it should not has been dropped");
        }

        [Test]
        public void GivenRegularTableWhenSpRunsToDeleteObjectsOlderThanTheSpecifiedDateThenNothingShouldHappen()
        {
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateTable("TempA"));
            bool doesTableExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesTableExist("TempA"));
            Assert.AreEqual(true, doesTableExist);

            // When deleting objects older than 10 days
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(10));
            doesTableExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesTableExist("TempA"));

            // Then
            Assert.AreEqual(true, doesTableExist, "Since table is not labeled as OLD and is not older than 10 days should not be deleted");

            // When deleting objects older than 1 day
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(1));
            doesTableExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesTableExist("TempA"));

            // Then
            Assert.AreEqual(true, doesTableExist, "Since table is not labeled as OLD and is not older than 1 day should not be deleted");

            // When deleting objects older than today
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(0));
            doesTableExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesTableExist("TempA"));

            // Then
            Assert.AreEqual(true, doesTableExist, "Since table is not labeled as OLD should not be deleted");
        }

        [Test]
        public void GivenOldTableLeftBehindTodayByPartitioningWhenSpRunsToDeleteObjectsOlderThanTenDaysThenNothingShouldHappen()
        {
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateTable("TempA_OLD"));
            bool doesTableExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesTableExist("TempA_OLD"));
            Assert.AreEqual(true, doesTableExist);

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(10));
            doesTableExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesTableExist("TempA_OLD"));

            // Then
            Assert.AreEqual(true, doesTableExist, "Since table is not older than 10 days should not be deleted");
        }

        [Test]
        public void GivenOldTableLeftBehindTodayByPartitioningWhenSpRunsToDeleteObjectsOlderThanTodayThenItShouldBeDeleted()
        {
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateTable("TempA_OLD"));
            bool doesTableExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesTableExist("TempA_OLD"));
            Assert.AreEqual(true, doesTableExist);

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(0));
            doesTableExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesTableExist("TempA_OLD"));

            // Then
            Assert.AreEqual(false, doesTableExist, "Since table older than today should has been deleted");
        }

        [Test]
        [Ignore("Scripting Engine Not Enabled yet.")]
        public void GivenOldTableLeftBehindTodayByPartitioningAndDDIStoreProCreatedTodayWhenSpRunsToDeleteObjectsOlderThanTodayThenTheyShouldBeDeleted()
        {
            int minAgeInDays = 0;
            // Given
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateSP("spDDI_RefreshIndexStructures_ManualScript_WasRunOn_Some_Date"));
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.CreateTable("TempA_OLD"));
            bool doesDdiManualScriptSpExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesDDIStoreProcExist(minAgeInDays));
            bool doesTableExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesTableExist("TempA_OLD"));
            Assert.AreEqual(true, doesDdiManualScriptSpExist);
            Assert.AreEqual(true, doesTableExist);

            // When
            this.sqlHelper.Execute(CleanupOldObjectsSqlStatements.ExecuteCleanupOldObjectsSP(minAgeInDays));
            doesDdiManualScriptSpExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesDDIStoreProcExist(minAgeInDays));
            doesTableExist = this.sqlHelper.ExecuteScalar<bool>(CleanupOldObjectsSqlStatements.DoesTableExist("TempA_OLD"));

            // Then
            Assert.AreEqual(false, doesDdiManualScriptSpExist, "Since SP is older than now then it should has been dropped");
            Assert.AreEqual(false, doesTableExist, "Since table older than today should has been deleted");
        }
    }
}