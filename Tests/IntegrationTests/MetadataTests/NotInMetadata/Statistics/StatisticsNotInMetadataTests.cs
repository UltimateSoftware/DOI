using DOI.Tests.IntegrationTests.MetadataTests.NotInMetadata.Constraints;
using DOI.Tests.TestHelpers;
using NUnit.Framework;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwIndexesHelper;


namespace DOI.Tests.IntegrationTests.MetadataTests.NotInMetadata.Statistics
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class StatisticNotInMetadataTests : DOIBaseTest
    {
        private const string StatisticsName = "ST_TempA_TempAId";

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

        /*
        [TestCase(true, false, true, TestName = "DefaultConstraint_NotInMetadata_InSqlServer_NotInMetadata")]
        [TestCase(true, true, false, TestName = "DefaultConstraint_NotInMetadata_InSqlServer_InMetadata")]
        [TestCase(false, false, false, TestName = "DefaultConstraint_NotInMetadata_NotInSqlServer_NotInMetadata")]
        [TestCase(false, true, false, TestName = "DefaultConstraint_NotInMetadata_NotInSqlServer_InMetadata")]
        public void DefaultConstraint_NotInMetadata(bool inSqlServer, bool inMetadata, bool shouldBeFlaggedAsNotInMetadata)
        {
            //Setup
            if (!inSqlServer)
            {
                this.sqlHelper.Execute(ConstraintsNotInMetadataSqlStatement.DropDefaultConstraint, 30, false, DatabaseName);
            }

            if (!inMetadata)
            {
                this.sqlHelper.Execute($"DELETE DOI.DefaultConstraints WHERE DatabaseName = '{DatabaseName}' AND DefaultConstraintName = 'Def_TempA_UpdatedUtcDt'");
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
        */

        [Test]
        public void GivenStatisticNotInSqlServerAndNotInMetadataWhenSPRunsThenNothingShouldHappen()
        {
            //Given
            this.sqlHelper.Execute(StatisticNotInMetadataSqlStatements.DropStatisticSql(StatisticsName), 30, false, DatabaseName);
            this.sqlHelper.Execute(StatisticNotInMetadataSqlStatements.DeleteStatisticMetadataSql(StatisticsName));

            int metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount(StatisticsName));
            Assert.AreEqual(0, metadataStatisticsCount);

            //When
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = '{DatabaseName}'");

            //Then
            metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount(StatisticsName));
            Assert.AreEqual(0, metadataStatisticsCount, "Statistic shouldn't be in metadata since it was not present in sql server");
        }

        [Test]
        public void GivenStatisticInSqlServerWhenSPRunsThenItShouldBeAddedToMetadataTable()
        {
            //Given
            this.sqlHelper.Execute($"DELETE DOI.[Statistics] WHERE DatabaseName = '{DatabaseName}' AND StatisticsName = '{StatisticsName}'");
            int metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount(StatisticsName));
            Assert.AreEqual(0, metadataStatisticsCount);

            //When
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = '{DatabaseName}'");

            //Then
            metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount(StatisticsName));
            Assert.AreEqual(1, metadataStatisticsCount, "Statistic should have been added to metadata since it was present in sql server");
            bool doesStatisticsExistInMetadataTable = this.sqlHelper.ExecuteScalar<bool>(StatisticNotInMetadataSqlStatements.DoesStatisticsExistInMetadataTable(StatisticsName));
            Assert.AreEqual(true, doesStatisticsExistInMetadataTable, "Statistic should has been added to metadata since it was present in sql server");
        }

        [Test]
        public void GivenStatisticInSqlServerWithWAInTheNameWhenSPRunsThenItShoulBeAddedToMetadataTableAndRenamed()
        {
            //Given
            //this.sqlHelper.Execute(StatisticNotInMetadataSqlStatements.CreateSqlServerStatistic("_WATest"));
            int metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount(StatisticsName));
            Assert.AreEqual(0, metadataStatisticsCount);

            //When
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = '{DatabaseName}'");

            //Then
            metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount(StatisticsName));
            Assert.AreEqual(1, metadataStatisticsCount, "Statistic should has been added to metadata since it was present in sql server");
            bool doesStatisticsExistInMetadataTable = this.sqlHelper.ExecuteScalar<bool>(StatisticNotInMetadataSqlStatements.DoesStatisticsExistInMetadataTable("ST_TempA_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticsExistInMetadataTable, "Statistic should has been added to metadata since it was present in sql server and renamed to follow format ST_TableName_ColumnName");
        }

        [Test]
        public void GivenStatisticWithMultipleColumnsInSqlServerWhenSPRunsThenItShoulBeAddedToMetadataTable()
        {
            //Given
            //this.sqlHelper.Execute(StatisticNotInMetadataSqlStatements.CreateSqlServerStatisticWithMultipleColumns("StatisticTest"));
            int metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount("StatisticTest"));
            Assert.AreEqual(0, metadataStatisticsCount);

            //When
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = '{DatabaseName}'");

            //Then
            metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount("StatisticTest"));
            Assert.AreEqual(1, metadataStatisticsCount, "Statistic should has been added to metadata since it was present in sql server");
            bool doesStatisticsExistInMetadataTable = this.sqlHelper.ExecuteScalar<bool>(StatisticNotInMetadataSqlStatements.DoesStatisticsExistInMetadataTable("StatisticTest"));
            Assert.AreEqual(true, doesStatisticsExistInMetadataTable, "Statistic should has been added to metadata since it was present in sql server and renamed to follow format ST_TableName_ColumnNameList");
            string metadataTableStatisticsColumnList = this.sqlHelper.ExecuteScalar<string>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsColumnList("StatisticTest"));
            Assert.AreEqual("TransactionUtcDt,TextCol", metadataTableStatisticsColumnList, "Statistic should have a comma separated column list");
        }

        [Test]
        public void GivenStatisticWithWAInNameAndWithMultipleColumnsInSqlServerWhenSPRunsThenItShoulBeAddedToMetadataTableAndRanamed()
        {
            //Given
            this.sqlHelper.Execute(StatisticNotInMetadataSqlStatements.CreateSqlServerStatisticWithMultipleColumns("_WATest"));
            int metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount(StatisticsName));
            Assert.AreEqual(0, metadataStatisticsCount);

            //When
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = '{DatabaseName}'");

            //Then
            metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount(StatisticsName));
            Assert.AreEqual(1, metadataStatisticsCount, "Statistic should has been added to metadata since it was present in sql server");
            bool doesStatisticsExistInMetadataTable = this.sqlHelper.ExecuteScalar<bool>(StatisticNotInMetadataSqlStatements.DoesStatisticsExistInMetadataTable("ST_TempA_TransactionUtcDt_TextCol"));
            Assert.AreEqual(true, doesStatisticsExistInMetadataTable, "Statistic should has been added to metadata since it was present in sql server and renamed to follow format ST_TableName_ColumnNameList");
            string metadataTableStatisticsColumnList = this.sqlHelper.ExecuteScalar<string>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsColumnList("ST_TempA_TransactionUtcDt_TextCol"));
            Assert.AreEqual("TransactionUtcDt,TextCol", metadataTableStatisticsColumnList, "Statistic should have a comma separated column list");
        }

        [Test]
        public void GivenStatisticInSqlServerWithNCCI_InTheNameWhenSPRunsThenItShoulNotBeAddedToMetadataTable()
        {
            //Given
            //this.sqlHelper.Execute(StatisticNotInMetadataSqlStatements.CreateSqlServerStatistic("NCCI_StatisticTest"));
            int metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount("NCCI_StatisticTest"));
            Assert.AreEqual(0, metadataStatisticsCount);

            //When
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = '{DatabaseName}'");

            //Then
            metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount("NCCI_StatisticTest"));
            Assert.AreEqual(0, metadataStatisticsCount, "Statistic shouldn't be in metadata since it should has been ignored");
            bool doesStatisticsExistInMetadataTable = this.sqlHelper.ExecuteScalar<bool>(StatisticNotInMetadataSqlStatements.DoesStatisticsExistInMetadataTable("NCCI_StatisticTest"));
            Assert.AreEqual(false, doesStatisticsExistInMetadataTable, "Statistic shouldn't be in metadata since it should has been ignored");
        }

        [Test]
        public void GivenStatisticInSqlServerWithCCI_InTheNameWhenSPRunsThenItShoulNotBeAddedToMetadataTable()
        {
            //Given
//            this.sqlHelper.Execute(StatisticNotInMetadataSqlStatements.CreateSqlServerStatistic("CCI_StatisticTest"));
            int metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount("CCI_StatisticTest"));
            Assert.AreEqual(0, metadataStatisticsCount);

            //When
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = '{DatabaseName}'");

            //Then
            metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount("CCI_StatisticTest"));
            Assert.AreEqual(0, metadataStatisticsCount, "Statistic shouldn't be in metadata since it should has been ignored");
            bool doesStatisticsExistInMetadataTable = this.sqlHelper.ExecuteScalar<bool>(StatisticNotInMetadataSqlStatements.DoesStatisticsExistInMetadataTable("CCI_StatisticTest"));
            Assert.AreEqual(false, doesStatisticsExistInMetadataTable, "Statistic shouldn't be in metadata since it should has been ignored");
        }

        [Test]
        public void GivenStatisticAlreadyInMetadataWhenSPRunsThenNothingShouldHappen()
        {
            //Given
            //this.sqlHelper.Execute(StatisticNotInMetadataSqlStatements.CreateSqlServerStatistic("StatisticTest"));
            //this.sqlHelper.Execute(StatisticNotInMetadataSqlStatements.InsertStatisticInMetadata("StatisticTest"));
            int metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount(StatisticsName));
            Assert.AreEqual(1, metadataStatisticsCount);

            //When
            this.sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = '{DatabaseName}'");

            //Then
            metadataStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticNotInMetadataSqlStatements.MetadataTableStatisticsCount(StatisticsName));
            Assert.AreEqual(1, metadataStatisticsCount, "Statistic count should be the same as before since statistic was already in metadata");
        }
    }
}
