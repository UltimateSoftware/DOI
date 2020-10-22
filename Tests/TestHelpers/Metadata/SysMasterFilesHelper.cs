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
    public class SysMasterFilesHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysMasterFiles";
        public const string SqlServerDmvName = "sys.master_files";

        public static List<SysMasterFiles> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {SqlServerDmvName} T 
            WHERE T.name = '{DatabaseName}'"));

            List<SysMasterFiles> expectedSysMasterFiles = new List<SysMasterFiles>();

            foreach (var row in expected)
            {
                var columnValue = new SysMasterFiles();

                columnValue.database_id = row.First(x => x.First == "database_id").Second.ObjectToInteger();
                columnValue.file_id = row.First(x => x.First == "file_id").Second.ObjectToInteger();
                columnValue.file_guid = row.First(x => x.First == "file_guid").Second.ToString();
                columnValue.type = row.First(x => x.First == "type").Second.ObjectToInteger();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.physical_name = row.First(x => x.First == "physical_name").Second.ToString();
                columnValue.state = row.First(x => x.First == "state").Second.ObjectToInteger();
                columnValue.state_desc = row.First(x => x.First == "state_desc").Second.ToString();
                columnValue.size = row.First(x => x.First == "size").Second.ObjectToInteger();
                columnValue.max_size = row.First(x => x.First == "max_size").Second.ObjectToInteger();
                columnValue.growth = row.First(x => x.First == "growth").Second.ObjectToInteger();
                columnValue.is_media_read_only = (bool)row.First(x => x.First == "is_media_read_only").Second;
                columnValue.is_read_only = (bool)row.First(x => x.First == "is_read_only").Second;
                columnValue.is_sparse = (bool)row.First(x => x.First == "is_sparse").Second;
                columnValue.is_percent_growth = (bool)row.First(x => x.First == "is_percent_growth").Second;
                columnValue.is_name_reserved = (bool)row.First(x => x.First == "is_name_reserved").Second;
                columnValue.create_lsn = row.First(x => x.First == "create_lsn").Second.ObjectToDecimal();
                columnValue.drop_lsn = row.First(x => x.First == "drop_lsn").Second.ObjectToDecimal();
                columnValue.read_only_lsn = row.First(x => x.First == "read_only_lsn").Second.ObjectToDecimal();
                columnValue.read_write_lsn = row.First(x => x.First == "read_write_lsn").Second.ObjectToDecimal();
                columnValue.differential_base_lsn = row.First(x => x.First == "differential_base_lsn").Second.ObjectToDecimal();
                columnValue.differential_base_guid = row.First(x => x.First == "differential_base_guid").Second.ToString();
                columnValue.differential_base_time = row.First(x => x.First == "differential_base_time").ObjectToDateTime();
                columnValue.redo_start_lsn = row.First(x => x.First == "redo_start_lsn").Second.ObjectToDecimal();
                columnValue.redo_start_fork_guid = row.First(x => x.First == "redo_start_fork_guid").Second.ToString();
                columnValue.redo_target_lsn = row.First(x => x.First == "redo_target_lsn").Second.ObjectToDecimal();
                columnValue.redo_target_fork_guid = row.First(x => x.First == "redo_target_fork_guid").Second.ToString();
                columnValue.backup_lsn = row.First(x => x.First == "backup_lsn").Second.ObjectToDecimal();
                columnValue.credential_id = row.First(x => x.First == "credential_id").Second.ObjectToInteger();

                expectedSysMasterFiles.Add(columnValue);
            }

            return expectedSysMasterFiles;
        }

        public static List<SysMasterFiles> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.{SysTableName} T 
            WHERE T.name = '{DatabaseName}'"));

            List<SysMasterFiles> actualSysMasterFiles = new List<SysMasterFiles>();

            foreach (var row in actual)
            {
                var columnValue = new SysMasterFiles();

                columnValue.database_id = row.First(x => x.First == "database_id").Second.ObjectToInteger();
                columnValue.file_id = row.First(x => x.First == "file_id").Second.ObjectToInteger();
                columnValue.file_guid = row.First(x => x.First == "file_guid").Second.ToString();
                columnValue.type = row.First(x => x.First == "type").Second.ObjectToInteger();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.physical_name = row.First(x => x.First == "physical_name").Second.ToString();
                columnValue.state = row.First(x => x.First == "state").Second.ObjectToInteger();
                columnValue.state_desc = row.First(x => x.First == "state_desc").Second.ToString();
                columnValue.size = row.First(x => x.First == "size").Second.ObjectToInteger();
                columnValue.max_size = row.First(x => x.First == "max_size").Second.ObjectToInteger();
                columnValue.growth = row.First(x => x.First == "growth").Second.ObjectToInteger();
                columnValue.is_media_read_only = (bool)row.First(x => x.First == "is_media_read_only").Second;
                columnValue.is_read_only = (bool)row.First(x => x.First == "is_read_only").Second;
                columnValue.is_sparse = (bool)row.First(x => x.First == "is_sparse").Second;
                columnValue.is_percent_growth = (bool)row.First(x => x.First == "is_percent_growth").Second;
                columnValue.is_name_reserved = (bool)row.First(x => x.First == "is_name_reserved").Second;
                columnValue.create_lsn = row.First(x => x.First == "create_lsn").Second.ObjectToDecimal();
                columnValue.drop_lsn = row.First(x => x.First == "drop_lsn").Second.ObjectToDecimal();
                columnValue.read_only_lsn = row.First(x => x.First == "read_only_lsn").Second.ObjectToDecimal();
                columnValue.read_write_lsn = row.First(x => x.First == "read_write_lsn").Second.ObjectToDecimal();
                columnValue.differential_base_lsn = row.First(x => x.First == "differential_base_lsn").Second.ObjectToDecimal();
                columnValue.differential_base_guid = row.First(x => x.First == "differential_base_guid").Second.ToString();
                columnValue.differential_base_time = row.First(x => x.First == "differential_base_time").ObjectToDateTime();
                columnValue.redo_start_lsn = row.First(x => x.First == "redo_start_lsn").Second.ObjectToDecimal();
                columnValue.redo_start_fork_guid = row.First(x => x.First == "redo_start_fork_guid").Second.ToString();
                columnValue.redo_target_lsn = row.First(x => x.First == "redo_target_lsn").Second.ObjectToDecimal();
                columnValue.redo_target_fork_guid = row.First(x => x.First == "redo_target_fork_guid").Second.ToString();
                columnValue.backup_lsn = row.First(x => x.First == "backup_lsn").Second.ObjectToDecimal();
                columnValue.credential_id = row.First(x => x.First == "credential_id").Second.ObjectToInteger();


                actualSysMasterFiles.Add(columnValue);
            }

            return actualSysMasterFiles;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            Assert.AreEqual(expected.Count, 1);

            var actual = GetActualValues();

            Assert.AreEqual(actual.Count, 1);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id);

                Assert.AreEqual(expectedRow.database_id, actualRow.database_id);
                Assert.AreEqual(expectedRow.file_id, actualRow.file_id);
                Assert.AreEqual(expectedRow.file_guid, actualRow.file_guid);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.data_space_id, actualRow.data_space_id);
                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.physical_name, actualRow.physical_name);
                Assert.AreEqual(expectedRow.state, actualRow.state);
                Assert.AreEqual(expectedRow.state_desc, actualRow.state_desc);
                Assert.AreEqual(expectedRow.size, actualRow.size);
                Assert.AreEqual(expectedRow.max_size, actualRow.max_size);
                Assert.AreEqual(expectedRow.growth, actualRow.growth);
                Assert.AreEqual(expectedRow.is_media_read_only, actualRow.is_media_read_only);
                Assert.AreEqual(expectedRow.is_read_only, actualRow.is_read_only);
                Assert.AreEqual(expectedRow.is_sparse, actualRow.is_sparse);
                Assert.AreEqual(expectedRow.is_percent_growth, actualRow.is_percent_growth);
                Assert.AreEqual(expectedRow.is_name_reserved, actualRow.is_name_reserved);
                Assert.AreEqual(expectedRow.create_lsn, actualRow.create_lsn);
                Assert.AreEqual(expectedRow.drop_lsn, actualRow.drop_lsn);
                Assert.AreEqual(expectedRow.read_only_lsn, actualRow.read_only_lsn);
                Assert.AreEqual(expectedRow.read_write_lsn, actualRow.read_write_lsn);
                Assert.AreEqual(expectedRow.differential_base_lsn, actualRow.differential_base_lsn);
                Assert.AreEqual(expectedRow.differential_base_guid, actualRow.differential_base_guid);
                Assert.AreEqual(expectedRow.differential_base_time, actualRow.differential_base_time);
                Assert.AreEqual(expectedRow.redo_start_lsn, actualRow.redo_start_lsn);
                Assert.AreEqual(expectedRow.redo_start_fork_guid, actualRow.redo_start_fork_guid);
                Assert.AreEqual(expectedRow.redo_target_lsn, actualRow.redo_target_lsn);
                Assert.AreEqual(expectedRow.redo_target_fork_guid, actualRow.redo_target_fork_guid);
                Assert.AreEqual(expectedRow.backup_lsn, actualRow.backup_lsn);
                Assert.AreEqual(expectedRow.credential_id, actualRow.credential_id);
            }
        }
    }
}
