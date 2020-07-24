using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using Models = DOI.Tests.Integration.Models;

namespace DOI.Tests.TestHelpers.Metadata
{
    class PartitionFunctionHelper
    {
        public Models.PartitionFunction PartitionFunction_Expected(string boundaryInterval, DateTime initialDate, int numOfFutureIntervals_Desired)
        {
            DateTime lastBoundaryDate;

            lastBoundaryDate = DateTime.Now.AddMonths(numOfFutureIntervals_Desired);

            return new Models.PartitionFunction()
            {
                PartitionFunctionName = $"pf{boundaryInterval}Test",
                PartitionFunctionDataType = "DATETIME2",
                BoundaryInterval = "Monthly",
                NumOfFutureIntervals_Desired = 1,
                NumOfFutureIntervals_Actual = 0,
                InitialDate = initialDate,
                UsesSlidingWindow = false,
                SlidingWindowSize = 0,
                IsDeprecated = false,
                PartitionSchemeName = $"ps{boundaryInterval}Test",
                NumOfCharsInSuffix = boundaryInterval == "Monthly" ? 6 : 4,
                LastBoundaryDate = lastBoundaryDate,//move to first of month?
                NumOfTotalPartitionFunctionIntervals = GetMonthDifference(initialDate, lastBoundaryDate),
                NumOfTotalPartitionSchemeIntervals = GetMonthDifference(initialDate, lastBoundaryDate) + 1,
                MinValueOfDataType = "0001-01-01"
            };
        }

        public static int GetMonthDifference(DateTime startDate, DateTime endDate)
        {
            int monthsApart = 12 * (startDate.Year - endDate.Year) + startDate.Month - endDate.Month;
            return Math.Abs(monthsApart);
        }

        protected void AssertBoundariesAndFileGroups(string partitionFunctionName)
        {
            // get actual values
            var actualPartitionFunctionBoundariesAddFuturePartitions = dataDrivenIndexTestHelper.GetExistingPartitionFunctionBoundaries(partitionFunctionName);
            var actualPartitionSchemeFilegroupsAddFuturePartitions = dataDrivenIndexTestHelper.GetExistingPartitionSchemeFilegroups(partitionFunctionName);

            Assert.AreEqual(this.expectedPartitionSchemeFilegroups.Count, actualPartitionSchemeFilegroupsAddFuturePartitions.Count, "FileGroup Count");
            Assert.AreEqual(this.expectedPartitionFunctionBoundaries.Count, actualPartitionFunctionBoundariesAddFuturePartitions.Count, "Boundaries Count");

            // assert before adding future partitions
            // ASSERT 1:  MATCH PARTITION FUNCTION BOUNDARIES TO EXPECTED
            foreach (var expectedPartitionFunctionBoundaryAddFuturePartitions in this.expectedPartitionFunctionBoundaries)
            {
                var actualPartitionFunctionBoundaryAddFuturePartitions =
                    actualPartitionFunctionBoundariesAddFuturePartitions.Find(
                        b => b.BoundaryId == expectedPartitionFunctionBoundaryAddFuturePartitions.BoundaryId);

                Assert.NotNull(actualPartitionFunctionBoundaryAddFuturePartitions, "ActualPartitionBoundary lookup.");
                Assert.AreEqual(expectedPartitionFunctionBoundaryAddFuturePartitions.BoundaryValueOnRight, actualPartitionFunctionBoundaryAddFuturePartitions.BoundaryValueOnRight, "BoundaryValueOnRight compare.");
                Assert.AreEqual(expectedPartitionFunctionBoundaryAddFuturePartitions.Name, actualPartitionFunctionBoundaryAddFuturePartitions.Name, "Name compare.");
                Assert.AreEqual(expectedPartitionFunctionBoundaryAddFuturePartitions.Type, actualPartitionFunctionBoundaryAddFuturePartitions.Type, "Type compare.");
                Assert.AreEqual(expectedPartitionFunctionBoundaryAddFuturePartitions.Value, actualPartitionFunctionBoundaryAddFuturePartitions.Value, "Value compare.");
            }

            // ASSERT 2:  MATCH PARTITION SCHEME FILEGROUPS TO EXPECTED
            foreach (var expectedPartitionSchemeFilegroupAddFuturePartitions in this.expectedPartitionSchemeFilegroups)
            {
                var actualPartitionSchemeFilegroupAddFuturePartitions =
                    actualPartitionSchemeFilegroupsAddFuturePartitions.Find(
                        b => b.DestinationFilegroupId == expectedPartitionSchemeFilegroupAddFuturePartitions
                                 .DestinationFilegroupId);

                Assert.NotNull(expectedPartitionSchemeFilegroupAddFuturePartitions, "ActualPartitionBoundary lookup.");
                Assert.AreEqual(expectedPartitionSchemeFilegroupAddFuturePartitions.DataSpaceType, actualPartitionSchemeFilegroupAddFuturePartitions.DataSpaceType, "DataSpaceType compare.");
                Assert.AreEqual(expectedPartitionSchemeFilegroupAddFuturePartitions.PartitionSchemeName, actualPartitionSchemeFilegroupAddFuturePartitions.PartitionSchemeName, "PartitionSchemeName compare.");
                Assert.AreEqual(expectedPartitionSchemeFilegroupAddFuturePartitions.FilegroupName, actualPartitionSchemeFilegroupAddFuturePartitions.FilegroupName, "FilegroupName compare.");
            }

            // ASSERT 3:  NO DUPLICATES IN PREP TABLE FUNCTION
            this.dataDrivenIndexTestHelper.GetPrepTableFunctionDuplicates(partitionFunctionName).Count.Should().Be(0);
        }

    }
}
