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
    public class vwPartitioning_FileGroupsHelper : SystemMetadataHelper
    {
        public const string UserTableName = "vwPartitionFunctionPartitions";
        public const string ViewName = "vwPartitioning_FileGroups";
        public string GetFilegroupSql(string partitionSchemeName = null, string createOrDrop = "Create")
        {
            var fieldName = createOrDrop == "Create" ? "AddFileGroupSQL" : "DropFileGroupSQL";
            var whereClause = partitionSchemeName == null ? string.Empty : $"AND PartitionSchemeName = '{partitionSchemeName}'";

            return sqlHelper.ExecuteScalar<string>($@"
            SELECT (SELECT {fieldName} + ';'
                    FROM DOI.vwPartitioning_Filegroups
                    WHERE DatabaseName = '{DatabaseName}'
                        {whereClause}
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
                columnValue.FileGroupName = row.First(x => x.First == "FileGroupName").Second.ToString();

                expectedPartitionFunctionPartitions.Add(columnValue);
            }

            return expectedPartitionFunctionPartitions;
        }

        public static List<vwPartitioning_Filegroups> GetActualValues(string partitionFunctionName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{ViewName} 
            WHERE DatabaseName = '{DatabaseName}' 
                AND PartitionFunctionName = '{partitionFunctionName}'
            ORDER BY BoundaryValue"));


            List<vwPartitioning_Filegroups> actualVwPartitioning_Filegroups = new List<vwPartitioning_Filegroups>();

            foreach (var row in actual)
            {
                var columnValue = new vwPartitioning_Filegroups();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.PartitionSchemeName = row.First(x => x.First == "PartitionSchemeName").Second.ToString();
                columnValue.BoundaryValue = row.First(x => x.First == "BoundaryValue").Second.ObjectToDateTime();
                columnValue.NextBoundaryValue = row.First(x => x.First == "NextBoundaryValue").Second.ObjectToDateTime();
                columnValue.FileGroupName = row.First(x => x.First == "FileGroupName").Second.ToString();
                columnValue.IsFileGroupMissing = row.First(x => x.First == "IsFileGroupMissing").Second.ObjectToInteger();

                actualVwPartitioning_Filegroups.Add(columnValue);
            }

            return actualVwPartitioning_Filegroups;
        }

        //verify DOI Sys table data against expected values.

        public static void AssertMetadata(string boundaryInterval, int isFileGroupMissing)
        {
            SqlHelper sqlHelper = new SqlHelper();
            string partitionFunctionName = String.Concat("pfTests", boundaryInterval);

            var expected = GetExpectedValues(partitionFunctionName);
            var actual = GetActualValues(partitionFunctionName);

            var numOfTotalPartitionSchemeIntervals = sqlHelper.ExecuteScalar<int>($@"
                SELECT CAST(NumOfTotalPartitionSchemeIntervals AS INT) AS NumOfTotalPartitionSchemeIntervals
                FROM DOI.PartitionFunctions 
                WHERE PartitionFunctionName = '{partitionFunctionName}'");

            Assert.Greater(expected.Count, 0);
            Assert.Greater(actual.Count, 0);

            Assert.AreEqual(expected.Count, actual.Count); //1 partition function only

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.PartitionFunctionName == expectedRow.PartitionFunctionName && x.BoundaryValue == expectedRow.BoundaryValue);

                Assert.AreEqual(numOfTotalPartitionSchemeIntervals, actual.Count);
                Assert.AreEqual(expectedRow.PartitionSchemeName, actualRow.PartitionSchemeName);
                Assert.AreEqual(expectedRow.NextBoundaryValue, actualRow.NextBoundaryValue);
                Assert.AreEqual(expectedRow.FileGroupName, actualRow.FileGroupName);
                Assert.AreEqual(isFileGroupMissing, actualRow.IsFileGroupMissing);
            }
        }

    }
}
