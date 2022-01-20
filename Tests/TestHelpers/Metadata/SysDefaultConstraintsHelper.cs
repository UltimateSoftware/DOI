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
    class SysDefaultConstraintsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysDefaultConstraints";
        public const string SqlServerDmvName = "sys.default_constraints";

        public static List<SysDefaultConstraints> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}"));

            List<SysDefaultConstraints> expectedSysDefaultConstraints = new List<SysDefaultConstraints>();

            foreach (var row in expected)
            {
                var columnValue = new SysDefaultConstraints();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.principal_id = row.First(x => x.First == "principal_id").Second.ObjectToInteger();
                columnValue.parent_object_id = row.First(x => x.First == "parent_object_id").Second.ObjectToInteger();
                columnValue.schema_id = row.First(x => x.First == "schema_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.modify_date = row.First(x => x.First == "modify_date").Second.ObjectToDateTime();
                columnValue.is_ms_shipped = (bool)row.First(x => x.First == "is_ms_shipped").Second;
                columnValue.is_published = (bool)row.First(x => x.First == "is_published").Second;
                columnValue.is_schema_published = (bool)row.First(x => x.First == "is_schema_published").Second;
                columnValue.parent_column_id = row.First(x => x.First == "parent_column_id").Second.ObjectToInteger();
                columnValue.definition = row.First(x => x.First == "definition").Second.ToString();
                columnValue.is_system_named = (bool)row.First(x => x.First == "is_system_named").Second;

                expectedSysDefaultConstraints.Add(columnValue);
            }

            return expectedSysDefaultConstraints;
        }

        public static List<SysDefaultConstraints> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT DC.* 
            FROM DOI.DOI.{SysTableName} DC
                INNER JOIN DOI.DOI.SysDatabases D ON DC.database_id = D.database_id
            WHERE D.name = '{DatabaseName}'"));

            List<SysDefaultConstraints> actualSysDefaultConstraints = new List<SysDefaultConstraints>();

            foreach (var row in actual)
            {
                var columnValue = new SysDefaultConstraints();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.principal_id = row.First(x => x.First == "principal_id").Second.ObjectToInteger();
                columnValue.parent_object_id = row.First(x => x.First == "parent_object_id").Second.ObjectToInteger();
                columnValue.schema_id = row.First(x => x.First == "schema_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.modify_date = row.First(x => x.First == "modify_date").Second.ObjectToDateTime();
                columnValue.is_ms_shipped = (bool)row.First(x => x.First == "is_ms_shipped").Second;
                columnValue.is_published = (bool)row.First(x => x.First == "is_published").Second;
                columnValue.is_schema_published = (bool)row.First(x => x.First == "is_schema_published").Second;
                columnValue.parent_column_id = row.First(x => x.First == "parent_column_id").Second.ObjectToInteger();
                columnValue.definition = row.First(x => x.First == "definition").Second.ToString();
                columnValue.is_system_named = (bool)row.First(x => x.First == "is_system_named").Second;

                actualSysDefaultConstraints.Add(columnValue);
            }

            return actualSysDefaultConstraints;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            var actual = GetActualValues();

            Assert.AreEqual(expected.Count, actual.Count);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.parent_object_id == expectedRow.parent_object_id && x.name == expectedRow.name);

                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.principal_id, actualRow.principal_id);
                Assert.AreEqual(expectedRow.parent_object_id, actualRow.parent_object_id);
                Assert.AreEqual(expectedRow.schema_id, actualRow.schema_id);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.create_date, actualRow.create_date);
                Assert.AreEqual(expectedRow.modify_date, actualRow.modify_date);
                Assert.AreEqual(expectedRow.is_ms_shipped, actualRow.is_ms_shipped);
                Assert.AreEqual(expectedRow.is_published, actualRow.is_published);
                Assert.AreEqual(expectedRow.is_schema_published, actualRow.is_schema_published);
                Assert.AreEqual(expectedRow.parent_column_id, actualRow.parent_column_id);
                Assert.AreEqual(expectedRow.definition, actualRow.definition);
                Assert.AreEqual(expectedRow.is_system_named, actualRow.is_system_named);
            }
        }
    }
}
