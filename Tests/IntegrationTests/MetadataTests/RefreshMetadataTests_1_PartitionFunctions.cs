using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DOI.TestHelpers;
using DOI.Tests.Integration;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]

    public class RefreshMetadataTests1PartitionFunctions : DOIBaseTest
    {
        [SetUp]
        public void Setup()
        {
            var sqlHelper = new SqlHelper();
            sqlHelper.Execute(TestHelpers.SetupSqlStatements_NonPartitioned.setUpPartitionFunctionsSql);


        }

        [TearDown]
        public void TearDown()
        {

        }


        [TestCase("pfMonthlyTest", "NumOfFutureIntervals", "2")]
        [Test]
        public void RefreshMetadata_PartitionFunctions_MetadataIsAccurate(string partitionFunctionName, string columnNameToUpdate, string newValue)
        {
            /*
             * 1. Check that the partition function metadata is correct.
             *
             *
             */
        }
    }
}