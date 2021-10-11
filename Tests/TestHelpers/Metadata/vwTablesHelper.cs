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
    public class vwTablesHelper : SystemMetadataHelper
    {
        public const string UserTableName = "[Tables]";
        public const string ViewName = "vwTables";

        public static List<Tables> GetExpectedValues(string tableName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{UserTableName} T
            WHERE T.DatabaseName = '{DatabaseName}'
                AND T.TableName = '{tableName}'"));

            List<Tables> expectedvwStatistics = new List<Tables>();

            foreach (var row in expected)
            {
                var columnValue = new Tables();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.PartitionColumn = row.First(x => x.First == "PartitionColumn").Second.ToString();
                columnValue.Storage_Desired = row.First(x => x.First == "Storage_Desired").Second.ToString();
                columnValue.Storage_Actual = row.First(x => x.First == "Storage_Actual").Second.ToString();
                columnValue.StorageType_Desired = row.First(x => x.First == "StorageType_Desired").Second.ToString();
                columnValue.StorageType_Actual = row.First(x => x.First == "StorageType_Actual").Second.ToString();
                columnValue.IntendToPartition = (bool)row.First(x => x.First == "IntendToPartition").Second;
                columnValue.ReadyToQueue = (bool)row.First(x => x.First == "ReadyToQueue").Second;
                columnValue.AreIndexesFragmented = (bool)row.First(x => x.First == "AreIndexesFragmented").Second;
                columnValue.AreIndexesBeingUpdated = (bool)row.First(x => x.First == "AreIndexesBeingUpdated").Second;
                columnValue.AreIndexesMissing = (bool)row.First(x => x.First == "AreIndexesMissing").Second;
                columnValue.IsStorageChanging = (bool)row.First(x => x.First == "IsStorageChanging").Second;
                columnValue.NeedsTransaction = (bool)row.First(x => x.First == "NeedsTransaction").Second;
                columnValue.AreStatisticsChanging = (bool)row.First(x => x.First == "AreStatisticsChanging").Second;
                columnValue.ReadyToQueue = (bool)row.First(x => x.First == "ReadyToQueue").Second;
                columnValue.PKColumnList = row.First(x => x.First == "PKColumnList").Second.ToString();
                columnValue.ColumnListNoTypes = row.First(x => x.First == "ColumnListNoTypes").Second.ToString();
                columnValue.ColumnListWithTypes = row.First(x => x.First == "ColumnListWithTypes").Second.ToString();
                columnValue.NewPartitionedPrepTableName = row.First(x => x.First == "NewPartitionedPrepTableName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();

                expectedvwStatistics.Add(columnValue);
            }

            return expectedvwStatistics;
        }

        public static List<vwTables> GetActualValues(string tableName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{ViewName} 
            WHERE DatabaseName = '{DatabaseName}'
                AND TableName = '{tableName}'"));


            List<vwTables> actualvwTables = new List<vwTables>();

            foreach (var row in actual)
            {
                var columnValue = new vwTables();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.PartitionColumn = row.First(x => x.First == "PartitionColumn").Second.ToString();
                columnValue.Storage_Desired = row.First(x => x.First == "Storage_Desired").Second.ToString();
                columnValue.Storage_Actual = row.First(x => x.First == "Storage_Actual").Second.ToString();
                columnValue.StorageType_Desired = row.First(x => x.First == "StorageType_Desired").Second.ToString();
                columnValue.StorageType_Actual = row.First(x => x.First == "StorageType_Actual").Second.ToString();
                columnValue.IntendToPartition = (bool)row.First(x => x.First == "IntendToPartition").Second;
                columnValue.ReadyToQueue = (bool)row.First(x => x.First == "ReadyToQueue").Second;
                columnValue.AreIndexesFragmented = (bool)row.First(x => x.First == "AreIndexesFragmented").Second;
                columnValue.AreIndexesBeingUpdated = (bool)row.First(x => x.First == "AreIndexesBeingUpdated").Second;
                columnValue.AreIndexesMissing = (bool)row.First(x => x.First == "AreIndexesMissing").Second;
                columnValue.IsStorageChanging = (bool)row.First(x => x.First == "IsStorageChanging").Second;
                columnValue.NeedsTransaction = (bool)row.First(x => x.First == "NeedsTransaction").Second;
                columnValue.AreStatisticsChanging = (bool)row.First(x => x.First == "AreStatisticsChanging").Second;
                columnValue.ReadyToQueue = (bool)row.First(x => x.First == "ReadyToQueue").Second;
                columnValue.PKColumnList = row.First(x => x.First == "PKColumnList").Second.ToString();
                columnValue.ColumnListNoTypes = row.First(x => x.First == "ColumnListNoTypes").Second.ToString();
                columnValue.NewPartitionedPrepTableName = row.First(x => x.First == "NewPartitionedPrepTableName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();

                actualvwTables.Add(columnValue);
            }

            return actualvwTables;
        }

        //verify DOI view data against expected values.
        public static void AssertMetadata(string tableName)
        {
            SqlHelper sqlHelper = new SqlHelper();

            var expected = GetExpectedValues(tableName);
            var actual = GetActualValues(tableName);

            Assert.IsTrue(actual.Count > 0, "RowsReturned");
            Assert.IsTrue(expected.Count == actual.Count, "MatchingRowCounts");

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.TableName == expectedRow.TableName);

                Assert.AreEqual(expectedRow.SchemaName, actualRow.SchemaName, "SchemaName");
                Assert.AreEqual(expectedRow.PartitionColumn, actualRow.PartitionColumn, "PartitionColumn");
                Assert.AreEqual(expectedRow.Storage_Desired, actualRow.Storage_Desired, "Storage_Desired");
                Assert.AreEqual(expectedRow.Storage_Actual, actualRow.Storage_Actual, "Storage_Actual");
                Assert.AreEqual(expectedRow.StorageType_Desired, actualRow.StorageType_Desired, "StorageType_Desired");
                Assert.AreEqual(expectedRow.StorageType_Actual, actualRow.StorageType_Actual, "StorageType_Actual");
                Assert.AreEqual(expectedRow.IntendToPartition, actualRow.IntendToPartition, "IntendToPartition");
                Assert.AreEqual(expectedRow.ReadyToQueue, actualRow.ReadyToQueue, "ReadyToQueue");
                Assert.AreEqual(expectedRow.AreIndexesFragmented, actualRow.AreIndexesFragmented, "AreIndexesFragmented");
                Assert.AreEqual(expectedRow.AreIndexesBeingUpdated, actualRow.AreIndexesBeingUpdated, "AreIndexesBeingUpdated");
                Assert.AreEqual(expectedRow.AreIndexesMissing, actualRow.AreIndexesMissing, "AreIndexesMissing");
                Assert.AreEqual(expectedRow.IsStorageChanging, actualRow.IsStorageChanging, "IsStorageChanging");
                Assert.AreEqual(expectedRow.NeedsTransaction, actualRow.NeedsTransaction, "NeedsTransaction");
                Assert.AreEqual(expectedRow.ReadyToQueue, actualRow.ReadyToQueue, "ReadyToQueue");
                Assert.AreEqual(expectedRow.AreStatisticsChanging, actualRow.AreStatisticsChanging, "AreStatisticsChanging");
                Assert.AreEqual(expectedRow.PKColumnList, actualRow.PKColumnList, "PKColumnList");
                Assert.AreEqual(expectedRow.ColumnListNoTypes, actualRow.ColumnListNoTypes, "ColumnListNoTypes");
                Assert.AreEqual(expectedRow.NewPartitionedPrepTableName, actualRow.NewPartitionedPrepTableName, "NewPartitionedPrepTableName");
                Assert.AreEqual(expectedRow.PartitionFunctionName, actualRow.PartitionFunctionName, "PartitionFunctionName");
            }
        }
    }
}
