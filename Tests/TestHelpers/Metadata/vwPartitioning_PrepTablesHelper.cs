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
    public class vwPartitioning_PrepTablesHelper : SystemMetadataHelper
    {
        public const string UserTableName = "vwPartitionFunctionPartitions";
        public const string ViewName = "vwPartitioning_Tables_PrepTables";

        public string GetPrepTablesSql(string partitionSchemeName)
        {
            return sqlHelper.ExecuteScalar<string>($@"
            SELECT (SELECT CreatePrepTableSQL + ';'
                    FROM DOI.{ViewName}
                    WHERE PartitionSchemeName = '{partitionSchemeName}'
                    FOR XML PATH(''), TYPE).value(N'.[1]', N'varchar(max)')");
        }

        public static List<vwPartitionFunctionPartitions> GetExpectedValues(string partitionFunctionName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{UserTableName}
            WHERE DatabaseName = '{DatabaseName}'
                AND PartitionFunctionName = '{partitionFunctionName}'
            ORDER BY BoundaryValue"));

            List<vwPartitionFunctionPartitions> expectedPartitionFunctionPartitions = new List<vwPartitionFunctionPartitions>();

            foreach (var row in expected)
            {
                var columnValue = new vwPartitionFunctionPartitions();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.PartitionSchemeName = row.First(x => x.First == "PartitionSchemeName").Second.ToString();
                columnValue.BoundaryValue = row.First(x => x.First == "BoundaryValue").Second.ObjectToDateTime();
                columnValue.NextBoundaryValue = row.First(x => x.First == "NextBoundaryValue").Second.ObjectToDateTime();
                columnValue.DBFileName = row.First(x => x.First == "DBFileName").Second.ToString();
                columnValue.PrepTableNameSuffix = row.First(x => x.First == "PrepTableNameSuffix").Second.ToString();
                columnValue.DateDiffs = row.First(x => x.First == "DateDiffs").Second.ObjectToInteger();
                columnValue.FileGroupName = row.First(x => x.First == "FileGroupName").Second.ToString();

                expectedPartitionFunctionPartitions.Add(columnValue);
            }

            return expectedPartitionFunctionPartitions;
        }

        public static List<vwPartitioning_Tables_PrepTables> GetActualValues(string partitionFunctionName, string tableName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{ViewName} 
            WHERE DatabaseName = '{DatabaseName}' 
                AND PartitionFunctionName = '{partitionFunctionName}'
                AND TableName = '{tableName}'
                AND IsNewPartitionedPrepTable = 0 
            ORDER BY BoundaryValue"));


            List<vwPartitioning_Tables_PrepTables> actualVwPartitioning_Tables_PrepTables = new List<vwPartitioning_Tables_PrepTables>();

            foreach (var row in actual)
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
                columnValue.PartitionColumn = row.First(x => x.First == "PartitionColumn").Second.ToString();
                columnValue.IsNewPartitionedPrepTable = row.First(x => x.First == "IsNewPartitionedPrepTable").Second.ObjectToInteger();
                columnValue.PKColumnList = row.First(x => x.First == "PKColumnList").Second.ToString();
                columnValue.PKColumnListJoinClause = row.First(x => x.First == "PKColumnListJoinClause").Second.ToString();
                columnValue.UpdateColumnList = row.First(x => x.First == "UpdateColumnList").Second.ToString();
                columnValue.Storage_Desired = row.First(x => x.First == "Storage_Desired").Second.ToString();
                columnValue.StorageType_Desired = row.First(x => x.First == "StorageType_Desired").Second.ToString();
                columnValue.PrepTableFilegroup = row.First(x => x.First == "PrepTableFilegroup").Second.ToString();

                actualVwPartitioning_Tables_PrepTables.Add(columnValue);
            }

            return actualVwPartitioning_Tables_PrepTables;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata(string boundaryInterval)
        {
            SqlHelper sqlHelper = new SqlHelper();
            string partitionFunctionName = String.Concat("pfTests", boundaryInterval);

            var expected = GetExpectedValues(partitionFunctionName);
            var actual = GetActualValues(partitionFunctionName, TableName_Partitioned);

            var isNewPartitionedPrepTable = 0;

            Assert.AreEqual(actual.Count, expected.Count); //1 partition function only

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.PartitionFunctionName == expectedRow.PartitionFunctionName && x.PrepTableNameSuffix == expectedRow.PrepTableNameSuffix && x.BoundaryValue == expectedRow.BoundaryValue);

                Assert.AreEqual("dbo", actualRow.SchemaName, "SchemaName");
                Assert.AreEqual(expectedRow.DateDiffs, actualRow.DateDiffs, "DateDiffs");
                Assert.AreEqual(string.Concat(TableName_Partitioned, expectedRow.PrepTableNameSuffix), actualRow.PrepTableName, "PrepTableName");
                Assert.AreEqual(string.Concat(TableName_Partitioned, "_NewPartitionedTableFromPrep"), actualRow.NewPartitionedPrepTableName, "NewPartitionedPrepTableName");
                Assert.AreEqual(expectedRow.PartitionFunctionName, actualRow.PartitionFunctionName, "PartitionFunctionName");
                Assert.AreEqual(expectedRow.BoundaryValue, actualRow.BoundaryValue, "BoundaryValue");
                Assert.AreEqual(expectedRow.NextBoundaryValue, actualRow.NextBoundaryValue, "NextBoundaryValue");
                Assert.AreEqual(PartitionColumnName, actualRow.PartitionColumn, "PartitionColumn");
                Assert.AreEqual(isNewPartitionedPrepTable, actualRow.IsNewPartitionedPrepTable, "IsNewPartitionedPrepTable");
                Assert.AreEqual(PartitionedTable_PKColumnList, actualRow.PKColumnList, "PKColumnList");
                Assert.AreEqual(expectedRow.PartitionSchemeName, actualRow.Storage_Desired, "Storage_Desired");
                Assert.AreEqual("PARTITION_SCHEME", actualRow.StorageType_Desired, "StorageType_Desired");
                Assert.AreEqual(expectedRow.FileGroupName, actualRow.PrepTableFilegroup, "PrepTableFilegroup");
            }
        }

    }
}
