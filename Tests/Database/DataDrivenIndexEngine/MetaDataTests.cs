using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Reporting.Ingestion.DataAccess.SqlDataStore.EntityMappings;
using NUnit.Framework;
using Reporting.TestHelpers;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class MetaDataTests
    {
        private DataDrivenIndexTestHelper dataDrivenIndexTestHelper;
        private List<string> expectedTableNames;

        [SetUp]
        public void Setup()
        {
            this.dataDrivenIndexTestHelper = new DataDrivenIndexTestHelper(new SqlHelper());
            this.expectedTableNames = this.GetExpectedTableNames();
        }

        [Test]
        public void ValidateTablesAreInMetadataTable()
        {
            var tablesInMetaData = this.dataDrivenIndexTestHelper.GetTablesInMetaData();

            foreach (var expectedTable in expectedTableNames)
            {
                var splitTableName = expectedTable.Split('.');

                Assert.IsNotNull(tablesInMetaData.FirstOrDefault(t => t.SchemaName == splitTableName[0] && t.TableName == splitTableName[1]), expectedTable);
            }
        }

        [Test]
        public void ValidateIndexesAreInMetaDataTable()
        {
            var existingIndexes = this.dataDrivenIndexTestHelper.GetExistingIndexes();
            var indexesInMetaData = this.dataDrivenIndexTestHelper.GetIndexInMetaData();
            var tablesReadytoQueue = this.dataDrivenIndexTestHelper.GetTablesReadytoQueue();

            foreach (var expectedTable in tablesReadytoQueue)
            {
                var actualItems = existingIndexes.FindAll(i => i.SchemaName == expectedTable.SchemaName && i.TableName == expectedTable.TableName);
                var expectedItems = indexesInMetaData.FindAll(i => i.SchemaName == expectedTable.SchemaName && i.TableName == expectedTable.TableName);

                Assert.AreEqual(expectedItems.Count, actualItems.Count, $"Index count for {expectedTable.TableName}.");
            }
        }

        private List<string> GetExpectedTableNames()
        {
            var result = new List<string>();

            var types = this.GetAllEntities();

            var tablesExpectedInMetaData = new List<string>();

            foreach (var item in types)
            {
                var entityConfig = (IReportingEntityMap)Activator.CreateInstance(item);
                tablesExpectedInMetaData.Add(entityConfig.TableName);
            }

            foreach (var tableName in tablesExpectedInMetaData)
            {
                var expectedSchema = "dbo";
                var expectedTableName = tableName;

                if (tableName.ToLower().StartsWith("datamart."))
                {
                    expectedSchema = "DataMart";
                    expectedTableName = tableName.Split('.').Last();
                }

                result.Add($"{expectedSchema}.{expectedTableName}");
            }

            return result;
        }

        public List<Type> GetAllEntities()
        {
            return AppDomain.CurrentDomain.GetAssemblies().SelectMany(x => x.GetTypes())
                 .Where(x => typeof(IReportingEntityMap).IsAssignableFrom(x) && !x.IsInterface && !x.IsAbstract)
                 .ToList();
        }
    }
}
