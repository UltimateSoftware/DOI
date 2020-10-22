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
    public class SysDataSpacesHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysDataSpaces";
        public const string SqlServerDmvName = "sys.data_spaces";

        public static List<SysDataSpaces> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}
            WHERE name = '{FilegroupName}'"));

            List<SysDataSpaces> expectedSysDataSpaces = new List<SysDataSpaces>();

            foreach (var row in expected)
            {
                var columnValue = new SysDataSpaces();

                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.is_default = (bool)row.First(x => x.First == "is_default").Second;
                columnValue.is_system = (bool)row.First(x => x.First == "is_system").Second;

                expectedSysDataSpaces.Add(columnValue);
            }

            return expectedSysDataSpaces;
        }

        public static List<SysDataSpaces> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT T.* 
            FROM DOI.DOI.{SysTableName} T
                INNER JOIN DOI.DOI.SysDatabases D ON T.database_id = D.database_id 
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{FilegroupName}'"));

            List<SysDataSpaces> actualSysDataSpaces = new List<SysDataSpaces>();

            foreach (var row in actual)
            {
                var columnValue = new SysDataSpaces();

                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.is_default = (bool)row.First(x => x.First == "is_default").Second;
                columnValue.is_system = (bool)row.First(x => x.First == "is_system").Second;

                actualSysDataSpaces.Add(columnValue);
            }

            return actualSysDataSpaces;
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
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.data_space_id == expectedRow.data_space_id);

                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.data_space_id, actualRow.data_space_id);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.is_default, actualRow.is_default);
                Assert.AreEqual(expectedRow.is_system, actualRow.is_system);
            }
        }
    }
}
