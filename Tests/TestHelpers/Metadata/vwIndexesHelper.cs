using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using Simple.Data.Ado.Schema;


namespace DOI.Tests.TestHelpers.Metadata
{
    public class vwIndexesHelper : SystemMetadataHelper
    {
        public const string UserTableNameRowStore = "IndexesRowStore";
        public const string UserTableNameColumnStore = "IndexesColumnStore";
        public const string ViewName = "vwIndexes";

        public static List<vwPartitioning_Tables_PrepTables> GetExpectedValues(string partitionFunctionName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{UserTableNameRowStore} T
            WHERE T.DatabaseName = '{DatabaseName}'
                AND T.PartitionFunctionName = '{partitionFunctionName}'
                AND T.IsNewPartitionedPrepTable = 0 
            ORDER BY BoundaryValue"));

            List<vwPartitioning_Tables_PrepTables> expectedvwPartitioning_Tables_PrepTables = new List<vwPartitioning_Tables_PrepTables>();

            foreach (var row in expected)
            {
                var columnValue = new vwPartitioning_Tables_PrepTables();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.DateDiffs = row.First(x => x.First == "DateDiffs").Second.ObjectToInteger();
                columnValue.PrepTableName = row.First(x => x.First == "PrepTableName").Second.ToString();
                columnValue.PrepTableNameSuffix = row.First(x => x.First == "PrepTableNameSuffix").Second.ToString();
                columnValue.NewPartitionedPrepTableName = row.First(x => x.First == "NewPartitionedPrepTableName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.BoundaryValue = row.First(x => x.First == "BoundaryValue").Second.ObjectToDateTime();
                columnValue.NextBoundaryValue = row.First(x => x.First == "NextBoundaryValue").Second.ObjectToDateTime();
                columnValue.IsNewPartitionedPrepTable = row.First(x => x.First == "IsNewPartitionedPrepTable").Second.ObjectToInteger();

                expectedvwPartitioning_Tables_PrepTables.Add(columnValue);
            }

            return expectedvwPartitioning_Tables_PrepTables;
        }

        public static List<vwPartitioning_Tables_PrepTables_Indexes> GetActualValues(string partitionFunctionName, string tableName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{ViewName} 
            WHERE DatabaseName = '{DatabaseName}' 
                AND PartitionFunctionName = '{partitionFunctionName}'
                AND ParentTableName = '{tableName}'
                AND IsNewPartitionedPrepTable = 0 
            ORDER BY BoundaryValue"));


            List<vwPartitioning_Tables_PrepTables_Indexes> actualVwPartitioning_Tables_PrepTables_Indexes = new List<vwPartitioning_Tables_PrepTables_Indexes>();

            foreach (var row in actual)
            {
                var columnValue = new vwPartitioning_Tables_PrepTables_Indexes();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.ParentTableName = row.First(x => x.First == "ParentTableName").Second.ToString();
                columnValue.ParentIndexName = row.First(x => x.First == "ParentIndexName").Second.ToString();
                columnValue.IsIndexMissingFromSQLServer = (bool)row.First(x => x.First == "IsIndexMissingFromSQLServer").Second;
                columnValue.PrepTableName = row.First(x => x.First == "PrepTableName").Second.ToString();
                columnValue.PrepTableIndexName = row.First(x => x.First == "PrepTableIndexName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.BoundaryValue = row.First(x => x.First == "BoundaryValue").Second.ObjectToDateTime();
                columnValue.NextBoundaryValue = row.First(x => x.First == "NextBoundaryValue").Second.ObjectToDateTime();
                columnValue.IsNewPartitionedPrepTable = row.First(x => x.First == "IsNewPartitionedPrepTable").Second.ObjectToInteger();
                columnValue.Storage_Actual = row.First(x => x.First == "Storage_Actual").Second.ToString();
                columnValue.StorageType_Actual = row.First(x => x.First == "StorageType_Actual").Second.ToString();
                columnValue.Storage_Desired = row.First(x => x.First == "Storage_Desired").Second.ToString();
                columnValue.StorageType_Desired = row.First(x => x.First == "StorageType_Desired").Second.ToString();
                columnValue.PrepTableFilegroup = row.First(x => x.First == "PrepTableFilegroup").Second.ToString();
                columnValue.IndexSizeMB_Actual = row.First(x => x.First == "IndexSizeMB_Actual").Second.ObjectToDecimal();
                columnValue.IndexType = row.First(x => x.First == "IndexType").Second.ToString();
                columnValue.IsClustered_Actual = (bool)row.First(x => x.First == "IsClustered_Actual").Second;
                columnValue.RowNum = row.First(x => x.First == "RowNum").Second.ObjectToInteger();

                actualVwPartitioning_Tables_PrepTables_Indexes.Add(columnValue);
            }

            return actualVwPartitioning_Tables_PrepTables_Indexes;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata(string boundaryInterval)
        {
            SqlHelper sqlHelper = new SqlHelper();
            string partitionFunctionName = String.Concat("pfTests", boundaryInterval);

            var expected = GetExpectedValues(partitionFunctionName);
            var actual = GetActualValues(partitionFunctionName, TableName_Partitioned);

            var expectedIndexCount = sqlHelper.ExecuteScalar<int>(
                $@"  SELECT COUNT(*)
                        FROM DOI.vwPartitioning_Tables_PrepTables
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TableName_Partitioned}'
                            AND IsNewPartitionedPrepTable = 0");

            var actualIndexCount = sqlHelper.ExecuteScalar<int>(
                $@" SELECT COUNT(*)
                        FROM (  SELECT IndexName
                                FROM DOI.IndexesRowStore 
                                WHERE DatabaseName = '{DatabaseName}' 
                                   AND TableName = '{TableName_Partitioned}'
                                UNION ALL
                                SELECT IndexName
                                FROM DOI.IndexesColumnStore 
                                WHERE DatabaseName = '{DatabaseName}' 
                                   AND TableName = '{TableName_Partitioned}')x");

            var actualPrepTableIndexRowCount = sqlHelper.ExecuteScalar<int>(
                $"SELECT COUNT(*) FROM DOI.{ViewName} WHERE DatabaseName = '{DatabaseName}' AND ParentTableName = '{TableName_Partitioned}' AND IsNewPartitionedPrepTable = 0");

            Assert.IsTrue(actual.Count > 0, "RowsReturned");
            Assert.AreEqual(expectedIndexCount * actualIndexCount, actualPrepTableIndexRowCount, "MatchingRowCounts"); //should have 'x' Indexes per partition.

            foreach (var expectedRow in expected)
            {
                var actualRowRowStoreIndex = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.PrepTableName == expectedRow.PrepTableName && x.BoundaryValue == expectedRow.BoundaryValue && x.IndexType == "RowStore" && x.IsClustered_Actual == false);

                Assert.AreEqual(expectedRow.SchemaName, actualRowRowStoreIndex.SchemaName, "SchemaName");
                Assert.AreEqual(expectedRow.TableName, actualRowRowStoreIndex.ParentTableName, "ParentTableName");
                Assert.AreEqual(expectedRow.PrepTableName, actualRowRowStoreIndex.PrepTableName, "PrepTableName");
                Assert.AreEqual(CIndexName_Partitioned, actualRowRowStoreIndex.ParentIndexName, "ParentIndexName");
                Assert.AreEqual(false, actualRowRowStoreIndex.IsIndexMissingFromSQLServer, "IsIndexMissingFromSQLServer");
                Assert.AreEqual(expectedRow.PrepTableName, actualRowRowStoreIndex.PrepTableName, "PrepTableName");
                Assert.AreEqual(CIndexName_Partitioned.Replace(expectedRow.TableName, expectedRow.PrepTableName), actualRowRowStoreIndex.PrepTableIndexName, "PrepTableIndexName");
                Assert.AreEqual(expectedRow.PartitionFunctionName, actualRowRowStoreIndex.PartitionFunctionName, "PartitionFunctionName");
                Assert.AreEqual(expectedRow.BoundaryValue, actualRowRowStoreIndex.BoundaryValue, "BoundaryValue");
                Assert.AreEqual(expectedRow.NextBoundaryValue, actualRowRowStoreIndex.NextBoundaryValue, "NextBoundaryValue");
                Assert.AreEqual(expectedRow.IsNewPartitionedPrepTable, actualRowRowStoreIndex.IsNewPartitionedPrepTable, "IsNewPartitionedPrepTable");
                Assert.AreEqual(string.Concat("psTests", boundaryInterval), actualRowRowStoreIndex.Storage_Actual, "Storage_Actual");
                Assert.AreEqual("PARTITION_SCHEME", actualRowRowStoreIndex.StorageType_Actual, "StorageType_Actual");
                Assert.AreEqual(expectedRow.Storage_Desired, actualRowRowStoreIndex.Storage_Desired, "Storage_Desired");
                Assert.AreEqual(expectedRow.StorageType_Desired, actualRowRowStoreIndex.StorageType_Desired, "StorageType_Desired");
                Assert.AreEqual(expectedRow.PrepTableFilegroup, actualRowRowStoreIndex.PrepTableFilegroup, "PrepTableFilegroup");
                Assert.AreEqual(1, actualRowRowStoreIndex.RowNum, "RowNum");
            }
        }

        public static string GetColumnsToUpdateFromIndexTypeSql(string indexUpdateType, string indexType)
        {
            string columnsToUpdateSql = string.Empty;

            switch (indexUpdateType)
            {
                case "CreateMissing":
                    columnsToUpdateSql = "IsIndexMissingFromSQLServer = 1";
                    break;
                case "CreateDropExisting":
                    columnsToUpdateSql = indexType == "RowStore" ? "IsIndexMissingFromSQLServer = 0, AreDropRecreateOptionsChanging = 1, IsPrimaryKey_Desired = 0, IsPrimaryKey_Actual = 0" : "IsIndexMissingFromSQLServer = 0, AreDropRecreateOptionsChanging = 1";
                    break;
                case "ExchangeTableNonPartitioned":
                    columnsToUpdateSql = "IsIndexMissingFromSQLServer = 0, AreDropRecreateOptionsChanging = 1, IsClusteredChanging = 1";
                    break;
                case "AlterRebuild":
                    columnsToUpdateSql =
                        "IsIndexMissingFromSQLServer = 0, AreDropRecreateOptionsChanging = 0, AreRebuildOnlyOptionsChanging = 1, NeedsPartitionLevelOperations = 0";
                    break;
                case "AlterReorganize":
                    columnsToUpdateSql = "FragmentationType = 'Light', NeedsPartitionLevelOperations = 0";
                    break;
                case "AlterSet":
                    columnsToUpdateSql =
                        "IsIndexMissingFromSQLServer = 0, AreDropRecreateOptionsChanging = 0, AreRebuildOnlyOptionsChanging = 0, NeedsPartitionLevelOperations = 0, AreSetOptionsChanging = 1";
                    break;
                case "AlterRebuild-PartitionLevel":
                    columnsToUpdateSql =
                        "IsIndexMissingFromSQLServer = 0, AreDropRecreateOptionsChanging = 0, FragmentationType = 'Heavy', NeedsPartitionLevelOperations = 1";
                    break;
                case "AlterReorganize-PartitionLevel":
                    columnsToUpdateSql = "FragmentationType = 'Light', NeedsPartitionLevelOperations = 1";
                    break;
            }

            return columnsToUpdateSql;
        }

        //public static void AssertSqlsAreNotNull(string tableName, string indexName)
        //{

        //}
    }
}
