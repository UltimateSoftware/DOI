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
    public class SysPartitionRangeValuesHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysPartitionRangeValues";
        public const string SqlServerDmvName = "sys.partition_range_values";

        public static List<SysPartitionRangeValues> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT prv.* 
            FROM {DatabaseName}.{SqlServerDmvName} prv
                INNER JOIN {DatabaseName}.sys.partition_functions pf ON pf.function_id = prv.function_id
            WHERE pf.name = '{PartitionFunctionName}'"));

            List<SysPartitionRangeValues> expectedSysPartitionRangeValues = new List<SysPartitionRangeValues>();

            foreach (var row in expected)
            {
                var columnValue = new SysPartitionRangeValues();

                columnValue.function_id = row.First(x => x.First == "function_id").Second.ObjectToInteger();
                columnValue.boundary_id = row.First(x => x.First == "boundary_id").Second.ObjectToInteger();
                columnValue.parameter_id = row.First(x => x.First == "parameter_id").Second.ObjectToInteger();
                columnValue.value = row.First(x => x.First == "value").Second.ObjectToDateTime();

                expectedSysPartitionRangeValues.Add(columnValue);
            }

            return expectedSysPartitionRangeValues;
        }

        public static List<SysPartitionRangeValues> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT T.* 
            FROM DOI.{SysTableName} T 
                INNER JOIN DOI.SysDatabases D ON T.database_id = d.database_id
                INNER JOIN DOI.SysPartitionFunctions PF ON T.function_id = pf.function_id
            WHERE D.name = '{DatabaseName}'
                AND pf.name = '{PartitionFunctionName}'"));

            List<SysPartitionRangeValues> actualSysPartitionRangeValues = new List<SysPartitionRangeValues>();

            foreach (var row in actual)
            {
                var columnValue = new SysPartitionRangeValues();

                columnValue.function_id = row.First(x => x.First == "function_id").Second.ObjectToInteger();
                columnValue.boundary_id = row.First(x => x.First == "boundary_id").Second.ObjectToInteger();
                columnValue.parameter_id = row.First(x => x.First == "parameter_id").Second.ObjectToInteger();
                columnValue.value = row.First(x => x.First == "value").Second.ObjectToDateTime();

                actualSysPartitionRangeValues.Add(columnValue);
            }

            return actualSysPartitionRangeValues;
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
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.function_id == expectedRow.function_id && x.boundary_id == expectedRow.boundary_id);

                Assert.AreEqual(expectedRow.function_id, actualRow.function_id);
                Assert.AreEqual(expectedRow.boundary_id, actualRow.boundary_id);
                Assert.AreEqual(expectedRow.parameter_id, actualRow.parameter_id);
                Assert.AreEqual(expectedRow.value, actualRow.value);
            }
        }
    }
}
