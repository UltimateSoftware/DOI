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
    public class SysColumnsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysColumns";
        public const string SqlServerDmvName = "sys.columns";

        public static List<SysColumns> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT C.* 
            FROM {DatabaseName}.{SqlServerDmvName} C
                INNER JOIN {DatabaseName}.sys.tables t ON t.object_id = c.object_id
            WHERE t.name = '{TableName}'"));

            List<SysColumns> expectedSysColumns = new List<SysColumns>();

            foreach (var row in expected)
            {
                var columnValue = new SysColumns();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.column_id = row.First(x => x.First == "column_id").Second.ObjectToInteger();
                columnValue.system_type_id = row.First(x => x.First == "system_type_id").Second.ObjectToInteger();
                columnValue.user_type_id = row.First(x => x.First == "user_type_id").Second.ObjectToInteger();
                columnValue.max_length = row.First(x => x.First == "max_length").Second.ObjectToInteger();
                columnValue.precision = row.First(x => x.First == "precision").Second.ObjectToInteger();
                columnValue.scale = row.First(x => x.First == "scale").Second.ObjectToInteger();
                columnValue.collation_name = row.First(x => x.First == "collation_name").Second.ToString();
                columnValue.is_nullable = (bool)row.First(x => x.First == "is_nullable").Second;
                columnValue.is_ansi_padded = (bool)row.First(x => x.First == "is_ansi_padded").Second;
                columnValue.is_rowguidcol = (bool)row.First(x => x.First == "is_rowguidcol").Second;
                columnValue.is_identity = (bool)row.First(x => x.First == "is_identity").Second;
                columnValue.is_computed = (bool)row.First(x => x.First == "is_computed").Second;
                columnValue.is_filestream = (bool)row.First(x => x.First == "is_filestream").Second;
                columnValue.is_replicated = (bool)row.First(x => x.First == "is_replicated").Second;
                columnValue.is_non_sql_subscribed = (bool)row.First(x => x.First == "is_non_sql_subscribed").Second;
                columnValue.is_merge_published = (bool)row.First(x => x.First == "is_merge_published").Second;
                columnValue.is_dts_replicated = (bool)row.First(x => x.First == "is_dts_replicated").Second;
                columnValue.is_xml_document = (bool)row.First(x => x.First == "is_xml_document").Second;
                columnValue.xml_collection_id = row.First(x => x.First == "xml_collection_id").ObjectToInteger();
                columnValue.default_object_id = row.First(x => x.First == "default_object_id").ObjectToInteger();
                columnValue.rule_object_id = row.First(x => x.First == "rule_object_id").Second.ObjectToInteger();
                columnValue.is_sparse = (bool)row.First(x => x.First == "is_sparse").Second;
                columnValue.is_column_set = (bool)row.First(x => x.First == "is_column_set").Second;
                columnValue.generated_always_type = row.First(x => x.First == "generated_always_type").Second.ObjectToInteger();
                columnValue.generated_always_type_desc = row.First(x => x.First == "generated_always_type_desc").Second.ToString();
                columnValue.encryption_type = row.First(x => x.First == "encryption_type").ObjectToInteger();
                columnValue.encryption_type_desc = row.First(x => x.First == "encryption_type_desc").ToString();
                columnValue.encryption_algorithm_name = row.First(x => x.First == "encryption_algorithm_name").Second.ToString();
                columnValue.column_encryption_key_id = row.First(x => x.First == "column_encryption_key_id").Second.ObjectToInteger();
                columnValue.column_encryption_key_database_name = row.First(x => x.First == "column_encryption_key_database_name").Second.ToString();
                columnValue.is_hidden = (bool)row.First(x => x.First == "is_hidden").Second;
                columnValue.is_masked = (bool)row.First(x => x.First == "is_masked").Second;

                expectedSysColumns.Add(columnValue);
            }

            return expectedSysColumns;
        }

        public static List<SysColumns> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT C.* 
            FROM DOI.DOI.{SysTableName} C
                INNER JOIN DOI.DOI.SysTables T ON T.database_id = C.database_id
                    AND T.object_id = C.object_id
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = T.database_id 
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{TableName}'"));

            List<SysColumns> actualSysColumns = new List<SysColumns>();

            foreach (var row in actual)
            {
                var columnValue = new SysColumns();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.column_id = row.First(x => x.First == "column_id").Second.ObjectToInteger();
                columnValue.system_type_id = row.First(x => x.First == "system_type_id").Second.ObjectToInteger();
                columnValue.user_type_id = row.First(x => x.First == "user_type_id").Second.ObjectToInteger();
                columnValue.max_length = row.First(x => x.First == "max_length").Second.ObjectToInteger();
                columnValue.precision = row.First(x => x.First == "precision").Second.ObjectToInteger();
                columnValue.scale = row.First(x => x.First == "scale").Second.ObjectToInteger();
                columnValue.collation_name = row.First(x => x.First == "collation_name").Second.ToString();
                columnValue.is_nullable = (bool)row.First(x => x.First == "is_nullable").Second;
                columnValue.is_ansi_padded = (bool)row.First(x => x.First == "is_ansi_padded").Second;
                columnValue.is_rowguidcol = (bool)row.First(x => x.First == "is_rowguidcol").Second;
                columnValue.is_identity = (bool)row.First(x => x.First == "is_identity").Second;
                columnValue.is_computed = (bool)row.First(x => x.First == "is_computed").Second;
                columnValue.is_filestream = (bool)row.First(x => x.First == "is_filestream").Second;
                columnValue.is_replicated = (bool)row.First(x => x.First == "is_replicated").Second;
                columnValue.is_non_sql_subscribed = (bool)row.First(x => x.First == "is_non_sql_subscribed").Second;
                columnValue.is_merge_published = (bool)row.First(x => x.First == "is_merge_published").Second;
                columnValue.is_dts_replicated = (bool)row.First(x => x.First == "is_dts_replicated").Second;
                columnValue.is_xml_document = (bool)row.First(x => x.First == "is_xml_document").Second;
                columnValue.xml_collection_id = row.First(x => x.First == "xml_collection_id").ObjectToInteger();
                columnValue.default_object_id = row.First(x => x.First == "default_object_id").ObjectToInteger();
                columnValue.rule_object_id = row.First(x => x.First == "rule_object_id").Second.ObjectToInteger();
                columnValue.is_sparse = (bool)row.First(x => x.First == "is_sparse").Second;
                columnValue.is_column_set = (bool)row.First(x => x.First == "is_column_set").Second;
                columnValue.generated_always_type = row.First(x => x.First == "generated_always_type").Second.ObjectToInteger();
                columnValue.generated_always_type_desc = row.First(x => x.First == "generated_always_type_desc").Second.ToString();
                columnValue.encryption_type = row.First(x => x.First == "encryption_type").ObjectToInteger();
                columnValue.encryption_type_desc = row.First(x => x.First == "encryption_type_desc").ToString();
                columnValue.encryption_algorithm_name = row.First(x => x.First == "encryption_algorithm_name").Second.ToString();
                columnValue.column_encryption_key_id = row.First(x => x.First == "column_encryption_key_id").Second.ObjectToInteger();
                columnValue.column_encryption_key_database_name = row.First(x => x.First == "column_encryption_key_database_name").Second.ToString();
                columnValue.is_hidden = (bool)row.First(x => x.First == "is_hidden").Second;
                columnValue.is_masked = (bool)row.First(x => x.First == "is_masked").Second;

                actualSysColumns.Add(columnValue);
            }

            return actualSysColumns;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            Assert.AreEqual(4, expected.Count);

            var actual = GetActualValues();

            Assert.AreEqual(4, actual.Count);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.name == expectedRow.name);

                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.column_id, actualRow.column_id);
                Assert.AreEqual(expectedRow.system_type_id, actualRow.system_type_id);
                Assert.AreEqual(expectedRow.user_type_id, actualRow.user_type_id);
                Assert.AreEqual(expectedRow.max_length, actualRow.max_length);
                Assert.AreEqual(expectedRow.precision, actualRow.precision);
                Assert.AreEqual(expectedRow.scale, actualRow.scale);
                Assert.AreEqual(expectedRow.collation_name, actualRow.collation_name);
                Assert.AreEqual(expectedRow.is_nullable, actualRow.is_nullable);
                Assert.AreEqual(expectedRow.is_ansi_padded, actualRow.is_ansi_padded);
                Assert.AreEqual(expectedRow.is_rowguidcol, actualRow.is_rowguidcol);
                Assert.AreEqual(expectedRow.is_identity, actualRow.is_identity);
                Assert.AreEqual(expectedRow.is_computed, actualRow.is_computed);
                Assert.AreEqual(expectedRow.is_filestream, actualRow.is_filestream);
                Assert.AreEqual(expectedRow.is_replicated, actualRow.is_replicated);
                Assert.AreEqual(expectedRow.is_non_sql_subscribed, actualRow.is_non_sql_subscribed);
                Assert.AreEqual(expectedRow.is_merge_published, actualRow.is_merge_published);
                Assert.AreEqual(expectedRow.is_dts_replicated, actualRow.is_dts_replicated);
                Assert.AreEqual(expectedRow.is_xml_document, actualRow.is_xml_document);
                Assert.AreEqual(expectedRow.xml_collection_id, actualRow.xml_collection_id);
                Assert.AreEqual(expectedRow.default_object_id, actualRow.default_object_id);
                Assert.AreEqual(expectedRow.rule_object_id, actualRow.rule_object_id);
                Assert.AreEqual(expectedRow.is_sparse, actualRow.is_sparse);
                Assert.AreEqual(expectedRow.is_column_set, actualRow.is_column_set);
                Assert.AreEqual(expectedRow.generated_always_type, actualRow.generated_always_type);
                Assert.AreEqual(expectedRow.generated_always_type_desc, actualRow.generated_always_type_desc);
                Assert.AreEqual(expectedRow.encryption_type, actualRow.encryption_type);
                Assert.AreEqual(expectedRow.encryption_type_desc, actualRow.encryption_type_desc);
                Assert.AreEqual(expectedRow.encryption_algorithm_name, actualRow.encryption_algorithm_name);
                Assert.AreEqual(expectedRow.column_encryption_key_id, actualRow.column_encryption_key_id);
                Assert.AreEqual(expectedRow.column_encryption_key_database_name, actualRow.column_encryption_key_database_name);
                Assert.AreEqual(expectedRow.is_hidden, actualRow.is_hidden);
                Assert.AreEqual(expectedRow.is_masked, actualRow.is_masked);
            }
        }
    }
}
