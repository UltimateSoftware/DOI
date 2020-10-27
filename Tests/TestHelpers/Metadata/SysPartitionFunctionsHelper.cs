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

        public static List<SysPartitionFunctions> GetExpectedValues()
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

        public static List<SysPartitionFunctions> GetActualValues()
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

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            Assert.AreEqual(1, expected.Count);

            var actual = GetActualValues();

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
    }
}
