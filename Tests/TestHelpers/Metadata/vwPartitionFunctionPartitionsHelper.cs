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
    public class vwPartitionFunctionPartitionsHelper : SystemMetadataHelper
    {
        public const string UserTableName = "PartitionFunctions";
        public const string ViewName = "vwPartitionFunctionPartitions";

        public static List<PartitionFunctions> GetExpectedValues(string partitionFunctionName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{UserTableName}
            WHERE DatabaseName = '{DatabaseName}'
                AND PartitionFunctionName = '{partitionFunctionName}'"));

            List<PartitionFunctions> expectedPartitionFunctions = new List<PartitionFunctions>();

            foreach (var row in expected)
            {
                var columnValue = new PartitionFunctions();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.PartitionFunctionDataType = row.First(x => x.First == "PartitionFunctionDataType").Second.ToString();
                columnValue.PartitionSchemeName = row.First(x => x.First == "PartitionSchemeName").Second.ToString();
                columnValue.BoundaryInterval = row.First(x => x.First == "BoundaryInterval").Second.ToString();
                columnValue.UsesSlidingWindow = (bool)row.First(x => x.First == "UsesSlidingWindow").Second;
                columnValue.SlidingWindowSize = row.First(x => x.First == "SlidingWindowSize").Second.ObjectToInteger();
                columnValue.IsDeprecated = (bool)row.First(x => x.First == "IsDeprecated").Second;
                columnValue.PartitionFunctionDataType = row.First(x => x.First == "PartitionFunctionDataType").Second.ToString();
                columnValue.NumOfFutureIntervals = row.First(x => x.First == "NumOfFutureIntervals").Second.ObjectToInteger();
                columnValue.InitialDate = row.First(x => x.First == "InitialDate").Second.ObjectToDateTime();
                columnValue.NumOfCharsInSuffix = row.First(x => x.First == "NumOfCharsInSuffix").Second.ObjectToInteger();
                columnValue.LastBoundaryDate = row.First(x => x.First == "LastBoundaryDate").Second.ObjectToDateTime();
                columnValue.NumOfTotalPartitionFunctionIntervals = row.First(x => x.First == "NumOfTotalPartitionFunctionIntervals").Second.ObjectToInteger();
                columnValue.NumOfTotalPartitionSchemeIntervals = row.First(x => x.First == "NumOfTotalPartitionSchemeIntervals").Second.ObjectToInteger();
                columnValue.MinValueOfDataType = row.First(x => x.First == "MinValueOfDataType").Second.ToString();

                expectedPartitionFunctions.Add(columnValue);
            }

            return expectedPartitionFunctions;
        }

        public static List<vwPartitionFunctionPartitions> GetActualValues(string partitionFunctionName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.vwPartitionFunctionPartitions 
            WHERE DatabaseName = '{DatabaseName}' 
                AND PartitionFunctionName = '{partitionFunctionName}'"));


            List<vwPartitionFunctionPartitions> actualVwPartitionFunctionPartitions = new List<vwPartitionFunctionPartitions>();

            foreach (var row in actual)
            {
                var columnValue = new vwPartitionFunctionPartitions();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.PartitionSchemeName = row.First(x => x.First == "PartitionSchemeName").Second.ToString();
                columnValue.BoundaryInterval = row.First(x => x.First == "BoundaryInterval").Second.ToString();
                columnValue.UsesSlidingWindow = (bool)row.First(x => x.First == "UsesSlidingWindow").Second;
                columnValue.SlidingWindowSize = row.First(x => x.First == "SlidingWindowSize").Second.ObjectToInteger();
                columnValue.IsDeprecated = (bool)row.First(x => x.First == "IsDeprecated").Second;
                columnValue.NextUsedFileGroupName = row.First(x => x.First == "NextUsedFileGroupName").Second.ToString();
                columnValue.BoundaryValue = row.First(x => x.First == "BoundaryValue").Second.ObjectToDateTime();
                columnValue.NextBoundaryValue = row.First(x => x.First == "NextBoundaryValue").Second.ObjectToDateTime();
                columnValue.DateDiffs = row.First(x => x.First == "DateDiffs").Second.ObjectToInteger();
                columnValue.PartitionNumber = row.First(x => x.First == "PartitionNumber").Second.ObjectToInteger();
                columnValue.FileGroupName = row.First(x => x.First == "FileGroupName").Second.ToString();
                columnValue.IsSlidingWindowActivePartition = row.First(x => x.First == "IsSlidingWindowActivePartition").Second.ObjectToInteger();
                columnValue.IncludeInPartitionFunction = row.First(x => x.First == "IncludeInPartitionFunction").Second.ObjectToInteger();
                columnValue.IncludeInPartitionScheme = row.First(x => x.First == "IncludeInPartitionScheme").Second.ObjectToInteger();
                columnValue.IsPartitionMissing = row.First(x => x.First == "IsPartitionMissing").Second.ObjectToInteger();
                columnValue.AddFileGroupSQL = row.First(x => x.First == "AddFileGroupSQL").Second.ToString();
                columnValue.AddFileSQL = row.First(x => x.First == "AddFileSQL").Second.ToString();
                columnValue.PartitionFunctionSplitSQL = row.First(x => x.First == "PartitionFunctionSplitSQL").Second.ToString();
                columnValue.SetFilegroupToNextUsedSQL = row.First(x => x.First == "SetFilegroupToNextUsedSQL").Second.ToString();
                columnValue.PrepTableNameSuffix = row.First(x => x.First == "PrepTableNameSuffix").Second.ToString();

                actualVwPartitionFunctionPartitions.Add(columnValue);
            }

            return actualVwPartitionFunctionPartitions;
        }

        //verify DOI Sys table data against expected values.

        public static void AssertMetadata(string boundaryInterval, DateTime initialDate, int numOfFutureIntervals, bool usesSlidingWindow = false, int? slidingWindowSize = null)
        {
            SqlHelper sqlHelper = new SqlHelper();
            string partitionFunctionName = String.Concat("pfTests", boundaryInterval);
            
            var expected = GetExpectedValues(partitionFunctionName);
            var actual = GetActualValues(partitionFunctionName);
            DateTime expectedLastBoundaryDate = DateTime.Now;
            int expectedNumCharsInSuffix = 0;
            int expectedNumOfTotalPartitionFunctionIntervals = 0;
            int expectedNumOfTotalPartitionSchemeIntervals = 0;

            switch (boundaryInterval)
            {
                case "Yearly":
                    expectedNumCharsInSuffix = 4;
                    break;
                case "Monthly":
                    expectedNumCharsInSuffix = 6;
                    break;
                default:
                    expectedNumCharsInSuffix = 0;
                    break;
            }

            if (!usesSlidingWindow)
            {

                    expectedLastBoundaryDate = sqlHelper.ExecuteScalar<DateTime>($@"
                SELECT MAX(BoundaryValue)
                FROM DOI.DOI.{ViewName} 
                WHERE DatabaseName = '{DatabaseName}'
                    AND PartitionFunctionName = '{partitionFunctionName}'");

                    expectedNumOfTotalPartitionFunctionIntervals = sqlHelper.ExecuteScalar<int>($@"
                SELECT COUNT(*)
                FROM DOI.DOI.{ViewName}  
                WHERE DatabaseName = '{DatabaseName}'
                    AND PartitionFunctionName = '{partitionFunctionName}'
                    AND IncludeInPartitionFunction = 1");

                    expectedNumOfTotalPartitionSchemeIntervals = sqlHelper.ExecuteScalar<int>($@"
                SELECT COUNT(*)
                FROM DOI.DOI.{ViewName}  
                WHERE DatabaseName = '{DatabaseName}'
                    AND PartitionFunctionName = '{partitionFunctionName}'
                    AND IncludeInPartitionScheme = 1");
            }
            else
            {
                //need sliding window logic here
            }

            Assert.AreEqual(1, expected.Count); //1 partition function only

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.PartitionFunctionName == expectedRow.PartitionFunctionName);

                Assert.AreEqual(expectedRow.NumOfTotalPartitionSchemeIntervals, actual.Count, "NumOfTotalPartitionSchemeIntervals");
                Assert.AreEqual(expectedNumOfTotalPartitionFunctionIntervals, expectedRow.NumOfTotalPartitionFunctionIntervals, "NumOfTotalPartitionFunctionIntervals");
                Assert.AreEqual(expectedNumOfTotalPartitionSchemeIntervals, expectedRow.NumOfTotalPartitionSchemeIntervals, "NumOfTotalPartitionSchemeIntervals");
                Assert.AreEqual("DATETIME2", expectedRow.PartitionFunctionDataType, "PartitionFunctionDataType");
                Assert.AreEqual(expectedNumCharsInSuffix, expectedRow.NumOfCharsInSuffix, "NumOfCharsInSuffix");
                Assert.AreEqual(expectedLastBoundaryDate, expectedRow.LastBoundaryDate, "LastBoundaryDate");


                Assert.AreEqual(expectedRow.PartitionSchemeName, actualRow.PartitionSchemeName, "PartitionSchemeName");
                Assert.AreEqual(expectedRow.BoundaryInterval, actualRow.BoundaryInterval, "BoundaryInterval");
                Assert.AreEqual(expectedRow.UsesSlidingWindow, actualRow.UsesSlidingWindow, "UsesSlidingWindow");
                Assert.AreEqual(expectedRow.SlidingWindowSize, actualRow.SlidingWindowSize, "SlidingWindowSize");
                Assert.AreEqual(expectedRow.IsDeprecated, actualRow.IsDeprecated, "IsDeprecated");
                //Assert.AreEqual(expectedRow.NextUsedFileGroupName, actualRow.NextUsedFileGroupName);
                //Assert.AreEqual(expectedRow.BoundaryValue, actualRow.BoundaryValue);
                //Assert.AreEqual(expectedRow.NextBoundaryValue, actualRow.NextBoundaryValue);
                //Assert.AreEqual(expectedRow.DateDiffs, actualRow.DateDiffs);
                //Assert.AreEqual(expectedRow.PartitionNumber, actualRow.PartitionNumber);
                //Assert.AreEqual(expectedRow.FileGroupName, actualRow.FileGroupName);
                //Assert.AreEqual(expectedRow.IsSlidingWindowActivePartition, actualRow.IsSlidingWindowActivePartition);
                //Assert.AreEqual(expectedRow.IncludeInPartitionFunction, actualRow.IncludeInPartitionFunction);
                //Assert.AreEqual(expectedRow.IncludeInPartitionScheme, actualRow.IncludeInPartitionScheme);
                //Assert.AreEqual(expectedRow.IsPartitionMissing, actualRow.IsPartitionMissing);
                //Assert.AreEqual(expectedRow.AddFileGroupSQL, actualRow.AddFileGroupSQL);
                //Assert.AreEqual(expectedRow.AddFileSQL, actualRow.AddFileSQL);
                //Assert.AreEqual(expectedRow.PartitionFunctionSplitSQL, actualRow.PartitionFunctionSplitSQL);
                //Assert.AreEqual(expectedRow.SetFilegroupToNextUsedSQL, actualRow.SetFilegroupToNextUsedSQL);
                //Assert.AreEqual(expectedRow.PrepTableNameSuffix, actualRow.PrepTableNameSuffix);
            }
        }
    }
}
