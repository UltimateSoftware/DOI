using System;
using System.Data.SqlClient;
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
        public const string TableName = "TempA";
        public static string SysAllocationUnits_RefreshMetadata = @"EXEC DOI.spRefreshMetadata_System_SysAllocationUnits @DatabaseId = ";

        public static SqlDataReader GetExpectedValues(string sqlServerDmvName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            return sqlHelper.ExecuteReader($@"
            SELECT * 
            FROM {DatabaseName}.{sqlServerDmvName} au
            WHERE EXISTS(   SELECT 'True'
                            FROM {DatabaseName}.sys.partitions p
                                INNER JOIN {DatabaseName}.sys.tables t ON t.object_id = p.object_id
                            WHERE p.hobt_id = au.container_id
                                AND t.name = '{TableName}')");
        }

        public static SqlDataReader GetActualValues(string sysTableName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            return sqlHelper.ExecuteReader($@"
            SELECT * 
            FROM DOI.DOI.{sysTableName} AU 
                INNER JOIN DOI.DOI.SysDatabases D ON D.database_id = AU.database_id 
            WHERE D.name = '{DatabaseName}'");
        }

        //verify DOI Sys table data against expected values.
        public static void AssertSysAllocationUnitsMetadata()
        {
            var expected = GetExpectedValues(SqlServerDmvName);

            var actual = GetActualValues(SysTableName);

            while (actual.Read())
            {
                Assert.AreEqual(expected["allocation_unit_id"], actual["allocation_unit_id"]);
                Assert.AreEqual(expected["type"], actual["type"]);
                Assert.AreEqual(expected["type_desc"], actual["type_desc"]);
                Assert.AreEqual(expected["container_id"], actual["container_id"]);
                Assert.AreEqual(expected["data_space_id"], actual["data_space_id"]);
                Assert.AreEqual(expected["total_pages"], actual["total_pages"]);
                Assert.AreEqual(expected["used_pages"], actual["used_pages"]);
                Assert.AreEqual(expected["data_pages"], actual["data_pages"]);
            }
        }
    }
}
