using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using Models = DOI.Tests.Integration.Models;

namespace DOI.Tests.TestHelpers.Metadata
{
    public class SysPartitionFunctionsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysPartitionFunctions";
        public const string SqlServerDmvName = "sys.partition_functions";
        public const string UserTableName = "PartitionFunctions";

        public static List<SysPartitionFunctions> GetExpectedSysValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName} 
            WHERE name = '{PartitionFunctionName}'"));

            List<SysPartitionFunctions> expectedSysPartitionFunctions = new List<SysPartitionFunctions>();

            foreach (var row in expected)
            {
                var columnValue = new SysPartitionFunctions();

                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.function_id = row.First(x => x.First == "function_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.fanout = row.First(x => x.First == "fanout").Second.ObjectToInteger();
                columnValue.boundary_value_on_right = (bool)row.First(x => x.First == "boundary_value_on_right").Second;
                columnValue.is_system = (bool)row.First(x => x.First == "is_system").Second;
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.modify_date = row.First(x => x.First == "modify_date").Second.ObjectToDateTime();

                expectedSysPartitionFunctions.Add(columnValue);
            }

            return expectedSysPartitionFunctions;
        }

        public static List<SysPartitionFunctions> GetActualSysValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT T.* 
            FROM DOI.{SysTableName} T 
                INNER JOIN DOI.SysDatabases D ON T.database_id = d.database_id
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{PartitionFunctionName}'"));

            List<SysPartitionFunctions> actualSysPartitionFunctions = new List<SysPartitionFunctions>();

            foreach (var row in actual)
            {
                var columnValue = new SysPartitionFunctions();

                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.function_id = row.First(x => x.First == "function_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.fanout = row.First(x => x.First == "fanout").Second.ObjectToInteger();
                columnValue.boundary_value_on_right = (bool)row.First(x => x.First == "boundary_value_on_right").Second;
                columnValue.is_system = (bool)row.First(x => x.First == "is_system").Second;
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.modify_date = row.First(x => x.First == "modify_date").Second.ObjectToDateTime();

                actualSysPartitionFunctions.Add(columnValue);
            }

            return actualSysPartitionFunctions;
        }

        public static List<PartitionFunctions> GetActualUserValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT T.* 
            FROM DOI.{UserTableName} T 
            WHERE T.DatabaseName = '{DatabaseName}'
                AND T.PartitionFunctionName = '{PartitionFunctionName}'"));

            List<PartitionFunctions> actualUserPartitionFunctions = new List<PartitionFunctions>();

            foreach (var row in actual)
            {
                var columnValue = new PartitionFunctions();

                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.PartitionFunctionDataType = row.First(x => x.First == "PartitionFunctionDataType").Second.ToString();
                columnValue.BoundaryInterval = row.First(x => x.First == "BoundaryInterval").Second.ToString();
                columnValue.NumOfFutureIntervals = row.First(x => x.First == "NumOfFutureIntervals").Second.ObjectToInteger();
                columnValue.InitialDate = row.First(x => x.First == "InitialDate").Second.ObjectToDateTime();
                columnValue.UsesSlidingWindow = (bool)row.First(x => x.First == "UsesSlidingWindow").Second;
                columnValue.SlidingWindowSize = row.First(x => x.First == "SlidingWindowSize").Second.ObjectToInteger();
                columnValue.IsDeprecated = (bool)row.First(x => x.First == "IsDeprecated").Second;
                columnValue.PartitionSchemeName = row.First(x => x.First == "PartitionSchemeName").Second.ToString();
                columnValue.NumOfCharsInSuffix = row.First(x => x.First == "NumOfCharsInSuffix").Second.ObjectToInteger();
                columnValue.LastBoundaryDate = row.First(x => x.First == "LastBoundaryDate").Second.ObjectToDateTime();
                columnValue.NumOfTotalPartitionFunctionIntervals = row.First(x => x.First == "NumOfTotalPartitionFunctionIntervals").Second.ObjectToInteger();
                columnValue.NumOfTotalPartitionSchemeIntervals = row.First(x => x.First == "NumOfTotalPartitionSchemeIntervals").Second.ObjectToInteger();
                columnValue.MinValueOfDataType = row.First(x => x.First == "MinValueOfDataType").Second.ToString();

                actualUserPartitionFunctions.Add(columnValue);
            }

            return actualUserPartitionFunctions;
        }
        public static List<vwPartitionFunctionPartitions> GetExpectedValues_vwPartitionFunctionPartitions()
        {
            List<vwPartitionFunctionPartitions> expected_vwPartitionFunctionPartitions = new List<vwPartitionFunctionPartitions>();

                var columnValue = new vwPartitionFunctionPartitions();

                //columnValue.DatabaseName = DatabaseName;
                //columnValue.PartitionFunctionName = PartitionFunctionName;
                //columnValue.PartitionSchemeName = PartitionSchemeName;
                //columnValue.BoundaryInterval = row.First(x => x.First == "BoundaryInterval").Second.ToString();
                //columnValue.UsesSlidingWindow = false;
                //columnValue.SlidingWindowSize = row.First(x => x.First == "SlidingWindowSize").Second.ToString();
                //columnValue.IsDeprecated = false;
                //columnValue.NextUsedFileGroupName = row.First(x => x.First == "NextUsedFileGroupName").Second.ToString();
                //columnValue.BoundaryValue = row.First(x => x.First == "BoundaryValue").Second.ObjectToDateTime();
                //columnValue.NextBoundaryValue = row.First(x => x.First == "NextBoundaryValue").Second.ObjectToDateTime();
                //columnValue.DateDiffs = row.First(x => x.First == "DateDiffs").Second.ObjectToInteger();
                //columnValue.PartitionNumber = row.First(x => x.First == "PartitionNumber").Second.ObjectToInteger();
                //columnValue.FileGroupName = row.First(x => x.First == "FileGroupName").Second.ToString();
                //columnValue.IsSlidingWindowActivePartition = row.First(x => x.First == "IsSlidingWindowActivePartition").Second.ObjectToInteger();
                //columnValue.IncludeInPartitionFunction = row.First(x => x.First == "IncludeInPartitionFunction").Second.ObjectToInteger();
                //columnValue.IncludeInPartitionScheme = row.First(x => x.First == "IncludeInPartitionScheme").Second.ObjectToInteger();
                //columnValue.IsPartitionMissing = row.First(x => x.First == "IsPartitionMissing").Second.ObjectToInteger();
                //columnValue.AddFileGroupSQL = row.First(x => x.First == "AddFileGroupSQL").Second.ToString();
                //columnValue.AddFileSQL = row.First(x => x.First == "AddFileSQL").Second.ToString();
                //columnValue.PartitionFunctionSplitSQL = row.First(x => x.First == "PartitionFunctionSplitSQL").Second.ToString();
                //columnValue.SetFilegroupToNextUsedSQL = row.First(x => x.First == "SetFilegroupToNextUsedSQL").Second.ToString();
                //columnValue.PrepTableNameSuffix = row.First(x => x.First == "PrepTableNameSuffix").Second.ToString();

                expected_vwPartitionFunctionPartitions.Add(columnValue);
            

            return expected_vwPartitionFunctionPartitions;
        }


        public static List<vwPartitionFunctionPartitions> GetActualValues_vwPartitionFunctionPartitions()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.vwPartitionFunctionPartitions 
            WHERE name = '{PartitionFunctionName}'"));

            List<vwPartitionFunctionPartitions> actual_vwPartitionFunctionPartitions = new List<vwPartitionFunctionPartitions>();

            foreach (var row in expected)
            {
                var columnValue = new vwPartitionFunctionPartitions();

                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.PartitionSchemeName = row.First(x => x.First == "PartitionSchemeName").Second.ToString();
                columnValue.BoundaryInterval = row.First(x => x.First == "BoundaryInterval").Second.ToString();
                columnValue.UsesSlidingWindow = (bool)row.First(x => x.First == "UsesSlidingWindow").Second;
                columnValue.SlidingWindowSize = row.First(x => x.First == "SlidingWindowSize").Second.ToString();
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

                actual_vwPartitionFunctionPartitions.Add(columnValue);
            }

            return actual_vwPartitionFunctionPartitions;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertSysMetadata()
        {
            var expected = GetExpectedSysValues();

            Assert.AreEqual(1, expected.Count);

            var actual = GetActualSysValues();

            Assert.AreEqual(1, actual.Count);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id);

                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.function_id, actualRow.function_id);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.fanout, actualRow.fanout);
                Assert.AreEqual(expectedRow.boundary_value_on_right, actualRow.boundary_value_on_right);
                Assert.AreEqual(expectedRow.is_system, actualRow.is_system);
                Assert.AreEqual(expectedRow.create_date, actualRow.create_date);
                Assert.AreEqual(expectedRow.modify_date, actualRow.modify_date);
            }
        }

        public static void AssertUserMetadata()
        {
            var actual = GetActualUserValues();

            Assert.AreEqual(1, actual.Count);

            foreach (var actualRow in actual)
            {
                Assert.AreEqual(DatabaseName, actualRow.DatabaseName);
                Assert.AreEqual(PartitionFunctionName, actualRow.PartitionFunctionName);
                Assert.AreEqual("DATETIME2", actualRow.PartitionFunctionDataType);
                Assert.AreEqual("Yearly", actualRow.BoundaryInterval);
                Assert.AreEqual(1, actualRow.NumOfFutureIntervals);
                Assert.AreEqual(DateTime.Parse("2016-01-01"), actualRow.InitialDate);
                Assert.AreEqual(false, actualRow.UsesSlidingWindow);
                Assert.AreEqual(0, actualRow.SlidingWindowSize);
                Assert.AreEqual(false, actualRow.IsDeprecated);
                Assert.AreEqual(PartitionSchemeName, actualRow.PartitionSchemeName);
                Assert.AreEqual(4, actualRow.NumOfCharsInSuffix);
                Assert.AreEqual(DateTime.Parse("2021-01-01"), actualRow.LastBoundaryDate);
                Assert.AreEqual(6, actualRow.NumOfTotalPartitionFunctionIntervals);
                Assert.AreEqual(7, actualRow.NumOfTotalPartitionSchemeIntervals);
                Assert.AreEqual("0001-01-01", actualRow.MinValueOfDataType);
            }
        }

    }
}
