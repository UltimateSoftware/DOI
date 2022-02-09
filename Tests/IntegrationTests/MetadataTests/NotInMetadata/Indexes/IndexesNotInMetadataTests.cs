using DOI.Tests.TestHelpers;
using NUnit.Framework;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwIndexesHelper;

namespace DOI.Tests.IntegrationTests.MetadataTests.NotInMetadata.Indexes
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class IndexNotInMetadataTests : DOIBaseTest
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

        [TestCase(true, false, "RowStore", true, TestName = "IndexRowStore_NotInMetadata_InSqlServer_NotInMetadata")]
        [TestCase(true, true, "RowStore", false, TestName = "IndexRowStore_NotInMetadata_InSqlServer_InMetadata")]
        [TestCase(false, false, "RowStore", false, TestName = "IndexRowStore_NotInMetadata_NotInSqlServer_NotInMetadata")]
        [TestCase(false, true, "RowStore", false, TestName = "IndexRowStore_NotInMetadata_NotInSqlServer_InMetadata")]
        [TestCase(true, false, "ColumnStore", true, TestName = "IndexColumnStore_NotInMetadata_InSqlServer_NotInMetadata")]
        [TestCase(true, true, "ColumnStore", false, TestName = "IndexColumnStore_NotInMetadata_InSqlServer_InMetadata")]
        [TestCase(false, false, "ColumnStore", false, TestName = "IndexColumnStore_NotInMetadata_NotInSqlServer_NotInMetadata")]
        [TestCase(false, true, "ColumnStore", false, TestName = "IndexColumnStore_NotInMetadata_NotInSqlServer_InMetadata")]
        public void Index_NotInMetadata(bool inSqlServer, bool inMetadata, string indexType, bool shouldBeFlaggedAsNotInMetadata)
        {
            //Setup
            if (inSqlServer && indexType == "RowStore")
            {

                this.sqlHelper.Execute(IndexNotInMetadataSqlStatement.CreateSqlServerRowStoreIndex, 30, false, DatabaseName);
            }

            if (inSqlServer && indexType == "ColumnStore")
            {

                this.sqlHelper.Execute(IndexNotInMetadataSqlStatement.CreateSqlServerColumnStoreIndex, 30, false, DatabaseName);
            }

            if (inMetadata && indexType == "RowStore")
            {
                this.sqlHelper.Execute(IndexNotInMetadataSqlStatement.InsertRowIndexInMetadata);
            }

            if (inMetadata && indexType == "ColumnStore")
            {
                this.sqlHelper.Execute(IndexNotInMetadataSqlStatement.InsertColumnIndexInMetadata);
            }

            //Action
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = '{DatabaseName}'");

            //Assert
            if (shouldBeFlaggedAsNotInMetadata)
            {
                this.VerifyThatObjectIsInTheNotInMetadataTable("Index in => SQL Server: true, Metadata: false, NotInMetadataTable: true");
            }
            else
            {
                this.VerifyThatObjectIsNotInTheNotInMetadataTable("Index in => SQL Server: true, Metadata: false, NotInMetadataTable: true");
            }
        }

        public void VerifyThatObjectIsInTheNotInMetadataTable(string message = null)
        {
            bool doesIndexExistInNotInMetadataTable = this.sqlHelper.ExecuteScalar<bool>(IndexNotInMetadataSqlStatement.DoesIndexExistInNotInMetadataTableSql);
            Assert.AreEqual(true, doesIndexExistInNotInMetadataTable, message);
        }

        public void VerifyThatObjectIsNotInTheNotInMetadataTable(string message = null)
        {
            bool doesIndexExistInNotInMetadataTable = this.sqlHelper.ExecuteScalar<bool>(IndexNotInMetadataSqlStatement.DoesIndexExistInNotInMetadataTableSql);
            Assert.AreEqual(false, doesIndexExistInNotInMetadataTable, message);
        }
    }
}
