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

            var actual = GetActualValues();

            Assert.AreEqual(expected.Count, actual.Count);

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
