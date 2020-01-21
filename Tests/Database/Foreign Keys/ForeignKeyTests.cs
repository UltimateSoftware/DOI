using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.Models;
using TestHelper = Reporting.TestHelpers;

namespace Reporting.Ingestion.Integration.Tests.Database.Foreign_Keys
{
    using MongoDB.Bson;

    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class ForeignKeyTests
    {
        /*
         * 1. drop parent FKs
         * 2. drop referencing FKs
         * 3. create parent FKs
         * 4. create referencing FKs
         * 5. enable FKs
         * 6. disable FKs
         * 7. run create referencing FK when ref tables does not exist
         * 8. run create parent FK when parent table does not exist
         * 9. test that all FKs were created
         * 10.drop parent FKs metadata only
         * 11.drop referencing FKs metadata only
         * 12.create parent FKs metadata only
         * 13.create referencing FKs metadata only
         * 14.enable FKs metadata only
         * 15.disable FKs metadata only
         */
        protected TestHelper.SqlHelper sqlHelper;

        [SetUp]
        public void Setup()
        {
            this.sqlHelper = new TestHelper.SqlHelper();
            TearDown();
            sqlHelper.Execute(ForeignKeySqlStatements.SetupFKTablesSql);
            sqlHelper.Execute(ForeignKeySqlStatements.InsertFKMetadata);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(ForeignKeySqlStatements.TearDownSql);
        }

        [OneTimeTearDown]
        public void OneTimeTearDown()
        {
            sqlHelper.Execute(ForeignKeySqlStatements.OneTimeTearDownSql);
        }

        [Test]
        public void ParentFkDropTest()
        {
            sqlHelper.Execute(ForeignKeySqlStatements.DropParentFkSql);
            int result = sqlHelper.ExecuteScalar<int>(ForeignKeySqlStatements.VerifyFkExistsSql);
            Assert.AreEqual(0, result);
        }
        
        [Test]
        public void ReferencingFkDropTest()
        {
            sqlHelper.Execute(ForeignKeySqlStatements.DropReferencingFkSql);
            int result = sqlHelper.ExecuteScalar<int>(ForeignKeySqlStatements.VerifyFkExistsSql);
            Assert.AreEqual(0, result);
        }
        
        [Test]
        public void ParentFkCreateTest()
        {
            sqlHelper.Execute(ForeignKeySqlStatements.CreateParentFkSql);
            int result = sqlHelper.ExecuteScalar<int>(ForeignKeySqlStatements.VerifyFkExistsSql);
            Assert.AreEqual(1, result);
        }

        [TestCase("FK_CheckConstraints_Tables_SchemaName_TableName")]
        [TestCase("FK_DefaultConstraints_Tables_SchemaName_TableName")]
        [TestCase("FK_IndexColumnStorePartitions_IndexesColumnStore_SchemaName_TableName_IndexName")]
        [TestCase("FK_IndexesColumnStore_Tables_SchemaName_TableName")]
        [TestCase("FK_IndexesRowStore_Tables_SchemaName_TableName")]
        [TestCase("FK_IndexRowStorePartitions_IndexesRowStore_SchemaName_TableName_IndexName")]
        [TestCase("FK_Statistics_Tables_SchemaName_TableName")]
        public void ParentFkCreateMetadataOnlyTest(string metadataForeignKey)
        {
            var sql = $@"
                SELECT  top 1 val = FK.FKName FROM Utility.ForeignKeys  FK
                WHERE parentschemaname = 'utility'
                AND FK.FKName  = '{metadataForeignKey}' ";

            string result = sqlHelper.ExecuteScalar<string>(sql);
            Assert.AreEqual(metadataForeignKey, result, $"Expecting foreign key to exist: {result} ");
        }

        [Test]
        public void ParentFkCreateWhenTableDoesNotExistTest()
        {
            sqlHelper.Execute("DROP TABLE IF EXISTS dbo.FKChildTable");
            sqlHelper.Execute(ForeignKeySqlStatements.CreateParentFkSql);
            int result = sqlHelper.ExecuteScalar<int>(ForeignKeySqlStatements.VerifyFkExistsSql);
            Assert.AreEqual(0, result);
        }

        [Test]
        public void ReferencingFkCreateTest()
        {
            sqlHelper.Execute(ForeignKeySqlStatements.CreateReferencingFkSql);
            int result = sqlHelper.ExecuteScalar<int>(ForeignKeySqlStatements.VerifyFkExistsSql);
            Assert.AreEqual(1, result);
        }
        
        [Test]
        public void ReferencingFkCreateWhenTableDoesNotExistTest()
        {
            sqlHelper.Execute("DROP TABLE IF EXISTS dbo.FKChildTable");
            sqlHelper.Execute(ForeignKeySqlStatements.CreateReferencingFkSql);
            int result = sqlHelper.ExecuteScalar<int>(ForeignKeySqlStatements.VerifyFkExistsSql);
            Assert.AreEqual(0, result);
        }

        [Test]
        public void FkDisableAllNonMetadataTest()
        {
            sqlHelper.Execute("EXEC Utility.spForeignKeysMetadataInsert");
            sqlHelper.Execute(ForeignKeySqlStatements.CreateAllFksSql);
            sqlHelper.Execute(ForeignKeySqlStatements.DisableFkSql);
            int result = sqlHelper.ExecuteScalar<int>(ForeignKeySqlStatements.VerifyEnabledNonMetadataFksExistSql);
            Assert.AreEqual(0, result);
        }

        [Test]
        public void FkEnableAllNonMetadataTest()
        {
            sqlHelper.Execute("EXEC Utility.spForeignKeysMetadataInsert");
            sqlHelper.Execute(ForeignKeySqlStatements.CreateAllFksSql);
            sqlHelper.Execute(ForeignKeySqlStatements.EnableFkSql);
            int result = sqlHelper.ExecuteScalar<int>(ForeignKeySqlStatements.VerifyDisabledNonMetadataFksExistSql);
            Assert.AreEqual(0, result);
        }
        
        [Test]
        public void FkEnableAllMetadataOnlyTest()
        {
            var numberOfUtilityForeignKeys = 7;
            sqlHelper.Execute("EXEC Utility.spForeignKeysMetadataInsert");
            sqlHelper.Execute(ForeignKeySqlStatements.CreateAllFksMetadataOnlySql);
            sqlHelper.Execute(ForeignKeySqlStatements.EnableFkSql);

            int numFKsOnSqlServer = sqlHelper.ExecuteScalar<int>(ForeignKeySqlStatements.VerifyFkExistsMetadataOnlySql);
            Assert.AreEqual(numberOfUtilityForeignKeys, numFKsOnSqlServer, "Number of FK in Utility schema.");

            int numDisabledFKs = sqlHelper.ExecuteScalar<int>(ForeignKeySqlStatements.VerifyDisabledMetadataOnlyFksExistSql);
            Assert.AreEqual(numFKsOnSqlServer, numDisabledFKs, "All FK in Utility schema should be disabled.");
        }
    }
}
