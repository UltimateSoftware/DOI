using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Run_Tests
{
    class StatisticsRenameTests
    {
    }
}

/*
 * using NUnit.Framework;
using TaxHub.TestHelpers;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class StatisticsRenameTests : SqlIndexJobBaseTest
    {
        [SetUp]
        public void Setup()
        {
            this.TearDown();
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("StatisticsViewTests_Setup.sql")), 120);
        }

        [TearDown]
        public void TearDown()
        {
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("StatisticsViewTests_TearDown.sql")), 120);
        }

        [Test]
        public void GivenStatisticAssociatedWithIndexWhenSPRunsThenNothingShouldHappen()
        {
            //Given
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerIndex("StatisticTest", "TempA", "TransactionUtcDt"));
            int tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount);
            bool doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);

            //When
            this.sqlHelper.Execute("EXEC Utility.spDDI_RenameStatistics");

            //Then
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be the same as before");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic should have the same name since is related to index and therefore ignored");
        }

        [Test]
        public void GivenStatisticWithProperNameFormatWhenSPRunsThenNothingShouldHappen()
        {
            //Given
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("ST_TempA_TransactionUtcDt", "TempA", "TransactionUtcDt"));
            int tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount);
            bool doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempA_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);

            //When
            this.sqlHelper.Execute("EXEC Utility.spDDI_RenameStatistics");

            //Then
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be the same as before");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempA_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic should have the same name since it was named properly and therefore ignored");
        }

        [Test]
        public void GivenWronglyNamedStatisticOnSingleColumnWhenSPRunsThenItShouldBeRenamedToUseProperFormat()
        {
            //Given
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("StatisticTest", "TempA", "TransactionUtcDt"));
            int tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount);
            bool doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);

            //When
            this.sqlHelper.Execute("EXEC Utility.spDDI_RenameStatistics");

            //Then
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be the same as before since no statistic was created just renamed");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempA_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic should have been renamed to show proper name format");
        }

        [Test]
        public void GivenWronglyNamedStatisticOnMultipleColumnsWhenSPRunsThenItShouldBeRenamedToUseProperFormat()
        {
            //Given
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatisticWithMultipleColumns("StatisticTest", "TempA"));
            int tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount);
            bool doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);

            //When
            this.sqlHelper.Execute("EXEC Utility.spDDI_RenameStatistics");

            //Then
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be the same as before since no statistic was created just renamed");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempA_TransactionUtcDt_TextCol"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic should have been renamed to show proper name format");
        }

        [Test]
        public void GivenWronglyNamedStatisticAndExistingOneForSameColumnWithProperNameWhenSPRunsThenBadlyNamedOneShouldBeDropped()
        {
            //Given
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("StatisticTest", "TempA", "TransactionUtcDt"));
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("ST_TempA_TransactionUtcDt", "TempA", "TransactionUtcDt"));
            int tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(2, tableStatisticsCount);
            bool doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempA_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);

            //When
            this.sqlHelper.Execute("EXEC Utility.spDDI_RenameStatistics");

            //Then
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be one less since badly renamed statistic should has been dropped");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempA_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic with proper name format should exist");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(false, doesStatisticExistsInSqlServer, "Statistic with bad name should has been dropped");
        }

        [Test]
        public void GivenWronglyNamedStatisticInTwoTablesSameColumnWhenSPRunsThenItShouldBeRenamedOnEachTable()
        {
            //Given
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("StatisticTest", "TempA", "TransactionUtcDt"));
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("StatisticTest", "TempB", "TransactionUtcDt"));
            int tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount);
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempB"));
            Assert.AreEqual(1, tableStatisticsCount);
            bool doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);

            //When
            this.sqlHelper.Execute("EXEC Utility.spDDI_RenameStatistics");

            //Then
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be the same as before since no statistic was created or dropped just renamed");
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempB"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be the same as before since no statistic was created or dropped just renamed");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempA_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic with proper name format should exist in TempA table");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempB_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic with proper name format should exist in TempB table");
        }

        [Test]
        public void GivenWronglyNamedStatisticInTwoTablesDifferentColumnWhenSPRunsThenItShouldBeRenamedOnEachTable()
        {
            //Given
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("StatisticTest", "TempA", "TransactionUtcDt"));
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("StatisticTest", "TempB", "TextCol"));
            int tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount);
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempB"));
            Assert.AreEqual(1, tableStatisticsCount);
            bool doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);

            //When
            this.sqlHelper.Execute("EXEC Utility.spDDI_RenameStatistics");

            //Then
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be the same as before since no statistic was created or dropped just renamed");
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempB"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be the same as before since no statistic was created or dropped just renamed");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempA_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic with proper name format should exist in TempA table");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempB_TextCol"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic with proper name format should exist in TempB table");
        }

        [Test]
        public void GivenBadStatisticInTwoTablesSameColumnAndExistingOnesWithProperNameWhenSPRunsThenItShouldDropTheBadOnesOnEachTable()
        {
            //Given
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("StatisticTest", "TempA", "TransactionUtcDt"));
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("ST_TempA_TransactionUtcDt", "TempA", "TransactionUtcDt"));
            int tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(2, tableStatisticsCount);
            bool doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempA_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);

            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("StatisticTest", "TempB", "TransactionUtcDt"));
            this.sqlHelper.Execute(StatisticsRenameSqlStatements.CreateSqlServerStatistic("ST_TempB_TransactionUtcDt", "TempB", "TransactionUtcDt"));
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempB"));
            Assert.AreEqual(2, tableStatisticsCount);
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempB_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer);

            //When
            this.sqlHelper.Execute("EXEC Utility.spDDI_RenameStatistics");

            //Then
            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempA"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be one less since badly renamed statistic should has been dropped");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempA_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic with proper name format should exist");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(false, doesStatisticExistsInSqlServer, "Statistic with bad name should has been dropped");

            tableStatisticsCount = this.sqlHelper.ExecuteScalar<int>(StatisticsRenameSqlStatements.TableStatisticsCount("TempB"));
            Assert.AreEqual(1, tableStatisticsCount, "Statistics count should be one less since badly renamed statistic should has been dropped");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("ST_TempB_TransactionUtcDt"));
            Assert.AreEqual(true, doesStatisticExistsInSqlServer, "Statistic with proper name format should exist");
            doesStatisticExistsInSqlServer = this.sqlHelper.ExecuteScalar<bool>(StatisticsRenameSqlStatements.DoesStatisticExistsInSqlServer("StatisticTest"));
            Assert.AreEqual(false, doesStatisticExistsInSqlServer, "Statistic with bad name should has been dropped");
        }
    }
}
*/