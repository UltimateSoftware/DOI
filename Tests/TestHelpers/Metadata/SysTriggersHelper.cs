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
    public class SysTriggersHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysTriggers";
        public const string SqlServerDmvName = "sys.triggers";

        public static List<SysTriggers> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}
            WHERE name = '{TriggerName}'"));

            List<SysTriggers> expectedSysTriggers = new List<SysTriggers>();

            foreach (var row in expected)
            {
                var columnValue = new SysTriggers();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.parent_class = row.First(x => x.First == "parent_class").Second.ObjectToInteger();
                columnValue.parent_class_desc = row.First(x => x.First == "parent_class_desc").Second.ToString();
                columnValue.parent_id = row.First(x => x.First == "parent_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.modify_date = row.First(x => x.First == "modify_date").Second.ObjectToDateTime();
                columnValue.is_ms_shipped = (bool)row.First(x => x.First == "is_ms_shipped").Second;
                columnValue.is_disabled = (bool)row.First(x => x.First == "is_disabled").Second;
                columnValue.is_not_for_replication = (bool)row.First(x => x.First == "is_not_for_replication").Second;
                columnValue.is_instead_of_trigger = (bool)row.First(x => x.First == "is_instead_of_trigger").Second;

                expectedSysTriggers.Add(columnValue);
            }

            return expectedSysTriggers;
        }

        public static List<SysTriggers> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT TR.* 
            FROM DOI.DOI.{SysTableName} TR
                INNER JOIN DOI.DOI.SysDatabases D ON TR.database_id = D.database_id
            WHERE D.name = '{DatabaseName}'"));

            List<SysTriggers> actualSysTriggers = new List<SysTriggers>();

            foreach (var row in actual)
            {
                var columnValue = new SysTriggers();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.parent_class = row.First(x => x.First == "parent_class").Second.ObjectToInteger();
                columnValue.parent_class_desc = row.First(x => x.First == "parent_class_desc").Second.ToString();
                columnValue.parent_id = row.First(x => x.First == "parent_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ToString();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.create_date = row.First(x => x.First == "create_date").Second.ObjectToDateTime();
                columnValue.modify_date = row.First(x => x.First == "modify_date").Second.ObjectToDateTime();
                columnValue.is_ms_shipped = (bool)row.First(x => x.First == "is_ms_shipped").Second;
                columnValue.is_disabled = (bool)row.First(x => x.First == "is_disabled").Second;
                columnValue.is_not_for_replication = (bool)row.First(x => x.First == "is_not_for_replication").Second;
                columnValue.is_instead_of_trigger = (bool)row.First(x => x.First == "is_instead_of_trigger").Second;

                actualSysTriggers.Add(columnValue);
            }

            return actualSysTriggers;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            var actual = GetActualValues();

            Assert.AreEqual(expected.Count, actual.Count);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.parent_id == expectedRow.parent_id && x.name == expectedRow.name);

                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.parent_class, actualRow.parent_class);
                Assert.AreEqual(expectedRow.parent_class_desc, actualRow.parent_class_desc);
                Assert.AreEqual(expectedRow.parent_id, actualRow.parent_id);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.create_date, actualRow.create_date);
                Assert.AreEqual(expectedRow.modify_date, actualRow.modify_date);
                Assert.AreEqual(expectedRow.is_ms_shipped, actualRow.is_ms_shipped);
                Assert.AreEqual(expectedRow.is_disabled, actualRow.is_disabled);
                Assert.AreEqual(expectedRow.is_not_for_replication, actualRow.is_not_for_replication);
                Assert.AreEqual(expectedRow.is_instead_of_trigger, actualRow.is_instead_of_trigger);
            }
        }
    }
}
