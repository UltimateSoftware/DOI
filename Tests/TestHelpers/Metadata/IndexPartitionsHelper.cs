using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using Simple.Data.Ado.Schema;
using Models = DOI.Tests.Integration.Models;


namespace DOI.Tests.TestHelpers.Metadata
{
    public class IndexPartitionsHelper : SystemMetadataHelper
    {
        public const string UserTableName_RowStore = "IndexPartitionsRowStore";
        public const string UserTableName_ColumnStore = "IndexPartitionsColumnStore";


        public static List<IndexPartitionsRowStore> GetExpectedValues_RowStore()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
                SELECT IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber,
                    'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\testDBFileName_Partition' + CAST(P.PartitionNumber AS VARCHAR(10)) + '.ndf' AS DataFileName
                FROM DOI.IndexesRowStore IRS
                    INNER JOIN DOI.vwPartitionFunctionPartitions P ON IRS.Storage_Desired = P.PartitionSchemeName
                WHERE IRS.StorageType_Desired = 'PARTITION_SCHEME'
                    AND IRS.DatabaseName = '{DatabaseName}'
                    AND IRS.SchemaName = 'dbo'
                    AND IRS.TableName = '{TableName_Partitioned}'
                    AND IRS.IndexName = '{CIndexName_Partitioned}'
                ORDER BY IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber"));

            List<IndexPartitionsRowStore> ExpectedValues_RowStore = new List<IndexPartitionsRowStore>();

            foreach (var row in expected)
            {
                var columnValue = new IndexPartitionsRowStore();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.IndexName = row.First(x => x.First == "IndexName").Second.ToString();
                columnValue.PartitionNumber = row.First(x => x.First == "PartitionNumber").Second.ObjectToInteger();
                columnValue.DataFileName = row.First(x => x.First == "DataFileName").Second.ToString();

                ExpectedValues_RowStore.Add(columnValue);
            }

            return ExpectedValues_RowStore;
        }
        public static List<IndexPartitionsColumnStore> GetExpectedValues_ColumnStore()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
                SELECT ICS.DatabaseName, ICS.SchemaName, ICS.TableName, ICS.IndexName, P.PartitionNumber
                FROM DOI.IndexesColumnStore ICS
                    INNER JOIN DOI.vwPartitionFunctionPartitions P ON ICS.Storage_Desired = P.PartitionSchemeName
                WHERE ICS.StorageType_Desired = 'PARTITION_SCHEME'
                    AND ICS.DatabaseName = '{DatabaseName}'
                    AND ICS.SchemaName = 'dbo'
                    AND ICS.TableName = '{TableName_Partitioned}'
                    AND ICS.IndexName = '{CIndexName_Partitioned}'
                ORDER BY ICS.DatabaseName, ICS.SchemaName, ICS.TableName, ICS.IndexName, P.PartitionNumber"));

            List<IndexPartitionsColumnStore> ExpectedValues_ColumnStore = new List<IndexPartitionsColumnStore>();

            foreach (var row in expected)
            {
                var columnValue = new IndexPartitionsColumnStore();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.IndexName = row.First(x => x.First == "IndexName").Second.ToString();
                columnValue.PartitionNumber = row.First(x => x.First == "PartitionNumber").Second.ObjectToInteger();


                ExpectedValues_ColumnStore.Add(columnValue);
            }

            return ExpectedValues_ColumnStore;
        }
        public static List<IndexPartitionsRowStore> GetActualValues_RowStore()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{UserTableName_RowStore}  
            WHERE DatabaseName = '{DatabaseName}'
                AND TableName = '{TableName_Partitioned}'
                AND IndexName = '{CIndexName_Partitioned}'
            ORDER BY PartitionNumber"));

            List<IndexPartitionsRowStore> ActualValues_RowStore = new List<IndexPartitionsRowStore>();

            foreach (var row in actual)
            {
                var columnValue = new IndexPartitionsRowStore();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.IndexName = row.First(x => x.First == "IndexName").Second.ToString();
                columnValue.PartitionNumber = row.First(x => x.First == "PartitionNumber").Second.ObjectToInteger();

                columnValue.Fragmentation = (double)row.First(x => x.First == "Fragmentation").Second.ObjectToInteger();
                columnValue.NumRows = row.First(x => x.First == "NumRows").Second.ObjectToInteger();
                columnValue.TotalPages = row.First(x => x.First == "TotalPages").Second.ObjectToInteger();
                columnValue.DataFileName = row.First(x => x.First == "DataFileName").Second.ToString();
                columnValue.DriveLetter = row.First(x => x.First == "DriveLetter").Second.ToString();
                columnValue.PartitionUpdateType = row.First(x => x.First == "PartitionUpdateType").Second.ToString();
                columnValue.TotalIndexPartitionSizeInMB = row.First(x => x.First == "TotalIndexPartitionSizeInMB").Second.ObjectToDecimal();
                ActualValues_RowStore.Add(columnValue);
            }

            return ActualValues_RowStore;
        }
        public static List<IndexPartitionsColumnStore> GetActualValues_ColumnStore()
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{UserTableName_ColumnStore}  
            WHERE DatabaseName = '{DatabaseName}'
                AND TableName = '{TableName_Partitioned}'
                AND IndexName = '{CIndexName_Partitioned}'
            ORDER BY PartitionNumber"));

            List<IndexPartitionsColumnStore> ActualValues_ColumnStore = new List<IndexPartitionsColumnStore>();

            foreach (var row in actual)
            {
                var columnValue = new IndexPartitionsColumnStore();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.IndexName = row.First(x => x.First == "IndexName").Second.ToString();
                columnValue.PartitionNumber = row.First(x => x.First == "PartitionNumber").Second.ObjectToInteger();

                ActualValues_ColumnStore.Add(columnValue);
            }

            return ActualValues_ColumnStore;
        }

        public static void AssertUserMetadata_RowStore()
        {
            var expected = GetExpectedValues_RowStore();

            var actual = GetActualValues_RowStore();

            Assert.AreEqual(expected.Count, actual.Count);
            Assert.Greater(actual.Count, 0);

            foreach (var expectedRow in expected)
            {
                var actualRow = actual.Find(x =>
                    x.DatabaseName == expectedRow.DatabaseName &&
                    x.SchemaName == expectedRow.SchemaName &&
                    x.TableName == expectedRow.TableName &&
                    x.IndexName == expectedRow.IndexName &&
                    x.PartitionNumber == expectedRow.PartitionNumber);

                Assert.AreEqual(1, actualRow.NumRows);
                //Assert.AreEqual(expectedRow.TotalPages, actualRow.TotalPages);
                //Assert.AreEqual(expectedRow.TotalIndexPartitionSizeInMB, actualRow.TotalIndexPartitionSizeInMB);
                Assert.AreEqual(0, actualRow.Fragmentation);
                Assert.AreEqual(expectedRow.DataFileName, actualRow.DataFileName);
                Assert.AreEqual("C", actualRow.DriveLetter);
                Assert.AreEqual("None", actualRow.PartitionUpdateType);
            }
        }

        public static void AssertUserMetadata_ColumnStore()
        {
            var expected = GetExpectedValues_ColumnStore();

            var actual = GetActualValues_ColumnStore();

            Assert.AreEqual(expected.Count, actual.Count);
        }
    }
}
