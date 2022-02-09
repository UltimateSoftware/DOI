using DOI.Tests.TestHelpers;
using NUnit.Framework;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwIndexesHelper;
namespace DOI.Tests.IntegrationTests.MetadataTests.NotInMetadata.Constraints
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class CheckConstraintsNotInMetadataTests : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            this.TearDown();
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_Setup.sql")), 120);
        }

        [TearDown]
        public void TearDown()
        {
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("IndexesViewTests_TearDown.sql")), 120);
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
        }

        [TestCase(true, false, true, TestName = "CheckConstraint_NotInMetadata_InSqlServer_NotInMetadata")]
        [TestCase(true, true, false, TestName = "CheckConstraint_NotInMetadata_InSqlServer_InMetadata")]
        [TestCase(false, false, false, TestName = "CheckConstraint_NotInMetadata_NotInSqlServer_NotInMetadata")]
        [TestCase(false, true, false, TestName = "CheckConstraint_NotInMetadata_NotInSqlServer_InMetadata")]
        public void CheckConstraint_NotInMetadata(bool inSqlServer, bool inMetadata, bool shouldBeFlaggedAsNotInMetadata)
        {
            //Setup
            if (!inSqlServer)
            {
                this.sqlHelper.Execute(ConstraintsNotInMetadataSqlStatement.DropCheckConstraint, 30, false, DatabaseName);
            }

            if (!inMetadata)
            {
                this.sqlHelper.Execute($"DELETE DOI.CheckConstraints WHERE DatabaseName = '{DatabaseName}' AND CheckConstraintName = 'Chk_TempA_TransactionUtcDt'");
            }

            //Action
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = '{DatabaseName}'");

            //Assert
            if (shouldBeFlaggedAsNotInMetadata)
            {
                this.VerifyThatObjectIsInTheNotInMetadataTable("Constraint in => SQL Server: true, Metadata: false, NotInMetadataTable: true");
            }
            else
            {
                this.VerifyThatObjectIsNotInTheNotInMetadataTable("Constraint in => SQL Server: true, Metadata: false, NotInMetadataTable: true");
            }
        }

        public void VerifyThatObjectIsInTheNotInMetadataTable(string message = null)
        {
            bool doesCheckConstraintExistInNotInMetadataTableSql = this.sqlHelper.ExecuteScalar<bool>(ConstraintsNotInMetadataSqlStatement.DoesCheckConstraintExistInNotInMetadataTableSql);
            Assert.AreEqual(true, doesCheckConstraintExistInNotInMetadataTableSql, message);
        }

        public void VerifyThatObjectIsNotInTheNotInMetadataTable(string message = null)
        {
            bool doesCheckConstraintExistInNotInMetadataTableSql = this.sqlHelper.ExecuteScalar<bool>(ConstraintsNotInMetadataSqlStatement.DoesCheckConstraintExistInNotInMetadataTableSql);
            Assert.AreEqual(false, doesCheckConstraintExistInNotInMetadataTableSql, message);
        }
    }
}
