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
    public class SysSchemasHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysSchemas";
        public const string SqlServerDmvName = "sys.schemas";
        public const string SchemaName = "Test";


        public static List<SysSchemas> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}
            WHERE name = '{SchemaName}'"));

            List<SysSchemas> expectedSysSchemas = new List<SysSchemas>();

            foreach (var row in expected)
            {
                var columnValue = new SysSchemas();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.schema_id = row.First(x => x.First == "schema_id").Second.ObjectToInteger();
                columnValue.principal_id = row.First(x => x.First == "principal_id").Second.ObjectToInteger();
                
                expectedSysSchemas.Add(columnValue);
            }

            return expectedSysSchemas;
        }

        public static List<SysSchemas> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{SysTableName} T 
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = T.database_id 
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{SchemaName}'"));

            List<SysSchemas> actualSysSchemas = new List<SysSchemas>();

            foreach (var row in actual)
            {
                var columnValue = new SysSchemas();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.schema_id = row.First(x => x.First == "schema_id").Second.ObjectToInteger();
                columnValue.principal_id = row.First(x => x.First == "principal_id").Second.ObjectToInteger();

                actualSysSchemas.Add(columnValue);
            }

            return actualSysSchemas;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            var actual = GetActualValues();

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id);

                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.schema_id, actualRow.schema_id);
                Assert.AreEqual(expectedRow.principal_id, actualRow.principal_id);
            }
        }
    }
}