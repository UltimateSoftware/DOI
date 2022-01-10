using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using DOI.Tests.IntegrationTests.Models;
using NUnit.Framework;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using Simple.Data.Ado.Schema;

namespace DOI.Tests.TestHelpers.Metadata
{
    public class vwPartitioning_PrepTablesConstraintsHelper : SystemMetadataHelper
    {
        public const string UserTableName = "vwPartitioning_Tables_PrepTables";
        public const string ViewName = "vwPartitioning_Tables_PrepTables_Constraints";

        public static List<vwPartitioning_Tables_PrepTables> GetExpectedValues(string partitionFunctionName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var expected = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{UserTableName}
            WHERE DatabaseName = '{DatabaseName}'
                AND PartitionFunctionName = '{partitionFunctionName}'
                AND IsNewPartitionedTable = 0 
            ORDER BY BoundaryValue"));

            List<vwPartitioning_Tables_PrepTables> expectedvwPartitioning_Tables_PrepTables = new List<vwPartitioning_Tables_PrepTables>();

            foreach (var row in expected)
            {
                var columnValue = new vwPartitioning_Tables_PrepTables();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.TableName = row.First(x => x.First == "TableName").Second.ToString();
                columnValue.DateDiffs = row.First(x => x.First == "DateDiffs").Second.ObjectToInteger();
                columnValue.PrepTableName = row.First(x => x.First == "PrepTableName").Second.ToString();
                columnValue.PrepTableNameSuffix = row.First(x => x.First == "PrepTableNameSuffix").Second.ToString();
                columnValue.NewPartitionedPrepTableName = row.First(x => x.First == "NewPartitionedPrepTableName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.BoundaryValue = row.First(x => x.First == "BoundaryValue").Second.ObjectToDateTime();
                columnValue.NextBoundaryValue = row.First(x => x.First == "NextBoundaryValue").Second.ObjectToDateTime();
                columnValue.IsNewPartitionedTable = row.First(x => x.First == "IsNewPartitionedTable").Second.ObjectToInteger();

                expectedvwPartitioning_Tables_PrepTables.Add(columnValue);
            }

            return expectedvwPartitioning_Tables_PrepTables;
        }

        public static List<vwPartitioning_Tables_PrepTables_Constraints> GetActualValues(string partitionFunctionName, string tableName)
        {
            SqlHelper sqlHelper = new SqlHelper();
            var actual = sqlHelper.ExecuteQuery(new SqlCommand($@"
            SELECT * 
            FROM DOI.DOI.{ViewName} 
            WHERE DatabaseName = '{DatabaseName}' 
                AND PartitionFunctionName = '{partitionFunctionName}'
                AND ParentTableName = '{tableName}'
                AND IsNewPartitionedTable = 0 
            ORDER BY BoundaryValue"));


            List<vwPartitioning_Tables_PrepTables_Constraints> actualVwPartitioning_Tables_PrepTables_Constraints = new List<vwPartitioning_Tables_PrepTables_Constraints>();

            foreach (var row in actual)
            {
                var columnValue = new vwPartitioning_Tables_PrepTables_Constraints();
                columnValue.DatabaseName = row.First(x => x.First == "DatabaseName").Second.ToString();
                columnValue.SchemaName = row.First(x => x.First == "SchemaName").Second.ToString();
                columnValue.ParentTableName = row.First(x => x.First == "ParentTableName").Second.ToString();
                columnValue.PrepTableName = row.First(x => x.First == "PrepTableName").Second.ToString();
                columnValue.NewPartitionedPrepTableName = row.First(x => x.First == "NewPartitionedPrepTableName").Second.ToString();
                columnValue.PartitionFunctionName = row.First(x => x.First == "PartitionFunctionName").Second.ToString();
                columnValue.BoundaryValue = row.First(x => x.First == "BoundaryValue").Second.ObjectToDateTime();
                columnValue.NextBoundaryValue = row.First(x => x.First == "NextBoundaryValue").Second.ObjectToDateTime();
                columnValue.IsNewPartitionedTable = row.First(x => x.First == "IsNewPartitionedTable").Second.ObjectToInteger();
                columnValue.ConstraintName = row.First(x => x.First == "ConstraintName").Second.ToString();
                columnValue.ConstraintType = row.First(x => x.First == "ConstraintType").Second.ToString();
                columnValue.RowNum = row.First(x => x.First == "RowNum").Second.ObjectToInteger();

                actualVwPartitioning_Tables_PrepTables_Constraints.Add(columnValue);
            }

            return actualVwPartitioning_Tables_PrepTables_Constraints;
        }

        //verify DOI Sys table data against expected values.
        public static void AssertMetadata(string boundaryInterval)
        {
            SqlHelper sqlHelper = new SqlHelper();
            string partitionFunctionName = String.Concat("pfTests", boundaryInterval);

            var expected = GetExpectedValues(partitionFunctionName);
            var actual = GetActualValues(partitionFunctionName, TableName_Partitioned);

            var isNewPartitionedPrepTable = 0;

            var expectedConstraintCount = sqlHelper.ExecuteScalar<int>(
                $@"  SELECT COUNT(*)
                        FROM DOI.vwPartitioning_Tables_PrepTables
                        WHERE DatabaseName = '{DatabaseName}' 
                            AND TableName = '{TableName_Partitioned}'
                            AND IsNewPartitionedTable = 0");

            var actualConstraintCount = sqlHelper.ExecuteScalar<int>(
                $@" SELECT COUNT(*)
                        FROM (  SELECT CheckConstraintName
                                FROM DOI.CheckConstraints 
                                WHERE DatabaseName = '{DatabaseName}' 
                                   AND TableName = '{TableName_Partitioned}'
                                UNION ALL
                                SELECT DefaultConstraintName
                                FROM DOI.DefaultConstraints 
                                WHERE DatabaseName = '{DatabaseName}' 
                                   AND TableName = '{TableName_Partitioned}')x");

            var actualPrepTableConstraintRowCount = sqlHelper.ExecuteScalar<int>(
                $"SELECT COUNT(*) FROM DOI.{ViewName} WHERE DatabaseName = '{DatabaseName}' AND ParentTableName = '{TableName_Partitioned}' AND IsNewPartitionedTable = 0");

            Assert.IsTrue(actual.Count > 0, "RowsReturned");
            Assert.AreEqual(expectedConstraintCount * actualConstraintCount, actualPrepTableConstraintRowCount, "MatchingRowCounts"); //should have 'x' constraints per partition.

            foreach (var expectedRow in expected)
            {
                //defaults
                var actualRowDefaultConstraints = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.PrepTableName == expectedRow.PrepTableName && x.BoundaryValue == expectedRow.BoundaryValue && x.ConstraintType == "DEFAULT" && x.ConstraintName.Contains("UpdatedUtcDt"));

                Assert.AreEqual(expectedRow.SchemaName, actualRowDefaultConstraints.SchemaName, "SchemaName");
                Assert.AreEqual(expectedRow.TableName, actualRowDefaultConstraints.ParentTableName, "ParentTableName");
                Assert.AreEqual(expectedRow.PrepTableName, actualRowDefaultConstraints.PrepTableName, "PrepTableName");
                Assert.AreEqual(expectedRow.NewPartitionedPrepTableName, actualRowDefaultConstraints.NewPartitionedPrepTableName, "NewPartitionedPrepTableName");
                Assert.AreEqual(expectedRow.PartitionFunctionName, actualRowDefaultConstraints.PartitionFunctionName, "PartitionFunctionName");
                Assert.AreEqual(expectedRow.BoundaryValue, actualRowDefaultConstraints.BoundaryValue, "BoundaryValue");
                Assert.AreEqual(expectedRow.NextBoundaryValue, actualRowDefaultConstraints.NextBoundaryValue, "NextBoundaryValue");
                Assert.AreEqual(isNewPartitionedPrepTable, actualRowDefaultConstraints.IsNewPartitionedTable, "IsNewPartitionedPrepTable");
                Assert.AreEqual(string.Concat("Def_", expectedRow.PrepTableName, "_UpdatedUtcDt"), actualRowDefaultConstraints.ConstraintName, "ConstraintName");
                Assert.AreEqual(1, actualRowDefaultConstraints.RowNum, "RowNum");

                actualRowDefaultConstraints = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.PrepTableName == expectedRow.PrepTableName && x.BoundaryValue == expectedRow.BoundaryValue && x.ConstraintType == "DEFAULT" && x.ConstraintName.Contains(PartitionColumnName));

                Assert.AreEqual(expectedRow.SchemaName, actualRowDefaultConstraints.SchemaName, "SchemaName");
                Assert.AreEqual(expectedRow.TableName, actualRowDefaultConstraints.ParentTableName, "ParentTableName");
                Assert.AreEqual(expectedRow.PrepTableName, actualRowDefaultConstraints.PrepTableName, "PrepTableName");
                Assert.AreEqual(expectedRow.NewPartitionedPrepTableName, actualRowDefaultConstraints.NewPartitionedPrepTableName, "NewPartitionedPrepTableName");
                Assert.AreEqual(expectedRow.PartitionFunctionName, actualRowDefaultConstraints.PartitionFunctionName, "PartitionFunctionName");
                Assert.AreEqual(expectedRow.BoundaryValue, actualRowDefaultConstraints.BoundaryValue, "BoundaryValue");
                Assert.AreEqual(expectedRow.NextBoundaryValue, actualRowDefaultConstraints.NextBoundaryValue, "NextBoundaryValue");
                Assert.AreEqual(isNewPartitionedPrepTable, actualRowDefaultConstraints.IsNewPartitionedTable, "IsNewPartitionedPrepTable");
                Assert.AreEqual(string.Concat("Def_", expectedRow.PrepTableName, "_TransactionUtcDt"), actualRowDefaultConstraints.ConstraintName, "ConstraintName");
                Assert.AreEqual(2, actualRowDefaultConstraints.RowNum, "RowNum");

                //check
                var actualRowCheckConstraints = actual.Find(x => x.DatabaseName == expectedRow.DatabaseName && x.PrepTableName == expectedRow.PrepTableName && x.BoundaryValue == expectedRow.BoundaryValue && x.ConstraintType == "CHECK");

                Assert.AreEqual(expectedRow.SchemaName, actualRowCheckConstraints.SchemaName, "SchemaName");
                Assert.AreEqual(expectedRow.TableName, actualRowCheckConstraints.ParentTableName, "ParentTableName");
                Assert.AreEqual(expectedRow.PrepTableName, actualRowCheckConstraints.PrepTableName, "PrepTableName");
                Assert.AreEqual(expectedRow.NewPartitionedPrepTableName, actualRowCheckConstraints.NewPartitionedPrepTableName, "NewPartitionedPrepTableName");
                Assert.AreEqual(expectedRow.PartitionFunctionName, actualRowCheckConstraints.PartitionFunctionName, "PartitionFunctionName");
                Assert.AreEqual(expectedRow.BoundaryValue, actualRowCheckConstraints.BoundaryValue, "BoundaryValue");
                Assert.AreEqual(expectedRow.NextBoundaryValue, actualRowCheckConstraints.NextBoundaryValue, "NextBoundaryValue");
                Assert.AreEqual(isNewPartitionedPrepTable, actualRowCheckConstraints.IsNewPartitionedTable, "IsNewPartitionedPrepTable");
                Assert.AreEqual(string.Concat("Chk_", expectedRow.PrepTableName, "_IncludedColumn"), actualRowCheckConstraints.ConstraintName, "ConstraintName");
                Assert.AreEqual(3, actualRowCheckConstraints.RowNum, "RowNum");
            }
        }
    }
}
