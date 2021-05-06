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
    public class SysDestinationDataSpacesHelper : SystemMetadataHelper
    {
        public const string SysTableName = "SysDestinationDataSpaces";
        public const string SqlServerDmvName = "sys.destination_data_spaces";

        public static List<SysDestinationDataSpaces> GetExpectedValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT dds.* 
            FROM {DatabaseName}.{SqlServerDmvName} dds"));

            List<SysDestinationDataSpaces> expectedSysDestinationDataSpaces = new List<SysDestinationDataSpaces>();

            foreach (var row in expected)
            {
                var columnValue = new SysDestinationDataSpaces();

                columnValue.partition_scheme_id = row.First(x => x.First == "partition_scheme_id").Second.ObjectToInteger();
                columnValue.destination_id = row.First(x => x.First == "destination_id").Second.ObjectToInteger();
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();

                expectedSysDestinationDataSpaces.Add(columnValue);
            }

            return expectedSysDestinationDataSpaces;
        }

        public static List<SysDestinationDataSpaces> GetActualValues()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT T.* 
            FROM DOI.{SysTableName} T"));

            List<SysDestinationDataSpaces> actualSysDestinationDataSpaces = new List<SysDestinationDataSpaces>();

            foreach (var row in actual)
            {
                var columnValue = new SysDestinationDataSpaces();

                columnValue.partition_scheme_id = row.First(x => x.First == "partition_scheme_id").Second.ObjectToInteger();
                columnValue.destination_id = row.First(x => x.First == "destination_id").Second.ObjectToInteger();
                columnValue.data_space_id = row.First(x => x.First == "data_space_id").Second.ObjectToInteger();

                actualSysDestinationDataSpaces.Add(columnValue);
            }

            return actualSysDestinationDataSpaces;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata()
        {
            var expected = GetExpectedValues();

            var actual = GetActualValues();

            Assert.AreEqual(expected.Count, actual.Count);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x => x.database_id == expectedRow.database_id && x.partition_scheme_id == expectedRow.partition_scheme_id && x.destination_id == expectedRow.destination_id);

                Assert.AreEqual(expectedRow.partition_scheme_id, actualRow.partition_scheme_id);
                Assert.AreEqual(expectedRow.destination_id, actualRow.destination_id);
                Assert.AreEqual(expectedRow.data_space_id, actualRow.data_space_id);
            }
        }
    }
}
