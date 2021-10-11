using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DOI.Tests.TestHelpers;
using DOI.Tests.Integration.Models;
using DOI.Tests.IntegrationTests;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using FluentAssertions;
using NUnit.Framework;

namespace DOI.Tests.TestHelpers.Metadata.StorageContainers
{
    public class StorageContainerHelper : DOIBaseTest
    {
        protected List<PartitionFunctionBoundary> expectedPartitionFunctionBoundaries;
        protected List<PartitionSchemeFilegroup> expectedPartitionSchemeFilegroups;
        private const string PartitionFunctionName = "PfSlidingWindowUnitTest";
        private const string PartitionSchemeName = "psSlidingWindowUnitTest";
        private const string PartitionFunctionNameNoSlidingWindow = "PfNoSlidingWindowUnitTest";
        private const string PartitionSchemeNameNoSlidingWindow = "psNoSlidingWindowUnitTest";
        private const string PartitionFunctionNameMonthly = "PfMonthlyUnitTest";
        private const string PartitionSchemeNameMonthly = "psMonthlyUnitTest";
        private const string TableTestFuturePartitionFailsDueToLocking = "TestFuturePartitionFailsDueToLocking";

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

        public Tuple<int, int> SetupInitialStateForYearlyPartitionsWith1FuturePartition()
        {
            // Arrange (Initial state - Only 1 future interval)
            //this.sqlHelper.Execute($@"
            //INSERT INTO DOI.DOI.PartitionFunctions ( DatabaseName, PartitionFunctionName ,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals ,InitialDate ,UsesSlidingWindow ,SlidingWindowSize ,IsDeprecated )
            //VALUES ( '{DatabaseName}', '{SystemMetadataHelper.PartitionFunctionNameYearly}', 'DATETIME2', 'Yearly', 1, '2016-01-01', 0, NULL, 0)");

            //sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_PartitionFunctionsSql);

            IndexesHelper.CreatePartitioningContainerObjects(SystemMetadataHelper.PartitionFunctionNameYearly);


            var boundaryId = 1;
            var boundaryYear = 2016;
            var initialFutureMaxYear = DateTime.Now.Year + 1;

            this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
            {
                DestinationFilegroupId = 1,
                PartitionSchemeName = SystemMetadataHelper.PartitionSchemeNameYearly,
                DataSpaceType = "FG",
                FilegroupName = $"{DatabaseName}_Historical"
            });

            do
            {
                this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                {
                    Name = SystemMetadataHelper.PartitionFunctionNameYearly,
                    Type = "R",
                    BoundaryValueOnRight = true,
                    BoundaryId = boundaryId,
                    Value = $"{boundaryYear}-01-01".ObjectToDateTime()
                });

                this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                {
                    DestinationFilegroupId = boundaryId + 1,
                    PartitionSchemeName = SystemMetadataHelper.PartitionSchemeNameYearly,
                    DataSpaceType = "FG",
                    FilegroupName = $"{DatabaseName}_{boundaryYear}"
                });

                boundaryId++;
                boundaryYear++;
            }
            while (boundaryYear <= initialFutureMaxYear);

            // Act
            //this.dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionFunction(SystemMetadataHelper.PartitionFunctionNameYearly);
            //this.dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionScheme(SystemMetadataHelper.PartitionFunctionNameYearly);

            // Assert
            this.AssertBoundariesAndFileGroups(SystemMetadataHelper.PartitionFunctionNameYearly);

            return new Tuple<int, int>(boundaryId, boundaryYear);
        }
    }
}
