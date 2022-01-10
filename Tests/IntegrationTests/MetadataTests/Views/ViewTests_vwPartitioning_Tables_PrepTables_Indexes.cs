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
using TablePartitioning = DOI.Tests.IntegrationTests.RunTests.TablePartitioning;
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
            sqlHelper.Execute(TestHelper.DropTableSql, 30, true, DatabaseName);
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
            }
            else
            {
                partitionFunctionMetadataSql = TestHelper.CreatePartitionFunctionMonthlyMetadataSql;
            }

            //create the objects UNPARTITIONED, and then update the metadata to partitioning.
            tableMetadataSql = TestHelper.CreateTableMetadataSql;
            tableSql = TestHelper.CreateTableSql; 
            indexSql = TestHelper.CreateCIndexSql;
            indexMetadataSql = TestHelper.CreateCIndexMetadataSql;
            indexColumnStoreSql = TestHelper.CreateNCCIIndexSql;
            indexColumnStoreMetadataSql = TestHelper.CreateNCCIIndexMetadataSql;

            //create partition function
            sqlHelper.Execute(partitionFunctionMetadataSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_PartitionFunctionsSql);//refresh metadata after metadata insert
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
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysTablesSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysCheckConstraintsSql);
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDefaultConstraintsSql);

            //assert that PrepTablesIndexes view is empty, since table is not set to be partitioned.
            var rowCount =
                sqlHelper.ExecuteScalar<int>(
                            $@" SELECT COUNT(*)
                                    FROM DOI.vwPartitioning_Tables_PrepTables_Indexes 
                                    WHERE DatabaseName = '{DatabaseName}' 
                                        AND PartitionFunctionName = '{partitionFunctionName}'");

            Assert.AreEqual(0, rowCount);

            //change metadata to partition table
            sqlHelper.Execute($@"
                        UPDATE DOI.Tables
                        SET IntendToPartition = 1,
                            PartitionFunctionName = '{partitionFunctionName}',
                            PartitionColumn = 'TransactionUtcDt'
                        WHERE SchemaName = 'dbo'
                            AND TableName = '{TestTableName1}'");

            //change metadata to partition indexes
            sqlHelper.Execute($@"
                        UPDATE DOI.IndexesRowStore
                        SET PartitionFunction_Desired = '{partitionFunctionName}',
                            PartitionColumn_Desired = 'TransactionUtcDt',
                            KeyColumnList_Desired = CASE
                                                        WHEN KeyColumnList_Desired NOT LIKE '%{TestHelper.PartitionColumnName}%'
                                                        THEN KeyColumnList_Desired + ',{TestHelper.PartitionColumnName} ASC' 
                                                        ELSE KeyColumnList_Desired
                                                    END 
                        WHERE SchemaName = 'dbo'
                            AND TableName = '{TestTableName1}'");

            sqlHelper.Execute($@"
                        UPDATE DOI.IndexesColumnStore
                        SET PartitionFunction_Desired = '{partitionFunctionName}',
                            PartitionColumn_Desired = 'TransactionUtcDt',
                            ColumnList_Desired =    CASE
                                                        WHEN ColumnList_Desired NOT LIKE '%{TestHelper.PartitionColumnName}%'
                                                        THEN ColumnList_Desired + ',{TestHelper.PartitionColumnName} ASC' 
                                                        ELSE ColumnList_Desired
                                                    END 
                        WHERE SchemaName = 'dbo'
                            AND TableName = '{TestTableName1}'");

            sqlHelper.Execute(TestHelper.RefreshMetadata_All);

            //partition function metadata has already been created, so views should show the filegroups & files that need to be created, plus the fact that they are missing.
            TestHelper.AssertMetadata(boundaryInterval);
        }

    }
}
