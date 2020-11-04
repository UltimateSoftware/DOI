using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;

namespace DOI.Tests.TestHelpers.Metadata
{
    public class ForeignKeysHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysForeignKeys";
        public const string SqlServerDmvName = "sys.foreign_keys";
        public const string UserTableName = "ForeignKeys";

        public static List<SysForeignKeys> GetExpectedSysValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}
            WHERE name = '{ForeignKeyName}'"));

            List<SysForeignKeys> expectedSysForeignKeys = new List<SysForeignKeys>();

            foreach (var row in expected)
            {
                var columnValue = new SysForeignKeys();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.principal_id = row.First(x => x.First == "principal_id").Second.ObjectToInteger();
                columnValue.schema_id = row.First(x => x.First == "schema_id").Second.ObjectToInteger();
                columnValue.parent_object_id = row.First(x => x.First == "parent_object_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.modify_date = row.First(x => x.First == "modify_date").Second.ObjectToDateTime();
                columnValue.is_ms_shipped = (bool)row.First(x => x.First == "is_ms_shipped").Second;
                columnValue.is_published = (bool)row.First(x => x.First == "is_published").Second;
                columnValue.is_schema_published = (bool)row.First(x => x.First == "is_schema_published").Second;
                columnValue.referenced_object_id = row.First(x => x.First == "referenced_object_id").Second.ObjectToInteger();
                columnValue.key_index_id = row.First(x => x.First == "key_index_id").Second.ObjectToInteger();
                columnValue.is_disabled = (bool)row.First(x => x.First == "is_disabled").Second;
                columnValue.is_not_for_replication = (bool)row.First(x => x.First == "is_not_for_replication").Second;
                columnValue.is_not_trusted = (bool)row.First(x => x.First == "is_not_trusted").Second;
                columnValue.delete_referential_action = row.First(x => x.First == "delete_referential_action").Second.ObjectToInteger();
                columnValue.delete_referential_action_desc = row.First(x => x.First == "delete_referential_action_desc").Second.ToString();
                columnValue.update_referential_action = row.First(x => x.First == "update_referential_action").Second.ObjectToInteger();
                columnValue.update_referential_action_desc = row.First(x => x.First == "update_referential_action_desc").Second.ToString();
                columnValue.is_system_named = (bool)row.First(x => x.First == "is_system_named").Second;
                columnValue.ParentColumnList_Actual = "TempAId";
                columnValue.ReferencedColumnList_Actual = "TempAId";
                columnValue.DeploymentTime = "Deployment";


                expectedSysForeignKeys.Add(columnValue);
            }

            return expectedSysForeignKeys;
        }

        public static List<SysForeignKeys> GetActualSysValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT FK.* 
            FROM DOI.DOI.{SysTableName} FK
                INNER JOIN DOI.DOI.SysTables T ON T.database_id = FK.database_id
                    AND FK.parent_object_id = T.object_id
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = T.database_id 
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{ChildTableName}'
                AND FK.name = '{ForeignKeyName}'"));

            List<SysForeignKeys> actualSysForeignKeys = new List<SysForeignKeys>();

            foreach (var row in actual)
            {
                var columnValue = new SysForeignKeys();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.principal_id = row.First(x => x.First == "principal_id").Second.ObjectToInteger();
                columnValue.schema_id = row.First(x => x.First == "schema_id").Second.ObjectToInteger();
                columnValue.parent_object_id = row.First(x => x.First == "parent_object_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.modify_date = row.First(x => x.First == "modify_date").Second.ObjectToDateTime();
                columnValue.is_ms_shipped = (bool)row.First(x => x.First == "is_ms_shipped").Second;
                columnValue.is_published = (bool)row.First(x => x.First == "is_published").Second;
                columnValue.is_schema_published = (bool)row.First(x => x.First == "is_schema_published").Second;
                columnValue.referenced_object_id = row.First(x => x.First == "referenced_object_id").Second.ObjectToInteger();
                columnValue.key_index_id = row.First(x => x.First == "key_index_id").Second.ObjectToInteger();
                columnValue.is_disabled = (bool)row.First(x => x.First == "is_disabled").Second;
                columnValue.is_not_for_replication = (bool)row.First(x => x.First == "is_not_for_replication").Second;
                columnValue.is_not_trusted = (bool)row.First(x => x.First == "is_not_trusted").Second;
                columnValue.delete_referential_action = row.First(x => x.First == "delete_referential_action").Second.ObjectToInteger();
                columnValue.delete_referential_action_desc = row.First(x => x.First == "delete_referential_action_desc").Second.ToString();
                columnValue.update_referential_action = row.First(x => x.First == "update_referential_action").Second.ObjectToInteger();
                columnValue.update_referential_action_desc = row.First(x => x.First == "update_referential_action_desc").Second.ToString();
                columnValue.is_system_named = (bool)row.First(x => x.First == "is_system_named").Second;
                columnValue.ParentColumnList_Actual = row.First(x => x.First == "ParentColumnList_Actual").Second.ToString();
                columnValue.ReferencedColumnList_Actual = row.First(x => x.First == "ReferencedColumnList_Actual").Second.ToString();
                columnValue.DeploymentTime = row.First(x => x.First == "DeploymentTime").Second.ToString();


                actualSysForeignKeys.Add(columnValue);
            }

            return actualSysForeignKeys;
        }

        public static List<ForeignKeys> GetActualUserValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT FK.ParentColumnList_Desired,
                    FK.ParentColumnList_Actual,
                    FK.ReferencedColumnList_Desired,
                    FK.ReferencedColumnList_Actual,
                    FK.DeploymentTime
            FROM DOI.DOI.{UserTableName} FK
            WHERE FK.DatabaseName = '{DatabaseName}'
                AND FK.ParentTableName = '{ChildTableName}'
                AND FK.FKName = '{ForeignKeyName}'"));

            List<ForeignKeys> actualForeignKeys = new List<ForeignKeys>();

            foreach (var row in actual)
            {
                var columnValue = new ForeignKeys();
                columnValue.ParentColumnList_Desired = row.First(x => x.First == "ParentColumnList_Desired").Second.ToString();
                columnValue.ParentColumnList_Actual = row.First(x => x.First == "ParentColumnList_Actual").Second.ToString();
                columnValue.ReferencedColumnList_Desired = row.First(x => x.First == "ReferencedColumnList_Desired").Second.ToString();
                columnValue.ReferencedColumnList_Actual = row.First(x => x.First == "ReferencedColumnList_Actual").Second.ToString();
                columnValue.DeploymentTime = row.First(x => x.First == "DeploymentTime").Second.ToString();

                actualForeignKeys.Add(columnValue);
            }

            return actualForeignKeys;
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
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.parent_object_id == expectedRow.parent_object_id && x.name == expectedRow.name);

                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.principal_id, actualRow.principal_id);
                Assert.AreEqual(expectedRow.schema_id, actualRow.schema_id);
                Assert.AreEqual(expectedRow.parent_object_id, actualRow.parent_object_id);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.create_date, actualRow.create_date);
                Assert.AreEqual(expectedRow.modify_date, actualRow.modify_date);
                Assert.AreEqual(expectedRow.is_ms_shipped, actualRow.is_ms_shipped);
                Assert.AreEqual(expectedRow.is_published, actualRow.is_published);
                Assert.AreEqual(expectedRow.is_schema_published, actualRow.is_schema_published);
                Assert.AreEqual(expectedRow.referenced_object_id, actualRow.referenced_object_id);
                Assert.AreEqual(expectedRow.key_index_id, actualRow.key_index_id);
                Assert.AreEqual(expectedRow.is_disabled, actualRow.is_disabled);
                Assert.AreEqual(expectedRow.is_not_for_replication, actualRow.is_not_for_replication);
                Assert.AreEqual(expectedRow.is_not_trusted, actualRow.is_not_trusted);
                Assert.AreEqual(expectedRow.delete_referential_action, actualRow.delete_referential_action);
                Assert.AreEqual(expectedRow.delete_referential_action_desc, actualRow.delete_referential_action_desc);
                Assert.AreEqual(expectedRow.update_referential_action, actualRow.update_referential_action);
                Assert.AreEqual(expectedRow.update_referential_action_desc, actualRow.update_referential_action_desc);
                Assert.AreEqual(expectedRow.is_system_named, actualRow.is_system_named);
                Assert.AreEqual(expectedRow.ParentColumnList_Actual, actualRow.ParentColumnList_Actual);
                Assert.AreEqual(expectedRow.ReferencedColumnList_Actual, actualRow.ReferencedColumnList_Actual);
                Assert.AreEqual(expectedRow.DeploymentTime, actualRow.DeploymentTime);
            }
        }

        public static void AssertUserMetadata()
        {
            var actual = GetActualUserValues();

            Assert.AreEqual(1, actual.Count);
            
            foreach (var row in actual)
            {
                Assert.AreEqual(row.ParentColumnList_Desired, row.ParentColumnList_Actual);
                Assert.AreEqual(row.ReferencedColumnList_Desired, row.ReferencedColumnList_Actual);
                Assert.AreEqual("Deployment", row.DeploymentTime);
            }
        }
    }
}
