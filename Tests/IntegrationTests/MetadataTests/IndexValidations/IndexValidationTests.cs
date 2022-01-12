using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.StorageContainers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.ForeignKeysHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.IndexValidations
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    public class IndexValidationTests : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            //sqlHelper.Execute(TestHelper.CreateForeignKeySql, 30, true, DatabaseName);
            //sqlHelper.Execute(TestHelper.CreateChildTableSql, 30, true, DatabaseName);
            //sqlHelper.Execute(TestHelper.CreateChildTableMetadataSql);

            //partitioned tables
            sqlHelper.Execute(TestHelper.CreateFilegroupSql);
            sqlHelper.Execute(TestHelper.CreateFilegroup2Sql);
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlyMetadataSql);
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionSchemeYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionedTableYearlyMetadataSql);
            sqlHelper.Execute(TestHelper.CreatePartitionedTableYearlySql, 30, true, DatabaseName);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            //sqlHelper.Execute(TestHelper.DropForeignKeySql, 30, true, DatabaseName);
            //sqlHelper.Execute(TestHelper.DropChildTableSql, 30, true, DatabaseName);
            //sqlHelper.Execute(TestHelper.DropChildTableMetadataSql);
            sqlHelper.Execute(TestHelper.DropTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropTableMetadataSql);
            sqlHelper.Execute(TestHelper.DropPartitionedTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionedTableMetadataSql);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlyMetadataSql);
            sqlHelper.Execute(TestHelper.DropFilegroupSql);
            sqlHelper.Execute(TestHelper.DropFilegroup2Sql);
        }

        #region PK Validations
        [Test]
        public void IndexValidationTests_MoreThan1PKDefined()
        {
            sqlHelper.Execute(TestHelper.CreateCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateCIndexMetadataSql);

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET IsPrimaryKey_Desired = 1, IsUnique_Desired = 1 WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestTableName1}' AND IndexName = '{TestHelper.CIndexName}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The Following Table(s) have more than 1 Primary Key defined.  Delete or convert one of the Primary Keys to a Unique index:dbo.{TestTableName1},", e.Message);
            }
        }

        [Test]
        public void IndexValidationTests_NoPKDefined()
        {
            sqlHelper.Execute(TestHelper.DropChildTableSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropChildTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateCIndexMetadataSql);

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET IsPrimaryKey_Desired = 0 WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestTableName1}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The Following Table(s) have no Primary Key defined.  Define one or more columns as Primary Key:dbo.{TestTableName1},", e.Message);
            }
        }

        #endregion

        #region Column Conflicts

        [Test]
        public void IndexValidationTests_IncludedColumnsAreAlsoKeyColumns()
        {
            sqlHelper.Execute(TestHelper.CreateNCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateNCIndexMetadataSql);

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET IncludedColumnList_Desired = REPLACE(REPLACE(KeyColumnList_Desired, 'ASC', SPACE(0)), 'DESC', SPACE(0)) WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestTableName1}' AND IndexName = '{TestHelper.NCIndexName}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The following indexes have an included column also listed as an key column. Remove the INCLUDED column:  {TestHelper.NCIndexName},", e.Message);
            }
        }

        #endregion

        #region Clustered Index Validations
        [Test]
        public void IndexValidationTests_MoreThan1ClusteredIndexDefined()
        {
            sqlHelper.Execute(TestHelper.CreateCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateCIndexMetadataSql);

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET IsClustered_Desired = 1 WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestTableName1}' AND IndexName = '{TestHelper.PKIndexName}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The Following Table(s) have more than 1 Clustered Index defined.  Delete or convert one of the Clustered Indexes to IsClustered = 0:dbo.{TestTableName1},", e.Message);
            }
        }

        #endregion

        #region Index-Parent Table Validations
        [Test]
        public void IndexValidationTests_IndexesNotMatchingStorageOfParentTable()
        {
            sqlHelper.Execute(TestHelper.CreateCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateCIndexMetadataSql);

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET Storage_Desired = '{TestHelper.Filegroup2Name}' WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestTableName1}' AND IndexName = '{TestHelper.CIndexName}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            var dbMetadataReader = this.sqlHelper.ExecuteReader($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
            string finalInfoMessage = string.Empty;

            while (dbMetadataReader.Read()) //just in case several messages are returned, we just select the one we're interested in.
            {
                if (Convert.ToString(dbMetadataReader["ErrorMessage"]).Contains(TestTableName1))
                {
                    finalInfoMessage = Convert.ToString(dbMetadataReader["ErrorMessage"]);
                }
            }

            Assert.AreEqual($"The Following Indexe(s) do not match the storage of their parent table:  dbo.{TestTableName1}.{TestHelper.CIndexName},", finalInfoMessage);
        }



        [Test]
        public void IndexValidationTests_StatisticsWithIncrementalSettingNotMatchingParentTable()
        {
            sqlHelper.Execute(TestHelper.CreateStatsSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateStatsMetadataSql);

            sqlHelper.Execute($"UPDATE DOI.[Statistics] SET IsIncremental_Desired = 1 WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestTableName1}' AND StatisticsName = '{TestHelper.StatsName}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The Following Statistic(s) have \"Incremental\" settings that do not match their parent table:  {TestHelper.StatsName},", e.Message);
            }
        }


        #endregion

        #region Invalid Object Name Validations

        [Test]
        public void IndexValidationTests_InvalidIndexColumnNames()
        {
            sqlHelper.Execute(TestHelper.CreateCIndexSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateCIndexMetadataSql);

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET KeyColumnList_Desired = 'TempAIdx' WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestTableName1}' AND IndexName = '{TestHelper.CIndexName}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The Following Index Column name(s) are invalid:  dbo.{TestTableName1}.TempAIdx,", e.Message);
            }
        }

        [Test]
        public void IndexValidationTests_InvalidTableNames()
        {
            var sql = TestHelper.CreateCIndexMetadataSql.Replace("'TempA'", "'TempAx'"); //mess up the tablename
            sqlHelper.Execute(sql);
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The Following Table name(s) are invalid:  dbo.TempAx,", e.Message);
            }
        }

        #endregion

        #region Partitioning Validations

        [Test]
        public void IndexValidationTests_IncludedColumnsAreAlsoPartitioningColumns()
        {
            sqlHelper.Execute(TestHelper.CreatePartitionedNCIndexWithIncludedColumnMetadataSql);

            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET PartitionColumn_Desired = IncludedColumnList_Desired WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestHelper.TableName_Partitioned}' AND IndexName = '{TestHelper.NCIndexName_Partitioned}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The following indexes have the partitioning column also listed as an INCLUDED column. Remove the INCLUDED column:  {TestHelper.NCIndexName_Partitioned},", e.Message);
            }
        }

        [Test]
        public void IndexValidationTests_PartitionedAlignedIndexesNoIncrementalStats()
        {
            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET OptionStatisticsIncremental_Desired = 0 WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestHelper.TableName_Partitioned}' AND IndexName = '{TestHelper.PKIndexName_Partitioned}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            var dbMetadataReader = this.sqlHelper.ExecuteReader($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
            string finalInfoMessage = string.Empty;

            while (dbMetadataReader.Read()) //just in case several messages are returned, we just select the one we're interested in.
            {
                if (Convert.ToString(dbMetadataReader["ErrorMessage"]).Contains(TestHelper.TableName_Partitioned))
                {
                    finalInfoMessage = Convert.ToString(dbMetadataReader["ErrorMessage"]);
                }
            }

            Assert.AreEqual($"The following Unique Index(es) are partition-aligned but do not have incremental statistics.  Set OptionStatisticsIncremental_Desired to 1 for these indexes:  {TestHelper.PKIndexName_Partitioned},", finalInfoMessage);
        }

        [Test]
        public void IndexValidationTests_NonPartitionedAlignedIndexesWithIncrementalStats()
        {
            sqlHelper.Execute($@"UPDATE DOI.IndexesRowStore 
                                    SET PartitionColumn_Desired = NULL, 
                                        OptionStatisticsIncremental_Desired = 1,
                                        PartitionFunction_Desired = NULL,
                                        Storage_Desired = '[PRIMARY]'
                                    WHERE DatabaseName = '{DatabaseName}' 
                                        AND TableName = '{TestHelper.TableName_Partitioned}' 
                                        AND IndexName = '{TestHelper.PKIndexName_Partitioned}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            var dbMetadataReader = this.sqlHelper.ExecuteReader($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
            string finalInfoMessage = string.Empty;

            while (dbMetadataReader.Read()) //just in case several messages are returned, we just select the one we're interested in.
            {
                if (Convert.ToString(dbMetadataReader["ErrorMessage"]).Contains(TestHelper.PKIndexName_Partitioned))
                {
                    finalInfoMessage = Convert.ToString(dbMetadataReader["ErrorMessage"]);
                }
            }

            Assert.AreEqual($"The following Unique Index(es) are NOT partition-aligned but do have incremental statistics.  Set OptionStatisticsIncremental_Desired to 0 for these indexes:  {TestHelper.PKIndexName_Partitioned},", finalInfoMessage);
        }

        [Test]
        public void IndexValidationTests_BadPartitionColumnPartitionSchemeCombination()
        {
            sqlHelper.Execute($"UPDATE DOI.Tables SET IntendToPartition = 0, PartitionColumn = NULL, PartitionFunctionName = NULL WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestHelper.TableName_Partitioned}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The Following Table(s) have a bad PartitionColumn/PartitionScheme combination:  dbo.{TestHelper.TableName_Partitioned}.{TestHelper.PKIndexName_Partitioned},", e.Message);
            }
        }

        [Test]
        public void IndexValidationTests_PartitionedIndexesWithNoPartitionColumnInKeyColumnList()
        {
            sqlHelper.Execute($"UPDATE DOI.IndexesRowStore SET KeyColumnList_Desired = REPLACE(KeyColumnList_Desired, ', {TestHelper.PartitionColumnName} ASC', SPACE(0)) WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestHelper.TableName_Partitioned}' AND IndexName = '{TestHelper.PKIndexName_Partitioned}'");
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The Following Indexe(s) are intended to be partitioned but do not have the Partition Column in their Key Column List:  {TestHelper.PKIndexName_Partitioned},", e.Message);
            }
        }

        [Test]
        public void IndexValidationTests_IndexPartitionsNotMatchingCompressionSettingOfParentIndex()
        {
            sqlHelper.Execute(TestHelper.CreatePartitionedCIndexYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionedCIndexYearlyMetadataSql);

            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            sqlHelper.Execute($@"   UPDATE DOI.IndexPartitionsRowStore 
                                        SET OptionDataCompression = 'ROW'
                                        WHERE DatabaseName = '{DatabaseName}' 
                                            AND TableName = '{TestHelper.TableName_Partitioned}' 
                                            AND IndexName = '{TestHelper.CIndexName_Partitioned}' 
                                            AND PartitionNumber = 1");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The Following Index Partition(s) do not match the compression setting of their parent index:  {TestHelper.CIndexName_Partitioned}__1,", e.Message);
            }
        }


        [Test]
        public void IndexValidationTests_PartitionedTablesNotHavingUpdatedUtcDtColumn()
        {
            sqlHelper.Execute($"UPDATE DOI.Tables SET IntendToPartition = 1, PartitionColumn = '{TestHelper.PartitionColumnName}', PartitionFunctionName = '{TestHelper.PartitionFunctionNameYearly}' WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TestHelper.TableName_Partitioned}'");
            sqlHelper.Execute($"ALTER TABLE dbo.{TestHelper.TableName_Partitioned} DROP CONSTRAINT Def_{TestHelper.TableName_Partitioned}_UpdatedUtcDt", 30, true, DatabaseName);
            sqlHelper.Execute($"ALTER TABLE dbo.{TestHelper.TableName_Partitioned} DROP COLUMN UpdatedUtcDt", 30, true, DatabaseName);
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Run_All @DatabaseName = N'{DatabaseName}', @RunValidations = 0");

            try
            {
                sqlHelper.Execute($"EXEC DOI.spIndexValidations @DatabaseName = '{DatabaseName}'");
                Assert.Fail(); //if we don't find an exception, something went wrong.
            }
            catch (Exception e)
            {
                Assert.AreEqual($"The Following Table(s) do NOT have the UpdatedUtc column.  This column is REQUIRED for partitioning:  dbo.{TestHelper.TableName_Partitioned},", e.Message);
            }
        }

        #endregion
    }
}