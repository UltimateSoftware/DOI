using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.vwTablesHelper;
using PfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionFunctionsHelper;
using PsTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitionSchemesHelper;
using FgTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_FileGroupsHelper;
using DbfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_DBFilesHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwTables : DOIBaseTest
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

        [Test]
        public void Views_vwTables_UnPartitionedTableMetadataIsAccurate()
        {
            var testHelper = new TestHelper();
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql);//refresh metadata after metadata insert

            //create partition function
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql); //refresh metadata again to show the partition function as existing on the server.

            //and now they should match
            TestHelper.AssertMetadata(TestHelper.TableName);
        }

        [Test]
        public void Views_vwTables_PartitionedTableYearlyMetadataIsAccurate()
        {
            //Setup
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlyMetadataSql);//create partition function metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);  //refresh metadata after metadata insert

            sqlHelper.Execute(pfTestHelper.GetPartitionFunctionSql(TestHelper.PartitionFunctionNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql); //refresh metadata again to show the partition function as existing on the server.

            //create all needed storage containers
            sqlHelper.Execute(fgTestHelper.GetFilegroupSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabaseFilesSql);

            //create partition scheme
            sqlHelper.Execute(psTestHelper.GetPartitionSchemeSql(TestHelper.PartitionSchemeNameYearly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysPartitionSchemesSql);

            sqlHelper.Execute(TestHelper.CreatePartitionedTableYearlyMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql);//refresh metadata after metadata insert

            //create partition function
            sqlHelper.Execute(TestHelper.CreatePartitionedTableYearlySql, 30, true, DatabaseName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql); //refresh metadata again to show the partition function as existing on the server.

            //and now they should match
            TestHelper.AssertMetadata(TestHelper.TableName_Partitioned);
        }

        [Test]
        public void Views_vwTables_PartitionedTableMonthlyMetadataIsAccurate()
        {
            //Setup
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionMonthlyMetadataSql);//create partition function metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);  //refresh metadata after metadata insert

            sqlHelper.Execute(pfTestHelper.GetPartitionFunctionSql(TestHelper.PartitionFunctionNameMonthly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql); //refresh metadata again to show the partition function as existing on the server.

            //create all needed storage containers
            sqlHelper.Execute(fgTestHelper.GetFilegroupSql(TestHelper.PartitionSchemeNameMonthly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(dbfTestHelper.GetDBFilesSql(TestHelper.PartitionSchemeNameMonthly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabaseFilesSql);

            //create partition scheme
            sqlHelper.Execute(psTestHelper.GetPartitionSchemeSql(TestHelper.PartitionSchemeNameMonthly, "Create"), 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysPartitionSchemesSql);

            sqlHelper.Execute(TestHelper.CreatePartitionedTableMonthlyMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql);//refresh metadata after metadata insert

            //create partition function
            sqlHelper.Execute(TestHelper.CreatePartitionedTableMonthlySql, 30, true, DatabaseName);

            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql); //refresh metadata again to show the partition function as existing on the server.

            //and now they should match
            TestHelper.AssertMetadata(TestHelper.TableName_Partitioned);
        }

        //change bit tests.
        //AreIndexesFragmented
        //AreIndexesBeingUpdated
        //AreIndexesMissing
        //IsClusteredIndexBeingDropped
        //WhichUniqueConstraintIsBeingDropped
        //IsStorageChanging
        //NeedsTransaction
        //AreStatisticsChanging
    }
}
