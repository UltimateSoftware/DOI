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
    public class vwPartitionSchemesHelper : SystemMetadataHelper
    {
        public const string UserTableName = "PartitionFunctions";
        public const string ViewName = "vwPartitionSchemes";

        public string GetPartitionSchemeSql(string partitionSchemeName, string createOrDrop)
        {
            var fieldName = createOrDrop == "Create" ? "CreatePartitionSchemeSQL" : "DropPartitionSchemeSQL";

            return sqlHelper.ExecuteScalar<string>($@"
            SELECT {fieldName} + ';'
            FROM DOI.{ViewName}
            WHERE PartitionSchemeName = '{partitionSchemeName}'");
        }

        public static List<vwPartitionSchemes> GetExpectedValues(string partitionSchemeName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
                SELECT * 
                FROM DOI.DOI.{UserTableName}
                WHERE DatabaseName = '{DatabaseName}'
                    AND PartitionSchemeName = '{partitionSchemeName}'"));

            var isPartitionSchemeMissing = sqlHelper.ExecuteScalar<int>($@"
                SELECT 0 
                FROM DOI.SysPartitionSchemes ps
                    INNER JOIN DOI.SysDatabases d ON ps.database_id = d.database_id
                    INNER JOIN DOI.SysPartitionFunctions pf ON pf.database_id = ps.database_id
                        AND pf.function_id = ps.function_id
                WHERE d.name = '{DatabaseName}'
                    AND ps.name = '{partitionSchemeName}'");

            var nextUsedFileGroupName = sqlHelper.ExecuteScalar<string>($@"
                SELECT NextUsedFileGroupName, *
				FROM DOI.SysPartitionFunctions pf
                    OUTER APPLY (	SELECT	FG.Name AS NextUsedFileGroupName,
								            prv.value, 
								            ps.Name AS PartitionSchemeName,
								            ps.function_id,dds.destination_id,
								            RANK() OVER (PARTITION BY ps.database_id, ps.name ORDER BY dds.destination_Id) AS dest_rank
						            FROM DOI.SysPartitionSchemes ps
                                        INNER JOIN DOI.SysDestinationDataSpaces AS DDS ON DDS.database_id = ps.database_id
                                            AND DDS.partition_scheme_id = ps.data_space_id
							            INNER JOIN DOI.SysFilegroups AS FG ON FG.data_space_id = DDS.data_space_ID 
                                            AND FG.database_id = DDS.database_id
							            LEFT JOIN DOI.SysPartitionRangeValues AS PRV ON PRV.database_id = DDS.database_id
                                            AND PRV.Boundary_ID = DDS.destination_id 
								            AND prv.function_id = ps.function_id 
						            WHERE pf.database_id = ps.database_id
                                        AND ps.function_id = pf.function_id                       
							            AND prv.Value IS NULL) x
				WHERE X.PartitionSchemeName = '{partitionSchemeName}'");

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
                WHERE ps.name = '{partitionSchemeName}'");

            List<vwPartitionSchemes> expectedVwPartitionSchemes = new List<vwPartitionSchemes>();

            foreach (var row in expected)
            {
                var columnValue = new vwPartitionSchemes();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionSchemeName = row.First(x => x.First == "PartitionSchemeName").Second.ToString();
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
                columnValue.NumOfTotalPartitionSchemeIntervals = row.First(x => x.First == "NumOfTotalPartitionSchemeIntervals").Second.ObjectToInteger();
                columnValue.MinValueOfDataType = row.First(x => x.First == "MinValueOfDataType").Second.ToString();
                columnValue.NextUsedFileGroupName = nextUsedFileGroupName;
                columnValue.IsPartitionSchemeMissing = isPartitionSchemeMissing;

                expectedVwPartitionSchemes.Add(columnValue);
            }

            return expectedVwPartitionSchemes;
        }

        public static List<vwPartitionSchemes> GetActualValues(string partitionSchemeName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{ViewName} 
            WHERE DatabaseName = '{DatabaseName}' 
                AND PartitionSchemeName = '{partitionSchemeName}'"));


            List<vwPartitionSchemes> actualVwPartitionSchemes = new List<vwPartitionSchemes>();

            foreach (var row in actual)
            {
                var columnValue = new vwPartitionSchemes();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionSchemeName = row.First(x => x.First == "PartitionSchemeName").Second.ToString();
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
                columnValue.NumOfTotalPartitionSchemeIntervals = row.First(x => x.First == "NumOfTotalPartitionSchemeIntervals").Second.ObjectToInteger();
                columnValue.MinValueOfDataType = row.First(x => x.First == "MinValueOfDataType").Second.ToString();
                columnValue.NextUsedFileGroupName = row.First(x => x.First== "NextUsedFileGroupName").Second.ToString();
                columnValue.IsPartitionSchemeMissing = row.First(x => x.First == "IsPartitionSchemeMissing").Second.ObjectToInteger();
                columnValue.CreatePartitionSchemeSQL = row.First(x => x.First == "CreatePartitionSchemeSQL").Second.ToString();
                columnValue.DropPartitionSchemeSQL = row.First(x => x.First == "DropPartitionSchemeSQL").Second.ToString();

                actualVwPartitionSchemes.Add(columnValue);
            }

            return actualVwPartitionSchemes;
        }

        //verify DOI Sys table data against expected values.

        public static void AssertMetadata(string boundaryInterval, DateTime initialDate, int numOfFutureIntervals, bool usesSlidingWindow = false, int? slidingWindowSize = null)
        {
            SqlHelper sqlHelper = new SqlHelper();
            string partitionSchemeName = String.Concat("psTests", boundaryInterval);

            var expected = GetExpectedValues(partitionSchemeName);
            var actual = GetActualValues(partitionSchemeName);

            Assert.AreEqual(1, expected.Count); //1 partition function only

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.PartitionSchemeName == expectedRow.PartitionSchemeName);

                Assert.AreEqual(expectedRow.PartitionFunctionName, actualRow.PartitionFunctionName, "PartitionFunctionName");
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
                Assert.AreEqual(expectedRow.NumOfTotalPartitionSchemeIntervals, actualRow.NumOfTotalPartitionSchemeIntervals, "NumOfTotalPartitionSchemeIntervals");
                Assert.AreEqual(expectedRow.MinValueOfDataType, actualRow.MinValueOfDataType, "MinValueOfDataType");
                Assert.AreEqual(expectedRow.NextUsedFileGroupName, actualRow.NextUsedFileGroupName, "NextUsedFileGroupName"); 
                Assert.AreEqual(expectedRow.IsPartitionSchemeMissing, actualRow.IsPartitionSchemeMissing, "IsPartitionSchemeMissing");

            }
        }

    }
}
