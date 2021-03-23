using System;
using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.ForeignKeysHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.Views
{
    public class ViewTests_vwForeignKeys : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDatabasesSql);
            sqlHelper.Execute(TestHelper.CreateTableSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.CreateTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateChildTableSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.CreateChildTableMetadataSql);
            sqlHelper.Execute(TestHelper.CreateForeignKeySql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.CreateForeignKeyMetadataSql);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropForeignKeySql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.DropChildTableSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.DropChildTableMetadataSql);
            sqlHelper.Execute(TestHelper.DropTableSql, 30, true, "DOIUnitTests");
            sqlHelper.Execute(TestHelper.DropTableMetadataSql);
        }

        [Test]
        public void Views_vwForeignKeys_MetadataIsAccurate()
        {
            //run refresh metadata
            sqlHelper.Execute(TestHelper.RefreshMetadata_SysForeignKeysSql);

            //and now they should match
            TestHelper.AssertUserMetadata();
        }
    }
}

