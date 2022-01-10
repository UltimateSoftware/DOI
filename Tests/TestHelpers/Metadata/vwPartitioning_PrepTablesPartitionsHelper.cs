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
    public class vwPartitioning_PrepTablesPartitionsHelper : SystemMetadataHelper
    {
        public const string UserTableName = "vwPartitionFunctionPartitions";
        public const string ViewName = "vwPartitioning_Tables_PrepTables_Partitions";

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
                columnValue.PartitionNumber = row.First(x => x.First == "PartitionNumber").Second.ObjectToInteger();

                expectedPartitionFunctionPartitions.Add(columnValue);
            }

            return expectedPartitionFunctionPartitions;
        }

        public static List<vwPartitioning_Tables_PrepTables_Partitions> GetActualValues(string partitionFunctionName, string tableName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{ViewName} 
            WHERE DatabaseName = '{DatabaseName}' 
                AND PartitionFunctionName = '{partitionFunctionName}'
                AND ParentTableName = '{tableName}'
                AND IsNewPartitionedTable = 0
            ORDER BY PartitionFunctionValue"));


            List<vwPartitioning_Tables_PrepTables_Partitions> actualVwPartitioning_Tables_PrepTables = new List<vwPartitioning_Tables_PrepTables_Partitions>();

            foreach (var row in actual)
            {
                var columnValue = new vwPartitioning_Tables_PrepTables_Partitions();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.ParentTableName = row.First(x => x.First == "ParentTableName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.NewPartitionedPrepTableName = row.First(x => x.First == "NewPartitionedPrepTableName").Second.ToString();
                columnValue.UnPartitionedPrepTableName = row.First(x => x.First == "UnPartitionedPrepTableName").Second.ToString();
                columnValue.PartitionFunctionValue = row.First(x => x.First == "PartitionFunctionValue").Second.ObjectToDateTime();
                columnValue.NextPartitionFunctionValue = row.First(x => x.First == "NextPartitionFunctionValue").Second.ObjectToDateTime();
                columnValue.PartitionNumber = row.First(x => x.First == "PartitionNumber").Second.ObjectToInteger();

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

            Assert.AreEqual(actual.Count, expected.Count); //1 partition function only

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.ParentTableName == TableName_Partitioned && x.PartitionFunctionName == expectedRow.PartitionFunctionName && x.PartitionFunctionValue == expectedRow.BoundaryValue);

                Assert.AreEqual("dbo", actualRow.SchemaName, "SchemaName");
                Assert.AreEqual(string.Concat(TableName_Partitioned, "_NewPartitionedTableFromPrep"), actualRow.NewPartitionedPrepTableName, "NewPartitionedPrepTableName");
                Assert.AreEqual(string.Concat(TableName_Partitioned, expectedRow.PrepTableNameSuffix), actualRow.UnPartitionedPrepTableName, "UnPartitionedPrepTableName");
                Assert.AreEqual(expectedRow.PartitionFunctionName, actualRow.PartitionFunctionName, "PartitionFunctionName");
                Assert.AreEqual(expectedRow.BoundaryValue, actualRow.PartitionFunctionValue, "PartitionFunctionValue");
                Assert.AreEqual(expectedRow.NextBoundaryValue, actualRow.NextPartitionFunctionValue, "NextPartitionFunctionValue");
                Assert.AreEqual(expectedRow.PartitionNumber, actualRow.PartitionNumber, "PartitionNumber");
            }
        }
    }
}
