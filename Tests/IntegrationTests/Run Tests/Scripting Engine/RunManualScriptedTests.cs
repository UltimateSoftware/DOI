using System;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Scripting_Engine;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.RunTests.Scripting_Engine
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]

    public class RunManualScriptedTests : DOIBaseTest
    {
        [TearDown]
        public void TearDown()
        {
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("RunManualScriptedTests_TearDown.sql")), 120);
        }

        [Test]
        [Ignore("Scripting Engine not enabled yet.")]
        public void GivenSPToBeRunByOnlineJobWhenManualScriptedSPRunsThenIfSPSucceedsItShouldBeRenamedToIncludeRunStatus()
        {
            // Given
            this.sqlHelper.Execute(RunManualScriptedSqlStatements.CreateSP("Online"));
            int dDiStoreProcCount = this.sqlHelper.ExecuteScalar<int>(RunManualScriptedSqlStatements.DDIStoreProcCount("Online"));
            Assert.AreEqual(1, dDiStoreProcCount);

            // When
            this.sqlHelper.Execute(RunManualScriptedSqlStatements.ExecuteRunManualScriptedSP(1));
            bool doesDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(RunManualScriptedSqlStatements.DoesDDIStoreProcExist("Online", "WasRunOn"));

            // Then
            Assert.AreEqual(true, doesDdiStoreProcExist, "Since SP was executed successfully it should has been renamed to denote success run status");
        }

        [Test]
        [Ignore("Scripting Engine not enabled yet.")]
        public void GivenSPToBeRunByOfflineJobWhenManualScriptedSPRunsThenIfSPSucceedsItShouldBeRenamedToIncludeRunStatus()
        {
            // Given
            this.sqlHelper.Execute(RunManualScriptedSqlStatements.CreateSP("Offline"));
            int dDiStoreProcCount = this.sqlHelper.ExecuteScalar<int>(RunManualScriptedSqlStatements.DDIStoreProcCount("Offline"));
            Assert.AreEqual(1, dDiStoreProcCount);

            // When
            this.sqlHelper.Execute(RunManualScriptedSqlStatements.ExecuteRunManualScriptedSP(0));
            bool doesDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(RunManualScriptedSqlStatements.DoesDDIStoreProcExist("Offline", "WasRunOn"));

            // Then
            Assert.AreEqual(true, doesDdiStoreProcExist, "Since SP was executed successfully it should has been renamed to denote success run status");
        }

        [Test]
        [Ignore("Scripting Engine not enabled yet.")]
        public void GivenSPToBeRunByOnlineJobWhenManualScriptedSPRunsThenIfSPFailsItShouldBeRenamedToIncludeRunStatus()
        {
            // Given
            this.sqlHelper.Execute(RunManualScriptedSqlStatements.CreateFailingSP("Online"));
            int dDiStoreProcCount = this.sqlHelper.ExecuteScalar<int>(RunManualScriptedSqlStatements.DDIStoreProcCount("Online"));
            Assert.AreEqual(1, dDiStoreProcCount);

            bool doesDdiStoreProcExist = false;
            // When
            try
            {
                this.sqlHelper.Execute(RunManualScriptedSqlStatements.ExecuteRunManualScriptedSP(1));
            }
            catch (Exception)
            {
                doesDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(RunManualScriptedSqlStatements.DoesDDIStoreProcExist("Online", "ErroredOutOn"));
            }

            // Then
            Assert.AreEqual(true, doesDdiStoreProcExist, "Since SP failed it should has been renamed to denote failure status");
        }

        [Test]
        [Ignore( "Scripting Engine not enabled yet.")]
        public void GivenSPToBeRunByOfflineJobWhenManualScriptedSPRunsThenIfSPFailsItShouldBeRenamedToIncludeRunStatus()
        {
            // Given
            this.sqlHelper.Execute(RunManualScriptedSqlStatements.CreateFailingSP("Offline"));
            int dDiStoreProcCount = this.sqlHelper.ExecuteScalar<int>(RunManualScriptedSqlStatements.DDIStoreProcCount("Offline"));
            Assert.AreEqual(1, dDiStoreProcCount);

            bool doesDdiStoreProcExist = false;
            // When
            try
            {
                this.sqlHelper.Execute(RunManualScriptedSqlStatements.ExecuteRunManualScriptedSP(0));
            }
            catch (Exception)
            {
                doesDdiStoreProcExist = this.sqlHelper.ExecuteScalar<bool>(RunManualScriptedSqlStatements.DoesDDIStoreProcExist("Offline", "ErroredOutOn"));
            }

            // Then
            Assert.AreEqual(true, doesDdiStoreProcExist, "Since SP failed it should has been renamed to denote failure status");
        }
    }
}