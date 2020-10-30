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
    public class SysTypesHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysTypes";
        public const string SqlServerDmvName = "sys.types";

        public static List<SysTypes> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}
            WHERE name = '{UserDefinedTypeName}'"));

            List<SysTypes> expectedSysTypes = new List<SysTypes>();

            foreach (var row in expected)
            {
                var columnValue = new SysTypes();

                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.system_type_id = row.First(x => x.First == "system_type_id").Second.ObjectToInteger();
                columnValue.user_type_id = row.First(x => x.First == "user_type_id").Second.ObjectToInteger();
                columnValue.schema_id = row.First(x => x.First == "schema_id").Second.ObjectToInteger();
                columnValue.principal_id = row.First(x => x.First == "principal_id").Second.ObjectToInteger();
                columnValue.max_length = row.First(x => x.First == "max_length").Second.ObjectToInteger();
                columnValue.precision = row.First(x => x.First == "precision").Second.ObjectToInteger();
                columnValue.scale = row.First(x => x.First == "scale").Second.ObjectToInteger();
                columnValue.collation_name = row.First(x => x.First == "collation_name").Second.ToString();
                columnValue.is_nullable = (bool)row.First(x => x.First == "is_nullable").Second;
                columnValue.is_user_defined = (bool)row.First(x => x.First == "is_user_defined").Second;
                columnValue.is_assembly_type = (bool)row.First(x => x.First == "is_assembly_type").Second;
                columnValue.default_object_id = row.First(x => x.First == "default_object_id").Second.ObjectToInteger();
                columnValue.rule_object_id = row.First(x => x.First == "rule_object_id").Second.ObjectToInteger();
                columnValue.is_table_type = (bool)row.First(x => x.First == "is_table_type").Second;

                expectedSysTypes.Add(columnValue);
            }

            return expectedSysTypes;
        }

        public static List<SysTypes> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT T.* 
            FROM DOI.{SysTableName} T 
                INNER JOIN DOI.SysDatabases D ON T.database_id = d.database_id
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{UserDefinedTypeName}'"));

            List<SysTypes> actualSysTypes = new List<SysTypes>();

            foreach (var row in actual)
            {
                var columnValue = new SysTypes();

                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.system_type_id = row.First(x => x.First == "system_type_id").Second.ObjectToInteger();
                columnValue.user_type_id = row.First(x => x.First == "user_type_id").Second.ObjectToInteger();
                columnValue.schema_id = row.First(x => x.First == "schema_id").Second.ObjectToInteger();
                columnValue.principal_id = row.First(x => x.First == "principal_id").Second.ObjectToInteger();
                columnValue.max_length = row.First(x => x.First == "max_length").Second.ObjectToInteger();
                columnValue.precision = row.First(x => x.First == "precision").Second.ObjectToInteger();
                columnValue.scale = row.First(x => x.First == "scale").Second.ObjectToInteger();
                columnValue.collation_name = row.First(x => x.First == "collation_name").Second.ToString();
                columnValue.is_nullable = (bool)row.First(x => x.First == "is_nullable").Second;
                columnValue.is_user_defined = (bool)row.First(x => x.First == "is_user_defined").Second;
                columnValue.is_assembly_type = (bool)row.First(x => x.First == "is_assembly_type").Second;
                columnValue.default_object_id = row.First(x => x.First == "default_object_id").Second.ObjectToInteger();
                columnValue.rule_object_id = row.First(x => x.First == "rule_object_id").Second.ObjectToInteger();
                columnValue.is_table_type = (bool)row.First(x => x.First == "is_table_type").Second;

                actualSysTypes.Add(columnValue);
            }

            return actualSysTypes;
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
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.user_type_id == expectedRow.user_type_id);

                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.system_type_id, actualRow.system_type_id);
                Assert.AreEqual(expectedRow.user_type_id, actualRow.user_type_id);
                Assert.AreEqual(expectedRow.schema_id, actualRow.schema_id);
                Assert.AreEqual(expectedRow.principal_id, actualRow.principal_id);
                Assert.AreEqual(expectedRow.max_length, actualRow.max_length);
                Assert.AreEqual(expectedRow.precision, actualRow.precision);
                Assert.AreEqual(expectedRow.scale, actualRow.scale);
                Assert.AreEqual(expectedRow.collation_name, actualRow.collation_name);
                Assert.AreEqual(expectedRow.is_nullable, actualRow.is_nullable);
                Assert.AreEqual(expectedRow.is_user_defined, actualRow.is_user_defined);
                Assert.AreEqual(expectedRow.is_assembly_type, actualRow.is_assembly_type);
                Assert.AreEqual(expectedRow.default_object_id, actualRow.default_object_id);
                Assert.AreEqual(expectedRow.rule_object_id, actualRow.rule_object_id);
                Assert.AreEqual(expectedRow.is_table_type, actualRow.is_table_type);
            }
        }
    }
}
