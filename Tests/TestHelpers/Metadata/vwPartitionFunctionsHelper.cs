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
    public class vwPartitionFunctionsHelper : SystemMetadataHelper
    {
        public const string UserTableName = "PartitionFunctions";
        public const string ViewName = "vwPartitionFunctions";

        public string GetPartitionFunctionSql(string partitionFunctionName, string createOrDrop)
        {
            var fieldName = createOrDrop == "Create" ? "CreatePartitionFunctionSQL" : "DropPartitionFunctionSQL";

            var sql = sqlHelper.ExecuteScalar<string>($@"
            SELECT {fieldName} + ';'
            FROM DOI.vwPartitionFunctions
            WHERE PartitionFunctionName = '{partitionFunctionName}'");

            return sql;
        }

        public static List<vwPartitionFunctions> GetExpectedValues(string partitionFunctionName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
                SELECT * 
                FROM DOI.DOI.{UserTableName}
                WHERE DatabaseName = '{DatabaseName}'
                    AND PartitionFunctionName = '{partitionFunctionName}'"));

            var isPartitionFunctionMissing = sqlHelper.ExecuteScalar<int>($@"
                SELECT 0 
                FROM DOI.SysPartitionFunctions pf
                    INNER JOIN DOI.SysDatabases d ON pf.database_id = d.database_id
                WHERE d.name = '{DatabaseName}'
                    AND pf.name = '{partitionFunctionName}'");

            var numOfFutureIntervals_Actual = sqlHelper.ExecuteScalar<int>($@"
                SELECT NumFutureIntervals
                FROM DOI.SysPartitionFunctions pf
                    INNER JOIN DOI.SysPartitionSchemes ps ON ps.function_id = pf.function_id
                    OUTER APPLY (   SELECT prv.function_id, COUNT(prv.boundary_id) AS NumFutureIntervals
                                    FROM DOI.SysDestinationDataSpaces AS DDS 
    				                    INNER JOIN DOI.SysFilegroups AS FG ON FG.data_space_id = DDS.data_space_ID 
					                    LEFT JOIN DOI.SysPartitionRangeValues AS PRV ON PRV.Boundary_ID = DDS.destination_id 
						                    AND prv.function_id = ps.function_id 
				                    WHERE DDS.partition_scheme_id = ps.data_space_id
                                        AND prv.value > GETDATE()
                                    GROUP BY PRV.function_id)x
                WHERE pf.name = '{partitionFunctionName}'");

            List<vwPartitionFunctions> expectedVwPartitionFunctions = new List<vwPartitionFunctions>();

            foreach (var row in expected)
            {
                var columnValue = new vwPartitionFunctions();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.PartitionFunctionDataType = row.First(x => x.First == "PartitionFunctionDataType").Second.ToString();
                columnValue.BoundaryInterval = row.First(x => x.First == "BoundaryInterval").Second.ToString();
                columnValue.NumOfFutureIntervals_Desired = row.First(x => x.First == "NumOfFutureIntervals").Second.ObjectToInteger();
                columnValue.NumOfFutureIntervals_Actual = numOfFutureIntervals_Actual;
                columnValue.InitialDate = row.First(x => x.First == "InitialDate").Second.ObjectToDateTime();
                columnValue.UsesSlidingWindow = (bool)row.First(x => x.First == "UsesSlidingWindow").Second;
                columnValue.SlidingWindowSize = row.First(x => x.First == "SlidingWindowSize").Second.ObjectToInteger();
                columnValue.IsDeprecated = (bool)row.First(x => x.First == "IsDeprecated").Second;
                columnValue.NumOfCharsInSuffix = row.First(x => x.First == "NumOfCharsInSuffix").Second.ObjectToInteger();
                columnValue.LastBoundaryDate = row.First(x => x.First == "LastBoundaryDate").Second.ObjectToDateTime();
                columnValue.NumOfTotalPartitionFunctionIntervals = row.First(x => x.First == "NumOfTotalPartitionFunctionIntervals").Second.ObjectToInteger();
                columnValue.MinValueOfDataType = row.First(x => x.First == "MinValueOfDataType").Second.ToString();
                columnValue.IsPartitionFunctionMissing = isPartitionFunctionMissing;

                expectedVwPartitionFunctions.Add(columnValue);
            }

            return expectedVwPartitionFunctions;
        }

        public static List<vwPartitionFunctions> GetActualValues(string partitionFunctionName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{ViewName} 
            WHERE DatabaseName = '{DatabaseName}' 
                AND PartitionFunctionName = '{partitionFunctionName}'"));


            List<vwPartitionFunctions> actualVwPartitionFunctions = new List<vwPartitionFunctions>();

            foreach (var row in actual)
            {
                var columnValue = new vwPartitionFunctions();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.PartitionFunctionDataType = row.First(x => x.First == "PartitionFunctionDataType").Second.ToString();
                columnValue.BoundaryInterval = row.First(x => x.First == "BoundaryInterval").Second.ToString();
                columnValue.NumOfFutureIntervals_Desired = row.First(x => x.First == "NumOfFutureIntervals_Desired").Second.ObjectToInteger();
                columnValue.NumOfFutureIntervals_Actual = row.First(x => x.First == "NumOfFutureIntervals_Actual").Second.ObjectToInteger();
                columnValue.InitialDate = row.First(x => x.First == "InitialDate").Second.ObjectToDateTime();
                columnValue.UsesSlidingWindow = (bool)row.First(x => x.First == "UsesSlidingWindow").Second;
                columnValue.SlidingWindowSize = row.First(x => x.First == "SlidingWindowSize").Second.ObjectToInteger();
                columnValue.IsDeprecated = (bool)row.First(x => x.First == "IsDeprecated").Second;
                columnValue.NumOfCharsInSuffix = row.First(x => x.First == "NumOfCharsInSuffix").Second.ObjectToInteger();
                columnValue.LastBoundaryDate = row.First(x => x.First == "LastBoundaryDate").Second.ObjectToDateTime();
                columnValue.NumOfTotalPartitionFunctionIntervals = row.First(x => x.First == "NumOfTotalPartitionFunctionIntervals").Second.ObjectToInteger();
                columnValue.MinValueOfDataType = row.First(x => x.First == "MinValueOfDataType").Second.ToString();
                columnValue.IsPartitionFunctionMissing = row.First(x => x.First == "IsPartitionFunctionMissing").Second.ObjectToInteger();
                columnValue.CreatePartitionFunctionSQL = row.First(x => x.First == "CreatePartitionFunctionSQL").Second.ToString();

                actualVwPartitionFunctions.Add(columnValue);
            }

            return actualVwPartitionFunctions;
        }

        //verify DOI Sys table data against expected values.

        public static void AssertMetadata(string boundaryInterval, DateTime initialDate, int numOfFutureIntervals, bool usesSlidingWindow = false, int? slidingWindowSize = null)
        {
            SqlHelper sqlHelper = new SqlHelper();
            string partitionFunctionName = String.Concat("pfTests", boundaryInterval);

            var expected = GetExpectedValues(partitionFunctionName);
            var actual = GetActualValues(partitionFunctionName);

            Assert.AreEqual(1, expected.Count); //1 partition function only

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.PartitionFunctionName == expectedRow.PartitionFunctionName);

                Assert.AreEqual("DATETIME2", expectedRow.PartitionFunctionDataType, "PartitionFunctionDataType");
                Assert.AreEqual(expectedRow.BoundaryInterval, actualRow.BoundaryInterval, "BoundaryInterval");
                Assert.AreEqual(expectedRow.NumOfFutureIntervals_Desired, actualRow.NumOfFutureIntervals_Desired, "NumOfFutureIntervals_Desired");
                Assert.AreEqual(expectedRow.NumOfFutureIntervals_Actual, actualRow.NumOfFutureIntervals_Actual, "NumOfFutureIntervals_Actual");
                Assert.AreEqual(expectedRow.InitialDate, actualRow.InitialDate, "InitialDate");
                Assert.AreEqual(expectedRow.UsesSlidingWindow, actualRow.UsesSlidingWindow, "UsesSlidingWindow");
                Assert.AreEqual(expectedRow.SlidingWindowSize, actualRow.SlidingWindowSize, "SlidingWindowSize");
                Assert.AreEqual(expectedRow.IsDeprecated, actualRow.IsDeprecated, "IsDeprecated");
                Assert.AreEqual(expectedRow.NumOfCharsInSuffix, actualRow.NumOfCharsInSuffix, "NumOfCharsInSuffix");
                Assert.AreEqual(expectedRow.LastBoundaryDate, actualRow.LastBoundaryDate, "LastBoundaryDate");
                Assert.AreEqual(expectedRow.NumOfTotalPartitionFunctionIntervals, actualRow.NumOfTotalPartitionFunctionIntervals, "NumOfTotalPartitionFunctionIntervals");
                Assert.AreEqual(expectedRow.MinValueOfDataType, actualRow.MinValueOfDataType, "MinValueOfDataType");
                Assert.AreEqual(expectedRow.IsPartitionFunctionMissing, actualRow.IsPartitionFunctionMissing, "IsPartitionFunctionMissing");
            }
        }



    }
}
