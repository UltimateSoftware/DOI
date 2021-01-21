using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using PtTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_PrepTablesHelper;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_PrepTablesIndexesHelper;
using PfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionsHelper;
using PsTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionSchemesHelper;
using FgTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_FileGroupsHelper;
using DbfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_DBFilesHelper;
using TablePartitioning = DOI.Tests.IntegrationTests.TablePartitioning;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwPartitioning_Tables_PrepTables_Indexes : DOIBaseTest
    {
        FgTestHelper fgTestHelper = new FgTestHelper();
        DbfTestHelper dbfTestHelper = new DbfTestHelper();
        PfTestHelper pfTestHelper = new PfTestHelper();
        PsTestHelper psTestHelper = new PsTestHelper();

        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
            //create a non-partitioned table and update its metadata to partition it.  then assert the metadata below.
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropPartitionedTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeMonthlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionMonthlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionedTableMetadataSql);
            //sqlHelper.Execute(fgTestHelper.GetFilegroupSql(null, "Drop"), 30, true, DatabaseName);
            //sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(null, "Drop"), 30, true, DatabaseName);
        }

        [TestCase("Yearly", "2016-01-01", 1)]
        [TestCase("Monthly", "2016-01-01", 12)]
        [Test]
        public void Views_vwPartitioning_Tables_PrepTables_Indexes_MetadataIsAccurate(string boundaryInterval, string initialDate, int numOfFutureIntervals, bool usesSlidingWindow = false, int? slidingWindowSize = null)
        {
            var partitionFunctionName = string.Concat("pfTests", boundaryInterval);
            var partitionSchemeName = string.Concat("psTests", boundaryInterval);

            string partitionFunctionMetadataSql = string.Empty;
            string tableMetadataSql = string.Empty;
            string tableSql = string.Empty;
            string indexSql = string.Empty;
            string indexMetadataSql = string.Empty;
            string indexColumnStoreSql = string.Empty;
            string indexColumnStoreMetadataSql = string.Empty;

            if (boundaryInterval == "Yearly")
            {
                partitionFunctionMetadataSql = TestHelper.CreatePartitionFunctionYearlyMetadataSql;
                tableMetadataSql = TestHelper.CreatePartitionedTableYearlyMetadataSql;
                tableSql = TestHelper.CreatePartitionedTableYearlySql;
                indexSql = TestHelper.CreatePartitionedIndexYearlySql;
                indexMetadataSql = TestHelper.CreatePartitionedIndexYearlyMetadataSql;
                indexColumnStoreSql = TestHelper.CreatePartitionedColumnStoreIndexMonthlySql;
                indexColumnStoreMetadataSql = TestHelper.CreatePartitionedColumnStoreIndexMonthlyMetadataSql;
            }
            else if (boundaryInterval == "Monthly")
            {
                partitionFunctionMetadataSql = TestHelper.CreatePartitionFunctionMonthlyMetadataSql;
                tableMetadataSql = TestHelper.CreatePartitionedTableMonthlyMetadataSql;
                tableSql = TestHelper.CreatePartitionedTableMonthlySql;
                indexSql = TestHelper.CreatePartitionedIndexMonthlySql;
                indexMetadataSql = TestHelper.CreatePartitionedIndexMonthlyMetadataSql;
                indexColumnStoreSql = TestHelper.CreatePartitionedColumnStoreIndexMonthlySql;
                indexColumnStoreMetadataSql = TestHelper.CreatePartitionedColumnStoreIndexMonthlyMetadataSql;
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

            //create table metadata
            sqlHelper.Execute(tableMetadataSql);
            sqlHelper.Execute(tableSql, 30, true, DatabaseName);
            sqlHelper.Execute(indexSql, 30, true, DatabaseName);
            sqlHelper.Execute(indexColumnStoreSql, 30, true, DatabaseName);
            sqlHelper.Execute(indexMetadataSql);
            sqlHelper.Execute(indexColumnStoreMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionedTablesSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysCheckConstraintsSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDefaultConstraintsSql);

            //partition function metadata has already been created, so views should show the filegroups & files that need to be created, plus the fact that they are missing.
            TestHelper.AssertMetadata(boundaryInterval);
        }

    }
}
