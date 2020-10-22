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
    public class SysFilegroupsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysFilegroups";
        public const string SqlServerDmvName = "sys.filegroups";

        public static List<SysFilegroups> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName} 
            WHERE name = '{FilegroupName}'"));

            List<SysFilegroups> expectedSysFilegroups = new List<SysFilegroups>();

            foreach (var row in expected)
            {
                var columnValue = new SysFilegroups();

                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.is_default = (bool)row.First(x => x.First == "is_default").Second;
                columnValue.is_system = (bool)row.First(x => x.First == "is_system").Second;
                columnValue.filegroup_guid = row.First(x => x.First == "filegroup_guid").Second.ToGuid();
                columnValue.log_filegroup_id = row.First(x => x.First == "log_filegroup_id").Second.ObjectToInteger();
                columnValue.is_read_only = (bool)row.First(x => x.First == "is_read_only").Second;
                columnValue.is_autogrow_all_files = (bool)row.First(x => x.First == "is_autogrow_all_files").Second;
               
                expectedSysFilegroups.Add(columnValue);
            }

            return expectedSysFilegroups;
        }

        public static List<SysFilegroups> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT T.* 
            FROM DOI.{SysTableName} T 
                INNER JOIN DOI.SysDatabases D ON T.database_id = d.database_id
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{FilegroupName}'"));

            List<SysFilegroups> actualSysFilegroups = new List<SysFilegroups>();

            foreach (var row in actual)
            {
                var columnValue = new SysFilegroups();

                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.is_default = (bool)row.First(x => x.First == "is_default").Second;
                columnValue.is_system = (bool)row.First(x => x.First == "is_system").Second;
                columnValue.filegroup_guid = row.First(x => x.First == "filegroup_guid").Second.ToGuid();
                columnValue.log_filegroup_id = row.First(x => x.First == "log_filegroup_id").Second.ObjectToInteger();
                columnValue.is_read_only = (bool)row.First(x => x.First == "is_read_only").Second;
                columnValue.is_autogrow_all_files = (bool)row.First(x => x.First == "is_autogrow_all_files").Second;

                actualSysFilegroups.Add(columnValue);
            }

            return actualSysFilegroups;
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
                Assert.AreEqual(expectedRow.data_space_id, actualRow.data_space_id);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.is_default, actualRow.is_default);
                Assert.AreEqual(expectedRow.is_system, actualRow.is_system);
                Assert.AreEqual(expectedRow.filegroup_guid, actualRow.filegroup_guid);
                Assert.AreEqual(expectedRow.log_filegroup_id, actualRow.log_filegroup_id);
                Assert.AreEqual(expectedRow.is_read_only, actualRow.is_read_only);
                Assert.AreEqual(expectedRow.is_autogrow_all_files, actualRow.is_autogrow_all_files);
            }
        }
    }
}
