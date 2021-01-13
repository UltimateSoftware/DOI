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

namespace DOI.Tests.TestHelpers.Metadata
{
    public class vwPartitioning_DBFilesHelper : SystemMetadataHelper
    {
        public const string UserTableName = "vwPartitionFunctionPartitions";
        public const string ViewName = "vwPartitioning_DBFiles";

        public string GetDBFilesSql(string partitionSchemeName, string createOrDrop)
        {
            var fieldName = createOrDrop == "Create" ? "AddFileSQL" : "DropFileSQL";

            return sqlHelper.ExecuteScalar<string>($@"
            SELECT (SELECT {fieldName} + ';'
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

                expectedPartitionFunctionPartitions.Add(columnValue);
            }

            return expectedPartitionFunctionPartitions;
        }

        public static List<vwPartitioning_DBFiles> GetActualValues(string partitionFunctionName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{ViewName} 
            WHERE DatabaseName = '{DatabaseName}' 
                AND PartitionFunctionName = '{partitionFunctionName}'
            ORDER BY BoundaryValue"));


            List<vwPartitioning_DBFiles> actualVwPartitioning_DBFiles = new List<vwPartitioning_DBFiles>();

            foreach (var row in actual)
            {
                var columnValue = new vwPartitioning_DBFiles();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.PartitionSchemeName = row.First(x => x.First == "PartitionSchemeName").Second.ToString();
                columnValue.BoundaryValue = row.First(x => x.First == "BoundaryValue").Second.ObjectToDateTime();
                columnValue.NextBoundaryValue = row.First(x => x.First == "NextBoundaryValue").Second.ObjectToDateTime();
                columnValue.DBFileName = row.First(x => x.First == "DBFileName").Second.ToString();
                columnValue.IsDBFileMissing = row.First(x => x.First == "IsDBFileMissing").Second.ObjectToInteger();

                actualVwPartitioning_DBFiles.Add(columnValue);
            }

            return actualVwPartitioning_DBFiles;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata(string boundaryInterval, int isDBFileMissing)
        {
            SqlHelper sqlHelper = new SqlHelper();
            string partitionFunctionName = String.Concat("pfTests", boundaryInterval);

            var expected = GetExpectedValues(partitionFunctionName);
            var actual = GetActualValues(partitionFunctionName);

            var numOfTotalPartitionSchemeIntervals = sqlHelper.ExecuteScalar<short>($@"
                SELECT NumOfTotalPartitionSchemeIntervals 
                FROM DOI.PartitionFunctions 
                WHERE PartitionFunctionName = '{partitionFunctionName}'");

            Assert.AreEqual(actual.Count, expected.Count); //1 partition function only

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.PartitionFunctionName == expectedRow.PartitionFunctionName && x.BoundaryValue == expectedRow.BoundaryValue);

                Assert.AreEqual(numOfTotalPartitionSchemeIntervals, actual.Count, "TotalPartitionSchemeIntervals");
                Assert.AreEqual(expectedRow.PartitionSchemeName, actualRow.PartitionSchemeName, "PartitionSchemeName");
                Assert.AreEqual(expectedRow.NextBoundaryValue, actualRow.NextBoundaryValue, "NextBoundaryValue");
                Assert.AreEqual(expectedRow.DBFileName, actualRow.DBFileName, "DBFileName");
                Assert.AreEqual(isDBFileMissing, actualRow.IsDBFileMissing, "IsDBFileMissing");
            }
        }

    }
}
