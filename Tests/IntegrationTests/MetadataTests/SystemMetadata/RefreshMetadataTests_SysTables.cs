using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SysTablesHelper;
using PfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionsHelper;
using PsTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionSchemesHelper;
using FgTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_FileGroupsHelper;
using DbfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_DBFilesHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class RefreshMetadataTests_SysTables : DOIBaseTest
    {
        FgTestHelper fgTestHelper = new FgTestHelper();
        DbfTestHelper dbfTestHelper = new DbfTestHelper();
        PfTestHelper pfTestHelper = new PfTestHelper();
        PsTestHelper psTestHelper = new PsTestHelper();

        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropPartitionedTableSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.DropTableSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.DropPartitionSchemeMonthlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionMonthlySql, 30, true, DatabaseName);
        }

        [TestCase(false, null, TestName = "RefreshMetadataTests_SysTables_MetadataIsAccurate_UnPartitionedTable")]
        [TestCase(true, "Yearly", TestName = "RefreshMetadataTests_SysTables_MetadataIsAccurate_PartitionedTable_Yearly")]
        [TestCase(true, "Monthly", TestName = "RefreshMetadataTests_SysTables_MetadataIsAccurate_PartitionedTable_Monthly")]
        public void RefreshMetadata_SysTables_MetadataIsAccurate(bool isPartitionedTable, string boundaryInterval = null)
        {
            var tableName = isPartitionedTable ? "TempA_Partitioned" : "TempA";
            string tableMetadataSql = string.Empty;
            string tableSql = string.Empty;
            string refreshMetadataSql = string.Empty;

            if (isPartitionedTable)
            {
                var partitionFunctionName = string.Concat("pfTests", boundaryInterval);
                var partitionSchemeName = string.Concat("psTests", boundaryInterval);

                string partitionFunctionMetadataSql = "";


                if (boundaryInterval == "Yearly")
                {
                    partitionFunctionMetadataSql = TestHelper.CreatePartitionFunctionYearlyMetadataSql;
                    tableMetadataSql = TestHelper.CreatePartitionedTableYearlyMetadataSql;
                    tableSql = TestHelper.CreatePartitionedTableYearlySql;
                }
                else if (boundaryInterval == "Monthly")
                {
                    partitionFunctionMetadataSql = TestHelper.CreatePartitionFunctionMonthlyMetadataSql;
                    tableMetadataSql = TestHelper.CreatePartitionedTableMonthlyMetadataSql;
                    tableSql = TestHelper.CreatePartitionedTableMonthlySql;
                }

                sqlHelper.Execute(partitionFunctionMetadataSql);
                sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);//refresh metadata after metadata insert
                //create partition function
                sqlHelper.Execute(pfTestHelper.GetPartitionFunctionSql(partitionFunctionName, "Create"), 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql); //refresh metadata again to show the partition function as existing on the server.

                //create all needed storage containers
                sqlHelper.Execute(fgTestHelper.GetFilegroupSql(partitionSchemeName, "Create"), 30, true, DatabaseName);
                sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(partitionSchemeName, "Create"), 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabaseFilesSql);

                //create partition scheme
                sqlHelper.Execute(psTestHelper.GetPartitionSchemeSql(partitionSchemeName, "Create"), 30, true, DatabaseName);
                sqlHelper.Execute(TestHelper.RefreshMetadata_SysPartitionSchemesSql);

                refreshMetadataSql = TestHelper.RefreshMetadata_PartitionedTablesSql;
            }
            else
            {
                tableMetadataSql = TestHelper.CreateTableMetadataSql;
                tableSql = TestHelper.CreateTableSql;
                refreshMetadataSql = TestHelper.RefreshMetadata_SysTablesSql;
            }

            //run table creation SQL
            sqlHelper.Execute(tableMetadataSql);
            sqlHelper.Execute(tableSql, 30, true, DatabaseName);
            
            //run refresh metadata
            sqlHelper.Execute(refreshMetadataSql);

            //and now they should match
            TestHelper.AssertSysMetadata(tableName);

            TestHelper.AssertUserMetadata(tableName, boundaryInterval);
        }
    }
}