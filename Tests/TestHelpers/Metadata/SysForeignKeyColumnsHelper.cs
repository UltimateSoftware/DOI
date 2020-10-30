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
    public class SysForeignKeyColumnsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysForeignKeyColumns";
        public const string SqlServerDmvName = "sys.foreign_key_columns";

        public static List<SysForeignKeyColumns> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT fkc.* 
            FROM {DatabaseName}.{SqlServerDmvName} fkc
                INNER JOIN {DatabaseName}.sys.foreign_keys fk ON fk.object_id = fkc.constraint_object_id
                INNER JOIN {DatabaseName}.sys.tables t ON t.object_id = fk.parent_object_id
            WHERE t.name = '{ChildTableName}'
                AND fk.name = '{ForeignKeyName}'"));

            List<SysForeignKeyColumns> expectedSysForeignKeyColumns = new List<SysForeignKeyColumns>();

            foreach (var row in expected)
            {
                var columnValue = new SysForeignKeyColumns();
                columnValue.constraint_object_id = row.First(x => x.First == "constraint_object_id").Second.ObjectToInteger();
                columnValue.constraint_column_id = row.First(x => x.First == "constraint_column_id").Second.ObjectToInteger();
                columnValue.parent_object_id = row.First(x => x.First == "parent_object_id").Second.ObjectToInteger();
                columnValue.parent_column_id = row.First(x => x.First == "parent_column_id").Second.ObjectToInteger();
                columnValue.referenced_object_id = row.First(x => x.First == "referenced_object_id").Second.ObjectToInteger();
                columnValue.referenced_column_id = row.First(x => x.First == "referenced_column_id").Second.ObjectToInteger();

                expectedSysForeignKeyColumns.Add(columnValue);
            }

            return expectedSysForeignKeyColumns;
        }

        public static List<SysForeignKeyColumns> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT FKC.* 
            FROM DOI.DOI.{SysTableName} FKC
                INNER JOIN DOI.DOI.SysForeignKeys FK ON FK.database_id = FKC.database_id
                    AND FK.object_id = FKC.constraint_object_id
                INNER JOIN DOI.DOI.SysTables T ON T.database_id = FK.database_id
                    AND FK.parent_object_id = T.object_id
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = T.database_id 
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{ChildTableName}'
                AND FK.name = '{ForeignKeyName}'"));

            List<SysForeignKeyColumns> actualSysForeignKeyColumns = new List<SysForeignKeyColumns>();

            foreach (var row in actual)
            {
                var columnValue = new SysForeignKeyColumns();
                columnValue.constraint_object_id = row.First(x => x.First == "constraint_object_id").Second.ObjectToInteger();
                columnValue.constraint_column_id = row.First(x => x.First == "constraint_column_id").Second.ObjectToInteger();
                columnValue.parent_object_id = row.First(x => x.First == "parent_object_id").Second.ObjectToInteger();
                columnValue.parent_column_id = row.First(x => x.First == "parent_column_id").Second.ObjectToInteger();
                columnValue.referenced_object_id = row.First(x => x.First == "referenced_object_id").Second.ObjectToInteger();
                columnValue.referenced_column_id = row.First(x => x.First == "referenced_column_id").Second.ObjectToInteger();

                actualSysForeignKeyColumns.Add(columnValue);
            }

            return actualSysForeignKeyColumns;
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
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.parent_object_id == expectedRow.parent_object_id && x.constraint_object_id == expectedRow.constraint_object_id && x.constraint_column_id == expectedRow.constraint_column_id && x.referenced_object_id == expectedRow.referenced_object_id && x.referenced_column_id == expectedRow.referenced_column_id);

                Assert.AreEqual(expectedRow.constraint_object_id, actualRow.constraint_object_id);
                Assert.AreEqual(expectedRow.constraint_column_id, actualRow.constraint_column_id);
                Assert.AreEqual(expectedRow.parent_object_id, actualRow.parent_object_id);
                Assert.AreEqual(expectedRow.parent_column_id, actualRow.parent_column_id);
                Assert.AreEqual(expectedRow.referenced_object_id, actualRow.referenced_object_id);
                Assert.AreEqual(expectedRow.referenced_column_id, actualRow.referenced_column_id);
            }
        }
    }
}
