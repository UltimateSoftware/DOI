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
    public class SysIndexesHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysIndexes";
        public const string SqlServerDmvName = "sys.indexes";

        public static List<SysIndexes> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName}
            WHERE name = '{IndexName}'"));

            List<SysIndexes> expectedSysIndexes = new List<SysIndexes>();

            foreach (var row in expected)
            {
                var columnValue = new SysIndexes();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.index_id = row.First(x => x.First == "index_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ObjectToInteger();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.is_unique = (bool) row.First(x => x.First == "is_unique").Second;
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.ignore_dup_key = (bool) row.First(x => x.First == "ignore_dup_key").Second;
                columnValue.is_primary_key = (bool) row.First(x => x.First == "is_primary_key").Second;
                columnValue.is_unique_constraint = (bool) row.First(x => x.First == "is_unique_constraint").Second;
                columnValue.fill_factor = row.First(x => x.First == "fill_factor").Second.ObjectToInteger();
                columnValue.is_padded = (bool) row.First(x => x.First == "is_padded").Second;
                columnValue.is_disabled = (bool) row.First(x => x.First == "is_disabled").Second;
                columnValue.is_hypothetical = (bool) row.First(x => x.First == "is_hypothetical").Second;
                columnValue.allow_row_locks = (bool) row.First(x => x.First == "allow_row_locks").Second;
                columnValue.allow_page_locks = (bool) row.First(x => x.First == "allow_page_locks").Second;
                columnValue.has_filter = (bool) row.First(x => x.First == "has_filter").Second;
                columnValue.filter_definition = row.First(x => x.First == "filter_definition").Second.ToString();
                columnValue.compression_delay = row.First(x => x.First == "compression_delay").Second.ObjectToInteger();
                columnValue.key_column_list = "TempAId ASC";
                columnValue.included_column_list = String.Empty;
                columnValue.has_LOB_columns = false;


                expectedSysIndexes.Add(columnValue);
            }

            return expectedSysIndexes;
        }

        public static List<SysIndexes> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT I.* 
            FROM DOI.DOI.{SysTableName} I 
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = I.database_id 
                INNER JOIN DOI.DOI.SysTables T ON T.database_id = I.database_id
                    AND T.object_id = I.object_id
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{TableName}'
                AND I.name = '{IndexName}'"));

            List<SysIndexes> actualSysIndexes = new List<SysIndexes>();

            foreach (var row in actual)
            {
                var columnValue = new SysIndexes();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.name = row.First(x => x.First == "name").Second.ToString();
                columnValue.index_id = row.First(x => x.First == "index_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ObjectToInteger();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.is_unique = (bool) row.First(x => x.First == "is_unique").Second;
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.ignore_dup_key = (bool) row.First(x => x.First == "ignore_dup_key").Second;
                columnValue.is_primary_key = (bool) row.First(x => x.First == "is_primary_key").Second;
                columnValue.is_unique_constraint = (bool) row.First(x => x.First == "is_unique_constraint").Second;
                columnValue.fill_factor = row.First(x => x.First == "fill_factor").Second.ObjectToInteger();
                columnValue.is_padded = (bool) row.First(x => x.First == "is_padded").Second;
                columnValue.is_disabled = (bool) row.First(x => x.First == "is_disabled").Second;
                columnValue.is_hypothetical = (bool) row.First(x => x.First == "is_hypothetical").Second;
                columnValue.allow_row_locks = (bool) row.First(x => x.First == "allow_row_locks").Second;
                columnValue.allow_page_locks = (bool) row.First(x => x.First == "allow_page_locks").Second;
                columnValue.has_filter = (bool) row.First(x => x.First == "has_filter").Second;
                columnValue.filter_definition = row.First(x => x.First == "filter_definition").Second.ToString();
                columnValue.compression_delay = row.First(x => x.First == "compression_delay").Second.ObjectToInteger();
                columnValue.key_column_list = row.First(x => x.First == "key_column_list").Second.ToString();
                columnValue.included_column_list = row.First(x => x.First == "included_column_list").Second.ToString();
                columnValue.has_LOB_columns = (bool)row.First(x => x.First == "has_LOB_columns").Second;

                actualSysIndexes.Add(columnValue);
            }

            return actualSysIndexes;
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
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.object_id == expectedRow.object_id && x.index_id == expectedRow.index_id);

                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.name, actualRow.name);
                Assert.AreEqual(expectedRow.index_id, actualRow.index_id);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.is_unique, actualRow.is_unique);
                Assert.AreEqual(expectedRow.data_space_id, actualRow.data_space_id);
                Assert.AreEqual(expectedRow.ignore_dup_key, actualRow.ignore_dup_key);
                Assert.AreEqual(expectedRow.is_primary_key, actualRow.is_primary_key);
                Assert.AreEqual(expectedRow.is_unique_constraint, actualRow.is_unique_constraint);
                switch (expectedRow.fill_factor)
                {
                    case 0:
                        Assert.AreEqual(100, actualRow.fill_factor); //fill factors are translated from 0 to 100 in our system.
                        break;
                    default:
                        Assert.AreEqual(expectedRow.fill_factor, actualRow.fill_factor);
                        break;
                }
                Assert.AreEqual(expectedRow.is_padded, actualRow.is_padded);
                Assert.AreEqual(expectedRow.is_disabled, actualRow.is_disabled);
                Assert.AreEqual(expectedRow.is_hypothetical, actualRow.is_hypothetical);
                Assert.AreEqual(expectedRow.allow_row_locks, actualRow.allow_row_locks);
                Assert.AreEqual(expectedRow.allow_page_locks, actualRow.allow_page_locks);
                Assert.AreEqual(expectedRow.has_filter, actualRow.has_filter);
                Assert.AreEqual(expectedRow.filter_definition, actualRow.filter_definition);
                Assert.AreEqual(expectedRow.compression_delay, actualRow.compression_delay);
                Assert.AreEqual(expectedRow.key_column_list, actualRow.key_column_list);
                Assert.AreEqual(expectedRow.included_column_list, actualRow.included_column_list);
                Assert.AreEqual(expectedRow.has_LOB_columns, actualRow.has_LOB_columns);
            }
        }
    }
}
