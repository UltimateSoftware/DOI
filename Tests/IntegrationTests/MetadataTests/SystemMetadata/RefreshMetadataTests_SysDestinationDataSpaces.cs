using System.Data.SqlClient;
using DOI.Tests.Integration;
using DOI.Tests.TestHelpers;
using TestHelper = DOI.Tests.TestHelpers.Metadata.SysDestinationDataSpacesHelper;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    
    public class RefreshMetadataTests_SysDestinationDataSpaces : DOIBaseTest
    { 
        [SetUp]
        public void Setup()
        {
            sqlHelper.Execute(TestHelper.CreateFilegroupSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreateFilegroup2Sql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.CreatePartitionSchemeYearlySql, 30, true, DatabaseName);
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(TestHelper.MetadataDeleteSql);
            sqlHelper.Execute(TestHelper.DropPartitionSchemeYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropFilegroupSql, 30, true, DatabaseName);
            sqlHelper.Execute(TestHelper.DropFilegroup2Sql, 30, true, DatabaseName);
        }

        [Test]
        public void RefreshMetadata_SysDestinationDataSpaces_MetadataIsAccurate()
        {
            //run refresh metadata

            sqlHelper.Execute(TestHelper.RefreshMetadata_SysDataSpacesSql);

            //and now they should match
            TestHelper.AssertMetadata();
        }
    }
}