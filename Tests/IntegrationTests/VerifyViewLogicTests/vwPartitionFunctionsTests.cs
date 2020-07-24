using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DOI.Tests.Integration;
using Models = DOI.Tests.Integration.Models;
using NUnit.Framework;
using Helper = DOI.Tests.TestHelpers.Metadata;

namespace DOI.Tests.IntegrationTests.ViewTests
{
    public class vwPartitionFunctionsTests : DOIBaseTest
    {
        /*
         * 1. vwPartitionFunctionPartitions
         *      - PrepTableNameSuffix
         *      - NextBoundaryValue
         *      - DateDiffs
         *      - PartitionNumber
         *      - IsPartitionMissing
         *
         */
        [SetUp]
        private void Setup()
        {
            //set up metadata
            TearDown();
            sqlHelper.Execute(Helper.PartitionFunctionsSql.PartitionFunction_Setup);
        }

        [TearDown]
        private void TearDown()
        {
            //delete metadata
            sqlHelper.Execute(Helper.PartitionFunctionsSql.PartitionFunction_TearDown);
        }

        [TestCase()]
        [Test]
        private void PartitionFunctions_VerifyUserMetadataInViews(string boundaryInterval, DateTime initialDate, int numOfFutureIntervals_Desired)
        {
            Setup();
            //PartitionFunction expectedPartitionFunctionValue = new PartitionFunction();
            var expectedPartitionFunctionValue = this.PartitionFunction_Expected(boundaryInterval, initialDate, numOfFutureIntervals_Desired);
            
            //assert that all view columns are correct.

        }
    }
}
