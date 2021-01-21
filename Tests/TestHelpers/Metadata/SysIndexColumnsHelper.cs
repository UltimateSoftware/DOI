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
    public class SysIndexColumnsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysIndexColumns";
        public const string SqlServerDmvName = "sys.index_columns";

        public static List<SysIndexColumns> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT ic.* 
            FROM {DatabaseName}.{SqlServerDmvName} ic
                INNER JOIN {DatabaseName}.sys.indexes i ON i.object_id = ic.object_id
                    AND i.index_id = ic.index_id
                INNER JOIN {DatabaseName}.sys.tables t ON t.object_id = i.object_id
            WHERE t.name = '{TableName}'
                AND i.name = '{CIndexName}'"));

            List<SysIndexColumns> expectedSysIndexColumns = new List<SysIndexColumns>();

            foreach (var row in expected)
            {
                var columnValue = new SysIndexColumns();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.index_id = row.First(x => x.First == "index_id").Second.ObjectToInteger();
                columnValue.index_column_id = row.First(x => x.First == "index_column_id").Second.ObjectToInteger();
                columnValue.column_id = row.First(x => x.First == "column_id").Second.ObjectToInteger();
                columnValue.key_ordinal = row.First(x => x.First == "key_ordinal").Second.ObjectToInteger();
                columnValue.partition_ordinal = row.First(x => x.First == "partition_ordinal").Second.ObjectToInteger();
                columnValue.is_descending_key = (bool)row.First(x => x.First == "is_descending_key").Second;
                columnValue.is_included_column = (bool)row.First(x => x.First == "is_included_column").Second;

                expectedSysIndexColumns.Add(columnValue);
            }

            return expectedSysIndexColumns;
        }

        public static List<SysIndexColumns> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT IC.* 
            FROM DOI.DOI.{SysTableName} IC
                INNER JOIN DOI.DOI.SysIndexes I ON I.database_id = IC.database_id
                    AND I.object_id = IC.object_id
                    AND I.index_id = IC.index_id
                INNER JOIN DOI.DOI.SysTables T ON T.database_id = I.database_id
                    AND I.object_id = T.object_id
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = T.database_id 
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{TableName}'
                AND I.name = '{CIndexName}'"));

            List<SysIndexColumns> actualSysIndexColumns = new List<SysIndexColumns>();

            foreach (var row in actual)
            {
                var columnValue = new SysIndexColumns();
                columnValue.object_id = row.First(x => x.First == "object_id").Second.ObjectToInteger();
                columnValue.index_id = row.First(x => x.First == "index_id").Second.ObjectToInteger();
                columnValue.index_column_id = row.First(x => x.First == "index_column_id").Second.ObjectToInteger();
                columnValue.column_id = row.First(x => x.First == "column_id").Second.ObjectToInteger();
                columnValue.key_ordinal = row.First(x => x.First == "key_ordinal").Second.ObjectToInteger();
                columnValue.partition_ordinal = row.First(x => x.First == "partition_ordinal").Second.ObjectToInteger();
                columnValue.is_descending_key = (bool)row.First(x => x.First == "is_descending_key").Second;
                columnValue.is_included_column = (bool)row.First(x => x.First == "is_included_column").Second;

                actualSysIndexColumns.Add(columnValue);
            }

            return actualSysIndexColumns;
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
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.object_id == expectedRow.object_id && x.index_id == expectedRow.index_id && x.column_id == expectedRow.column_id);

                Assert.AreEqual(expectedRow.object_id, actualRow.object_id);
                Assert.AreEqual(expectedRow.index_id, actualRow.index_id);
                Assert.AreEqual(expectedRow.index_column_id, actualRow.index_column_id);
                Assert.AreEqual(expectedRow.column_id, actualRow.column_id);
                Assert.AreEqual(expectedRow.key_ordinal, actualRow.key_ordinal);
                Assert.AreEqual(expectedRow.partition_ordinal, actualRow.partition_ordinal);
                Assert.AreEqual(expectedRow.is_descending_key, actualRow.is_descending_key);
                Assert.AreEqual(expectedRow.is_included_column, actualRow.is_included_column);
            }
        }
    }
}
