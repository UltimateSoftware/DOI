using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwStatisticsHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwStatistics : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
        }

        [Test]
        public void Views_vwStatistics_MetadataIsAccurate()
        {
            var testHelper = new TestHelper();
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateStatsMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysStatsSql);//refresh metadata after metadata insert

            //create partition function
            sqlHelper.Execute(TestHelper.CreateStatsSql, 30, true, DatabaseName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysStatsSql); //refresh metadata again to show the partition function as existing on the server.

            //and now they should match
            TestHelper.AssertMetadata();
        }
    }
}
