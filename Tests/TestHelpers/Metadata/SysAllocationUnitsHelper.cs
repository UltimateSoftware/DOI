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
    public class SysAllocationUnitsHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysAllocationUnits";
        public const string SqlServerDmvName = "sys.allocation_units";

        public static List<SysAllocationUnits> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM {DatabaseName}.{SqlServerDmvName} au
            WHERE EXISTS(   SELECT 'True'
                            FROM {DatabaseName}.sys.partitions p
                                INNER JOIN {DatabaseName}.sys.indexes i ON i.object_id = p.object_id
                                    AND i.index_id = p.index_id
                                INNER JOIN {DatabaseName}.sys.tables t ON t.object_id = i.object_id
                            WHERE p.hobt_id = au.container_id
                                AND t.name = '{TableName}'
                                AND i.name = '{CIndexName}')
            ORDER BY container_id, type"));

            List<SysAllocationUnits> expectedSysAllocationUnits = new List<SysAllocationUnits>();

            foreach (var row in expected)
            {
                var columnValue = new SysAllocationUnits();
                columnValue.allocation_unit_id = row.First(x => x.First == "allocation_unit_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ObjectToInteger();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.container_id = row.First(x => x.First == "container_id").Second.ToString();
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.total_pages = row.First(x => x.First == "total_pages").Second.ObjectToInteger();
                columnValue.used_pages = row.First(x => x.First == "used_pages").Second.ObjectToInteger();
                columnValue.data_pages = row.First(x => x.First == "data_pages").Second.ObjectToInteger();

                expectedSysAllocationUnits.Add(columnValue);
            }

            return expectedSysAllocationUnits;
        }

        public static List<SysAllocationUnits> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual =  sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT AU.* 
            FROM DOI.DOI.{SysTableName} AU 
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = AU.database_id 
                INNER JOIN DOI.DOI.SysPartitions P ON P.database_id = AU.database_id
                    AND P.hobt_id = AU.container_id
                INNER JOIN DOI.DOI.SysIndexes I ON I.database_id = P.database_id
                    AND I.object_id = P.object_id
                    AND I.index_id = P.index_id
                INNER JOIN DOI.DOI.SysTables T ON T.database_id = I.database_id
                    AND T.object_id = I.object_id
            WHERE D.name = '{DatabaseName}'
                AND T.name = '{TableName}'
                AND I.name = '{CIndexName}'
            ORDER BY container_id, type"));

            List<SysAllocationUnits> actualSysAllocationUnits = new List<SysAllocationUnits>();

            foreach (var row in actual)
            {
                var columnValue = new SysAllocationUnits();
                columnValue.allocation_unit_id = row.First(x => x.First == "allocation_unit_id").Second.ObjectToInteger();
                columnValue.type = row.First(x => x.First == "type").Second.ObjectToInteger();
                columnValue.type_desc = row.First(x => x.First == "type_desc").Second.ToString();
                columnValue.container_id = row.First(x => x.First == "container_id").Second.ToString();
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();
                columnValue.total_pages = row.First(x => x.First == "total_pages").Second.ObjectToInteger();
                columnValue.used_pages = row.First(x => x.First == "used_pages").Second.ObjectToInteger();
                columnValue.data_pages = row.First(x => x.First == "data_pages").Second.ObjectToInteger();

                actualSysAllocationUnits.Add(columnValue);
            }

            return actualSysAllocationUnits;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            Assert.AreEqual(2, expected.Count); //2 allocation units are created, one for normal row data and one for row overflow.

            var actual = GetActualValues();

            Assert.AreEqual(2, actual.Count);//2 allocation units are created, one for normal row data and one for row overflow.

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.container_id == expectedRow.container_id && x.type == expectedRow.type);

                Assert.AreEqual(expectedRow.allocation_unit_id, actualRow.allocation_unit_id);
                Assert.AreEqual(expectedRow.type, actualRow.type);
                Assert.AreEqual(expectedRow.type_desc, actualRow.type_desc);
                Assert.AreEqual(expectedRow.container_id, actualRow.container_id);
                Assert.AreEqual(expectedRow.data_space_id, actualRow.data_space_id);
                Assert.AreEqual(expectedRow.total_pages, actualRow.total_pages);
                Assert.AreEqual(expectedRow.used_pages, actualRow.used_pages);
                Assert.AreEqual(expectedRow.data_pages, actualRow.data_pages);
            }
        }
    }
}
